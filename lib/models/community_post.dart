import 'dart:typed_data';

class CommunityComment {
  const CommunityComment({
    this.id = '',
    this.authorId = '',
    required this.authorName,
    required this.message,
    required this.timeLabel,
    this.isHelpful = false,
    this.createdAt,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String message;
  final String timeLabel;
  final bool isHelpful;
  final DateTime? createdAt;

  factory CommunityComment.fromMap(Map<String, dynamic> map) {
    final createdAt = _readDateTime(map['createdAt']);
    return CommunityComment(
      id: map['id']?.toString() ?? '',
      authorId: map['authorId']?.toString() ?? '',
      authorName: map['authorName']?.toString() ?? 'Community Member',
      message: map['message']?.toString() ?? '',
      timeLabel:
          _timeLabelFromDate(createdAt) ?? map['timeLabel']?.toString() ??
          'Just now',
      isHelpful: map['isHelpful'] as bool? ?? false,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'message': message,
      'timeLabel': timeLabel,
      'isHelpful': isHelpful,
      'createdAt': createdAt,
    };
  }

  CommunityComment copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? message,
    String? timeLabel,
    bool? isHelpful,
    DateTime? createdAt,
  }) {
    return CommunityComment(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      message: message ?? this.message,
      timeLabel: timeLabel ?? this.timeLabel,
      isHelpful: isHelpful ?? this.isHelpful,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CommunityPost {
  const CommunityPost({
    required this.id,
    this.authorId = '',
    required this.authorName,
    required this.authorRole,
    required this.category,
    required this.plantName,
    required this.title,
    required this.problemDescription,
    required this.timeLabel,
    required this.comments,
    required this.likeCount,
    required this.saveCount,
    this.imageBytes,
    this.imageUrl,
    this.createdAt,
    this.isLiked = false,
    this.isSaved = false,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String category;
  final String plantName;
  final String title;
  final String problemDescription;
  final String timeLabel;
  final Uint8List? imageBytes;
  final String? imageUrl;
  final DateTime? createdAt;
  final List<CommunityComment> comments;
  final int likeCount;
  final int saveCount;
  final bool isLiked;
  final bool isSaved;

  int get commentCount => comments.length;

  factory CommunityPost.fromMap(
    Map<String, dynamic> map, {
    String currentUserId = '',
  }) {
    final comments = _readComments(map['comments']);
    final likedBy = _readStringList(map['likedBy']);
    final savedBy = _readStringList(map['savedBy']);
    final createdAt = _readDateTime(map['createdAt']);

    return CommunityPost(
      id: map['id']?.toString() ?? '',
      authorId: map['authorId']?.toString() ?? '',
      authorName: map['authorName']?.toString() ?? 'Community Member',
      authorRole: map['authorRole']?.toString() ?? 'Community Member',
      category: map['category']?.toString() ?? 'Care',
      plantName: map['plantName']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      problemDescription: map['problemDescription']?.toString() ?? '',
      timeLabel:
          _timeLabelFromDate(createdAt) ?? map['timeLabel']?.toString() ??
          'Just now',
      imageUrl: map['imageUrl']?.toString(),
      createdAt: createdAt,
      comments: comments,
      likeCount: _readInt(map['likeCount'], fallback: likedBy.length),
      saveCount: _readInt(map['saveCount'], fallback: savedBy.length),
      isLiked: currentUserId.isNotEmpty && likedBy.contains(currentUserId),
      isSaved: currentUserId.isNotEmpty && savedBy.contains(currentUserId),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'category': category,
      'plantName': plantName,
      'title': title,
      'problemDescription': problemDescription,
      'timeLabel': timeLabel,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'comments': comments.map((comment) => comment.toMap()).toList(),
      'likeCount': likeCount,
      'saveCount': saveCount,
    };
  }

  CommunityComment? get helpfulAnswer {
    for (final comment in comments) {
      if (comment.isHelpful) {
        return comment;
      }
    }
    return null;
  }

  CommunityPost copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorRole,
    String? category,
    String? plantName,
    String? title,
    String? problemDescription,
    String? timeLabel,
    Uint8List? imageBytes,
    String? imageUrl,
    DateTime? createdAt,
    List<CommunityComment>? comments,
    int? likeCount,
    int? saveCount,
    bool? isLiked,
    bool? isSaved,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      category: category ?? this.category,
      plantName: plantName ?? this.plantName,
      title: title ?? this.title,
      problemDescription: problemDescription ?? this.problemDescription,
      timeLabel: timeLabel ?? this.timeLabel,
      imageBytes: imageBytes ?? this.imageBytes,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      comments: comments ?? this.comments,
      likeCount: likeCount ?? this.likeCount,
      saveCount: saveCount ?? this.saveCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

List<CommunityComment> _readComments(dynamic rawComments) {
  final comments = <CommunityComment>[];
  if (rawComments is! List) {
    return comments;
  }

  for (final rawComment in rawComments) {
    if (rawComment is Map) {
      comments.add(CommunityComment.fromMap(Map<String, dynamic>.from(rawComment)));
    }
  }

  return comments;
}

List<String> _readStringList(dynamic rawValues) {
  if (rawValues is! List) {
    return <String>[];
  }

  return rawValues.map((value) => value.toString()).toList(growable: false);
}

int _readInt(dynamic value, {required int fallback}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return fallback;
}

DateTime? _readDateTime(dynamic value) {
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  if (value is Map && value['seconds'] is int) {
    final seconds = value['seconds'] as int;
    final nanoseconds = value['nanoseconds'] as int? ?? 0;
    return DateTime.fromMillisecondsSinceEpoch(
      (seconds * 1000) + (nanoseconds ~/ 1000000),
      isUtc: true,
    ).toLocal();
  }
  return null;
}

String? _timeLabelFromDate(DateTime? dateTime) {
  if (dateTime == null) {
    return null;
  }

  final difference = DateTime.now().difference(dateTime);
  if (difference.inMinutes < 1) {
    return 'Just now';
  }
  if (difference.inHours < 1) {
    return '${difference.inMinutes}m ago';
  }
  if (difference.inDays < 1) {
    return '${difference.inHours}h ago';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  }

  return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
}
