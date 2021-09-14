import 'dart:io';

import 'package:ecom/src/models/ecom_category.dart';
import 'package:ecom/src/models/product.dart';
import 'package:ecom/src/providers/categories.dart';
import 'package:ecom/src/utils/utils.dart';
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
    final priceEditingController = useTextEditingController(text: "usd");
    final moneyEditingController = useTextEditingController();
    final loading = useState<bool>(false);
    final thumbnails = useState<List<File>>([]);
    final category = useState<EcomCategory?>(null);
    final productState =
        useState<ProductQuality>(ProductQuality("Excellente", "excellent"));

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
                          final source = await getPicker(context);
                          if (source == null) return;
                          final List<XFile>? images =
                              await picker.pickMultiImage();
                          if (images == null) return;
                          thumbnails.value = images
                              .sublist(0, 4)
                              .map<File>((i) => File(i.path))
                              .toList();
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
                  height: 250,
                  child: ReorderableListView.builder(
                    itemCount: thumbnails.value.length,
                    onReorder: (_, __) {},
                    itemBuilder: (context, index) {
                      return Container();
                    },
                  ),
                ),
              ],
              const SizedBox(height: 20),
              TextFormField(
                maxLength: 24,
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
                replacement: CircularProgressIndicator(),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        // verify if the users has upload at least one photo
                        // verifty if the user has set category
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
            ],
          ),
        ),
      ),
    );
  }
}
