import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/my_date_util.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/models/message.dart';
import 'package:we_chat/widgets/dialogs/profile_dialog.dart';

import '../main.dart';
import '../screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  //last message info( if null --> no message)
  Message? _messsage;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width*0.02,vertical: 4),
      color:  Colors.blue.shade100,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: (){
          //for navigating to chat screen
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)));
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context,snapshot){

            final data=snapshot.data?.docs;
            final list=data
                ?.map((e) => Message.fromJson(e.data()))
                .toList()??[];
            if(list.isNotEmpty)
              _messsage=list[0];
              //print(list[0]);

            return ListTile(
              //user name
                title: Text(widget.user.name),
                //user profile pic
                //leading: const CircleAvatar(child: Icon(CupertinoIcons.person),),
                leading: InkWell(
                  onTap: (){
                    showDialog(context: context, builder: (_) => ProfileDialog(user: widget.user));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height*0.03),
                    child: CachedNetworkImage(
                        width: mq.height*0.055,
                        height: mq.height*0.055,
                        fit: BoxFit.fill,
                        imageUrl: widget.user.image,
                        errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person))
                    ),
                  ),
                ),

                //last message
                subtitle: Text(_messsage != null ?
                    _messsage!.type== Type.image ?
                        'image'
                        : _messsage!.msg
                    : widget.user.about, maxLines: 1,),

                //last message time
                trailing: _messsage==null
                    ? null //show nothing when no message sent
                    : _messsage!.read.isEmpty && _messsage!.fromId!=APIs.user.uid
                //show for unread message
                    ?Container(width: 15, height: 15,
                  decoration:BoxDecoration(color: Colors.greenAccent.shade400,
                      borderRadius:BorderRadius.circular(10) ) ,
                  //message sent time
                ) : Text(
                  MyDateUtil.getLastMesssageTime(
                      context: context, time: _messsage!.sent),
                  style: TextStyle(color:  Colors.black54),
                )

            );
          },)
      ),
    );
  }
}

  
