import 'dart:developer';
//import 'dart:html';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/helper/my_date_util.dart';
import 'package:we_chat/screens/view_Profile_screen.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../widgets/message_card.dart';
import 'dart:io';
class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //for storing all messages
  List<Message> _list=[];
  //for handling message text changes
  final _textController = TextEditingController();
  //_showEmoji --> to show or hide value of that respective emoji
  //_isUploading --> for checking if image uploaded or not?
  bool _showEmoji=false, _isUploading=false;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          //if emojis are shown and back button is pressed then hide emojis
          //or else simply close current screen on back button click
          onWillPop: (){
            if(_showEmoji){
              setState(() => _showEmoji = !_showEmoji);
              //RETURNING FALSE KEEPS IT IN CURRENT SCREEN
              return Future.value(false);
            }else{
              //TRUE MEANS IT OUT OF CURRENT SCHEME
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              //REMOVE DEFAULT BACK BUTTON FROM APPBAR
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            backgroundColor:const Color.fromARGB(255, 234, 248, 255),
            //body
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context,snapshot){
                      switch(snapshot.connectionState){
                      //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();

                      //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                        //the question mark marks store data only if its not null
                        final data=snapshot.data?.docs;
                           _list=data?.map((e) => Message.fromJson(e.data())).toList()??[];

                          if(_list.isNotEmpty){
                            return ListView.builder(
                               reverse: true,
                                itemCount:
                                 _list.length,
                                padding: EdgeInsets.only(top:  mq.height*0.01),
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context,index){
                                  return MessageCard(message: _list[index]);
                                });
                          }
                          else{
                            return const Center(
                              child: Text('Say Hi! 👋',
                                style: TextStyle(fontSize: 20),),
                            );
                          }
                      }
                    },
                  ),
                ),

                //progress indicator for showing image uploading
                if(_isUploading)
                const Align(
                  alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                        child: CircularProgressIndicator(strokeWidth: 2,))),
                _chatInput(),

                //show emojis on keyboard emoji button and vice versa
                if(_showEmoji)
                SizedBox(
                  height: mq.height * 0.35,
                  child: EmojiPicker(
                  textEditingController: _textController,
                  config: Config(
                    bgColor: const Color.fromARGB(255, 234, 248, 255),
                  columns: 8,
                  //emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      emojiSizeMax: 32 * (Theme.of(context).platform == TargetPlatform.iOS ? 1.30 : 1.0)

      ),
      ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _appBar() {
    //INKWELL SO THAT THERE IS SOME EFFECT ON CLICK
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => ViewProfileScreen(user: widget.user)));
      },
      child: StreamBuilder(
          stream: APIs.getUserInfo(widget.user),
          builder: (context,snapshot){
            final data=snapshot.data?.docs;
            final list=data
                ?.map((e) => ChatUser.fromJson(e.data()))
                .toList()??[];


         return Row(
           children: [
             //back button
             IconButton(
                 onPressed: (){Navigator.pop(context);},
                 icon: Icon(Icons.arrow_back,
                   color: Colors.black54,)),

             ClipRRect(
               //user profile picture
               borderRadius: BorderRadius.circular(mq.height*0.3),
               child: CachedNetworkImage(
                   width: mq.height*0.05,
                   height: mq.height*0.05,
                   fit: BoxFit.fill,
                   imageUrl: list.isNotEmpty? list[0].image : widget.user.image,
                   //placeholder: (context, url) => CircularProgressIndicator(),
                   errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person))
               ),
             ),
             //add some space
             const SizedBox(width: 10),
             //TO DISPLAY USER DETAILS BESIDE PROFILE PIC ON APP BAR
             Column(
               mainAxisAlignment: MainAxisAlignment.center,
               crossAxisAlignment:  CrossAxisAlignment.start,
               children: [
                 //user name
                 Text(list.isNotEmpty? list[0].name : widget.user.name,
                     style:const TextStyle(
                         fontSize: 16,
                         color: Colors.black87,
                         fontWeight: FontWeight.w500)),

                 SizedBox(height: 2),
                 //last seen time
                 Text(
                     list.isNotEmpty
                         ?list[0].isOnline
                         ?'Online'
                     :MyDateUtil.getLastActiveTime(context: context, lastActive: list[0].lastActive)
                     : MyDateUtil.getLastActiveTime(context: context, lastActive: widget.user.lastActive),
                     style:const TextStyle(
                       fontSize: 13,
                       color: Colors.black54,))
               ],
             )
           ],
         );

      })  );
  }
  //bottom chat inout field
  Widget _chatInput(){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: mq.height *0.01, horizontal: mq.width*0.025),
      child: Row(
        children: [
          //Input field and buttons
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Row(children:
                  //emoji button
                [IconButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() => _showEmoji= !_showEmoji);
                  },
                  icon: Icon(Icons.emoji_emotions,color: Colors.blueAccent, size: 25,)),
                //EXPANDED WIDGET COVERS THE ENTIRE SPACE LEFT IN PARENT i.e BETWEEN EMOJI AND GALLERY BUTTON
                Expanded(
                      child: TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onTap: (){
                          if(_showEmoji)
                          setState(() => _showEmoji= !_showEmoji);
                        },
                        decoration:const InputDecoration(
                        hintText: 'Type Something...',
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        border: InputBorder.none),
                   )),

                //pick image from gallery button
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        //picking multiple images
                        final List<XFile> images =
                        await picker.pickMultiImage(imageQuality: 70);
                        //uploading and sending image one by one
                        for (var i in images){
                          log('Image path: ${i.path}');
                          setState(() => _isUploading= true);
                          await APIs.sendChatImage(widget.user ,File(i.path));
                          setState(() => _isUploading= false);;
                        }

                      },
                      icon: Icon(Icons.image,color: Colors.blueAccent, size: 26,)),
                  //pick image from camera button
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        //pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera,imageQuality: 70);

                        if (image != null) {
                          log('Image path: ${image.path}');
                          setState(() => _isUploading= true);
                          await APIs.sendChatImage(widget.user ,File(image.path));
                          setState(() => _isUploading= false);
                        }

                      },
                      icon: Icon(Icons.camera_alt_rounded,color: Colors.blueAccent,size: 26,)),

                  SizedBox(width: mq.width*0.02,)

                ],
              ),
            ),
          ),
          //send message button
          MaterialButton(
              onPressed: (){
                if(_textController.text.isNotEmpty){
                  if(_list.isEmpty){
                    //on first message add the user to my user collection
                      APIs.sendFirstMessage(widget.user, _textController.text, Type.Text);
                  }
                  else{
                    //simply send messsage
                  APIs.sendMessage(widget.user, _textController.text, Type.Text);}
                  _textController.text= '';
                }
              },
              minWidth: 0,
              padding: EdgeInsets.only(top: 10,bottom: 10,right: 5,left: 10),
              shape:  const CircleBorder(),
              color:  Colors.green,
              child: Icon(Icons.send,color: Colors.white,size: 28,))
        ],
      ),
    );
  }
}
