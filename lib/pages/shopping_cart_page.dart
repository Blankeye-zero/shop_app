import 'package:flutter/material.dart';
import 'package:shop_app/provider/cart.dart';
import '../provider/cart.dart' show Cart;
import 'package:provider/provider.dart';
import '../widgets/cart_item.dart' /*as ci*/;
import '../provider/orders.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final cartElementval = cart.items.values.toList();
    final cartElementkey = cart.items.keys.toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  SizedBox(width: 10),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .headline6
                              .color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  /* A widget that has stacked up elements like the badge custom widget*/
                  OrderButton(cart: cart, cartElementval: cartElementval),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cart.itemCount,
              itemBuilder: (ctx,
                      index) => /*ci.CartItem -> but i just changed the name to CartElementval*/
                  CartElement(
                      cartElementval[index].id,
                      cartElementkey[index],
                      cartElementval[index].price,
                      cartElementval[index].quantity,
                      cartElementval[index].title),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
    @required this.cartElementval,
  }) : super(key: key);

  final Cart cart;
  final List<CartItem> cartElementval;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

//refactoring to a new stateful widget makes only the OrderButton to rebuild rather than the entire widget
class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: _isLoading
          ? CircularProgressIndicator()
          : Text(
              'Order Now',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Orders>(context, listen: false)
                  .addOrder(widget.cartElementval, widget.cart.totalAmount);
              setState(() {
                _isLoading = false;
              });
              widget.cart.clear();
            },
    );
  }
}
