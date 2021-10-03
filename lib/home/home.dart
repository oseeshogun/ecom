import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecom/home/product_detail.dart';
import 'package:ecom/home/profil/profil.dart';
import 'package:ecom/src/models/ecom_category.dart';
import 'package:ecom/src/models/product.dart';
import 'package:ecom/src/providers/categories.dart';
import 'package:ecom/src/providers/product.dart';
import 'package:ecom/src/providers/user.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'cashout/panier.dart';

class Home extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Découvertes",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Les meilleures articles du marché",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          useProvider(ecomCategoriesProvider).when(
            data: (categories) {
              return SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final EcomCategory category = categories[index];
                    return CategoryHome(category: category, index: index);
                  },
                ),
              );
            },
            loading: () => Container(),
            error: (err, st) => Container(),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              children: [
                Text(
                  "Produits populaires",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Voir plus",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          useProvider(popularProductsProvider).when(
            data: (products) {
              debugPrint(products.length.toString());
              if (products.length == 0) return Container();
              return Container(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final Product product = products[index];
                    return Padding(
                      padding: EdgeInsets.only(left: index == 0 ? 8.0 : 0.0),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        width: 176,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => ProductDetail(product)));
                          },
                          child: Material(
                            elevation: 5.0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: product.urls[0],
                                        imageBuilder: (context, provider) {
                                          return Hero(
                                            tag: product.urls[0],
                                            child: Container(
                                              height: 140,
                                              width: 160,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
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
                                            height: 140,
                                            width: 160,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                      Positioned(
                                        right: 10,
                                        bottom: 0,
                                        child: Transform.translate(
                                          offset: Offset(0.0, 15.0),
                                          child: Container(
                                            padding: const EdgeInsets.all(6.0),
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              shape: BoxShape.circle,
                                            ),
                                            child: InkWell(
                                              child: Icon(
                                                Icons.shopping_cart,
                                                color: Colors.white,
                                              ),
                                              onTap: () {},
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    product.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          product.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
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
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => Container(),
            error: (err, st) => Container(),
          ),
        ],
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          color: Colors.black,
        ),
        onPressed: () {},
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.search,
            color: Colors.black,
          ),
          onPressed: () {},
        ),
        if (FirebaseAuth.instance.currentUser != null)
          useProvider(userProvider(FirebaseAuth.instance.currentUser!.uid))
              .when(
            data: (user) {
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.shopping_cart,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => Panier()));
                    },
                  ),
                  if (user.panier.length != 0) Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        user.panier.length.toString(),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => Container(),
            error: (err, st) {
              debugPrint(err.toString());
              return Container();
            },
          ),
        if (FirebaseAuth.instance.currentUser != null)
          useProvider(userProvider(FirebaseAuth.instance.currentUser!.uid))
              .when(
            data: (user) {
              return InkWell(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => Profil()));
                },
                child: CachedNetworkImage(
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
                      backgroundImage: AssetImage("assets/images/avatar.jpg"),
                    );
                  },
                ),
              );
            },
            loading: () => Container(),
            error: (err, st) => Container(),
          ),
        const SizedBox(width: 10),
      ],
    );
  }
}

class CategoryHome extends HookWidget {
  const CategoryHome({
    required this.category,
    required this.index,
  });

  final EcomCategory category;
  final int index;

  @override
  Widget build(BuildContext context) {
    final selectedCategory = useProvider(selectedCategoryProvider);
    final bool selected = selectedCategory.state == null
        ? index == 0
        : selectedCategory.state == category;
    return GestureDetector(
      onTap: () {
        selectedCategory.state = category;
      },
      child: Container(
        width: MediaQuery.of(context).size.width * .4,
        margin: EdgeInsets.only(
          right: 5.0,
          left: index == 0 ? 16.0 : 5.0,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
        ),
        decoration: BoxDecoration(
          color: category.color,
          borderRadius: BorderRadius.circular(20),
          border: selected ? Border.all() : null,
        ),
        child: Row(
          children: [
            category.icon,
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                overflow: TextOverflow.fade,
              ),
            )
          ],
        ),
      ),
    );
  }
}
