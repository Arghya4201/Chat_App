import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/screens/view_Profile_screen.dart';

import '../../main.dart';
class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});

   final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(width: mq.width* 0.6,
        height: mq.height *0.35,
      child: Stack(
        children: [
          //user profile pic
          Positioned(
            top: mq.height * 0.075,
            left: mq.width *0.1,
            child: ClipRRect(
              //user profile pic on  profile screen
              borderRadius: BorderRadius.circular(mq.height*0.25),
              child: CachedNetworkImage(
                  width: mq.width*0.5,
                  fit: BoxFit.cover,
                  imageUrl: user.image,
                  //placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person))
              ),
            ),
          ),
          //user name
          Positioned(
            left: mq.width*0.04,
            top: mq.height*0.02,
            width: mq.width* 0.55,
            child: Text(user.name,
            style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w500)),
          ),
          //info button
          Positioned(
              right: 8,
              top: 6,

              child: MaterialButton(
                  onPressed:(){
                    //CLOSE CURRENT SCREEN
                    Navigator.pop(context);
                    //MOVE TO USER VIEW_PROFILE SCREEN
                    Navigator.push(
                        context, MaterialPageRoute(
                        builder: (_) => ViewProfileScreen(user: user)));
                  },
                minWidth: 0,
                padding: const EdgeInsets.all(0),
                shape: CircleBorder(),
                  child:
                  Icon(Icons.info_outline,color: Colors.blue,size: 30),
              ))

        ],
      ),),
    );
  }
}
