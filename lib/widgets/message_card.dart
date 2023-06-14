import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:we_chat/helper/dialogs.dart';
import 'package:we_chat/helper/my_date_util.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    //IF FROM ID OF SENDER AND TO ID OF RECEIVER MATCHES THE SHOW GREEN BOZ i.e WE HAVE SENT THE MESSAGE
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: (){
         _showBottomSheet(isMe);
      },
        child: isMe ? _greenMessage()
        : _blueMessage());

  }
  //sender or another user message
  Widget _blueMessage() {

    //update last read message if sender and receiver are different
    if(widget.message.read.isEmpty){
      APIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      //  ADD SPACE BETWEEN MSG BOX AND TIME SHOWN
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message content
        //WRAP WITH FLEXIBLE TO HANDLE LONG MES THAT WOULD GO OUT SCREEN
        //EXPANDED TAKES UP ALL SPACE WHEREAS FLEXIBLE TAKES ONLY WHAT IS NEEDED
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type==Type.image
                ?mq.width*0.03
                : mq.width*0.04),
              margin: EdgeInsets.symmetric(
                horizontal: mq.width* 0.04, vertical: mq.height* 0.01),
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 221, 245, 255),
                  border: Border.all(color: Colors.lightBlue),
                  //making borders curved
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30))),
              child:
              widget.message.type== Type.Text?
              //show text
              Text(
                widget.message.msg,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ) :

              //show image
              ClipRRect(
                //user profile picture
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl: widget.message.msg,
                  placeholder: (context, url) =>
                    const  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.image, size: 70),
                ),
              ),
          ),
        ),
        //SHOWING TIME OF TEXT
        //message time
        Padding(
          padding: EdgeInsets.only(right: mq.width* 0.04),
          child:  Text(MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
            style:const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),

      ],
    );
  }

//Our or user message
  Widget _greenMessage(){
    return Row(
      //  ADD SPACE BETWEEN MSG BOX AND TIME SHOWN
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //WRAP WITH FLEXIBLE TO HANDLE LONG MES THAT WOULD GO OUT SCREEN
        //EXPANDED TAKES UP ALL SPACE WHEREAS FLEXIBLE TAKES ONLY WHAT IS NEEDED
        //message content

        //SHOWING TIME OF TEXT
        //message time
        Row(
          children: [
            //for adding some space
            SizedBox(width: mq.width* 0.04,),

            //ONLY SHOW DOUBLE TICK IF READ NOT EMPTY
            //double tick blue icon for message read
            if(widget.message.read.isNotEmpty)
            const Icon(
              Icons.done_all_rounded,
              color: Colors.blue,
            size: 20,),
            //for adding some space
            SizedBox(width: 2,),
            //sent time
            Text(MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
              style:const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type==Type.image
                ? mq.width*0.03
                : mq.width*0.04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width* 0.04, vertical: mq.height* 0.01),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 218, 255, 176),
                border: Border.all(color: Colors.lightGreen),
                //making borders curved
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: widget.message.type== Type.Text?
            //show text
            Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ) :

            //show image
            ClipRRect(
              //user profile picture
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: widget.message.msg,
                placeholder: (context, url) =>
                  const  Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) =>
                const Icon(Icons.image, size: 70),
              ),
            ),
          ),
        ),

      ],
    );
  }

  //bottom sheet for modifying message details
  void _showBottomSheet(bool isMe){
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            //show size as per the content
            shrinkWrap: true,

            children: [

              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height*0.015, horizontal: mq.width*0.4),
                decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),

              widget.message.type== Type.Text?
              //copy option
              _OptionItem(icon:const Icon(Icons.copy_all_rounded,
                color: Colors.blue,size: 26,),
                  name: 'Copy Text',
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: widget.message.msg));
                    //for hiding bottom sheet after text copied
                    Navigator.pop(context);
                    Dialogs.showSnackbar(context, 'Text Copied!');
              })
                  :
                  //save option
                  _OptionItem(icon:const Icon(Icons.download_rounded,
                  color: Colors.blue,size: 26,),
                  name: 'Save Image',
                  onTap: () async {}),

              //separator or divider
              if(isMe)
              Divider(
                color: Colors.black54,
                endIndent: mq.width* 0.04,
                indent: mq.height*0.04,
              ),

              //edit option
              if(widget.message.type==Type.Text && isMe)
              _OptionItem(icon:const Icon(Icons.edit,
                color: Colors.blue,size: 26,),
                  name: 'Edit Message',
                  onTap: (){
                    //for hiding bottom sheet after text copied
                    Navigator.pop(context);
                    _showMessageUpdateDialog();
                  }),

              //delete option
              if(isMe)
              _OptionItem(icon:const Icon(Icons.delete_forever,
                color: Colors.red,size: 26,),
                  name: 'Delete Message',
                  onTap: () async {
                   await APIs.deleteMessage(widget.message).then((value) {
                     //for hiding bottom sheet after text copied
                     Navigator.pop(context);
                   });

                  }),

              //separator or divider
              Divider(
                color: Colors.black54,
                endIndent: mq.width* 0.04,
                indent: mq.width*0.04,
              ),

              //sent time
              _OptionItem(icon:const Icon(Icons.remove_red_eye,
                color: Colors.blue,),
                  name: 'Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                  onTap: (){}),

              //read time
              _OptionItem(icon:const Icon(Icons.remove_red_eye,
                color: Colors.green,),
                  name: widget.message.read.isEmpty
                      ? 'Read At: Not seen yet'
                      : 'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                  onTap: (){}),

            ],
          );
        });
    
  }
  //dialog for updating message content
  void _showMessageUpdateDialog(){
    String updatedMsg= widget.message.msg;
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          contentPadding: const EdgeInsets.only(left: 24,right: 24,top: 20,bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      //title
      title: Row(children:const [
        Icon(Icons.message,
          color: Colors.blue,
          size: 28,),
        Text(' Update Message')],),

      //content
      content: TextFormField(
        initialValue: updatedMsg,
        onChanged: (value)=> updatedMsg=value,
        maxLines: null,
        decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
      ),

      //actions
      actions: [
        MaterialButton(onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Cancel',
        style: TextStyle(color:  Colors.blue, fontSize: 16),
        ),),

        MaterialButton(onPressed: () {
          Navigator.pop(context);
          APIs.updateMessage(widget.message, updatedMsg);
        },
          child: const Text('Update',
            style: TextStyle(color:  Colors.blue, fontSize: 16),
          ),)
      ],
    ));
  }

}



//custom options card (for copy,edit,delete, etc)
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem({required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.only(
            left: mq.width* 0.05,
            top: mq.height*0.015,
            bottom: mq.height *0.015),
          child: Row(children: [icon, Flexible(child: Text('    $name',
            style: const TextStyle(fontSize: 15,color: Colors.black54,letterSpacing: 0.5),))]),
        ));
  }
}


