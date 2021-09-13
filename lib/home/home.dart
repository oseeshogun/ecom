import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecom/src/models/ecom_category.dart';
import 'package:ecom/src/providers/categories.dart';
import 'package:ecom/src/providers/user.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Home extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
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
        ],
      ),
    );
  }

  AppBar appBar() {
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
        IconButton(
          icon: Icon(
            Icons.shopping_cart,
            color: Colors.black,
          ),
          onPressed: () {},
        ),
        if (FirebaseAuth.instance.currentUser != null)
          useProvider(userProvider(FirebaseAuth.instance.currentUser!.uid))
              .when(
            data: (user) {
              return CachedNetworkImage(
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
