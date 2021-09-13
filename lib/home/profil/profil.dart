import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/src/providers/user.dart';
import 'package:ecom/src/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;

class Profil extends HookWidget {
  final ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final loadingImage = useState<bool>(false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: useProvider(userProvider(FirebaseAuth.instance.currentUser!.uid))
            .when(
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
          useProvider(userProvider(FirebaseAuth.instance.currentUser!.uid))
              .when(
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
                              final XFile? image =
                                  await picker.pickImage(source: source);
                              if (image == null) {
                                loadingImage.value = false;
                                return;
                              }
                              final tempDir =
                                  await path_provider.getTemporaryDirectory();
                              final File? result =
                                  await FlutterImageCompress.compressAndGetFile(
                                image.path,
                                tempDir.path + "/" + path.basename(image.path),
                                quality: 80,
                              );
                              if (result == null) {
                                loadingImage.value = false;
                                return;
                              }
                              final profilUploadTask = await FirebaseStorage
                                  .instance
                                  .ref(
                                      'uploads' + '/' + path.basename(image.path))
                                  .putFile(File(result.path));
                              final profileUrl =
                                  await profilUploadTask.ref.getDownloadURL();
                              final String uid =
                                  FirebaseAuth.instance.currentUser!.uid;
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
      ),
      body: Column(
        children: [
          ProfilSetting(
            iconData: CupertinoIcons.chat_bubble_2,
            label: "Mes conversations",
            onPressed: () {},
          ),
          ProfilSetting(
            iconData: CupertinoIcons.bell,
            label: "Mes notifications",
            onPressed: () {},
          ),
          ProfilSetting(
            iconData: CupertinoIcons.cube_box,
            label: "Mes produits",
            onPressed: () {},
          ),
          ProfilSetting(
            iconData: LineIcons.history,
            label: "Mes conversations",
            onPressed: () {},
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
    );
  }
}
