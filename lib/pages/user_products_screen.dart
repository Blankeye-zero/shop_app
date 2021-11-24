import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/pages/edit_screen.dart';
import '../widgets/appDrawer.dart';
import '../provider/products.dart';
import '../widgets/user_products_widget.dart';

class UserProductsScreen extends StatelessWidget {
  //const UserProductsScreen({ Key? key }) : super(key: key);
  static const String routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    /* As we are not making use of state in this class, we are fetching state as an argument 
   We donot want to listen to the products here, we just want to trigger the fetchProducts()*/
    await Provider.of<Products>(context, listen: false).fetchProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    //final productsLink = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('User Products'),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              })
        ],
      ),
      drawer: AppDrawer(),
      /* The refresh Indicator takes a child widget on which we wrap it, and then it takes an OnRefresh argument which executes a function that returns a future
      It automatically shows a spinner in the mean time while the future executes*/
      //Future builder returns a widget once a certain future is returned, in this case, once the _refreshProducts()'s await block gets executed.
      //It needs the context metadata and a snapshot of the current state before building the widget since we could return to the snapshot if an exception occurs.
      body: FutureBuilder(
          future: _refreshProducts(context),
          builder: (context, snapshot) {
            return snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    /*The reason why we are not directly referencing refresh products here is because we need to provide context as an argument.
            Therefore we are passing on context as an argument within an anon function where it exists.*/
                    child: Consumer<Products>(
                      //The consumer is placed here so that the Future builder dosent fall into an infinite
                      //loop and only renders the part of a widget rather than the whole application.
                      builder: (ctx, productsLink, _) => Padding(
                        padding: EdgeInsets.all(8.0),
                        child: ListView.builder(
                            itemCount: productsLink.items.length,
                            itemBuilder: (_, i) => UserProductWidget(
                                productsLink.items[i].id,
                                productsLink.items[i].title,
                                productsLink.items[i].imageUrl)),
                      ),
                    ),
                  );
          }),
    );
  }
}
