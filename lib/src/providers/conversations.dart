import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/src/models/conversation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rxdart/rxdart.dart' as rx;

final conversationsProvider = StreamProvider.family<List<Conversation>, String>((ref, uid){
  final Stream<QuerySnapshot> stream1 =  FirebaseFirestore.instance
      .collection("conversations")
      .where("user1", isEqualTo: uid)
      .orderBy('timestamp')
      .snapshots();
  final Stream<QuerySnapshot> stream2 =  FirebaseFirestore.instance
      .collection("conversations")
      .where("user2", isEqualTo: uid)
      .orderBy('timestamp')
      .snapshots();
    return rx.CombineLatestStream.combine2(stream1, stream2, (QuerySnapshot a, QuerySnapshot b){
      return [
        ...a.docs,
        ...b.docs,
      ];
    }).asyncMap<List<Conversation>>((docs) {
        return docs.map<Conversation>((doc) {
          return Conversation();
        }).toList();
      });
});