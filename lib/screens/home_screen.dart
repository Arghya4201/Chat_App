
import 'dart:core';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/screens/Profile_screen.dart';
import '../api/apis.dart';
import '../main.dart';
import '../widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list=[];
  //to store search items,
  //final cause only use once and underscore to make it private as it wont be used anywhere else except this screen
  final List<ChatUser> _searchList=[];
  //to store search status
  bool _isSearching=false;
  @override
  void initState(){
    super.initState();
    APIs.getSelfInfo();



    //for updating user active status according to lifecycle events
    //resume --active or online
    //pause -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message){
      log('Message: $message');

      if(APIs.auth.currentUser !=null){
        if(message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if(message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      //remove keyboard on tap anywhere on screen
      onTap: () => FocusScope.of(context).unfocus(),
      //when back button is clicked on phone this willpopscope is triggered
      child: WillPopScope(
        //if search is on back button pressed then close search,
        //else close the current screen
        onWillPop: () {
          if( _isSearching){
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          }else{
            return Future.value(true);
          }
        } ,
        child: Scaffold(
          appBar: AppBar(
            leading: Icon(CupertinoIcons.home),
            //to display search bar on top after click on search button
            title: _isSearching
                ?TextField(
              decoration:const InputDecoration(border: InputBorder.none, hintText: 'Name, Email, ...'),
              autofocus: true,//cursor comes on tap
              style: TextStyle(fontSize: 17, letterSpacing: 0.5),
              //when text changes update search list,
              // val is the user to be searched
              onChanged:(val){
                //search logic
                _searchList.clear();

                for (var i in _list){
                  if(i.name.toLowerCase().contains(val.toLowerCase()) ||
                      i.email.toLowerCase().contains(val.toLowerCase())){
                    _searchList.add(i);
                  }
                  setState(() {
                    _searchList;
                  });
                }
              },
            ): Text('We Chat'),
            actions: [
              //search user button,
              //if is searching true then show icon
              IconButton(onPressed: (){
                setState(() {
                  //whatever the current icon is change state on tapping to its reverse
                  _isSearching = !_isSearching;
                });
              }, icon: Icon(_isSearching
                  ? CupertinoIcons.clear_circled_solid
                  : Icons.search)),
              //more features button
              IconButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(user: APIs.me)));
              }, icon: const  Icon(Icons.more_vert))
            ],
          ),
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FloatingActionButton(
                  onPressed: () {
                    _addChatUserDialog();
                  },child: Icon(Icons.add_comment_rounded),),
              ),

          body: StreamBuilder(
              stream: APIs.getMyUsersId(),
              //get id of only known users
              builder: (context,snapshot){
                switch(snapshot.connectionState){
                //if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: CircularProgressIndicator());

                //if some or all data is loaded then show it
                  case ConnectionState.active:
                  case ConnectionState.done:
              return StreamBuilder(
                stream: APIs.getAllUsers(snapshot.data?.docs
                    .map((e) => e.id)
                    .toList()??
                    []),
                //get only those users whose id is provided
                builder: (context,snapshot){
                  switch(snapshot.connectionState){
                  //if data is loading
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      //return const Center(child: CircularProgressIndicator());

                  //if some or all data is loaded then show it
                    case ConnectionState.active:
                    case ConnectionState.done:
                    //the question mark marks store data only if its not null
                      final data=snapshot.data?.docs;
                      _list=data?.map((e) => ChatUser.fromJson(e.data())).toList()??[];
                      if(_list.isNotEmpty){
                        return ListView.builder(
                            itemCount: _isSearching ? _searchList.length : _list.length,
                            padding: EdgeInsets.only(top:  mq.height*0.01),
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context,index){
                              return ChatUserCard(user:
                              //if searching then show that user on search card
                              _isSearching?_searchList[index] : _list[index]);
                              //return Text('Name: ${list[index]}');
                            });
                      }
                      else{
                        return const Center(
                          child: Text('No connections Found!!',
                            style: TextStyle(fontSize: 20),),
                        );
                      }
                  }
                },
              );
            }
            
            //return const Center(child: CircularProgressIndicator(strokeWidth: 2,));
          }),
        ),
      ),
    );
  }

  void _addChatUserDialog(){
    String email= '';
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          contentPadding: const EdgeInsets.only(left: 24,right: 24,top: 20,bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          //title
          title: Row(children:const [
            Icon(Icons.person,
              color: Colors.blue,
              size: 28,),
            Text(' Add User by Email')],),

          //content
          content: TextFormField(
            onChanged: (value)=> email=value,
            maxLines: null,
            decoration: InputDecoration(
                hintText: 'Email Id',
                prefixIcon: Icon(Icons.email,color: Colors.blue,),
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

              APIs.addChatUser(email);
            },
              child: const Text('Add',
                style: TextStyle(color:  Colors.blue, fontSize: 16),
              ),)
          ],
        ));
  }
}
