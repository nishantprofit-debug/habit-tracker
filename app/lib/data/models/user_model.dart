import 'package:equatable/equatable.dart';

/// User Model
class UserModel extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String timezone;
  final bool notificationEnabled;
  final String morningReminderTime;
  final String eveningReminderTime;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.timezone = 'UTC',
    this.notificationEnabled = true,
    this.morningReminderTime = '06:00:00',
    this.eveningReminderTime = '21:00:00',
    required this.createdAt,
  });

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      timezone: json['timezone'] as String? ?? 'UTC',
      notificationEnabled: json['notification_enabled'] as bool? ?? true,
      morningReminderTime: json['morning_reminder_time'] as String? ?? '06:00:00',
      eveningReminderTime: json['evening_reminder_time'] as String? ?? '21:00:00',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'timezone': timezone,
      'notification_enabled': notificationEnabled,
      'morning_reminder_time': morningReminderTime,
      'evening_reminder_time': eveningReminderTime,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create from database map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['display_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      timezone: map['timezone'] as String? ?? 'UTC',
      notificationEnabled: (map['notification_enabled'] as int?) == 1,
      morningReminderTime: map['morning_reminder_time'] as String? ?? '06:00:00',
      eveningReminderTime: map['evening_reminder_time'] as String? ?? '21:00:00',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'timezone': timezone,
      'notification_enabled': notificationEnabled ? 1 : 0,
      'morning_reminder_time': morningReminderTime,
      'evening_reminder_time': eveningReminderTime,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copy with
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? timezone,
    bool? notificationEnabled,
    String? morningReminderTime,
    String? eveningReminderTime,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      timezone: timezone ?? this.timezone,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      morningReminderTime: morningReminderTime ?? this.morningReminderTime,
      eveningReminderTime: eveningReminderTime ?? this.eveningReminderTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get display name or email
  String get nameOrEmail => displayName ?? email.split('@').first;

  /// Get initials for avatar
  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return displayName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        avatarUrl,
        timezone,
        notificationEnabled,
        morningReminderTime,
        eveningReminderTime,
        createdAt,
      ];
}

/// Auth Token Response Model
class AuthTokenResponse extends Equatable {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;
  final UserModel user;

  const AuthTokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
    required this.user,
  });

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) {
    return AuthTokenResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_in'] as int,
      tokenType: json['token_type'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        expiresIn,
        tokenType,
        user,
      ];
}
