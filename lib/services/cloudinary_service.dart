// lib/services/cloudinary_service.dart
import 'dart:io';
import 'package:cloudinary/cloudinary.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  late final Cloudinary cloudinary;

  CloudinaryService() {
    cloudinary = Cloudinary.signedConfig(
      cloudName: '', //  Cloudinary cloud name
      apiKey: '', //  Cloudinary API key
      apiSecret: '', //  Cloudinary API secret
    );
  }

  Future<List<String>> uploadMultipleImages(List<XFile> images, String userId) async {
    List<String> imageUrls = [];
    
    for (int i = 0; i < images.length; i++) {
      try {
        final response = await cloudinary.upload(
          file: File(images[i].path).path,
          resourceType: CloudinaryResourceType.image,
          folder: 'uee_reports/$userId',
          fileName: 'report_${DateTime.now().millisecondsSinceEpoch}_$i',
        );
        
        if (response.isSuccessful) {
          imageUrls.add(response.secureUrl!);
          print('✅ Image $i uploaded: ${response.secureUrl}');
        } else {
          print('❌ Failed to upload image $i: ${response.error}');
        }
      } catch (e) {
        print('❌ Error uploading image $i: $e');
        // Continue with other images even if one fails
      }
    }
    
    return imageUrls;
  }

  // For single image upload
  Future<String?> uploadImage(XFile image, String userId) async {
    try {
      final response = await cloudinary.upload(
        file: File(image.path).path,
        resourceType: CloudinaryResourceType.image,
        folder: 'uee_reports/$userId',
        fileName: 'report_${DateTime.now().millisecondsSinceEpoch}',
      );
      
      if (response.isSuccessful) {
        return response.secureUrl;
      } else {
        print('❌ Failed to upload image: ${response.error}');
        return null;
      }
    } catch (e) {
      print('❌ Error uploading image: $e');
      return null;
    }
  }
}
