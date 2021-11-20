import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart.dart';
//import '../provider/products.dart';

class CartElement extends StatelessWidget {
  //const CartItem({ Key? key }) : super(key: key);
  final String id;
  final String prodId;
  final double price;
  final int quantity;
  final String title;

  CartElement(
    this.id,
    this.prodId,
    this.price,
    this.quantity,
    this.title,
  );

  @override
  Widget build(BuildContext context) {
    //final productId = ModalRoute.of(context).settings.arguments as String;
    // final loadedProduct =  Provider.of<Products>(context, listen: false).findById(productId);
    return Dismissible(
      key: ValueKey(prodId),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(Icons.delete, color: Colors.white, size: 40),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      ),
      direction: DismissDirection.startToEnd,
      //confirms with the user whether they really need to delete the element.
      //The showDialog returns a boolean and is of type Future.
      //The resultant bool returned by ShowDialog can be controlled by the Navigator.pop() method as stated in its description.
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Confirm Delete?'),
            content: Text('Proceed?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(true);
                  },
                  child: Text('Yes')),
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(false);
                  },
                  child: Text('No'))
            ],
          ),
        );
      },
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(prodId);
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
                child: FittedBox(
              child: Padding(
                  padding: const EdgeInsets.all(2), child: Text('$price')
                  //Image.network(loadedProduct.imageUrl),
                  ),
            )),
            title: Text(title),
            subtitle: Text('Total: \$${(price * quantity)}'),
            trailing: Column(
              children: [
                Text('\$$price'),
                Text('$quantity x'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
