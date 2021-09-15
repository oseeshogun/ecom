import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/src/models/ecom_category.dart';
import 'package:ecom/src/models/product.dart';
import 'package:ecom/src/providers/categories.dart';
import 'package:ecom/src/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:select_form_field/select_form_field.dart';

class CreateProduct extends HookWidget {
  final ImagePicker picker = ImagePicker();
  final formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> devices = [
    {
      'value': 'cdf',
      'label': 'CDF',
    },
    {
      'value': 'usd',
      'label': 'USD',
    }
  ];

  @override
  Widget build(BuildContext context) {
    final priceEditingController = useTextEditingController();
    final moneyEditingController = useTextEditingController(text: "usd");
    final titleEditingController = useTextEditingController();
    final marqueEditingController = useTextEditingController();
    final loading = useState<bool>(false);
    final thumbnails = useState<List<File>>([]);
    final category = useState<EcomCategory?>(null);
    final productState =
        useState<ProductQuality>(ProductQuality("Excellente", "excellent"));

    final description = useState<String>("");

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
          "Nouveau produit",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
          ),
        ),
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: ListView(
            children: [
              Container(
                child: Column(
                  children: [
                    Text(
                      "Charger jusqu'à 5 images",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Material(
                      child: GestureDetector(
                        onTap: () async {
                          final List<XFile>? images =
                              await picker.pickMultiImage();
                          if (images == null) return;
                          if (images.length > 5) return;
                          thumbnails.value =
                              images.map<File>((i) => File(i.path)).toList();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(),
                          ),
                          padding: const EdgeInsets.all(7.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add),
                              const SizedBox(width: 10),
                              Text("Charger les images"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (thumbnails.value.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  height: 100,
                  child: ReorderableListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: thumbnails.value.length,
                    onReorder: (oldIndex, index) {
                      final int newIndex = index > oldIndex ? index - 1 : index;
                      final List<File> _thumbs = thumbnails.value;
                      final File file = _thumbs.removeAt(oldIndex);
                      _thumbs.insert(newIndex, file);
                      thumbnails.value = _thumbs;
                    },
                    itemBuilder: (context, index) {
                      if (index >= thumbnails.value.length){
                        return Container(
                          key: ValueKey(index),
                        );
                      }
                      final thumb = thumbnails.value[index];
                      return Container(
                        key: ValueKey(thumb.path),
                        width: 100,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              thumb,
                              fit: BoxFit.cover,
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(.5),
                                ),
                                child: InkWell(
                                  child: Icon(Icons.close),
                                  onTap: () {
                                    final List<File> _thumbs = thumbnails.value;
                                    final File file = _thumbs.removeAt(index);
                                    thumbnails.value = thumbnails.value.where((thumb) => thumb.path != file.path).toList();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 20),
              TextFormField(
                maxLength: 24,
                controller: titleEditingController,
                decoration: InputDecoration(
                    hintText: "ex: Chémise Versace", labelText: "Titre"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Veuilez remplir ce champ";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  hintText: "ex: Chémise pour homme avec des carrées.",
                  labelText: "Description",
                ),
                onChanged: (value) {
                  description.value = value;
                },
                maxLines: 7,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Veuilez remplir ce champ";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  context
                      .read(ecomCategoriesProvider)
                      .whenData((categories) async {
                    final String? tempCategory = await chooseDialog(
                      context: context,
                      title: "Choississez une catégorie",
                      selections: categories
                          .where((c) {
                            if (c.restricted) return false;
                            if (c.index == 0) return false;
                            return true;
                          })
                          .toList()
                          .map<String>((s) => s.name)
                          .toList(),
                    );
                    if (tempCategory == null) return;
                    final classCategory =
                        categories.firstWhere((s) => s.name == tempCategory);
                    category.value = classCategory;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Catégorie",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const Spacer(),
                    if (category.value != null) Text(category.value!.name),
                    const SizedBox(width: 10),
                    Icon(Icons.edit, color: Colors.grey),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  hintText:
                      "Ecrivez le fabricant du produit ou\nl'auteur dans le cas d'un e-book.",
                  labelText: "Marque",
                ),
                maxLines: 2,
                maxLength: 30,
                controller: marqueEditingController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Veuilez remplir ce champ";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () async {
                  final String? tempState = await chooseDialog(
                    context: context,
                    title: "Quel est état du produit ?",
                    selections: Product.conditions.map((p) => p.name).toList(),
                  );
                  if (tempState == null) return;
                  final classState =
                      Product.conditions.firstWhere((c) => c.name == tempState);
                  productState.value = classState;
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Etat du produit",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const Spacer(),
                    Text(productState.value.name),
                    const SizedBox(width: 10),
                    Icon(Icons.edit, color: Colors.grey),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SelectFormField(
                controller: moneyEditingController,
                type: SelectFormFieldType.dropdown,
                labelText: 'Devise',
                hintText: 'Mettez le devise (CDF par défaut)',
                items: devices,
                onChanged: (val) => debugPrint(val),
                onSaved: (val) => debugPrint(val),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: priceEditingController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.attach_money_outlined),
                  labelText: "Prix",
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Veuilez remplir ce champ";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              Visibility(
                visible: !loading.value,
                replacement: Container(
                  alignment: Alignment.center,
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        // verify if the users has upload at least one photo
                        if (thumbnails.value.length < 1) {
                          showOutput(context,
                              "Vous pouvez mettre au moins une image du produit.");
                          return;
                        }
                        // verifty if the user has set category
                        if (category.value == null) {
                          showOutput(
                              context, "Vous devez choisir une categorie.");
                          return;
                        }
                        loading.value = true;
                        // save the product information
                        final productId =
                            DateTime.now().microsecondsSinceEpoch.toString();
                        // upload images and save it
                        final List<String> urls = await Future.wait<String>(
                          thumbnails.value
                              .map<Future<String>>(
                                  (file) => uploadFile("products", file))
                              .toList(),
                        );
                        await FirebaseFirestore.instance
                            .collection("products")
                            .doc(productId)
                            .set({
                          "title": titleEditingController.text,
                          "description": description.value,
                          "brand": marqueEditingController.text,
                          "author": FirebaseAuth.instance.currentUser!.uid,
                          "money": moneyEditingController.text,
                          "price":
                              double.tryParse(priceEditingController.text) ??
                                  0.0,
                          "category": category.value?.name,
                          "categoryIndex": category.value?.index,
                          "condition": productState.value.key,
                          "urls": urls,
                          "timestamp": DateTime.now().millisecondsSinceEpoch,
                        });
                        Navigator.of(context).pop();
                      }
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                      padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(vertical: 15),
                      ),
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                    ),
                    child: Text(
                      "Sauvegarder",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
