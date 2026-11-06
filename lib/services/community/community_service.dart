import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../models/community_post.dart';

class CommunityServiceException implements Exception {
  const CommunityServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CommunityService {
  const CommunityService();

  bool get isAvailable => Firebase.apps.isNotEmpty;

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection('community_posts');

  Stream<List<CommunityPost>> watchPosts({
    String currentUserId = '',
  }) {
    if (!isAvailable) {
      return Stream<List<CommunityPost>>.error(
        const CommunityServiceException(
          'Firebase is not configured for this build.',
        ),
      );
    }

    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CommunityPost.fromMap(
                  <String, dynamic>{
                    ...doc.data(),
                    'id': doc.id,
                  },
                  currentUserId: currentUserId,
                ),
              )
              .toList(growable: false),
        );
  }

  Future<void> createPost({
    required String authorName,
    required String authorRole,
    required String category,
    required String plantName,
    required String title,
    required String problemDescription,
    required Uint8List? imageBytes,
    required String imageFileName,
  }) async {
    if (!isAvailable) {
      throw const CommunityServiceException(
        'Firebase is not configured for this build.',
      );
    }

    try {
      final now = DateTime.now();
      final currentUser = FirebaseAuth.instance.currentUser;
      final postRef = _collection.doc();
      String? imageUrl;

      if (imageBytes != null && imageBytes.isNotEmpty) {
        imageUrl = await _uploadPostImage(
          postId: postRef.id,
          imageBytes: imageBytes,
          fileName: imageFileName,
        );
      }

      await postRef.set(
        <String, dynamic>{
          'id': postRef.id,
          'authorId': currentUser?.uid ?? 'guest',
          'authorName': authorName.trim().isEmpty
              ? _displayName(currentUser)
              : authorName.trim(),
          'authorRole': authorRole.trim().isEmpty
              ? 'Community Member'
              : authorRole.trim(),
          'category': category.trim(),
          'plantName': plantName.trim(),
          'title': title.trim(),
          'problemDescription': problemDescription.trim(),
          'timeLabel': 'Just now',
          'imageUrl': imageUrl,
          'createdAt': now,
          'updatedAt': now,
          'likeCount': 0,
          'saveCount': 0,
          'likedBy': <String>[],
          'savedBy': <String>[],
          'comments': <Map<String, dynamic>>[],
        },
      );
    } on CommunityServiceException {
      rethrow;
    } on FirebaseException catch (_) {
      throw const CommunityServiceException(
        'Unable to save the post right now.',
      );
    } catch (_) {
      throw const CommunityServiceException(
        'Unable to create the post right now.',
      );
    }
  }

  Future<void> setLike({
    required String postId,
    required String userId,
    required bool isLiked,
  }) async {
    await _updateUserReaction(
      postId: postId,
      userId: userId,
      fieldName: 'likedBy',
      countFieldName: 'likeCount',
      shouldInclude: isLiked,
    );
  }

  Future<void> setSave({
    required String postId,
    required String userId,
    required bool isSaved,
  }) async {
    await _updateUserReaction(
      postId: postId,
      userId: userId,
      fieldName: 'savedBy',
      countFieldName: 'saveCount',
      shouldInclude: isSaved,
    );
  }

  Future<void> addComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String message,
  }) async {
    if (!isAvailable) {
      throw const CommunityServiceException(
        'Firebase is not configured for this build.',
      );
    }

    try {
      final postRef = _collection.doc(postId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(postRef);
        if (!snapshot.exists) {
          throw const CommunityServiceException(
            'The community post could not be found.',
          );
        }

        final data = snapshot.data() ?? <String, dynamic>{};
        final comments = _readCommentMaps(data['comments']);
        final now = DateTime.now();

        comments.add(
          <String, dynamic>{
            'id': '${postRef.id}-${now.microsecondsSinceEpoch}',
            'authorId': authorId,
            'authorName': authorName.trim().isEmpty ? 'You' : authorName.trim(),
            'message': message.trim(),
            'timeLabel': 'Just now',
            'isHelpful': false,
            'createdAt': now,
          },
        );

        transaction.update(
          postRef,
          <String, dynamic>{
            'comments': comments,
            'updatedAt': now,
          },
        );
      });
    } on CommunityServiceException {
      rethrow;
    } on FirebaseException catch (_) {
      throw const CommunityServiceException(
        'Unable to add the comment right now.',
      );
    } catch (_) {
      throw const CommunityServiceException(
        'Unable to add the comment right now.',
      );
    }
  }

  Future<void> markHelpful({
    required String postId,
    required String commentId,
  }) async {
    if (!isAvailable) {
      throw const CommunityServiceException(
        'Firebase is not configured for this build.',
      );
    }

    try {
      final postRef = _collection.doc(postId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(postRef);
        if (!snapshot.exists) {
          throw const CommunityServiceException(
            'The community post could not be found.',
          );
        }

        final data = snapshot.data() ?? <String, dynamic>{};
        final comments = _readCommentMaps(data['comments']);
        var foundComment = false;

        for (var index = 0; index < comments.length; index++) {
          final comment = comments[index];
          final isHelpful = comment['id']?.toString() == commentId;
          if (isHelpful) {
            foundComment = true;
          }
          if (comment['isHelpful'] == isHelpful) {
            continue;
          }
          comments[index] = <String, dynamic>{
            ...comment,
            'isHelpful': isHelpful,
          };
        }

        if (!foundComment) {
          throw const CommunityServiceException(
            'The comment could not be found.',
          );
        }

        transaction.update(
          postRef,
          <String, dynamic>{
            'comments': comments,
            'updatedAt': DateTime.now(),
          },
        );
      });
    } on CommunityServiceException {
      rethrow;
    } on FirebaseException catch (_) {
      throw const CommunityServiceException(
        'Unable to update the helpful answer right now.',
      );
    } catch (_) {
      throw const CommunityServiceException(
        'Unable to update the helpful answer right now.',
      );
    }
  }

  Future<void> _updateUserReaction({
    required String postId,
    required String userId,
    required String fieldName,
    required String countFieldName,
    required bool shouldInclude,
  }) async {
    if (!isAvailable) {
      throw const CommunityServiceException(
        'Firebase is not configured for this build.',
      );
    }

    try {
      final postRef = _collection.doc(postId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(postRef);
        if (!snapshot.exists) {
          throw const CommunityServiceException(
            'The community post could not be found.',
          );
        }

        final data = snapshot.data() ?? <String, dynamic>{};
        final values = _readStringList(data[fieldName]);
        if (shouldInclude) {
          if (!values.contains(userId)) {
            values.add(userId);
          }
        } else {
          values.remove(userId);
        }

        transaction.update(
          postRef,
          <String, dynamic>{
            fieldName: values,
            countFieldName: values.length,
            'updatedAt': DateTime.now(),
          },
        );
      });
    } on CommunityServiceException {
      rethrow;
    } on FirebaseException catch (_) {
      throw const CommunityServiceException(
        'Unable to update the post right now.',
      );
    } catch (_) {
      throw const CommunityServiceException(
        'Unable to update the post right now.',
      );
    }
  }

  Future<String> _uploadPostImage({
    required String postId,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('community_posts/$postId/${_sanitizeFileName(fileName)}');
      await ref.putData(imageBytes);
      return ref.getDownloadURL();
    } on FirebaseException {
      throw const CommunityServiceException(
        'Unable to upload the image right now.',
      );
    }
  }

  String _displayName(User? user) {
    final name = user?.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    final email = user?.email?.trim();
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return 'Guest Gardener';
  }

  String _sanitizeFileName(String fileName) {
    final cleaned = fileName.split(RegExp(r'[\\/]')).last.trim();
    return cleaned.isEmpty ? 'community_image.jpg' : cleaned;
  }
}

List<Map<String, dynamic>> _readCommentMaps(dynamic rawComments) {
  if (rawComments is! List) {
    return <Map<String, dynamic>>[];
  }

  return rawComments
      .whereType<Map>()
      .map((comment) => Map<String, dynamic>.from(comment))
      .toList(growable: false);
}

List<String> _readStringList(dynamic rawValues) {
  if (rawValues is! List) {
    return <String>[];
  }

  return rawValues.map((value) => value.toString()).toList(growable: true);
}
