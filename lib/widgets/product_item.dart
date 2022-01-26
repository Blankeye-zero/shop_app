import 'package:flutter/material.dart';
import 'package:shop_app/provider/cart.dart';
import '../pages/product_detail_page.dart';
import '../provider/product.dart';
import 'package:provider/provider.dart';
import '../provider/auth.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem(this.id, this.title, this.imageUrl);

  // static const routeName = '/product-item';

  @override
  Widget build(BuildContext context) {
    final product =
        Provider.of<Product>(context, listen: false); //set the listen = false.
    final cart = Provider.of<Cart>(context, listen: false); //set listen = fasle
    final authData = Provider.of<Auth>(context, listen: false);
    return GridTile(
        child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                ProductDetailPage.routeName,
                arguments: product.id,
              );
            },
            //FadeInImage takes a placeholder...
            child: FadeInImage(
                placeholder:
                    AssetImage('assets/images/product-placeholder.png'),
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.cover)),
        footer: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: GridTileBar(
            backgroundColor: Colors.black54, //a bit transparent black.
            leading: Consumer<Product>(
              builder: (ctx, product, _) => IconButton(
                icon: Icon(product.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border),
                onPressed: () {
                  product.toggleFavoriteStatus(authData.token, authData.userId);
                },
              ),
            ),
/* The Consumer is a generic method (means untyped method) provided by the provider package. The Consumer Method is used to only rebuild parts of a widget rather than rebuilding the whole of a widget using Provider.of(context) method. 
This helps improve efficiency. We have to set the listen argument to false in the Provider.of(context) method so that only widgets that are wrapped within
the Consumer class are updated*/
            title: Text(
              product.title,
              textAlign: TextAlign.center,
            ),
            trailing: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  cart.addItem(product.id, product.price, product.title);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  //hides current snackbar if a new one pops up...

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                          'Added item to cart!',
                        ),
                        duration: Duration(seconds: 2),
                        action: SnackBarAction(
                            label: 'UNDO',
                            onPressed: () {
                              cart.removeSingleItem(product.id);
                              //updates the cart badge and actual items list...
                            })),
                  );
                  //creats an object that links to the nearest widget that controls the whole page
                  //the nearest scaffold is in the products overview
                }),
          ),
        )); // a widget that works particularly well inside of grids.
  }
}
