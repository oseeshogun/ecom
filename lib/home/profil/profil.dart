import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/home/profil/products/products.dart';
import 'package:ecom/src/providers/user.dart';
import 'package:ecom/src/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

import 'conversations/conversations.dart';

class Profil extends HookWidget {
  final ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final loadingImage = useState<bool>(false);

    final appBar = AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: useProvider(userProvider(uid)).when(
        data: (user) => Text(
          "Bonjour ${user.name}",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
          ),
        ),
        loading: () => Text(
          "Bonjour",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
          ),
        ),
        error: (err, st) => Text(
          "Bonjour",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
          ),
        ),
      ),
      actions: [
        useProvider(userProvider(uid)).when(
          data: (user) {
            return InkWell(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => Profil()));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Stack(
                  fit: StackFit.loose,
                  children: [
                    CachedNetworkImage(
                      imageUrl: user.image,
                      imageBuilder: (context, imageProvider) {
                        return CircleAvatar(
                          radius: 20,
                          backgroundImage: imageProvider,
                        );
                      },
                      placeholder: (context, _) {
                        return CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              AssetImage("assets/images/avatar.jpg"),
                        );
                      },
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.transparent,
                      child: Visibility(
                        visible: !loadingImage.value,
                        replacement: SizedBox(
                          height: 10,
                          width: 10,
                          child: CircularProgressIndicator(),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.camera_alt,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                            loadingImage.value = true;
                            final source = await getPicker(context);
                            if (source == null) {
                              loadingImage.value = false;
                              return;
                            }
                            final XFile? image = await picker.pickImage(
                              source: source,
                              imageQuality: 80,
                            );
                            if (image == null) {
                              loadingImage.value = false;
                              return;
                            }
                            final profilUploadTask = await FirebaseStorage
                                .instance
                                .ref(
                                    'uploads' + '/' + path.basename(image.path))
                                .putFile(File(image.path));
                            final profileUrl =
                                await profilUploadTask.ref.getDownloadURL();
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .update({"image": profileUrl});
                            loadingImage.value = false;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => Container(),
          error: (err, st) => Container(),
        ),
      ],
    );
    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          ProfilSetting(
            iconData: CupertinoIcons.chat_bubble_2,
            label: "Mes conversations",
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => Conversations()));
            },
          ),
          ProfilSetting(
            iconData: CupertinoIcons.bell,
            label: "Mes notifications",
            onPressed: () {},
          ),
          ProfilSetting(
            iconData: CupertinoIcons.cube_box,
            label: "Mes produits",
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => Products()));
            },
          ),
          ProfilSetting(
            iconData: LineIcons.history,
            label: "Historique",
            onPressed: () {},
          ),
          useProvider(userProvider(uid)).when(
            data: (user) {
              return Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () async {
                      final String? username = await getInputDialog(
                        context: context,
                        previous: user.name,
                        title: "Mettez votre nom d'utilisateur",
                      );
                      if (username == null) return;
                      debugPrint(username.toString());
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .set({"name": username}, SetOptions(merge: true));
                    },
                  ),
                  Expanded(
                    child: user.name.isEmpty
                        ? Text("Changer votre nom d'utilisateur.")
                        : Text(user.name),
                  ),
                ],
              );
            },
            loading: () => Container(),
            error: (err, st) => Container(),
          ),
        ],
      ),
    );
  }
}

class ProfilSetting extends StatelessWidget {
  const ProfilSetting({
    Key? key,
    required this.label,
    required this.iconData,
    required this.onPressed,
  }) : super(key: key);

  final String label;
  final IconData iconData;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 12,
      ),
      child: GestureDetector(
        onTap: () => onPressed(),
        child: Row(
          children: [
            Icon(iconData, size: 30),
            const SizedBox(width: 20),
            Text(
              label,
              style: Theme.of(context).textTheme.headline6,
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: () => onPressed(),
            ),
          ],
        ),
      ),
    );
  }
}
