import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;
 
class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final messageTextController = TextEditingController(); 
  final _auth = FirebaseAuth.instance;
  

  String messageText;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        // print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                      });
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

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('messages').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                  backgroundColor: Colors.lightBlueAccent),
            );
          }
          final messages = snapshot.data.docs.reversed;
          List<MessageBubble> messageBubbles = [];
          for (var message in messages) {
            final messageText = message.data()['text'];
            final messageSender = message.data()['sender'];
            final currentUser = loggedInUser.email;
            final messageBubble =
                MessageBubble(sender: messageSender, text: messageText,
                isMe: currentUser == messageSender,
                );
            messageBubbles.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              children: messageBubbles,
            ),
          );
        });
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.isMe});

  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          Material(
            borderRadius: isMe ? BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)) : BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30), topRight: Radius.circular(30)),
            elevation: 10,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                text,
                style: TextStyle(color: isMe ? Colors.white : Colors.black54, fontSize: 15.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ListView.builder(
//                   itemCount:
//                       snapshot.data.length == null ? 0 : snapshot.data.length,
//                   itemBuilder: (_, index) {
//                     return ListTile(
//                       leading: Icon(Icons.person),
//                       title: Text(snapshot.data[index].data["name"] ??
//                           "There is an error somewhere"),
//                       subtitle: Text(snapshot.data[index].data["ordered at"]),
//                       trailing: IconButton(
//                         tooltip: 'Delete',
//                         icon: Icon(Icons.delete),
//                         onPressed: () async {
//                           return showDialog<void>(
//                               context: context,
//                               barrierDismissible: false, //user must tap button
//                               builder: (BuildContext context) {
//                                 return AlertDialog(
//                                   title: Text('Delete?'),
//                                   content: Text("Delete " +
//                                       snapshot.data[index].data["name"] +
//                                       "'s order?"),
//                                   actions: [
//                                     FlatButton(
//                                       child: Text('No'),
//                                       onPressed: () {
//                                         Navigator.of(context).pop();
//                                       },
//                                     ),
//                                     FlatButton(
//                                       child: Text('Yes'),
//                                       onPressed: () async {
//                                         await firestore.runTransaction(
//                                             (Transaction myTransaction) async {
//                                           await myTransaction.delete(
//                                               snapshot.data[index].reference);
//                                         });
//                                         Navigator.of(context).pop();
//                                         Flushbar(
//                                           title: "Deleted!",
//                                           message: "The order has been deleted",
//                                           duration: Duration(seconds: 3),
//                                         ).show(context);
//                                         setState(() {
//                                           Navigator.of(context).pushNamedAndRemoveUntil('/screen2', (Route<dynamic> route) => false);
//                                         });
//                                       },
//                                     )
//                                   ],
//                                 );
//                               });
//                         },
//                       ),
//                       onTap: () => navigateToDetail(snapshot.data[index]),
//                     );
//                   });