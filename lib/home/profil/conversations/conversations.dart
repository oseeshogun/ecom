import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecom/home/chat/chat.dart';
import 'package:ecom/src/providers/conversations.dart';
import 'package:ecom/src/providers/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Conversations extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Mes conversations",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
          ),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: useProvider(conversationsProvider(uid)).when(
          data: (conversations) {
            if (conversations.length == 0)
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .7,
                    height: MediaQuery.of(context).size.width * .7,
                    child: SvgPicture.asset(
                        "assets/svgs/undraw_Empty_re_opql.svg"),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Aucune conversation en cours",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                    ),
                  ),
                ],
              );
            return Container(
              child: ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  final chatter = conversation.users
                      .firstWhere((element) => element != uid);
                  return ChatItem(
                    chatter: chatter,
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => Chat(chatter)));
                    },
                  );
                },
              ),
            );
          },
          loading: () => Container(),
          error: (err, st) {
            print(err);
            return Container(
                child: Text(
              "$st",
            ));
          },
        ),
      ),
    );
  }
}

class ChatItem extends HookWidget {
  final Function onPressed;
  final String chatter;

  ChatItem({required this.onPressed, required this.chatter});

  @override
  Widget build(BuildContext context) {
    return useProvider(userProvider(chatter)).when(
      loading: () => Container(),
      error: (err, st) => Container(),
      data: (author) {
        return Container(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 15,
          ),
          child: GestureDetector(
            onTap: () => onPressed(),
            child: Row(
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
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
