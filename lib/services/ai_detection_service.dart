// lib/services/ai_detection_service.dart
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIDetectionService {
  static const String _apiKey = 'AIzaSyD3edDK5--6gKp8aPeQKISAUGupe4KqX5s';
  late final GenerativeModel _model;

  AIDetectionService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.4,
        topK: 40,
        topP: 0.95,
      ),
    );
  }

  /// 🔍 Analyze a single image
  Future<IssueDetectionResult> detectIssueFromImage(File imageFile) async {
    try {
      print('🔍 Starting AI analysis...');

      final imageBytes = await imageFile.readAsBytes();
      print('📸 Image loaded: ${imageBytes.length} bytes');

      // Randomize categories each time to reduce bias
      final categories = [
        'Road Damage',
        'Street Light',
        'Water Supply',
        'Sewage',
        'Garbage',
        'Electricity',
        'Public Transport',
        'Parks & Recreation',
        'Other'
      ]..shuffle();

      final categoryList = categories.join(', ');

      // ✅ Improved neutral prompt with few-shot examples
      final prompt = '''
You are an infrastructure inspection assistant.

Analyze the provided image and reply ONLY with a JSON object that describes if there is an infrastructure issue.

You can choose from these categories:
$categoryList

Priority levels: low, medium, high, urgent

Here are examples of how to respond:

Example 1 (no visible issue):
{"category":"Other","priority":"low","confidence":0.2,"description":"Clean road and surroundings, no visible damage or problem"}

Example 2 (visible damage):
{"category":"Road Damage","priority":"high","confidence":0.85,"description":"Deep pothole about 40cm wide with broken asphalt and visible gravel"}

If the image is blurry, unclear, or has no visible infrastructure, use Example 1 format.

Important:
- Reply with a single JSON object only.
- Do not include markdown or explanations.
- Confidence should be between 0.0 and 1.0.
- Be honest; if no damage is visible, say so.

Now analyze this image carefully:
''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      print('⏳ Sending request to Gemini AI...');
      final response = await _model.generateContent(content);
      final responseText = response.text?.trim() ?? '';

      print('✅ Raw AI Response:\n$responseText\n');

      final parsedResult = _parseResponse(responseText);

      // 🧠 Sanity check: prevent repetitive false positives
      if (parsedResult.category == 'Road Damage' &&
          parsedResult.confidence > 0.8 &&
          !parsedResult.description.toLowerCase().contains('pothole') &&
          !parsedResult.description.toLowerCase().contains('crack') &&
          !parsedResult.description.toLowerCase().contains('asphalt')) {
        print('⚠️ Suspicious road damage confidence - lowering to 0.55');
        return IssueDetectionResult(
          category: parsedResult.category,
          priority: parsedResult.priority,
          confidence: 0.55,
          description: parsedResult.description,
        );
      }

      return parsedResult;
    } catch (e) {
      print('❌ AI Detection error: $e');
      throw Exception('AI Detection failed: ${e.toString()}');
    }
  }

  /// 🔍 Analyze multiple images and combine results
  Future<IssueDetectionResult> analyzeMultipleImages(List<File> images) async {
    if (images.isEmpty) {
      throw Exception('No images provided for analysis');
    }

    print('🔍 Analyzing ${images.length} images...');
    List<IssueDetectionResult> allResults = [];

    final imagesToAnalyze = images.take(3).toList();

    for (int i = 0; i < imagesToAnalyze.length; i++) {
      try {
        print('\n📸 ===== Analyzing image ${i + 1}/${imagesToAnalyze.length} =====');
        final result = await detectIssueFromImage(imagesToAnalyze[i]);
        allResults.add(result);
        print('Result: ${result.category} | ${result.priority} | ${result.confidencePercentage}');
        print('Description: ${result.description}\n');
      } catch (e) {
        print('⚠️ Error analyzing image ${i + 1}: $e');
      }
    }

    if (allResults.isEmpty) {
      throw Exception('Could not analyze any images. Please try again.');
    }

    // Filter out low confidence and "Other" category unless all are "Other"
    final validResults = allResults.where((r) =>
        r.confidence >= 0.6 && r.category != 'Other').toList();

    if (validResults.isEmpty) {
      print('⚠️ No clear infrastructure issue detected in any image');
      allResults.sort((a, b) => b.confidence.compareTo(a.confidence));
      return allResults.first;
    }

    return _getBestResultWithConsensus(validResults);
  }

  /// 🧩 Consensus logic for multi-image analysis
  IssueDetectionResult _getBestResultWithConsensus(List<IssueDetectionResult> results) {
    if (results.isEmpty) {
      return IssueDetectionResult(
        category: 'Other',
        priority: 'low',
        confidence: 0.3,
        description: 'No clear infrastructure issue detected',
      );
    }

    // Group results by category
    Map<String, List<IssueDetectionResult>> categoryGroups = {};
    for (var result in results) {
      categoryGroups[result.category] = categoryGroups[result.category] ?? [];
      categoryGroups[result.category]!.add(result);
    }

    // Find most common category
    String mostCommonCategory = categoryGroups.entries
        .reduce((a, b) => a.value.length > b.value.length ? a : b)
        .key;

    // Get best result from that category
    final categoryResults = categoryGroups[mostCommonCategory]!;
    categoryResults.sort((a, b) => b.confidence.compareTo(a.confidence));

    print('🎯 Final consensus: $mostCommonCategory (${categoryResults.length}/${results.length} images)');
    return categoryResults.first;
  }

  /// 🧾 Parse and validate AI response
  IssueDetectionResult _parseResponse(String responseText) {
    try {
      String cleanText = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .replaceAll('\n', ' ')
          .trim();

      final jsonStart = cleanText.indexOf('{');
      final jsonEnd = cleanText.lastIndexOf('}') + 1;

      if (jsonStart == -1 || jsonEnd <= jsonStart) {
        print('⚠️ No JSON found in response');
        return _createFallbackResult();
      }

      cleanText = cleanText.substring(jsonStart, jsonEnd);
      print('📝 Extracted JSON: $cleanText');

      final categoryMatch = RegExp(r'"category"\s*:\s*"([^"]+)"').firstMatch(cleanText);
      final priorityMatch = RegExp(r'"priority"\s*:\s*"([^"]+)"').firstMatch(cleanText);
      final confidenceMatch = RegExp(r'"confidence"\s*:\s*([\d.]+)').firstMatch(cleanText);
      final descriptionMatch = RegExp(r'"description"\s*:\s*"([^"]+)"').firstMatch(cleanText);

      if (categoryMatch == null || descriptionMatch == null) {
        print('⚠️ Missing required fields');
        return _createFallbackResult();
      }

      final category = _validateCategory(categoryMatch.group(1) ?? 'Other');
      final priority = _validatePriority(priorityMatch?.group(1) ?? 'medium');
      final confidence = double.tryParse(confidenceMatch?.group(1) ?? '0.5') ?? 0.5;
      final description = descriptionMatch.group(1) ?? 'Issue detected';

      final validatedConfidence = _validateConfidence(
        category: category,
        description: description,
        originalConfidence: confidence,
      );

      return IssueDetectionResult(
        category: category,
        priority: priority,
        confidence: validatedConfidence,
        description: description,
      );
    } catch (e) {
      print('⚠️ Parse error: $e');
      return _createFallbackResult();
    }
  }

  /// ⚖️ Confidence correction
  double _validateConfidence({
    required String category,
    required String description,
    required double originalConfidence,
  }) {
    final genericPhrases = [
      'infrastructure issue',
      'visible in image',
      'detected in',
      'appears to be',
      'seems to',
    ];

    int genericCount = 0;
    for (var phrase in genericPhrases) {
      if (description.toLowerCase().contains(phrase)) {
        genericCount++;
      }
    }

    if (genericCount >= 2 && originalConfidence > 0.7) {
      print('⚠️ Generic description with high confidence - downgrading');
      return 0.5;
    }

    final hasSpecifics = RegExp(r'\d+\s*(cm|meter|m|inch|wide|deep|large|small)')
        .hasMatch(description.toLowerCase());

    if (!hasSpecifics && originalConfidence > 0.8) {
      print('⚠️ No specific measurements - lowering confidence');
      return 0.7;
    }

    if (description.length < 40 && originalConfidence > 0.8) {
      print('⚠️ Short description - lowering confidence');
      return 0.65;
    }

    if (category == 'Road Damage' &&
        originalConfidence > 0.8 &&
        !description.toLowerCase().contains('pothole') &&
        !description.toLowerCase().contains('crack') &&
        !description.toLowerCase().contains('asphalt')) {
      print('⚠️ Auto-detected suspicious "Road Damage" - downgrading confidence.');
      return 0.55;
    }

    return originalConfidence.clamp(0.0, 1.0);
  }

  /// 🧰 Fallback result
  IssueDetectionResult _createFallbackResult() {
    return IssueDetectionResult(
      category: 'Other',
      priority: 'low',
      confidence: 0.3,
      description: 'Unable to analyze image clearly',
    );
  }

  /// ✅ Validate category
  String _validateCategory(String category) {
    const validCategories = [
      'Road Damage',
      'Street Light',
      'Water Supply',
      'Sewage',
      'Garbage',
      'Electricity',
      'Public Transport',
      'Parks & Recreation',
      'Other'
    ];

    for (var valid in validCategories) {
      if (category.toLowerCase() == valid.toLowerCase()) {
        return valid;
      }
    }

    print('⚠️ Invalid category: $category, defaulting to Other');
    return 'Other';
  }

  /// ✅ Validate priority
  String _validatePriority(String priority) {
    const validPriorities = ['low', 'medium', 'high', 'urgent'];
    final lowerPriority = priority.toLowerCase().trim();

    if (!validPriorities.contains(lowerPriority)) {
      print('⚠️ Invalid priority: $priority, defaulting to medium');
      return 'medium';
    }

    return lowerPriority;
  }
}

/// 🧩 Data model
class IssueDetectionResult {
  final String category;
  final String priority;
  final double confidence;
  final String description;

  IssueDetectionResult({
    required this.category,
    required this.priority,
    required this.confidence,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'priority': priority,
      'confidence': confidence,
      'description': description,
    };
  }

  factory IssueDetectionResult.fromMap(Map<String, dynamic> map) {
    return IssueDetectionResult(
      category: map['category'] ?? 'Other',
      priority: map['priority'] ?? 'medium',
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Category: $category, Priority: $priority, Confidence: ${confidencePercentage}';
  }

  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';
  bool get isHighConfidence => confidence >= 0.7;

  String get confidenceLevel {
    if (confidence >= 0.8) return 'High';
    if (confidence >= 0.6) return 'Medium';
    return 'Low';
  }
}
