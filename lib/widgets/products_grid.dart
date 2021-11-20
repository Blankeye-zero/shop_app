import 'package:flutter/material.dart';
import 'package:shop_app/provider/products.dart';
import 'product_item.dart';
import 'package:provider/provider.dart';

class ProductsGrid extends StatelessWidget {
  final bool _showFavs;
  ProductsGrid(this._showFavs);
  @override
  Widget build(BuildContext context) {
    final loadedProducts = _showFavs
        ? Provider.of<Products>(context).favoriteItems
        : Provider.of<Products>(context).items;

    //the "of" method is a generic method that lets us reference the Products()
    return GridView.builder(
      padding: const EdgeInsets.all(
          10), //adding const makes it not rebuild on every build method invoke.
      itemCount:
          loadedProducts.length, //how many elements do we have in the list
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: loadedProducts[i],
        // itemBuilder: (ctx, i) => ChangeNotifierProvider(create: (c) =>loadedProducts[i],
        child: ProductItem(
            // loadedProducts[i].id,
            // loadedProducts[i].title,
            // loadedProducts[i].imageUrl,
            ),
      ), //the builder function receives context metadata and receives the index of the item that it is going to build iteratively for forthcoming indexes.
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing:
              10), //defines how the grid is structured, how many columns should it have?
    );
  }
}

//Consumer only rebuilds the widgets that are part of its builder, Provider.of() on the other hand triggers a complete re-build (i.e. re-runs build()) of this widget's widget tree.
// Provider.of<...> sets up a LISTENER to provided data, it does NOT provide data to other listeners itself.
//some state/ data that only matters to one (or a few) widgets dosen't need to be managed globally.