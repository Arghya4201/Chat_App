

import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/helper/dialogs.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/screens/auth/login_screen.dart';
//import 'package:we_chat/screens/auth/profile_screen.dart';

import '../api/apis.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key,required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //To store the form for about section validation
  final _formKey= GlobalKey<FormState>();
  String? _image;
  //List<ChatUser> list=[];
  @override
  Widget build(BuildContext context) {
    //Gesture detector to hide keyboard when click anywhere
    return GestureDetector(
      //to hide keyboard
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(

          title: const Text('Profile Screen'),
        ),  //floating action button to ass new user
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton.extended(
                backgroundColor: Colors.redAccent,
                onPressed: () async {
                  //TO show progress bar
                  Dialogs.showProgressBar(context);

                  await APIs.updateActiveStatus(false);

                  //sign out from apps
                  await APIs.auth.signOut().then((value) async {
                    await GoogleSignIn().signOut().then((value) {
                      //For hiding progress dialog
                      Navigator.pop(context);
                      APIs.auth = FirebaseAuth.instance;
                      //To remove home screen from backstack
                      Navigator.pop(context);
                      //Replacing home screen with login screen
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) =>LoginScreen()));
                    });
                  });

                },icon:const Icon(Icons.logout),
                  label:const Text('Logout')),
            ),
        
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal:mq.width * 0.05),
            child: SingleChildScrollView(
              child: Column(children: [
                //for adding some space
                SizedBox(width: mq.width,height: mq.height*0.03),
                //user profile pic
                Stack(
                  children: [
                    _image !=null
                        ?
                        //local image
                      ClipRRect(
                      //user profile pic on  profile screen
                      borderRadius:
                      BorderRadius.circular(mq.height*0.1),
                      child: Image.file(File(_image!),
                      width: mq.height*0.2,
                      height: mq.height*0.2,
                      fit: BoxFit.cover,),
                     )
                        :
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
                    //Edit image button
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: MaterialButton(
                         elevation: 1,
                          onPressed: (){
                           //bottom sheet on pressing edit image button
                           _showBottomSheet();
                          },
                          shape: CircleBorder(),
                              color :Colors.white,
                        child: Icon(Icons.edit,color: Colors.blue),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: mq.height*0.05),
                Text(widget.user.email,
                    style: const TextStyle(color: Colors.black54,fontSize: 16)),

                SizedBox(width: mq.width,height: mq.height*0.03),
                //NAME INPUT FIELD
                TextFormField(
                 initialValue: widget.user.name,
                 //when i change and save the name then it should change and saved in name attribute of the user
                 onSaved: (val)=> APIs.me.name=val?? '',
                 //cannot be null or empty
                  validator: (val)=>val!= null && val.isNotEmpty
                      ? null
                      : 'Required Field',
                 decoration: InputDecoration(
                     prefixIcon: const Icon(Icons.person, color:Colors.blue,),
                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                     hintText: 'eg: Jane Doe',
                     label: Text('Name')),
                ),

                SizedBox(height: mq.height*0.02),
                //SHOW ABOUT FIELD
                TextFormField(
                  initialValue: widget.user.about,
                  onSaved: (val)=> APIs.me.about=val?? '',
                  //cannot be null or empty
                  validator: (val)=>val!= null && val.isNotEmpty
                      ? null
                      : 'Required Field',
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.info_outline, color: Colors.blue,),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      hintText: 'eg: Feeling Lazy',
                      label:const Text('About')),
                ),

                SizedBox(height: mq.height*0.05),
                //UPDATE PROFILE BUTTON
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      shape:const StadiumBorder(),
                      minimumSize: Size(mq.width*0.5,mq.height*0.06)),
                  onPressed: (){
                    if(_formKey.currentState!.validate()){
                      //if not null then save the value
                      _formKey.currentState!.save();
                      //call validator func to store updated info in firebase
                      APIs.updateUserInfo().then((value){
                        //show a snap bar after update
                        Dialogs.showSnackbar((context),'Profile Updated Successfully!');
                      });

                    }
                  },
                  icon: Icon(Icons.edit,size: 28,),
                  label: const Text('UPDATE', style:TextStyle(fontSize: 16) ,),)

              ],),
            ),
          ),
        )
      ),
    );
  }

  //bottom sheet to show profile picture to user
  void _showBottomSheet(){
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))),
        builder: (_) {
      return ListView(
        //show size as per the content
        shrinkWrap: true,
        padding: EdgeInsets.only(top: mq.height*0.03, bottom: mq.height*0.05),
        children: [
          //pick profile picture label
          const Text('Pick Profile Picture',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
          //for adding some space in between
          SizedBox(height: mq.height*0.02,),
          //buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //pick from gallery button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  fixedSize: Size(mq.width*0.3, mq.height*0.15),),
                  onPressed: () async {
                    //ALL CODES BELOW COPIED FROM IMAGE PICKER TO STORE IMAGE PERMANENTLY
                    final ImagePicker picker = ImagePicker();
                    // Pick an image.
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

                    if(image != null){
                      log('Image path: ${image.path} --MimeType: ${image.mimeType}');
                      setState(() {
                        _image=image.path;
                      });
                      APIs.updateProfilePicture(File(_image!));
                      //for hiding bottom sheet AFTER IMAGE PICKED
                      Navigator.pop(context);
                    }
                  },
                  child: Image.asset('images/add_image.png')),
              //Take picture from camera button
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize: Size(mq.width*0.3, mq.height*0.15),),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    // Pick an image.
                    final XFile? image = await picker.pickImage(source: ImageSource.camera);

                    if(image != null){
                      log('Image path: ${image.path}');
                      setState(() {
                        _image=image.path;
                      });
                      APIs.updateProfilePicture(File(_image!));
                      //for hiding bottom sheet AFTER IMAGE PICKED
                      Navigator.pop(context);
                    }
                  },
                  child: Image.asset('images/camera.png')),
            ],
          )
        ],
      );
    });
  }
}
