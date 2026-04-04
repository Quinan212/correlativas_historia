import 'dart:math';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/verification_request.dart';
import '../models/verification_upload_image.dart';

class VerificationRepository {
  const VerificationRepository();

  static const String bucketName = 'verification-evidence';
  static const int _maxUploadWidth = 1600;
  static const int _imageQuality = 80;

  Future<XFile?> pickImage() {
    return ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: _maxUploadWidth.toDouble(),
      imageQuality: _imageQuality,
    );
  }

  Future<VerificationRequest> submitRequest({
    required SupabaseClient client,
    required String deviceId,
    required String matterId,
    required String matterName,
    required String careerId,
    required VerificationUploadImage image,
  }) async {
    final bytes = image.bytes;
    final ext = _fileExtension(image.fileName);
    final path =
        '$deviceId/${DateTime.now().millisecondsSinceEpoch}_${_randHex(6)}.$ext';

    await client.storage.from(bucketName).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: _contentTypeFor(ext),
            upsert: false,
          ),
        );

    final publicUrl = client.storage.from(bucketName).getPublicUrl(path);

    final inserted = await client
        .from('verification_requests')
        .insert({
          'device_id': deviceId,
          'matter_id': matterId,
          'matter_name': matterName,
          'career_id': careerId,
          'image_path': path,
          'image_url': publicUrl,
          'status': VerificationRequestStatus.pending.value,
        })
        .select()
        .single();

    return VerificationRequest.fromMap(inserted);
  }

  Future<List<VerificationRequest>> fetchOwnRequests({
    required SupabaseClient client,
    required String deviceId,
  }) async {
    final rows = await client
        .from('verification_requests')
        .select()
        .eq('device_id', deviceId)
        .order('created_at', ascending: false);

    return rows
        .cast<Map<String, dynamic>>()
        .map(VerificationRequest.fromMap)
        .toList(growable: false);
  }

  Stream<List<VerificationRequest>> watchOwnRequests({
    required SupabaseClient client,
    required String deviceId,
  }) {
    return client
        .from('verification_requests')
        .stream(primaryKey: ['id'])
        .eq('device_id', deviceId)
        .order('created_at', ascending: false)
        .map(
          (rows) => rows
              .cast<Map<String, dynamic>>()
              .map(VerificationRequest.fromMap)
              .toList(growable: false),
        );
  }

  Future<List<VerificationRequest>> fetchPendingRequests({
    required SupabaseClient client,
  }) async {
    final rows = await client
        .from('verification_requests')
        .select()
        .eq('status', VerificationRequestStatus.pending.value)
        .order('created_at', ascending: true);

    return rows
        .cast<Map<String, dynamic>>()
        .map(VerificationRequest.fromMap)
        .toList(growable: false);
  }

  Stream<List<VerificationRequest>> watchPendingRequests({
    required SupabaseClient client,
  }) {
    return client
        .from('verification_requests')
        .stream(primaryKey: ['id'])
        .eq('status', VerificationRequestStatus.pending.value)
        .order('created_at', ascending: true)
        .map(
          (rows) => rows
              .cast<Map<String, dynamic>>()
              .map(VerificationRequest.fromMap)
              .toList(growable: false),
        );
  }

  Stream<List<VerificationRequest>> watchReviewedRequests({
    required SupabaseClient client,
  }) {
    return client
        .from('verification_requests')
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false)
        .map(
          (rows) => rows
              .cast<Map<String, dynamic>>()
              .map(VerificationRequest.fromMap)
              .where((item) => item.status != VerificationRequestStatus.pending)
              .toList(growable: false),
        );
  }

  Stream<Set<String>> watchApprovedMatterIds({
    required SupabaseClient client,
    required String deviceId,
  }) {
    return client
        .from('device_subject_permissions')
        .stream(primaryKey: ['id'])
        .eq('device_id', deviceId)
        .map(
          (rows) => rows
              .cast<Map<String, dynamic>>()
              .map((row) => (row['matter_id'] ?? '').toString())
              .where((value) => value.isNotEmpty)
              .toSet(),
        );
  }

  Future<void> approveRequest({
    required SupabaseClient client,
    required VerificationRequest request,
    required String adminDeviceId,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();

    await client.from('verification_requests').update({
      'status': VerificationRequestStatus.approved.value,
      'reviewed_by_device_id': adminDeviceId,
      'reviewed_at': now,
      'updated_at': now,
    }).eq('id', request.id);

    await client.from('device_subject_permissions').upsert({
      'device_id': request.deviceId,
      'matter_id': request.matterId,
      'matter_name': request.matterName,
      'career_id': request.careerId,
      'granted_by_device_id': adminDeviceId,
      'created_at': now,
    }, onConflict: 'device_id,matter_id');
  }

  Future<void> rejectRequest({
    required SupabaseClient client,
    required String requestId,
    required String adminDeviceId,
    String? reviewNote,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();

    await client.from('verification_requests').update({
      'status': VerificationRequestStatus.rejected.value,
      'review_note': reviewNote,
      'reviewed_by_device_id': adminDeviceId,
      'reviewed_at': now,
      'updated_at': now,
    }).eq('id', requestId);
  }

  String _fileExtension(String name) {
    final parts = name.toLowerCase().split('.');
    if (parts.length < 2) return 'jpg';
    final ext = parts.last.trim();
    if (ext.isEmpty) return 'jpg';
    return ext;
  }

  String _contentTypeFor(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  String _randHex(int length) {
    final random = Random.secure();
    final bytes = Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
