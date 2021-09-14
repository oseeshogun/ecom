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
      body: SizedBox(
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
              child: Text(
                "Aucun produit publié",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                ),
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
