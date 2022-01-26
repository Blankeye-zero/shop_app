import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/products.dart';

class ProductDetailPage extends StatelessWidget {
  // final String title;
  // final double price;

  //ProductDetailPage(this.title,this.price);

  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final loadedProduct =
        Provider.of<Products>(context, listen: false).findById(productId);
    //refactoring widgets - moving logic into provider class. This listener reruns this Products method whenever the build state changes. On this product Detail screen, there is little change,
    //so we dont need to reflect any unnecessary changes using listener:false. Thus it will only build once when the initial build of the app.
    //we only need build, and no updating thus this is a viable solution.

    return Scaffold(
      // appBar: AppBar(title: Text(loadedProduct.title)),
      //slivers are scrollable areas on the screen
      body: CustomScrollView(
        slivers: <Widget>[],
        child: Column(
          children: [
            //The Hero widget needs tobe present at both the screens, in order to work and both the hero widgets need the same tag id.
            Hero(
              tag: loadedProduct.id,
              child: Container(
                  height: 300,
                  width: double.infinity,
                  child:
                      Image.network(loadedProduct.imageUrl, fit: BoxFit.cover)),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "\$${loadedProduct.price}",
              style: TextStyle(color: Colors.grey, fontSize: 20),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              child: Text(
                loadedProduct.description,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            )
          ],
        ),
      ),
    );
  }
}
