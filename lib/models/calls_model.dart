class CallHistoryModel {
  final String callerId;
  final String receiverId;
  final String callerPhone;
  final String callerName;
  final String receiverName;
  final String receiverPhone;
  final String receiverImageURL;
  final String callerImageURL;
  final DateTime callTime;
  final bool isOutgoing;
  final int duration; // en secondes

  CallHistoryModel({
    required this.callerId,
    required this.receiverId,
    required this.callerPhone,
    required this.callerName,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverImageURL,
    required this.callerImageURL,
    required this.callTime,
    required this.isOutgoing,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'receiverId': receiverId,
      'callerName': callerName,
      'receiverName': receiverName,
      'callerPhone': callerPhone,
      'receiverPhone': receiverPhone,
      'receiverImageURL': receiverImageURL,
      'callerImageURL': callerImageURL,
      'callTime': callTime.millisecondsSinceEpoch,
      'isOutgoing': isOutgoing,
      'duration': duration,
    };
  }

  factory CallHistoryModel.fromMap(Map<String, dynamic> map) {
    return CallHistoryModel(
      callerId: map['callerId'],
      receiverId: map['receiverId'],
      callerPhone: map['callerPhone'],
      callerName: map['callerName'],
      receiverName: map['receiverName'],
      receiverPhone: map['receiverPhone'],
      receiverImageURL: map['receiverImageURL'],
      callerImageURL: map['callerImageURL'],
      callTime: DateTime.fromMillisecondsSinceEpoch(map['callTime']),
      isOutgoing: map['isOutgoing'],
      duration: map['duration'],
    );
  }
}
