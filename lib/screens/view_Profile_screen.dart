

import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/helper/dialogs.dart';
import 'package:we_chat/helper/my_date_util.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/screens/auth/login_screen.dart';
//import 'package:we_chat/screens/auth/profile_screen.dart';

import '../api/apis.dart';
import '../main.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({super.key,required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

//view profile screen -- to view profile of user WHEN TAPPED ON HOME SCREEN
class _ViewProfileScreenState extends State<ViewProfileScreen> {

  //List<ChatUser> list=[];
  @override
  Widget build(BuildContext context) {
    //Gesture detector to hide keyboard when click anywhere
    return GestureDetector(
      //to hide keyboard
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(

          title: Text(widget.user.name)),

        floatingActionButton:
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Joined On ',
              style: TextStyle
                (color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 16), ),
            Text(MyDateUtil.getLastMesssageTime(context: context, time: widget.user.createdAt, showYear: true),
                style: const TextStyle(color: Colors.black54,fontSize: 15)),
          ],
        ),
        //body
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal:mq.width * 0.05),
          child: SingleChildScrollView(
            child: Column(children: [
              //for adding some space
              SizedBox(width: mq.width,height: mq.height*0.03),
              //user profile pic
              ClipRRect(
                //user profile pic on  profile screen
                borderRadius: BorderRadius.circular(mq.height*0.1),
                child: CachedNetworkImage(
                    width: mq.height*0.2,
                    height: mq.height*0.2,
                    fit: BoxFit.cover,
                    imageUrl: widget.user.image,
                    //placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person))
                ),
              ),

              SizedBox(height: mq.height*0.05),
              //user email label
              Text(widget.user.email,
                  style: const TextStyle(color: Colors.black87,fontSize: 16)),

              //for adding some space
              SizedBox(height: mq.height*0.02),

              //user about
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'About ',
                    style: TextStyle
                      (color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 16), ),
                  Text(widget.user.about,
                      style: const TextStyle(color: Colors.black54,fontSize: 15)),
                ],
              ),

            ],),
          ),
        )
      ),
    );
  }

}
