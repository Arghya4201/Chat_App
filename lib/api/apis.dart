import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'package:we_chat/models/message.dart';

import '../models/chat_user.dart';
class APIs{
  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  //for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;
  //To store self info

  //To return current user
  static User get user=> auth.currentUser!;

  //for accessing firebase messaging (push notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  //for getting firebase message token
  static Future<void> getFirebaseMessagingToken() async{

    await fMessaging.requestPermission();
    await fMessaging.getAPNSToken().then((t) {
      if(t!=null){
        me.pushToken=t;
        log('Push Token: $t');
      }
    } );
  }

  //for sending push notification
  static Future<void> sendPushNotification(
      ChatUser chatUser,String msg) async{
     try{
       final body=
       {
         "to":chatUser.pushToken,
         "notification":{
           "title":chatUser.name,
           "body":msg
         }
       };
       var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
           headers: {
             HttpHeaders.contentTypeHeader: 'application/json',
             HttpHeaders.authorizationHeader:
             'key=AAAAgNZo004:APA91bFmyOSYEFJuoXEPt5zP96iWNnC23NziJTE-434mZ2tssNMwRAH7cwxDd3Ih6YkDH4wh3xPLW5cP0VnbV6BQaF1zISJwhqIvCiy8mIvpspp5ZlaZqoK3jry2JcztFGF_YOSo1x1W'
           },
           body: jsonEncode(body));
       log('Response status: ${res.statusCode}');
       log('Response body: ${res.body}');
     } catch(e){
       log('\nsendPushNotificationE: $e');
     }
  }

  static late ChatUser me;
  //to check if user already exists
  static Future<bool> userExists()async{
    return ( await firestore
        .collection('users')
        .doc(user.uid)
        .get())
        .exists;
  }

  //for adding chat user for our conversation
  static Future<bool> addChatUser(String email)async{
     final data=await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

      log('data: ${data.docs}');
     //check email is not invalid or self email
     if(data.docs.isNotEmpty && data.docs.first.id !=user.uid){
       //user exists
       log('data: ${data.docs.first.data()}');
       firestore.
       collection('users').
       doc(user.uid).
       collection('my_users').
       doc(data.docs.first.id).set({});
       return true;
     }
     else
       return false;
  }

  //for getting current user info
  static Future<void> getSelfInfo()async {
     await firestore
         .collection('users')
         .doc(user.uid).get()
         .then((user) async {
           //If user exists store their info else create a new user
           if(user.exists){
             me=ChatUser.fromJson(user.data()!);
             await getFirebaseMessagingToken();
             //for setting user status to active
             APIs.updateActiveStatus(true);
            log('My Data: ${user.data()}');
           }else{
              await createUser().then((value)=> getSelfInfo());
           }
     });
  }
  //to create a new user
  static Future<void> createUser()async{
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser= ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey I am using we chat",
      image: user.photoURL.toString(),
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: ''
    );
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  //TO GET ALL USERS FROM FIRESTORE DATABASE
  static Stream<QuerySnapshot<Map<String,dynamic>>> getAllUsers(List<String> userIds){
    //log('\nUserId: $userIds');
    return firestore
        .collection('users')
        .where('id', whereIn: userIds)
        //.where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //for getting id of known users form firestore database
  static Stream<QuerySnapshot<Map<String,dynamic>>> getMyUsersId(){
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  //for adding a user when first message is sent
  static Future<void> sendFirstMessage(ChatUser chatUser, String msg,Type type)async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid).set({})
        .then((value) => sendMessage(chatUser, msg, type));
  }

  //to update user info into firebase after change from profile screen
  static Future<void> updateUserInfo()async {
    await firestore
        .collection('users')
        .doc(user.uid)
    //update func takes json file as input so to put the keys of name and about so that they get changed in firebase
        .update({
      'name': me.name,
      'about': me.about,
        });
  }
  //update profile picture of user
  static Future<void> updateProfilePicture(File file) async{
    //ext stores extension like jpeg,png,etc
    final ext = file.path.split('.').last;
    log('Extension $ext');
    //store file ref with path
    //make the path a folder of name profile pictures and the name of the image would be equal to user id to prevent duplicate images
    final ref=storage.ref().child('profile_pictures/${user.uid}.$ext');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'))
    .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred/1000}kb');
    });
    //updates me.image with the new images url link in firestore data base
    me.image= await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'image': me.image,
    });

  }

  //for getting user specific info
  static Stream<QuerySnapshot<Map<String,dynamic>>> getUserInfo
      (ChatUser chatUser) {
         return firestore
        .collection('users')
        .where('id',isEqualTo: chatUser.id)
        .snapshots();
  }


   //update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async{
    firestore
        .collection('users')
        .doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
        });
  }
  //************************chat screen related apis *********************

  //ACCEPTING THE SENDERS ID COMPARES WITH SOME HASHCODE
  //useful for getting conversation id
  static getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

//for getting all messages of specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String,dynamic>>> getAllMessages(ChatUser user){
    return firestore
    //API TO FETCH MESSAGE
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent',descending: true)
        .snapshots();
  }
  //chats(collection) --> conversation_id(doc) --> messages (collection) --> messages (doc)
  //for sending message
static Future<void> sendMessage(ChatUser chatUser, String msg,Type type) async{
    //message sending time (also used as id)
    final time= DateTime.now().millisecondsSinceEpoch.toString();
    //message to send
    final Message message=Message(
        msg: msg,
        toId: chatUser.id,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);
    final ref=
        firestore.collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) => sendPushNotification(chatUser, type==Type.Text ? msg : 'Image'));
  }

  //update read status of message FRO BLUE TICK
  //WILL CALL THIS FUNC ONLY FOR BLUE MSG THAT IS WHEN MESSAGE COMES FROM FRONT
  static Future<void> updateMessageReadStatus(Message message) async{
    //USING FROM ID AS WE WANT READ UPDATE FOR THE MESSAGE SENT FROM THE PERSON IN FRONT IS BEING READ BY US OR NOT
    //UPDATING THE KEY READ
    firestore.collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //get only last message of specific chat TO SHOW BELOW THE USER IF NO CHAT DONE THEN SHOW USER ABOUT
  static Stream<QuerySnapshot<Map<String ,dynamic>>> getLastMessage(ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent',descending: true)
        .limit(1)
        .snapshots();
  }
  //SEND PHOTO
  //send chat image
static Future<void> sendChatImage(ChatUser chatUser, File file) async {
  final ext = file.path.split('.').last;

  //store file ref with path
  //make the path a folder of name profile pictures and the name of the image would be equal to user id to prevent duplicate images
  final ref=storage.ref().child('images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
  await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'))
      .then((p0) {
    log('Data Transferred: ${p0.bytesTransferred/1000}kb');
  });

  //updates me.image with the new images url link in firestore data base
  final imageUrl= await ref.getDownloadURL();
  await sendMessage(chatUser, imageUrl, Type.image);

}
//delete message
  static Future<void> deleteMessage(Message message) async{
    await firestore.collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();
      if(message.type==Type.image)
      await storage.refFromURL(message.msg).delete();
  }

  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async{
    await firestore.collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});

  }

}