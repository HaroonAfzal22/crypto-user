import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptocurrency_flutter/constants.dart';
import 'package:cryptocurrency_flutter/main.dart';
import 'package:cryptocurrency_flutter/model/user_model.dart';
import 'package:flutter/material.dart';

import 'dart:developer' as devtools show log;

import 'package:nb_utils/nb_utils.dart';

class TypeChatScreen extends StatefulWidget {


  @override
  _TypeChatScreenState createState() => _TypeChatScreenState();
}

class _TypeChatScreenState extends State<TypeChatScreen> {
  UserModel userModel = UserModel();
  final messageController = TextEditingController();
  List? messageWidgetList;
  final _fireStore = FirebaseFirestore.instance;

  var messageText;


  @override
  void initState() {
    // getCurrentUser();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,

        title: Center(
          child: Text('⚡️Chat'),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder(
              stream: _fireStore
                  .collection('user')
                  .doc(appStore.uid.validate())
                  .collection('UsersChat')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return Expanded(
                    child: ListView(
                      padding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      reverse: true,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: snapshot.data!.docs.reversed
                          .map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;

                        return MessageBubble(
                          isME:appStore.email.validate() == data['sender'],
                          userEmail: data['sender'],
                          userText: data['text'],
                        );
                      }).toList(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                return Text("Loading");
              },
            ),
            Container(
              decoration: kMessagertContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration.copyWith(
                          hintText: 'Type you\'r message here...'),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      devtools.log(
                          'message: $messageText user:${appStore.uid.validate()}');
                      try {
                        messageController.clear();

                        stream:
                        _fireStore
                            .collection('user')
                            .doc(appStore.uid.validate())
                            .collection('UsersChat')
                            .add({
                          'sender':appStore.email.validate(),
                          'text': messageText,
                        });
                      } on Exception catch (e) {
                        devtools.log('Exception from fireStore $e');
                        // TODO
                      }
                      //Implement send functionality.
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDialogWidget extends StatelessWidget {
  CustomDialogWidget(
      {required this.widget, required this.nameKey, required this.nameValue});
  String nameKey;
  String nameValue;
  final TypeChatScreen widget;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text('$nameKey:'),
        SizedBox(
          width: 20,
        ),
        Text(nameValue)
      ],
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {required this.userEmail, required this.userText, required this.isME});
  String userText;
  String userEmail;
  bool isME;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
        isME ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(userEmail,
              style: TextStyle(color: Colors.black54, fontSize: 12)),
          Material(
            borderRadius: isME
                ? BorderRadius.only(
              bottomRight: Radius.circular(30),
              bottomLeft: Radius.circular(30),
              topLeft: Radius.circular(30),
            )
                : BorderRadius.only(
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                topRight: Radius.circular(30)),
            elevation: 5,
            color: isME ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                userText,
                style: TextStyle(
                    color: isME ? Colors.white : Colors.black54, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
