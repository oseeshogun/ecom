import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/src/models/user.dart';
import 'package:ecom/src/providers/product.dart';
import 'package:ecom/src/providers/user.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:count_stepper/count_stepper.dart';

class Panier extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
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
        title: Text(
          "Panier",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        actions: [
          // if (false) IconButton(
          //   icon: Icon(
          //     Icons.delete,
          //     color: Colors.black,
          //   ),
          //   onPressed: () {},
          // ),
        ],
      ),
      body: useProvider(userProvider(uid)).when(
        data: (user) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: user.panier.length,
                  itemBuilder: (context, index) {
                    final productId = user.panier[index];
                    return PanierItem(productId, user);
                  },
                ),
              )
            ],
          );
        },
        loading: () => Container(),
        error: (err, st) => Container(),
      ),
    );
  }
}

class PanierItem extends HookWidget {
  final String productId;
  final User user;

  PanierItem(this.productId, this.user);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return useProvider(productProvider(productId)).when(
      data: (product) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 10,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: product.urls[0],
                    imageBuilder: (context, provider) {
                      return Hero(
                        tag: product.urls[0],
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: provider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                    placeholder: (context, _) {
                      return Container(
                        height: 60,
                        width: 60,
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
                        CountStepper(
                          iconColor: Theme.of(context).primaryColor,
                          defaultValue: 1,
                          max: 10,
                          min: 1,
                          iconDecrementColor: Colors.black,
                          splashRadius: 25,
                          onPressed: (value) {
                            debugPrint(value.toString());
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          child: Icon(Icons.delete),
                          onTap: () {
                            FirebaseFirestore.instance
                                .collection("users")
                                .doc(uid)
                                .update({
                              "panier": user.panier
                                  .where((element) => element != product.id)
                                  .toSet()
                                  .toList(),
                            });
                          },
                        ),
                        Text(
                          product.price.toString() + " " + product.moneySign,
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
              Divider(
                height: 5,
              ),
            ],
          ),
        );
      },
      loading: () => Container(),
      error: (err, st) => Container(),
    );
  }
}
