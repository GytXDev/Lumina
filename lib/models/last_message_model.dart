class LastMessageModel {
  final String username;
  final String profileImageUrl;
  final String contactId;
  final String senderId; 
  final DateTime timeSent;
  final String lastMessage;
  final int unreadCount;
  final String lastMessageId;

  LastMessageModel({
    required this.username,
    required this.profileImageUrl,
    required this.contactId,
    required this.senderId,
    required this.timeSent,
    required this.lastMessage,
    required this.lastMessageId,
    this.unreadCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'profileImageUrl': profileImageUrl,
      'contactId': contactId,
      'senderId': senderId, 
      'timeSent': timeSent.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
      'lastMessageId': lastMessageId,
    };
  }

  factory LastMessageModel.fromMap(Map<String, dynamic> map) {
    return LastMessageModel(
      username: map['username'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      contactId: map['contactId'] ?? '',
      senderId: map['senderId'] ?? '', 
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageId: map['lastMessageId'] ?? '',
      unreadCount: map['unreadCount'] ?? 0,
    );
  }
}
