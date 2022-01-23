import 'package:fe/screens/chat/widgets/chat.rooms.empty.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:extended/extended.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRoomsBlockedScreen extends StatelessWidget {
  const ChatRoomsBlockedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Blocked Rooms'),
      ),
      body: AuthState(
        signedIn: (u) => Column(
          children: [
            Text('my uid: ' + FirebaseAuth.instance.currentUser!.uid),
            Row(children: [
              TextButton(
                  onPressed: () {
                    Get.toNamed('/chat-rooms-screen');
                  },
                  child: const Text('Room list')),
            ]),
            Expanded(
              child: ChatRoomsBlocked(
                itemBuilder: (String otherUid) => ChatRoomsBlockUser(otherUid),
              ),
            ),
          ],
        ),
        signedOut: () => ChatRoomsEmpty(),
      ),
    );
  }
}

class ChatRoomsBlockUser extends StatefulWidget {
  const ChatRoomsBlockUser(this.otherUid, {Key? key}) : super(key: key);

  final String otherUid;
  @override
  State<ChatRoomsBlockUser> createState() => _ChatRoomsBlockUserState();
}

class _ChatRoomsBlockUserState extends State<ChatRoomsBlockUser> {
  String get otherUid => widget.otherUid;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return UserDoc(
      uid: otherUid,
      builder: (UserModel user) {
        return GestureDetector(
          onTap: () =>
              Get.toNamed('/chat-room-screen', arguments: {'uid': otherUid}),
          child: Container(
            margin: const EdgeInsets.all(xs),
            padding: const EdgeInsets.all(xs),
            // decoration: BoxDecoration(
            //   borderRadius: const BorderRadius.all(Radius.circular(sm)),
            //   color: room.hasNewMessage ? Colors.blue[50] : Colors.transparent,
            // ),
            child: Row(
              children: [
                Avatar(url: user.photoUrl, size: 50),
                spaceXsm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${user.name} ',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      spaceXxs,
                      // Text(
                      //   room.text,
                      //   maxLines: 1,
                      //   overflow: TextOverflow.ellipsis,
                      //   style: bodyText4,
                      // ),
                    ],
                  ),
                ),
                spaceXsm,
                Popup(
                  icon: const Icon(Icons.menu),
                  options: {
                    'unblock': PopupOption(
                      icon: const Icon(Icons.block),
                      label: 'Unblock',
                    ),
                    'close': PopupOption(
                      icon: const Icon(Icons.cancel),
                      label: 'Close',
                    ),
                  },
                  initialValue: '',
                  onSelected: (v) async {
                    if (v == 'unblock') {
                      ChatService.instance.unblockUser(otherUid);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}