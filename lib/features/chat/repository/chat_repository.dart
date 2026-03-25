import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/common/repositories/common_firebase_storage_repository.dart';
import 'package:northern_trader/common/utils/utils.dart';
import 'package:northern_trader/common/enums/message_enum.dart';
import 'package:northern_trader/models/chat_contact.dart';
import 'package:northern_trader/models/message.dart';
import 'package:northern_trader/models/user_model.dart';
import 'package:uuid/uuid.dart';

final chatRepositoryProvider = Provider(
  (ref) => ChatRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChatRepository({
    required this.firestore,
    required this.auth,
  });

  String? getCurrentUserId() {
    return auth.currentUser?.uid;
  }

  Future<String?> getOwnerId() async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .where('isOwner', isEqualTo: true)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<List<ChatContact>> getChatContacts() async* {
    String? currentUserId = getCurrentUserId();
    if (currentUserId == null || currentUserId.isEmpty) {
      yield [];
      return;
    }
    
    final currentUserDoc = await firestore.collection('users').doc(currentUserId).get();
    final isOwner = currentUserDoc.data()?['isOwner'] ?? false;
    
    if (isOwner) {
      yield* firestore
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .snapshots()
          .map((event) {
        List<ChatContact> contacts = [];
        for (var document in event.docs) {
          contacts.add(ChatContact.fromMap({
            ...document.data(),
            'contactId': document.id,
          }));
        }
        return contacts;
      });
    } else {
      final ownerId = await getOwnerId();
      if (ownerId == null || ownerId.isEmpty) {
        yield [];
        return;
      }
      
      yield* firestore
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .doc(ownerId)
          .snapshots()
          .map((doc) {
        if (doc.exists && doc.data() != null) {
          return [ChatContact.fromMap({
            ...doc.data()!,
            'contactId': ownerId,
          })];
        }
        return <ChatContact>[];
      });
    }
  }

  Stream<List<Message>> getChatStream(String recieverUserId) {
    String? currentUserId = getCurrentUserId();
    if (currentUserId == null || currentUserId.isEmpty || recieverUserId.isEmpty) {
      return Stream.value([]);
    }
    
    return firestore
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      return messages;
    });
  }

  void _saveDataToContactsSubcollection(
    UserModel senderUserData,
    UserModel? recieverUserData,
    String text,
    DateTime timeSent,
    String recieverUserId,
  ) async {
    String? currentUserId = getCurrentUserId();
    if (currentUserId == null || recieverUserData == null) return;

    var recieverChatContact = ChatContact(
      name: senderUserData.name,
      profilePic: senderUserData.profilePic,
      contactId: senderUserData.uid,
      timeSent: timeSent,
      lastMessage: text,
    );
    await firestore
        .collection('users')
        .doc(recieverUserId)
        .collection('chats')
        .doc(currentUserId)
        .set(
          recieverChatContact.toMap(),
        );
    
    var senderChatContact = ChatContact(
      name: recieverUserData.name,
      profilePic: recieverUserData.profilePic,
      contactId: recieverUserData.uid,
      timeSent: timeSent,
      lastMessage: text,
    );
    await firestore
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .doc(recieverUserId)
        .set(
          senderChatContact.toMap(),
        );
  }

  void _saveMessageToMessageSubcollection({
    required String recieverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required MessageEnum messageType,
    required String senderUsername,
    required String? recieverUserName,
  }) async {
    String? currentUserId = getCurrentUserId();
    if (currentUserId == null) return;
    
    final message = Message(
      senderId: currentUserId,
      recieverid: recieverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
      repliedMessage: '',
      repliedTo: '',
      repliedMessageType: MessageEnum.text,
    );
    
    await firestore
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .doc(messageId)
        .set(
          message.toMap(),
        );
    
    await firestore
        .collection('users')
        .doc(recieverUserId)
        .collection('chats')
        .doc(currentUserId)
        .collection('messages')
        .doc(messageId)
        .set(
          message.toMap(),
        );
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String recieverUserId,
    required UserModel senderUser,
  }) async {
    try {
      String? currentUserId = getCurrentUserId();
      if (currentUserId == null) {
        showSnackBar(context: context, content: 'User not authenticated');
        return;
      }
      
      var timeSent = DateTime.now();
      UserModel? recieverUserData;

      var userDataMap =
          await firestore.collection('users').doc(recieverUserId).get();
      if (!userDataMap.exists || userDataMap.data() == null) {
        showSnackBar(context: context, content: 'Получатель не найден');
        return;
      }
      recieverUserData = UserModel.fromMap(userDataMap.data()!);

      var messageId = const Uuid().v1();

      _saveDataToContactsSubcollection(
        senderUser,
        recieverUserData,
        text,
        timeSent,
        recieverUserId,
      );

      _saveMessageToMessageSubcollection(
        recieverUserId: recieverUserId,
        text: text,
        timeSent: timeSent,
        messageType: MessageEnum.text,
        messageId: messageId,
        username: senderUser.name,
        recieverUserName: recieverUserData?.name,
        senderUsername: senderUser.name,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendFileMessage({
    required BuildContext context,
    required dynamic file, 
    required String recieverUserId,
    required UserModel senderUserData,
    required ProviderRef ref,
    required MessageEnum messageEnum,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String imageUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
            'chat/${messageEnum.type}/${senderUserData.uid}/$recieverUserId/$messageId',
            file,
          );

      UserModel? recieverUserData;
      var userDataMap =
          await firestore.collection('users').doc(recieverUserId).get();
      recieverUserData = UserModel.fromMap(userDataMap.data()!);

      String contactMsg;

      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 Photo';
          break;
        case MessageEnum.video:
          contactMsg = '📸 Video';
          break;
        case MessageEnum.audio:
          contactMsg = '🎵 Audio';
          break;
        case MessageEnum.gif:
          contactMsg = 'GIF';
          break;
        case MessageEnum.file:
          contactMsg = '📎 File';
          break;
        default:
          contactMsg = '📎 File';
      }
      _saveDataToContactsSubcollection(
        senderUserData,
        recieverUserData,
        contactMsg,
        timeSent,
        recieverUserId,
      );

      _saveMessageToMessageSubcollection(
        recieverUserId: recieverUserId,
        text: imageUrl,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUserData.name,
        messageType: messageEnum,
        recieverUserName: recieverUserData?.name,
        senderUsername: senderUserData.name,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void setChatMessageSeen(
    BuildContext context,
    String recieverUserId,
    String messageId,
  ) async {
    try {
      String? currentUserId = getCurrentUserId();
      if (currentUserId == null) return;

      // Обновляем в коллекции получателя (текущего пользователя)
      await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});
      
      // Обновляем в коллекции отправителя (чтобы он видел, что сообщение прочитано)
      await firestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(currentUserId)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}

