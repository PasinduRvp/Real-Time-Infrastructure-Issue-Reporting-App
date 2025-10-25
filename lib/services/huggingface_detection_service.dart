// lib/services/huggingface_detection_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class HuggingFaceDetectionService {
	static const String _apiKey = 'apiKey';

  // Multiple specialized models
  static const String _objectDetectionModel = 'facebook/detr-resnet-50';
  static const String _imageClassificationModel = 'microsoft/resnet-50';
  static const String _wasteDetectionModel = 'keremberke/yolov8m-garbage-detection';
  static const String _sceneClassificationModel = 'google/vit-base-patch16-224';
  
  /// 🔍 Main detection with ultra-enhanced multi-model approach
  Future<IssueDetectionResult> detectIssueFromImage(File imageFile) async {
    try {
      print('🔍 Starting ULTRA-ENHANCED AI analysis...');
      
      final imageBytes = await imageFile.readAsBytes();
      print('📸 Image loaded: ${imageBytes.length} bytes');

      // Preprocess image
      final processedImage = await _preprocessImage(imageBytes);

      // Collect results from multiple sources
      List<DetectionAttempt> allAttempts = [];

      // 1. Specialized Garbage Detection
      try {
        print('\n🗑️ === ATTEMPT 1: Specialized Garbage Detection ===');
        final result = await _detectGarbage(processedImage);
        allAttempts.add(DetectionAttempt(result, 'Garbage Detection', weight: 2.0));
        print('✅ Result: ${result.category} (${result.confidencePercentage})');
      } catch (e) {
        print('⚠️ Garbage detection failed: $e');
      }

      // 2. Object Detection
      try {
        print('\n🎯 === ATTEMPT 2: Object Detection ===');
        final result = await _detectObjects(processedImage);
        allAttempts.add(DetectionAttempt(result, 'Object Detection', weight: 1.5));
        print('✅ Result: ${result.category} (${result.confidencePercentage})');
      } catch (e) {
        print('⚠️ Object detection failed: $e');
      }

      // 3. Scene Classification
      try {
        print('\n🏷️ === ATTEMPT 3: Scene Classification ===');
        final result = await _classifyScene(processedImage);
        allAttempts.add(DetectionAttempt(result, 'Scene Classification', weight: 1.2));
        print('✅ Result: ${result.category} (${result.confidencePercentage})');
      } catch (e) {
        print('⚠️ Scene classification failed: $e');
      }

      // 4. General Image Classification
      try {
        print('\n🔬 === ATTEMPT 4: Image Classification ===');
        final result = await _classifyImage(processedImage);
        allAttempts.add(DetectionAttempt(result, 'Image Classification', weight: 1.0));
        print('✅ Result: ${result.category} (${result.confidencePercentage})');
      } catch (e) {
        print('⚠️ Image classification failed: $e');
      }

      // 5. Text-based Analysis (Color and Pattern Detection)
      try {
        print('\n🎨 === ATTEMPT 5: Visual Analysis ===');
        final result = await _analyzeVisualFeatures(processedImage);
        allAttempts.add(DetectionAttempt(result, 'Visual Analysis', weight: 0.8));
        print('✅ Result: ${result.category} (${result.confidencePercentage})');
      } catch (e) {
        print('⚠️ Visual analysis failed: $e');
      }

      if (allAttempts.isEmpty) {
        return _createFallbackResult();
      }

      // Smart fusion of all results
      return _fuseResults(allAttempts);
      
    } catch (e) {
      print('❌ AI Detection error: $e');
      throw Exception('AI Detection failed: ${e.toString()}');
    }
  }

  /// 🗑️ Specialized garbage detection (unchanged)
  Future<IssueDetectionResult> _detectGarbage(Uint8List imageBytes) async {
    try {
      final url = Uri.parse('https://api-inference.huggingface.co/models/$_wasteDetectionModel');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/octet-stream',
        },
        body: imageBytes,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 503) {
        await Future.delayed(const Duration(seconds: 15));
        return _detectGarbage(imageBytes);
      }

      if (response.statusCode == 200) {
        final List<dynamic> detections = json.decode(response.body);
        
        if (detections.isNotEmpty) {
          final garbageDetections = detections.where((d) {
            final label = (d['label'] ?? '').toString().toLowerCase();
            final score = (d['score'] ?? 0.0).toDouble();
            return score > 0.25 && (
              label.contains('garbage') || label.contains('trash') ||
              label.contains('waste') || label.contains('plastic') ||
              label.contains('bottle') || label.contains('bag') ||
              label.contains('paper') || label.contains('cardboard') ||
              label.contains('metal') || label.contains('glass') ||
              label.contains('litter')
            );
          }).toList();

          if (garbageDetections.isNotEmpty) {
            final avgConfidence = garbageDetections
                .map((d) => (d['score'] as num).toDouble())
                .reduce((a, b) => a + b) / garbageDetections.length;
            
            return IssueDetectionResult(
              category: 'Garbage',
              priority: _determinePriorityForGarbage(garbageDetections.length, avgConfidence),
              confidence: avgConfidence,
              description: 'Detected ${garbageDetections.length} waste item(s)',
            );
          }
        }
      }
      
      return IssueDetectionResult(
        category: 'Other',
        priority: 'low',
        confidence: 0.1,
        description: 'No garbage detected',
      );
      
    } catch (e) {
      print('⚠️ Garbage detection error: $e');
      rethrow;
    }
  }

  /// 🎯 ULTRA-ENHANCED Object Detection
  Future<IssueDetectionResult> _detectObjects(Uint8List imageBytes) async {
    try {
      final url = Uri.parse('https://api-inference.huggingface.co/models/$_objectDetectionModel');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/octet-stream',
        },
        body: imageBytes,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 503) {
        await Future.delayed(const Duration(seconds: 15));
        return _detectObjects(imageBytes);
      }

      if (response.statusCode == 200) {
        final List<dynamic> detections = json.decode(response.body);
        return _processObjectDetectionsEnhanced(detections);
      }
      
      return IssueDetectionResult(
        category: 'Other',
        priority: 'low',
        confidence: 0.1,
        description: 'No objects detected',
      );
      
    } catch (e) {
      rethrow;
    }
  }

  /// 🏷️ Scene Classification
  Future<IssueDetectionResult> _classifyScene(Uint8List imageBytes) async {
    try {
      final url = Uri.parse('https://api-inference.huggingface.co/models/$_sceneClassificationModel');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/octet-stream',
        },
        body: imageBytes,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 503) {
        await Future.delayed(const Duration(seconds: 15));
        return _classifyScene(imageBytes);
      }

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        return _processSceneClassification(results);
      }
      
      return IssueDetectionResult(
        category: 'Other',
        priority: 'low',
        confidence: 0.1,
        description: 'Scene not classified',
      );
      
    } catch (e) {
      rethrow;
    }
  }

  /// 🔬 General Image Classification
  Future<IssueDetectionResult> _classifyImage(Uint8List imageBytes) async {
    try {
      final url = Uri.parse('https://api-inference.huggingface.co/models/$_imageClassificationModel');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/octet-stream',
        },
        body: imageBytes,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 503) {
        await Future.delayed(const Duration(seconds: 15));
        return _classifyImage(imageBytes);
      }

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        return _processImageClassification(results);
      }
      
      return IssueDetectionResult(
        category: 'Other',
        priority: 'low',
        confidence: 0.1,
        description: 'Image not classified',
      );
      
    } catch (e) {
      rethrow;
    }
  }

  /// 🎨 Visual Feature Analysis
  Future<IssueDetectionResult> _analyzeVisualFeatures(Uint8List imageBytes) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return _createFallbackResult();

      Map<String, int> colorProfiles = {
        'dark_gray': 0,    // Asphalt/Road
        'brown': 0,        // Dirt/Sewage
        'blue': 0,         // Water
        'yellow': 0,       // Street lights
        'green': 0,        // Parks/vegetation
        'red': 0,          // Warning signs/electrical
        'white': 0,        // Road markings
      };

      // Sample pixels to analyze dominant colors
      int sampleSize = 50;
      int step = (image.width * image.height) ~/ (sampleSize * sampleSize);
      
      for (int i = 0; i < image.width * image.height; i += step) {
        int x = i % image.width;
        int y = i ~/ image.width;
        if (y >= image.height) break;
        
        final pixel = image.getPixel(x, y);
        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();
        
        // Classify color
        if (r < 60 && g < 60 && b < 60) {
          colorProfiles['dark_gray'] = colorProfiles['dark_gray']! + 1;
        } else if (r > 150 && g > 100 && b < 100) {
          colorProfiles['brown'] = colorProfiles['brown']! + 1;
        } else if (b > r && b > g && b > 100) {
          colorProfiles['blue'] = colorProfiles['blue']! + 1;
        } else if (r > 200 && g > 200 && b < 150) {
          colorProfiles['yellow'] = colorProfiles['yellow']! + 1;
        } else if (g > r && g > b && g > 100) {
          colorProfiles['green'] = colorProfiles['green']! + 1;
        } else if (r > 150 && g < 100 && b < 100) {
          colorProfiles['red'] = colorProfiles['red']! + 1;
        } else if (r > 200 && g > 200 && b > 200) {
          colorProfiles['white'] = colorProfiles['white']! + 1;
        }
      }

      // Determine category based on color profile
      String dominantColor = colorProfiles.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      
      int totalSamples = colorProfiles.values.reduce((a, b) => a + b);
      double confidence = colorProfiles[dominantColor]! / totalSamples;

      Map<String, CategoryInfo> colorToCategory = {
        'dark_gray': CategoryInfo('Road Damage', 'medium'),
        'brown': CategoryInfo('Sewage', 'high'),
        'blue': CategoryInfo('Water Supply', 'high'),
        'yellow': CategoryInfo('Street Light', 'medium'),
        'green': CategoryInfo('Parks & Recreation', 'low'),
        'red': CategoryInfo('Electricity', 'high'),
        'white': CategoryInfo('Road Damage', 'low'),
      };

      final catInfo = colorToCategory[dominantColor]!;
      
      return IssueDetectionResult(
        category: catInfo.category,
        priority: catInfo.priority,
        confidence: confidence * 0.6, // Lower confidence for visual analysis
        description: 'Visual analysis suggests ${catInfo.category.toLowerCase()}',
      );
      
    } catch (e) {
      print('⚠️ Visual analysis error: $e');
      return _createFallbackResult();
    }
  }

  /// 📊 ULTRA-ENHANCED Object Detection Processing
  IssueDetectionResult _processObjectDetectionsEnhanced(List<dynamic> detections) {
    if (detections.isEmpty) {
      return _createFallbackResult();
    }

    // Comprehensive keyword mapping
    final Map<String, CategoryInfo> keywords = {
      // Road Damage - Ultra expanded
      'road': CategoryInfo('Road Damage', 'medium'),
      'street': CategoryInfo('Road Damage', 'medium'),
      'pavement': CategoryInfo('Road Damage', 'medium'),
      'asphalt': CategoryInfo('Road Damage', 'high'),
      'crack': CategoryInfo('Road Damage', 'urgent'),
      'pothole': CategoryInfo('Road Damage', 'urgent'),
      'hole': CategoryInfo('Road Damage', 'high'),
      'sidewalk': CategoryInfo('Road Damage', 'medium'),
      'curb': CategoryInfo('Road Damage', 'medium'),
      'concrete': CategoryInfo('Road Damage', 'medium'),
      'broken': CategoryInfo('Road Damage', 'high'),
      'damaged': CategoryInfo('Road Damage', 'high'),
      
      // Street Light - Expanded
      'light': CategoryInfo('Street Light', 'medium'),
      'lamp': CategoryInfo('Street Light', 'medium'),
      'pole': CategoryInfo('Street Light', 'medium'),
      'street light': CategoryInfo('Street Light', 'high'),
      'lantern': CategoryInfo('Street Light', 'medium'),
      'bulb': CategoryInfo('Street Light', 'high'),
      'fixture': CategoryInfo('Street Light', 'medium'),
      'illumination': CategoryInfo('Street Light', 'medium'),
      
      // Water Supply - Expanded
      'water': CategoryInfo('Water Supply', 'high'),
      'pipe': CategoryInfo('Water Supply', 'high'),
      'hydrant': CategoryInfo('Water Supply', 'urgent'),
      'leak': CategoryInfo('Water Supply', 'urgent'),
      'flood': CategoryInfo('Water Supply', 'urgent'),
      'puddle': CategoryInfo('Water Supply', 'medium'),
      'drain': CategoryInfo('Water Supply', 'medium'),
      'fountain': CategoryInfo('Water Supply', 'low'),
      'tap': CategoryInfo('Water Supply', 'high'),
      'valve': CategoryInfo('Water Supply', 'high'),
      'wet': CategoryInfo('Water Supply', 'medium'),
      
      // Sewage - New category
      'sewer': CategoryInfo('Sewage', 'urgent'),
      'sewage': CategoryInfo('Sewage', 'urgent'),
      'manhole': CategoryInfo('Sewage', 'medium'),
      'drainage': CategoryInfo('Sewage', 'high'),
      'overflow': CategoryInfo('Sewage', 'urgent'),
      'waste water': CategoryInfo('Sewage', 'urgent'),
      
      // Garbage - Expanded
      'trash': CategoryInfo('Garbage', 'high'),
      'garbage': CategoryInfo('Garbage', 'high'),
      'waste': CategoryInfo('Garbage', 'high'),
      'bin': CategoryInfo('Garbage', 'medium'),
      'litter': CategoryInfo('Garbage', 'high'),
      'plastic': CategoryInfo('Garbage', 'medium'),
      'bottle': CategoryInfo('Garbage', 'medium'),
      'bag': CategoryInfo('Garbage', 'medium'),
      'container': CategoryInfo('Garbage', 'low'),
      'dumpster': CategoryInfo('Garbage', 'medium'),
      'rubbish': CategoryInfo('Garbage', 'high'),
      
      // Electricity - Expanded
      'wire': CategoryInfo('Electricity', 'urgent'),
      'cable': CategoryInfo('Electricity', 'urgent'),
      'power': CategoryInfo('Electricity', 'high'),
      'electric': CategoryInfo('Electricity', 'high'),
      'transformer': CategoryInfo('Electricity', 'high'),
      'utility': CategoryInfo('Electricity', 'medium'),
      'meter': CategoryInfo('Electricity', 'low'),
      'circuit': CategoryInfo('Electricity', 'high'),
      
      // Public Transport - Expanded
      'traffic': CategoryInfo('Public Transport', 'medium'),
      'sign': CategoryInfo('Public Transport', 'medium'),
      'signal': CategoryInfo('Public Transport', 'high'),
      'bus': CategoryInfo('Public Transport', 'low'),
      'stop': CategoryInfo('Public Transport', 'medium'),
      'crosswalk': CategoryInfo('Public Transport', 'medium'),
      'parking': CategoryInfo('Public Transport', 'low'),
      'barrier': CategoryInfo('Public Transport', 'medium'),
      
      // Parks & Recreation - Expanded
      'tree': CategoryInfo('Parks & Recreation', 'low'),
      'bench': CategoryInfo('Parks & Recreation', 'low'),
      'playground': CategoryInfo('Parks & Recreation', 'medium'),
      'grass': CategoryInfo('Parks & Recreation', 'low'),
      'park': CategoryInfo('Parks & Recreation', 'low'),
      'garden': CategoryInfo('Parks & Recreation', 'low'),
      'fence': CategoryInfo('Parks & Recreation', 'low'),
    };

    Map<String, List<double>> categoryScores = {};
    
    for (var detection in detections) {
      final label = (detection['label'] as String).toLowerCase();
      final score = (detection['score'] as num).toDouble();
      
      if (score < 0.25) continue;
      
      print('  🔍 Detected: $label (${(score * 100).toStringAsFixed(1)}%)');
      
      bool matched = false;
      for (var entry in keywords.entries) {
        if (label.contains(entry.key)) {
          final category = entry.value.category;
          categoryScores[category] = categoryScores[category] ?? [];
          categoryScores[category]!.add(score);
          matched = true;
          print('    ✓ Matched to: $category');
          break;
        }
      }
      
      if (!matched) {
        print('    ✗ No match found');
      }
    }
    
    if (categoryScores.isNotEmpty) {
      String bestCategory = '';
      double bestScore = 0.0;
      
      for (var entry in categoryScores.entries) {
        final avgScore = entry.value.reduce((a, b) => a + b) / entry.value.length;
        final boostedScore = avgScore * entry.value.length; // Boost by frequency
        
        if (boostedScore > bestScore) {
          bestScore = avgScore; // Use original avg for confidence
          bestCategory = entry.key;
        }
      }
      
      String priority = 'medium';
      for (var entry in keywords.entries) {
        if (entry.value.category == bestCategory) {
          priority = entry.value.priority;
          break;
        }
      }
      
      return IssueDetectionResult(
        category: bestCategory,
        priority: priority,
        confidence: bestScore,
        description: 'Detected $bestCategory issue',
      );
    }
    
    return _createFallbackResult();
  }

  /// 🏷️ Scene Classification Processing
  IssueDetectionResult _processSceneClassification(List<dynamic> results) {
    if (results.isEmpty) return _createFallbackResult();

    final patterns = {
      RegExp(r'(road|street|highway|pavement|asphalt)', caseSensitive: false): 
        CategoryInfo('Road Damage', 'medium'),
      RegExp(r'(park|garden|playground|outdoor|field)', caseSensitive: false): 
        CategoryInfo('Parks & Recreation', 'low'),
      RegExp(r'(water|flood|leak|puddle|rain)', caseSensitive: false): 
        CategoryInfo('Water Supply', 'high'),
      RegExp(r'(urban|city|building|infrastructure)', caseSensitive: false): 
        CategoryInfo('Road Damage', 'low'),
      RegExp(r'(night|dark|evening|light)', caseSensitive: false): 
        CategoryInfo('Street Light', 'medium'),
    };

    for (var result in results.take(3)) {
      final label = (result['label'] as String).toLowerCase();
      final score = (result['score'] as num).toDouble();
      
      print('  🏷️ Scene: $label (${(score * 100).toStringAsFixed(1)}%)');
      
      for (var entry in patterns.entries) {
        if (entry.key.hasMatch(label)) {
          return IssueDetectionResult(
            category: entry.value.category,
            priority: entry.value.priority,
            confidence: score * 0.8,
            description: 'Scene classification suggests ${entry.value.category.toLowerCase()}',
          );
        }
      }
    }
    
    return _createFallbackResult();
  }

  /// 📊 Image Classification Processing
  IssueDetectionResult _processImageClassification(List<dynamic> results) {
    if (results.isEmpty) return _createFallbackResult();

    final patterns = {
      // Infrastructure patterns
      RegExp(r'(crack|damage|broken|pothole|hole)', caseSensitive: false): 
        CategoryInfo('Road Damage', 'high'),
      RegExp(r'(trash|garbage|waste|litter|dump|bottle|plastic|bag)', caseSensitive: false): 
        CategoryInfo('Garbage', 'high'),
      RegExp(r'(water|wet|flood|leak|puddle|pipe)', caseSensitive: false): 
        CategoryInfo('Water Supply', 'high'),
      RegExp(r'(wire|cable|power|electric|pole)', caseSensitive: false): 
        CategoryInfo('Electricity', 'high'),
      RegExp(r'(light|lamp|bulb|lantern)', caseSensitive: false): 
        CategoryInfo('Street Light', 'medium'),
      RegExp(r'(sewer|sewage|drain|manhole)', caseSensitive: false): 
        CategoryInfo('Sewage', 'high'),
      RegExp(r'(road|street|pavement|asphalt|sidewalk)', caseSensitive: false): 
        CategoryInfo('Road Damage', 'medium'),
      RegExp(r'(tree|grass|park|bench|garden)', caseSensitive: false): 
        CategoryInfo('Parks & Recreation', 'low'),
      RegExp(r'(traffic|sign|signal|bus|transport)', caseSensitive: false): 
        CategoryInfo('Public Transport', 'medium'),
    };

    for (var result in results.take(5)) {
      final label = (result['label'] as String).toLowerCase();
      final score = (result['score'] as num).toDouble();
      
      print('  🔬 Class: $label (${(score * 100).toStringAsFixed(1)}%)');
      
      for (var entry in patterns.entries) {
        if (entry.key.hasMatch(label)) {
          return IssueDetectionResult(
            category: entry.value.category,
            priority: entry.value.priority,
            confidence: score * 0.9,
            description: 'Classification: ${entry.value.category}',
          );
        }
      }
    }
    
    return _createFallbackResult();
  }

  /// 🧠 Smart Result Fusion
  IssueDetectionResult _fuseResults(List<DetectionAttempt> attempts) {
    print('\n🧠 === FUSING RESULTS ===');
    
    // Group by category
    Map<String, List<DetectionAttempt>> categoryGroups = {};
    for (var attempt in attempts) {
      if (attempt.result.category == 'Other') continue;
      
      categoryGroups[attempt.result.category] = 
          categoryGroups[attempt.result.category] ?? [];
      categoryGroups[attempt.result.category]!.add(attempt);
    }
    
    if (categoryGroups.isEmpty) {
      print('❌ No valid detections, using fallback');
      return _createFallbackResult();
    }
    
    // Calculate weighted scores
    Map<String, double> categoryScores = {};
    for (var entry in categoryGroups.entries) {
      double totalScore = 0;
      for (var attempt in entry.value) {
        totalScore += attempt.result.confidence * attempt.weight;
      }
      categoryScores[entry.key] = totalScore;
      
      print('  📊 ${entry.key}: ${totalScore.toStringAsFixed(2)} '
            '(${entry.value.length} detection(s))');
    }
    
    // Get best category
    String bestCategory = categoryScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    // Get best result for that category
    final categoryAttempts = categoryGroups[bestCategory]!;
    categoryAttempts.sort((a, b) => 
        b.result.confidence.compareTo(a.result.confidence));
    
    final bestResult = categoryAttempts.first.result;
    
    print('🎯 FINAL RESULT: ${bestResult.category} '
          '(${bestResult.confidencePercentage})');
    
    return bestResult;
  }

  /// 🖼️ Image Preprocessing
  Future<Uint8List> _preprocessImage(Uint8List imageBytes) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return imageBytes;
      
      img.Image processed = image;
      
      // Resize if too large
      if (image.width > 1200 || image.height > 1200) {
        final ratio = 1200 / (image.width > image.height ? image.width : image.height);
        processed = img.copyResize(
          image,
          width: (image.width * ratio).toInt(),
          height: (image.height * ratio).toInt(),
        );
      }
      
      // Enhance image
      processed = img.adjustColor(
        processed, 
        contrast: 1.15, 
        brightness: 1.1,
        saturation: 1.1,
      );
      
      return Uint8List.fromList(img.encodeJpg(processed, quality: 90));
    } catch (e) {
      return imageBytes;
    }
  }

  /// 🗑️ Garbage Priority
  String _determinePriorityForGarbage(int itemCount, double confidence) {
    if (itemCount >= 5 && confidence > 0.6) return 'urgent';
    if (itemCount >= 3 || confidence > 0.7) return 'high';
    if (itemCount >= 1 || confidence > 0.5) return 'medium';
    return 'low';
  }

  /// 🔍 Multiple Images Analysis
  Future<IssueDetectionResult> analyzeMultipleImages(List<File> images) async {
    if (images.isEmpty) {
      throw Exception('No images provided');
    }

    print('\n🔍 === ANALYZING ${images.length} IMAGES ===');
    List<IssueDetectionResult> allResults = [];

    for (int i = 0; i < images.length && i < 3; i++) {
      try {
        print('\n📸 IMAGE ${i + 1}/${images.length}');
        final result = await detectIssueFromImage(images[i]);
        allResults.add(result);
      } catch (e) {
        print('⚠️ Error on image ${i + 1}: $e');
      }
    }

    if (allResults.isEmpty) {
      throw Exception('Could not analyze any images');
    }

    // Filter and get consensus
    final validResults = allResults.where((r) =>
        r.confidence >= 0.35 && r.category != 'Other').toList();

    if (validResults.isEmpty) {
      allResults.sort((a, b) => b.confidence.compareTo(a.confidence));
      return allResults.first;
    }

    return _getBestResultWithConsensus(validResults);
  }

  /// 🎯 Consensus Algorithm
  IssueDetectionResult _getBestResultWithConsensus(List<IssueDetectionResult> results) {
    Map<String, List<IssueDetectionResult>> groups = {};
    
    for (var result in results) {
      groups[result.category] = groups[result.category] ?? [];
      groups[result.category]!.add(result);
    }

    Map<String, double> scores = {};
    for (var entry in groups.entries) {
      final avgConf = entry.value
          .map((r) => r.confidence)
          .reduce((a, b) => a + b) / entry.value.length;
      scores[entry.key] = avgConf * entry.value.length;
    }

    String best = scores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    final bestResults = groups[best]!;
    bestResults.sort((a, b) => b.confidence.compareTo(a.confidence));

    print('🎯 Consensus: $best (${bestResults.length}/${results.length})');
    return bestResults.first;
  }

  /// 🧰 Fallback Result
  IssueDetectionResult _createFallbackResult() {
    return IssueDetectionResult(
      category: 'Other',
      priority: 'low',
      confidence: 0.2,
      description: 'Unable to identify specific infrastructure issue',
    );
  }
}

/// 🔬 Detection Attempt Wrapper
class DetectionAttempt {
  final IssueDetectionResult result;
  final String source;
  final double weight;

  DetectionAttempt(this.result, this.source, {this.weight = 1.0});
}

/// 📋 Category Info Helper
class CategoryInfo {
  final String category;
  final String priority;
  
  const CategoryInfo(this.category, this.priority);
}

/// 🧩 Detection Result Model
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