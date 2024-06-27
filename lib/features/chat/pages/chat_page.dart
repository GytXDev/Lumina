// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumina/colors/extension/extension_theme.dart';
import 'package:lumina/features/calls/pages/calling_page.dart';
import 'package:lumina/languages/app_translations.dart';
import 'package:lumina/main.dart';
import 'package:shimmer/shimmer.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../colors/helpers/last_seen_message.dart';
import '../../../models/user_models.dart';
//import '../../../routes/routes_pages.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/widgets/custom_icon_button.dart';
import '../controllers/chat_controller.dart';
import '../widgets/chat_text.dart';
import '../widgets/info_card.dart';
import '../widgets/message_card.dart';
import '../widgets/show_date_card.dart';

final pageStorageBucket = PageStorageBucket();
UserModel? currentUser;
String? currentUserid = FirebaseAuth.instance.currentUser?.uid;

class ChatPage extends ConsumerWidget {
  ChatPage({super.key, required this.user});

  final UserModel user;
  final ScrollController scrollerControntroller = ScrollController();

  Future<UserModel?> _getUserDoc() async {
    if (currentUserid == null) return null;
    final usersCollection = FirebaseFirestore.instance.collection('users');
    final currentUserDoc = await usersCollection.doc(currentUserid!).get();
    return UserModel.fromMap(currentUserDoc.data() as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatControllerProvider).markMessagesAsSeen(user.uid);
    });

    // Écouter les changements de thème
    final themeMode = ref.watch(themeModeProvider);
    // Déterminer l'image de fond en fonction du thème
    final backgroundImage = themeMode == ThemeMode.dark
        ? 'assets/images/black.jpg'
        : 'assets/images/white.jpg';

    return Scaffold(
      appBar: AppBar(
        elevation: 4.0, // Adds shadow under the AppBar for depth
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(20),
          child: const Row(
            children: [
              SizedBox(
                width: 10.0,
              ),
              Icon(Icons.arrow_back_ios),
            ],
          ),
        ),
        title: InkWell(
          onTap: () {
            /*Navigator.pushNamed(
              context,
              Routes.profile,
              arguments: user,
            );*/
          },
          child: Row(
            children: [
              Hero(
                tag: 'profile',
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                    image: user.profileImageUrl.isNotEmpty
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(
                                user.profileImageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: user.profileImageUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.grey, size: 32)
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    //récuperer la présence de connexion de l'utilisateur
                    StreamBuilder(
                      stream: ref
                          .read(authControllerProvider)
                          .getUserPresenceStatus(uid: user.uid),
                      builder: (_, snapshot) {
                        if (snapshot.connectionState !=
                            ConnectionState.active) {
                          return Text(
                            AppLocalizations.of(context)
                                .translate('connectingText'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          );
                        }
                        final singleUserModel = snapshot.data!;

                        final lastMessage =
                            lastSeenMessage(singleUserModel.lastSeen, context);

                        return Text(
                          singleUserModel.active
                              ? AppLocalizations.of(context)
                                  .translate('onlineStatus')
                              : AppLocalizations.of(context)
                                  .translateWithVariables('onlineAgoText',
                                      {'duration': lastMessage}),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),

        actions: [
          /*CustomIconButton(
            onTap: () {},
            icon: Icons.video_call,
            iconColor: Colors.white,
          ),*/
          CustomIconButton(
            onTap: () async {
              final currentUser = await _getUserDoc();
              if (currentUser != null && user.username.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CallingPage(
                      calleeName: user.username,
                      calleeAvatar: user.profileImageUrl,
                      calleePhone: user.phoneNumber,
                      calleeUid: user.uid,
                      callerName: currentUser.username,
                      callerUid: currentUser.uid,
                      callerPhone: currentUser.phoneNumber,
                      callerAvatar: currentUser.profileImageUrl,
                    ),
                  ),
                );
              }
            },
            icon: Icons.call,
            iconColor: Colors.white,
          ),

          /*CustomIconButton(
            onTap: () {},
            icon: Icons.more_vert,
            iconColor: Colors.white,
          ),*/
        ],
      ),
      body: Stack(
        children: [
          Image(
            height: double.maxFinite,
            width: double.maxFinite,
            image: AssetImage(backgroundImage),
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: StreamBuilder(
              stream: ref
                  .watch(chatControllerProvider)
                  .getAllOneToOneMessage(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.active) {
                  return ListView.builder(
                    itemCount: 15,
                    itemBuilder: (__, index) {
                      final random = Random().nextInt(14);
                      return Container(
                        alignment: random.isEven
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        margin: EdgeInsets.only(
                          top: 5,
                          bottom: 5,
                          left: random.isEven ? 150 : 15,
                          right: random.isEven ? 15 : 150,
                        ),
                        child: ClipPath(
                          clipper: UpperNipMessageClipperTwo(
                            random.isEven
                                ? MessageType.send
                                : MessageType.receive,
                            nipWidth: 8,
                            nipHeight: 10,
                            bubbleRadius: 12,
                          ),
                          child: Shimmer.fromColors(
                            baseColor: random.isEven
                                ? context.theme.greyColor!.withOpacity(.3)
                                : context.theme.greyColor!.withOpacity(.2),
                            highlightColor: random.isEven
                                ? context.theme.greyColor!.withOpacity(.4)
                                : context.theme.greyColor!.withOpacity(.3),
                            child: Container(
                              height: 40,
                              width: 170 +
                                  double.parse(
                                    (random * 2).toString(),
                                  ),
                              color: context.theme.redColor,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return PageStorage(
                  bucket: pageStorageBucket,
                  child: ListView.builder(
                    key: const PageStorageKey('chat_page_list'),
                    itemCount: snapshot.data?.length ?? 0,
                    controller: scrollerControntroller,
                    padding: const EdgeInsets.only(bottom: 25),
                    itemBuilder: (BuildContext context, int index) {
                      final message = snapshot.data![index];
                      final isSender = message.senderId ==
                          FirebaseAuth.instance.currentUser!.uid;

                      final haveNip = (index == 0) ||
                          (index == snapshot.data!.length - 1 &&
                              message.senderId !=
                                  snapshot.data![index - 1].senderId) ||
                          (message.senderId !=
                                  snapshot.data![index - 1].senderId &&
                              message.senderId ==
                                  snapshot.data![index + 1].senderId) ||
                          (message.senderId !=
                                  snapshot.data![index - 1].senderId &&
                              message.senderId !=
                                  snapshot.data![index + 1].senderId);

                      final isShowDateCard = (index == 0) ||
                          ((index == snapshot.data!.length - 1) &&
                              (message.timeSent.day >
                                  snapshot.data![index - 1].timeSent.day)) ||
                          (message.timeSent.day >
                                  snapshot.data![index - 1].timeSent.day &&
                              message.timeSent.day <=
                                  snapshot.data![index + 1].timeSent.day);

                      return Column(
                        children: [
                          if (index == 0) const InfoCard(),
                          if (isShowDateCard)
                            ShowDateCard(date: message.timeSent),
                          MessageCard(
                            isSender: isSender,
                            haveNip: haveNip,
                            message: message,
                            refContainer: ref,
                            receiverId: user.uid,
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          GestureDetector(
            onTap: () {
              scrollerControntroller;
            },
            child: Container(
              alignment: const Alignment(0, 1),
              child: ChatTextField(
                receiverId: user.uid,
                scrollController: scrollerControntroller,
              ),
            ),
          )
        ],
      ),
    );
  }
}
