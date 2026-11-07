import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';

/// Uploads report photos to Cloudinary.
class StorageService {
  StorageService(this._client);

  final http.Client _client;

  Uri get _uploadUrl => Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload',
      );

  /// Sends the photo to Cloudinary using the unsigned upload preset,
  /// and returns the photo's web link plus its Cloudinary id.
  Future<({String url, String path})> uploadIncidentPhoto({
    required String uid,
    required File file,
  }) async {
    final request = http.MultipartRequest('POST', _uploadUrl)
      ..fields['upload_preset'] = cloudinaryUploadPreset
      ..fields['folder'] = 'incident_photos/$uid'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await http.Response.fromStream(await _client.send(request));
    if (response.statusCode != 200) {
      throw Exception('Cloudinary upload failed (${response.statusCode}): ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (
      url: body['secure_url'] as String,
      path: body['public_id'] as String,
    );
  }
}
