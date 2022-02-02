import 'package:extended/extended.dart';
import 'package:fe/service/app.controller.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();
    print('initState;');
    UserService.instance.updateAdminStatus().then((value) => setState(() => {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('didChangeDependencies;');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Screen'),
      ),
      body: PagePadding(
        children: [
          UserService.instance.user.isAdmin
              ? const Text('You are an admin')
              : const Text('You are not admin'),
          ElevatedButton(
            onPressed: AppController.of.openCategory,
            child: const Text('Category Management'),
          ),
        ],
      ),
    );
  }
}