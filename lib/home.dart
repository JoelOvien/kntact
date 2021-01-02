import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Iterable<Contact> _contacts;
  // Iterable<Contact> contacts = await ContactsService.getContacts();

  String displayName, givenName, middleName, prefix, suffix, familyName;

// Company
  String company, jobTitle;

// Email addresses
  Iterable<Item> emails = [];

// Phone numbers
  Iterable<Item> phones = [];

// Post addresses
  Iterable<PostalAddress> postalAddresses = [];
  @override
  void initState() {
    // _getPermission();
    fetchKntcts();
    super.initState();
    // refreshContacts();
  }
  _write(String text) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/lib/hello.txt');
    await file.writeAsString(text);
  }
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }
  // Future<File> writeCounter(int counter) async {
  //   final file = await _localFile;
  //
  //   // Write the file.
  //   return file.writeAsString('$counter');
  // }
  Future<File> writeCounter(int counter) async {
    final file = await  File('helooo.dart');

    // Write the file
    return file.writeAsString('$counter');
  }
// }

  Future<void> fetchKntcts() async {
    final PermissionStatus permissionStatus = await _getPermission();
    if (permissionStatus == PermissionStatus.granted) {
      // _write("ar");
      writeCounter(32124525134);
      getContacts();
      Iterable<Contact> contacts = await ContactsService.getContacts();
      List<Contact> contactsList = contacts.toList();
      for (int i = 0; i < 100; i++) {
        print(contactsList[i].phones.first.value.toString());
      }      // contacts.forEach((contact){
      //   print(contact.displayName+" = "+contact.phones.toString());
      // });
    }
  }

  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted && permission != PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ?? PermissionStatus.undetermined;
    } else {
      return permission;
    }
  }

  Future<void> getContacts() async {
    //Make sure we already have permissions for contacts when we get to this
    //page, so we can just retrieve it
    final Iterable<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (Text('Contacts')),
      ),
      body: _contacts != null
          //Build a list view of all contacts, displaying their avatar and
          // display name
          ? ListView.builder(
              itemCount: _contacts?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                Contact contact = _contacts?.elementAt(index);
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 18),
                  leading: (contact.avatar != null && contact.avatar.isNotEmpty)
                      ? CircleAvatar(
                          backgroundImage: MemoryImage(contact.avatar),
                        )
                      : CircleAvatar(
                          child: Text(contact.initials()),
                          backgroundColor: Theme.of(context).accentColor,
                        ),
                  title: Text(contact.displayName ?? ''),
                  // //This can be further expanded to showing contacts detail
                  // // onPressed().
                  // trailing: Row(
                  //   mainAxisSize: MainAxisSize.min,
                  //   children: <Widget>[
                  //     PhoneButton(phoneNumbers: contact.phones),
                  //     SmsButton(phoneNumbers: contact.phones)
                  //   ],
                  // ),
                );
              },
            )
          : RaisedButton(
              onPressed: () async {
                final PermissionStatus permissionStatus = await _getPermission();
                if (permissionStatus == PermissionStatus.granted) {
                  print("hrer");
                } else {
                  //If permissions have been denied show standard cupertino alert dialog
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => CupertinoAlertDialog(
                            title: Text('Permissions error'),
                            content: Text('Please enable contacts access '
                                'permission in system settings'),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                child: Text('OK'),
                                onPressed: () => Navigator.of(context).pop(),
                              )
                            ],
                          ));
                }
              },
              child: Container(child: Text('See Contacts')),
            ),
    );
  }
}

class HelperFunctions {
  static String getValidPhoneNumber(Iterable phoneNumbers) {
    if (phoneNumbers != null && phoneNumbers.toList().isNotEmpty) {
      List phoneNumbersList = phoneNumbers.toList();
      // This takes first available number. Can change this to display all
      // numbers first and let the user choose which one use.
      return phoneNumbersList[0].value;
    }
    return null;
  }

  // Used for error messages
  static void standardAlertDialog(BuildContext context, String title, String content) {
    showDialog<Dialog>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: content.isNotEmpty ? Text(content) : null,
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}

class MessagingDialog extends StatefulWidget {
  MessagingDialog({Key key, this.messageCallback, this.recipient}) : super(key: key);

  final Function messageCallback;
  final String recipient;

  @override
  _MessagingDialogState createState() => _MessagingDialogState();
}

class _MessagingDialogState extends State<MessagingDialog> {
  TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Enter Message"),
      content: TextFormField(controller: controller),
      actions: <Widget>[
        FlatButton(
          child: Text("OK"),
          onPressed: () {
            widget.messageCallback(context, controller.text, widget.recipient);
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
