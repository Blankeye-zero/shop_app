import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/provider/cart.dart';
import 'package:shop_app/provider/products.dart';
import 'package:shop_app/widgets/appDrawer.dart';
import 'package:shop_app/widgets/products_grid.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import 'shopping_cart_page.dart';

enum FilterOptions { Favorites, All }

// enums are just a way to add labels to integers
class ProductOverviewPage extends StatefulWidget {
  static const routeName = 'products-overview';

  @override
  _ProductOverviewPageState createState() => _ProductOverviewPageState();
}

class _ProductOverviewPageState extends State<ProductOverviewPage> {
  bool _showOnlyFavorites = false;
  bool _isInit = true;
  var _isLoading = false;

  /* @override
  void initState() {
    //Provider.of<Products>(context).fetchProducts(); wont work
    //Future.delayed(Duration.zero).then((_){Provider.of<Products>(context).fetchProducts();})
    //workaround
    super.initState();
  }
  // the Provider.of<>(context) method wont work within initState unless the listen argument is set to false.
  //Here we are trying to fetch json data from firebase using a http get request.
  */

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchProducts().then((_) => setState(() {
            _isLoading = false;
          }));
    }
    _isInit = false;
    super.didChangeDependencies();
  }

//The didChangeDependencies() is a viable solution to our problem.
//It reruns everytime state changes, we put fetch method inside it, This is useful for providing realtime data but we only want to fetch our data once.
//Therefore we are running an IF check within it. This part of code could be tweaked or optimized further - Its a design flaw.
// The value of _isLoading is changed within setState as to reflect UI changes in real time.
  @override
  Widget build(BuildContext context) {
    //the products overview page is gonna fill up the screen therefore Scaffold
    //final productsContainer = Provider.of<Products>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            onSelected: (FilterOptions selectedValue) {
              setState(
                () {
                  if (selectedValue == FilterOptions.Favorites) {
                    _showOnlyFavorites = true;
                  } else {
                    _showOnlyFavorites = false;
                  }
                },
              );
            },
            /* For reflecting data on UI */
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only favorites'),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(child: Text('All'), value: FilterOptions.All),
            ],
          ),
          Consumer<Cart>(
            builder: (ctx, cartData, i) =>
                Badge(child: i, value: cartData.itemCount.toString()),
            child: IconButton(
                icon: Icon(
                  Icons.shopping_cart,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                }),
          ),
          //Here I first wrap the entire Badge widget within Consumer. But we only need the value to be rebuilt, so...
          //later I passed the iconButton to the Consumer as a child - Thereby the icon button would not be rebuild everytime the state changes.
          //But the value parameter of Badge is passed onto the builder thus, Consumer will only check for state changes in the value argument.
        ],
      ),
      drawer: AppDrawer(),
      //optimizes longer gridview items.and only renders items that are to be displayed on the screen while hiding items not on the screen
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavorites),
    );
  }
}
