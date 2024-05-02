// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lumina/languages/app_translations.dart';

class CallHistoryPage extends StatefulWidget {
  const CallHistoryPage({super.key});

  @override
  State<CallHistoryPage> createState() => _CallHistoryPageState();
}

class _CallHistoryPageState extends State<CallHistoryPage> {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> callHistory = [];

  String formatCallTime(int timestamp) {
    DateTime callDateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateTime now = DateTime.now();

    if (callDateTime.year == now.year &&
        callDateTime.month == now.month &&
        callDateTime.day == now.day) {
      // Si l'appel date d'aujourd'hui, afficher l'heure
      String formattedTime = DateFormat('HH:mm').format(callDateTime);
      return formattedTime;
    } else {
      // Si l'appel date d'un jour antérieur, afficher la date sans l'heure
      String formattedDate = DateFormat('yyyy-MM-dd').format(callDateTime);
      return formattedDate;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCallHistory();
  }

  Future<void> fetchCallHistory() async {
    if (currentUserId == null) return;

    try {
      final callerHistoryDocs = await FirebaseFirestore.instance
          .collection('callsHistory')
          .where('callerId', isEqualTo: currentUserId)
          .get();

      final receiverHistoryDocs = await FirebaseFirestore.instance
          .collection('callsHistory')
          .where('receiverId', isEqualTo: currentUserId)
          .get();

      setState(() {
        callHistory = [
          ...receiverHistoryDocs.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }),
          ...callerHistoryDocs.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }),
        ];
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('errorFetchingHistory'),
              style: const TextStyle(color: Coolors.blueDark),
            ),
          ),
        );
      }
    }
  }

  String getCallType(Map<String, dynamic> callData) {
    if (callData['callerId'] == currentUserId) {
      return AppLocalizations.of(context).translate('outgoingCall');
    } else if (callData['receiverId'] == currentUserId &&
        callData['duration'] == 0) {
      return AppLocalizations.of(context).translate('missedCall');
    } else if (callData['receiverId'] == currentUserId &&
        callData['duration'] != 0) {
      return AppLocalizations.of(context).translate('receivedCall');
    } else {
      return ''; // Gérer le cas par défaut si nécessaire
    }
  }

  Icon getCallIcon(Map<String, dynamic> callData) {
    if (callData['callerId'] == currentUserId) {
      return const Icon(Icons.call_made,
          color: Coolors.greenDark); // Icône pour appel sortant
    } else if (callData['receiverId'] == currentUserId &&
        callData['duration'] == 0) {
      return Icon(Icons.call_missed,
          color: context.theme.redColor); // Icône pour appel manqué
    } else if (callData['receiverId'] == currentUserId &&
        callData['duration'] != 0) {
      return const Icon(Icons.call_received,
          color: Coolors.blueDark); // Icône pour appel reçu
    } else {
      return const Icon(Icons.error,
          color: Colors.red); // Gérer le cas par défaut si nécessaire
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: callHistory.isEmpty
          ? Center(
              child: Text(
              AppLocalizations.of(context).translate('noCallForNow'),
            ))
          : ListView.builder(
              itemCount: callHistory.length,
              itemBuilder: (context, index) {
                var call = callHistory[index];
                return GestureDetector(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(
                          AppLocalizations.of(context)
                              .translate('deleteCallConfirmation'),
                        ),
                        actions: [
                          TextButton(
                            child: Text(
                              AppLocalizations.of(context).translate('cancel'),
                            ),
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                          ),
                          TextButton(
                            child: Text(
                              AppLocalizations.of(context).translate('delete'),
                              style: TextStyle(
                                color: context.theme.redColor,
                              ),
                            ),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('callsHistory')
                                  .doc(call['id'])
                                  .delete();

                              fetchCallHistory();

                              // ignore: use_build_context_synchronously
                              Navigator.of(ctx).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: ListTile(
                    leading: (call['callerId'] == currentUserId
                                    ? call['receiverImageURL']
                                    : call['callerImageURL']) !=
                                null &&
                            (call['callerId'] == currentUserId
                                    ? call['receiverImageURL']
                                    : call['callerImageURL'])
                                .isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(
                              call['callerId'] == currentUserId
                                  ? call['receiverImageURL']
                                  : call['callerImageURL'],
                            ),
                          )
                        : const CircleAvatar(
                            // ignore: sort_child_properties_last
                            child: Icon(Icons.person, color: Colors.white),
                            backgroundColor: Coolors.greyDark,
                          ),
                    title: Text(
                      call['callerId'] == currentUserId
                          ? call['receiverName']
                          : call['callerName'],
                    ),
                    subtitle: Text(
                      "${getCallType(call)} - ${formatCallTime(call['callTime'])}",
                      style: const TextStyle(color: Coolors.greyDark),
                    ),
                    trailing: getCallIcon(call),
                    onTap: () {},
                  ),
                );
              },
            ),
    );
  }
}
