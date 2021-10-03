import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/home/chat/chat.dart';
import 'package:ecom/src/models/product.dart';
import 'package:ecom/src/providers/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sweetsheet/sweetsheet.dart';

class ProductDetail extends HookWidget {
  final Product product;

  ProductDetail(this.product);

  @override
  Widget build(BuildContext context) {
    final selectedSize = useState<String>("M");
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final SweetSheet _sweetSheet = SweetSheet();
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * .55,
              child: Swiper(
                itemCount: product.urls.length,
                pagination: SwiperPagination(),
                control: SwiperControl(),
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: product.urls[index],
                    imageBuilder: (context, provider) {
                      final container = Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: provider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                      if (index == 0)
                        return Hero(
                          tag: product.urls[index],
                          child: container,
                        );
                      return container;
                    },
                    placeholder: (context, _) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SafeArea(
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * .50,
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: ListView(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                product.moneySign +
                                    ' ' +
                                    product.price.toString(),
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: useProvider(userProvider(product.author)).when(
                            data: (author) {
                              return Stack(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: author.image,
                                    imageBuilder: (context, imageProvider) {
                                      return CircleAvatar(
                                        radius: 25,
                                        backgroundImage: imageProvider,
                                      );
                                    },
                                    placeholder: (context, _) {
                                      return CircleAvatar(
                                        radius: 25,
                                        backgroundImage: AssetImage(
                                            "assets/images/avatar.jpg"),
                                      );
                                    },
                                  ),
                                  Positioned(
                                    bottom: 0.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 2),
                                          Text(
                                            author.stars.toStringAsFixed(1),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(Icons.star),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              );
                            },
                            loading: () => Container(),
                            error: (err, st) => Container(),
                          ),
                        ),
                      ],
                    ),
                    if (product.categoryIndex == 1) ...[
                      const SizedBox(height: 20),
                      Text(
                        "Votre taille",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: ["S", "M", "L", "XL"].map<Widget>((size) {
                          return Container(
                            height: 50,
                            width: 50,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: GestureDetector(
                              onTap: () {
                                selectedSize.value = size;
                              },
                              child: Material(
                                color: Colors.white,
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      size,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: selectedSize.value == size
                                            ? Colors.blueAccent
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      "Description",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(product.description),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Material(
                          color: Colors.white,
                          elevation: 5.0,
                          shape: CircleBorder(),
                          child: IconButton(
                            icon: Icon(
                              Icons.message,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => Chat(product.author)));
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Discutez avec le vendeur.",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    useProvider(userProvider(uid)).when(
                      data: (user) {
                        return ElevatedButton(
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection("users")
                                .doc(uid)
                                .update({
                              "panier":
                                  [...user.panier, product.id].toSet().toList(),
                            });
                            _sweetSheet.show(
                              context: context,
                              description: Text("Produit ajouté au panier"),
                              color: SweetSheetColor.SUCCESS,
                              positive: SweetSheetAction(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                title: 'OK',
                                icon: Icons.done,
                              ),
                            );
                          },
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  EdgeInsets.symmetric(
                                vertical: 15,
                              )),
                              backgroundColor: MaterialStateProperty.all(
                                Colors.black,
                              ),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(15)))),
                          child: Text(
                            "Ajouter au panier",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        );
                      },
                      loading: () => Container(),
                      error: (err, st) => Container(),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
