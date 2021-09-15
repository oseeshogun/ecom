import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:image_picker/image_picker.dart';

Future<String> uploadFile(String folder, File file) async {
  final frontUploadTask = await FirebaseStorage.instance
      .ref('$folder/${DateTime.now().toIso8601String()}.png')
      .putFile(file);
  return await frontUploadTask.ref.getDownloadURL();
}

Future<ImageSource?> getPicker(BuildContext context) async {
  return await showPlatformDialog<ImageSource>(
    context: context,
    builder: (_) => BasicDialogAlert(
      title: Text("Continuer avec "),
      actions: [
        BasicDialogAction(
          title: Text("Camera"),
          onPressed: () {
            Navigator.of(context).pop(ImageSource.camera);
          },
        ),
        BasicDialogAction(
          title: Text("Gallerie"),
          onPressed: () {
            Navigator.of(context).pop(ImageSource.gallery);
          },
        ),
        BasicDialogAction(
          title: Text("Annuler"),
          onPressed: () {
            Navigator.of(context).pop(null);
          },
        ),
      ],
    ),
  );
}

Future<String?> getInputDialog({
  required BuildContext context,
  required String title,
  required String previous,
}) async {
  final TextEditingController textEditingController =
      new TextEditingController(text: previous);
  return await showPlatformDialog<String>(
    context: context,
    builder: (_) => BasicDialogAlert(
      title: Text(title),
      actions: [
        Material(
          elevation: 0,
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: textEditingController,
              maxLines: 1,
              maxLength: 10,
            ),
          ),
        ),
        BasicDialogAction(
          title: Text("Confirmer"),
          onPressed: () {
            Navigator.of(context).pop(textEditingController.text);
          },
        ),
        BasicDialogAction(
          title: Text("Annuler"),
          onPressed: () {
            Navigator.of(context).pop(null);
          },
        ),
      ],
    ),
  );
}

Future<String?> chooseDialog({
  required BuildContext context,
  required String title,
  required List<String> selections,
}) async {
  return await showPlatformDialog<String>(
    context: context,
    builder: (_) => BasicDialogAlert(
      title: Text(title),
      actions: [
        ...selections.map<BasicDialogAction>((selection) {
          return BasicDialogAction(
            title: Text(selection),
            onPressed: () {
              Navigator.of(context).pop(selection);
            },
          );
        }),
        BasicDialogAction(
          title: Text("Annuler"),
          onPressed: () {
            Navigator.of(context).pop(null);
          },
        ),
      ],
    ),
  );
}

Future<void> showOutput(BuildContext context, String message) async {
  await showPlatformDialog(
    context: context,
    builder: (_) => BasicDialogAlert(
      title: Text(message),
      actions: [
        BasicDialogAction(
          title: Text("Annuler"),
          onPressed: () {
            Navigator.of(context).pop(null);
          },
        ),
      ],
    ),
  );
}
