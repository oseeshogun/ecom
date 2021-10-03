import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/src/providers/conversations.dart';
import 'package:ecom/src/providers/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:bubble/bubble.dart';

class Chat extends HookWidget {
  final String chatter;

  Chat(this.chatter);

  @override
  Widget build(BuildContext context) {
    final text = useState<String>("");
    final textController = useTextEditingController();
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: useProvider(userProvider(chatter)).when(
          data: (author) {
            return Row(
              children: [
                CachedNetworkImage(
                  imageUrl: author.image,
                  imageBuilder: (context, imageProvider) {
                    return CircleAvatar(
                      radius: 25,
                      backgroundImage: imageProvider,
                    );
                  },
                  placeholder: (context, _) {
                    return CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage("assets/images/avatar.jpg"),
                    );
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    author.name.isEmpty ? "Pas de nom" : author.name,
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => Container(),
          error: (err, st) => Container(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            Expanded(
              child: useProvider(conversationsProvider(uid)).when(
                data: (conversations) {
                  final bool exists = conversations
                      .any((element) => element.users.contains(chatter));
                  debugPrint("conversations data: $exists $conversations");
                  if (!exists) return Container();
                  final conversation = conversations
                      .firstWhere((element) => element.users.contains(chatter));
                  return MessagesContainer(conversation.id);
                },
                loading: () => Container(),
                error: (err, st) => Container(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: TextField(
                  onChanged: (value) {
                    text.value = value;
                  },
                  controller: textController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Ecrivez ici...",
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                    suffixIcon: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      child: text.value.trim().isEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.mic,
                                color: Colors.white,
                              ),
                              onPressed: () {},
                            )
                          : IconButton(
                              icon: Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                // send message
                                debugPrint("send message");

                                context
                                    .read(conversationsProvider(uid))
                                    .maybeWhen(
                                      data: (conversations) async {
                                        final bool exists = conversations.any(
                                            (element) => element.users
                                                .contains(chatter));
                                        debugPrint(
                                            "conversations data: $exists $conversations");
                                        if (exists) {
                                          final conversation =
                                              conversations.firstWhere(
                                                  (element) => element.users
                                                      .contains(chatter));
                                          FirebaseFirestore.instance
                                              .collection("conversations")
                                              .doc(conversation.id)
                                              .collection("messages")
                                              .add({
                                            "type": "text",
                                            "content": text.value,
                                            "createdAt": DateTime.now()
                                                .millisecondsSinceEpoch,
                                            "writer": uid,
                                            "receiver": chatter,
                                          });
                                          textController.text = "";
                                          text.value = "";
                                        } else {
                                          final doc = await FirebaseFirestore
                                              .instance
                                              .collection("conversations")
                                              .add({
                                            "users": [uid, chatter],
                                            "timestamp": DateTime.now()
                                                .millisecondsSinceEpoch,
                                          });
                                          FirebaseFirestore.instance
                                              .collection("conversations")
                                              .doc(doc.id)
                                              .collection("messages")
                                              .add({
                                            "type": "text",
                                            "content": text.value,
                                            "createdAt": DateTime.now()
                                                .millisecondsSinceEpoch,
                                            "writer": uid,
                                            "receiver": chatter,
                                          });
                                          textController.text = "";
                                          text.value = "";
                                        }
                                      },
                                      error: (err, st) {
                                        debugPrint(err.toString());
                                      },
                                      orElse: () {},
                                    );
                              },
                            ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class MessagesContainer extends HookWidget {
  final String conversationId;

  MessagesContainer(this.conversationId);
  @override
  Widget build(BuildContext context) {
    return useProvider(chatMessages(conversationId)).when(
        data: (messages) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages.reversed.toList()[index];
                final uid = FirebaseAuth.instance.currentUser!.uid;
                final bool isMine = uid == message.writer;
                return Container(
                  alignment:
                      isMine ? Alignment.centerRight : Alignment.centerLeft,
                  margin: const EdgeInsets.symmetric(
                    vertical: 3,
                  ),
                  child: Bubble(
                    color: isMine ? Colors.blueAccent : Colors.white,
                    child: Container(
                      padding: const EdgeInsets.only(
                        right: 20,
                      ),
                      child: Text(
                        message.content,
                        style: TextStyle(
                          fontSize: 18,
                          color: isMine ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    nip: isMine ? BubbleNip.rightTop : BubbleNip.leftTop,
                  ),
                );
              },
            ),
          );
        },
        loading: () => Container(),
        error: (err, st) => Container());
  }
}
