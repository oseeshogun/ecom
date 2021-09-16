import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/src/models/product.dart';
import 'package:ecom/src/providers/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'create_product.dart';

class Products extends HookWidget {
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
          "Mes produits",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => CreateProduct()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: SizedBox(
          width: double.infinity,
          child: useProvider(myproductsProvider(uid)).when(
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
                      "Aucun produit publié",
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
                      final Product product = conversations[index];
                      return Column(
                        children: [
                          Row(
                            children: [
                              CachedNetworkImage(
                                imageUrl: product.urls[1],
                                imageBuilder: (context, provider) {
                                  return Container(
                                    height: 60,
                                    width: 60,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: provider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                                placeholder: (context, _) {
                                  return Container(
                                    height: 60,
                                    width: 60,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      product.description,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                height: 60,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection("products")
                                              .doc(product.id)
                                              .delete();
                                        },
                                      ),
                                    ),
                                    Text(
                                      product.price.toString() +
                                          " " +
                                          product.moneySign,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Divider(),
                        ],
                      );
                    }),
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
      ),
    );
  }
}
