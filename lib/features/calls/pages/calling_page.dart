// ignore_for_file: avoid_print

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../models/calls_model.dart';
import 'call_timeout_page.dart';
import 'elapsed_time_loading.dart';

class CallingPage extends StatefulWidget {
  final String calleeName;
  final String? calleeAvatar;
  final String calleePhone;
  final String calleeUid;

  final String callerName;
  final String callerUid;
  final String callerPhone;
  final String? callerAvatar;

  const CallingPage({
    super.key,
    required this.calleeName,
    this.calleeAvatar,
    required this.calleePhone,
    required this.calleeUid,
    required this.callerName,
    required this.callerUid,
    required this.callerPhone,
    required this.callerAvatar,
  });

  @override
  State<CallingPage> createState() => _CallingPageState();
}

class _CallingPageState extends State<CallingPage> {
  late RtcEngine _engine;
  bool isMuted = false;
  bool isOnSpeaker = false;
  Stopwatch stopwatch = Stopwatch();
  Timer? timer;
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  // Nouvel état pour suivre si l'appel est en cours
  bool isCallAnswered = false;
  int callTimeoutSeconds = 45;

  @override
  void initState() {
    super.initState();
    initAgora();
    startTimer();
    // Définir l'état initial
    isMuted = false;
    isOnSpeaker = false;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
    _engine.leaveChannel();
    _engine.release();
  }

  Future<void> initAgora() async {
    var microphonePermission = await Permission.microphone.request();
    if (!microphonePermission.isGranted) {
      print('Permission du microphone refusée');
      return;
    }

    String? appId = "";

    // Crée le moteur Agora
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    // Enregistre les gestionnaires d'événements Agora
    _registerAgoraEventHandlers();

    // Commence la prévisualisation de la caméra
    await _engine.startPreview();

    // Obtient le token et rejoint le canal
    String? token = currentUserId!;
    await _engine.joinChannel(
      token: token,
      channelId: currentUserId!,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  void _registerAgoraEventHandlers() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print(
              "Joined channel ${connection.channelId} with uid ${connection.localUid}");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("User $remoteUid joined");
          setState(() {
            isCallAnswered = true;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          print("User $remoteUid has gone offline");
        },
      ),
    );
  }

  void startTimer() {
    stopwatch.reset();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => updateUI());
  }

  void updateUI() {
    setState(() {
      if (isCallAnswered) {
        // Si l'appel a été décroché, réinitialiser le timer
        stopwatch.reset();
      } else {
        if (stopwatch.elapsed.inSeconds >= callTimeoutSeconds) {
          // Si l'appel n'est pas décroché après 45 secondes, afficher le message Time Out
          handleCallTimeout();
        }
      }
    });
  }

  String get elapsedTime {
    return "${stopwatch.elapsed.inMinutes}:${(stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  void saveCallToHistory(CallHistoryModel call) async {
    final callHistoryCollection =
        FirebaseFirestore.instance.collection('callsHistory');
    await callHistoryCollection.add(call.toMap());
  }

  void handleCallTimeout() {
    _engine.leaveChannel();

    // Afficher la page Time Out
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const CallTimeoutPage(),
      ),
    );
  }

  void handleCallEnd() {
    _engine.leaveChannel();

    var call = CallHistoryModel(
      callerId: widget.callerUid,
      callerName: widget.callerName,
      callerPhone: widget.callerPhone,
      isOutgoing: true,
      duration: stopwatch.elapsed.inSeconds,
      receiverId: widget.calleeUid,
      receiverName: widget.calleeName,
      receiverPhone: widget.calleePhone,
      callTime: DateTime.now(),
      callerImageURL: widget.callerAvatar!,
      receiverImageURL: widget.calleeAvatar!,
    );

    saveCallToHistory(call);

    stopwatch.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coolors.backgroundDark,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: widget.calleeAvatar != null
                ? NetworkImage(widget.calleeAvatar!)
                : null,
            child: widget.calleeAvatar == null
                ? const Icon(Icons.person, color: Coolors.greyDark, size: 50)
                : null,
          ),
          const SizedBox(height: 15),
          Text(
            widget.calleeName,
            style: const TextStyle(fontSize: 24, color: Coolors.blueDark),
          ),
          const SizedBox(height: 15),
          // Temps écoulé ou texte "Calling"
          isCallAnswered
              ? ElapsedTimeWidget(elapsedTime: elapsedTime)
              : const ElapsedTimeLoadingWidget(),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(isMuted ? Icons.mic_off : Icons.mic,
                    color: isMuted ? Coolors.greyDark : Coolors.blueDark),
                onPressed: () {
                  setState(() {
                    isMuted = !isMuted;
                    _engine.muteLocalAudioStream(isMuted);
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  isOnSpeaker ? Icons.volume_off : Icons.volume_up,
                  color: isOnSpeaker ? Coolors.greenDark : Coolors.greyDark,
                ),
                onPressed: () {
                  setState(() {
                    isOnSpeaker = !isOnSpeaker;
                    _engine.setDefaultAudioRouteToSpeakerphone(isOnSpeaker);
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.call_end, color: context.theme.redColor),
                onPressed: () {
                  handleCallEnd();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

