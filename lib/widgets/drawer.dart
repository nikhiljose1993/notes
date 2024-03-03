import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/screens/change_password.dart';

final _firebase = FirebaseAuth.instance;

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  bool _isPasswordHidden = true;
  final TextEditingController _passwordController = TextEditingController();
  String _errMessage = '';

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nameOfuser = _firebase.currentUser!.displayName;

    Future deleteUserAccount() async {
      String? email = _firebase.currentUser!.email;
      String password = _passwordController.text;
      final user = _firebase.currentUser!;

      CollectionReference userNotesReference =
          FirebaseFirestore.instance.collection(user.uid);

      QuerySnapshot userNotesSnapshot = await userNotesReference.get();
      // Deleting each documents
      for (var note in userNotesSnapshot.docs) {
        await note.reference.delete();
      }
      // Deleting the collection itself
      await userNotesReference.parent?.delete();

      try {
        await user.delete();

        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } on FirebaseAuthException catch (err) {
        if (err.code == "requires-recent-login") {
          // Signing in again for a recent sign-in to delete
          await _firebase.signInWithEmailAndPassword(
              email: email!, password: password);
          deleteUserAccount();
        } else {
          _errMessage = err.code;
        }
      }
    }

    void showDeleteDialoge() async {
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                backgroundColor: theme.colorScheme.errorContainer,
                title: const Text('Re-enter your password'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _passwordController,
                      enableSuggestions: false,
                      autocorrect: false,
                      obscureText: _isPasswordHidden,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: theme.colorScheme.background,
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordHidden
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _isPasswordHidden = !_isPasswordHidden;
                            });
                          },
                          iconSize: 20,
                          padding: const EdgeInsets.only(right: 10),
                          color: theme.colorScheme.secondary.withAlpha(180),
                        ),
                        suffixIconConstraints:
                            const BoxConstraints(maxHeight: 30, maxWidth: 40),
                      ),
                    ),
                    if (_errMessage.isNotEmpty) Text(_errMessage),
                  ],
                ),
                titleTextStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.background,
                    ),
                    onPressed: () {
                      // deleteUserAccount();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      foregroundColor: theme.colorScheme.onError,
                      backgroundColor: theme.colorScheme.error,
                    ),
                    onPressed: deleteUserAccount,
                    child: const Text('Delete'),
                  )
                ],
              );
            },
          );
        },
      );
    }

    return Drawer(
      backgroundColor: theme.colorScheme.secondary,
      child: ListView(
        children: [
          SizedBox(
            height: 45,
            child: DrawerHeader(
              margin: const EdgeInsets.symmetric(vertical: 0),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              // decoration: BoxDecoration(color: theme.colorScheme.primary),
              child: Text(
                'Hello $nameOfuser',
                style: TextStyle(
                    color: theme.colorScheme.background, fontSize: 24),
              ),
            ),
          ),
          // ListTile(
          //   iconColor: theme.colorScheme.background,
          //   textColor: theme.colorScheme.background,
          //   leading: const Icon(Icons.change_circle_outlined),
          //   title: const Text('Change password'),
          //   onTap: () {
          //     Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => const ChangePassword(),
          //         ));
          //   },
          // ),
          ListTile(
            iconColor: theme.colorScheme.background,
            textColor: theme.colorScheme.background,
            leading: const Icon(Icons.delete_outline),
            title: const Text('Delete account'),
            onTap: showDeleteDialoge,
          ),
          ListTile(
            iconColor: theme.colorScheme.background,
            textColor: theme.colorScheme.background,
            leading: const Icon(Icons.logout_outlined),
            title: const Text('SignOut'),
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
