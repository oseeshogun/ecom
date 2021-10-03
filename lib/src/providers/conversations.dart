import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/src/models/conversation.dart';
import 'package:ecom/src/models/message.dart';
import 'package:email_validator/email_validator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final conversationsProvider =
    StreamProvider.family<List<Conversation>, String>((ref, uid) {
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream = FirebaseFirestore.instance
      .collection("conversations")
      .where("users", arrayContains: uid)
      .orderBy('timestamp')
      .snapshots();
  return stream.asyncMap<List<Conversation>>((QuerySnapshot<Map<String, dynamic>> query) {
    return query.docs.map<Conversation>((DocumentSnapshot<Map<String, dynamic>> doc) {
      return Conversation(
        users: List.castFrom(doc.data()?["users"]).map<String>((e) => e.toString()).toList(),
        id: doc.id,
      );
    }).toList();
  });
});


final chatMessages = StreamProvider.family<List<Message>, String>((ref, convID){
  return FirebaseFirestore.instance
      .collection("conversations")
      .doc(convID)
      .collection("messages")
      .snapshots().asyncMap<List<Message>>((query) {
        return query.docs.map<Message>((DocumentSnapshot<Map<String, dynamic>> doc) {
            return Message(
              id: doc.id,
              type: doc.data()?["type"] ?? "text",
              content: doc.data()?["content"] ?? "",
              createdAt: doc.data()?["created_at"] ?? 0,
              writer: doc.data()?["writer"] ?? "",
              receiver: doc.data()?["receiver"] ?? "",
            );
        }).toList();
      });
});