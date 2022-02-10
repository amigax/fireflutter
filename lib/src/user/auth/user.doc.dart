import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../../fireflutter.dart';

/// UserDoc
///
class UserDoc extends StatefulWidget {
  const UserDoc({required this.uid, required this.builder, Key? key}) : super(key: key);
  final String uid;
  final Widget Function(UserModel) builder;

  @override
  State<UserDoc> createState() => _UserDocState();
}

class _UserDocState extends State<UserDoc> with DatabaseMixin {
  UserModel? user;

  @override
  void initState() {
    super.initState();

    UserService.instance.getOtherUserDoc(widget.uid).then((v) => user = v);
    () async {
      try {
        final event = await userDoc(widget.uid).get();

        if (event.exists) {
          user = UserModel.fromJson(event.value, event.key!);
        } else {
          user = UserModel();
        }
        setState(() {});
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          // If user document does not exists, it comes here with the follow error;
          // [firebase_database/permission-denied] Client doesn't have permission to access the desired data.
          // debugPrint(e.toString());
          setState(() => user = UserModel());
        } else {
          rethrow;
        }
      } catch (e) {
        rethrow;
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return Center(child: CircularProgressIndicator.adaptive());
    return widget.builder(user!);
  }
}
