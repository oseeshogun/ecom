import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecom/src/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:card_swiper/card_swiper.dart';

class ProductDetail extends HookWidget {
  final Product product;

  ProductDetail(this.product);

  @override
  Widget build(BuildContext context) {
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
                      if (index != 0) return container;
                      return Hero(
                        tag: "product_url",
                        child: container,
                      );
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
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
