import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/pages/auth_screen.dart';
import 'package:shop_app/pages/product_detail_page.dart';
import 'package:shop_app/pages/products_overview_page.dart';
import 'package:shop_app/pages/shopping_cart_page.dart';
import 'package:shop_app/provider/auth.dart';
import 'package:shop_app/provider/orders.dart';
import './provider/products.dart';
import 'provider/cart.dart';
import './pages/orders_page.dart';
import 'pages/user_products_screen.dart';
import 'pages/edit_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return /*ChangeNotifierProvider.value(
      value: Products(), an alternative to passing context  using create argument*/
        MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        /* ChangeNotifierProxyProvider is actually a generic class thus we need to specify the intended type through angular brackets, it basically creats a link to access a dependency that is 
        to be mentioned above the current provider, and passes it to the current provider. We can pass on the token this way*/
        /* If we have more than a single dependency, then correspondingly ChangeProxyProvider2, ChangeProxyProvider3 classes are available*/
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (ctx) => Products("", [], ""),
          update: (ctx, auth, previousState) => Products(auth.token,
              previousState == null ? [] : previousState.items, auth.userId),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => Orders("", [], ""),
          update: (ctx, auth, previousState) => Orders(auth.token,
              previousState == null ? [] : previousState.orders, auth.userId),
        ),
      ],
      //the .value constructor can be used as an alternative if there is no context involved.
      //also this is the right approach when we use a listener as a part of a list or a grid since the UI is dynamically rendered using builder methods.
      // The MultiProvider Method is used to link up multiple providers to a widget.
      child: Consumer<Auth>(
        builder: (context, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            fontFamily: 'Lato',
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey)
                .copyWith(secondary: Colors.black54),
          ),
          //to show the login page instead of authscreen if not logged in already, we use futureBuilder
          home: auth.isAuth
              ? ProductOverviewPage()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, snapshot) {
                    return snapshot.connectionState == ConnectionState.waiting
                        ? Center(
                            child: Text('Loading....'),
                          )
                        : AuthScreen();
                  },
                ),
          debugShowCheckedModeBanner: false,
          routes: {
            ProductOverviewPage.routeName: (ctx) => ProductOverviewPage(),
            ProductDetailPage.routeName: (ctx) => ProductDetailPage(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersPage.routeName: (ctx) => OrdersPage(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
//named routes are much easier to comprehend to map the basic structure of an application than 
// on the fly routes that we pass on in the Gesture detector in Product item.dart
//another downside is that we cannot pass data onto constructors that we donot have. 