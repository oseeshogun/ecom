import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:image_picker/image_picker.dart';

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