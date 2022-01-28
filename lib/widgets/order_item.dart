import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';

import '../provider/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  // const OrderItem({ Key? key }) : super(key: key);
  final ord.OrderItem order;

  OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

//We are using stateful widget because we need to rerender ui during runtime based on the fact whether the 'Order Now' is clicked
class _OrderItemState extends State<OrderItem> {
  var _expanded = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height:
          _expanded ? min(widget.order.products.length * 20.0 + 110, 200) : 95,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('\$${widget.order.amount}'),
              subtitle: Text(
                DateFormat('dd:MM:yyyy hh:mm').format(widget.order.date),
              ),
              trailing: IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  }),
            ),
            AnimatedContainer(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              /* min - minimum height of two values -requires double val */
              duration: Duration(milliseconds: 300),
              height: _expanded
                  ? min(widget.order.products.length * 20.0 + 10, 100)
                  : 0,
              child: ListView(
                  children: widget.order.products
                      .map((prod) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                prod.title,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text('${prod.quantity}x \$${prod.price}',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey))
                            ],
                          ))
                      .toList()),
            )
          ],
        ),
      ),
    );
  }
}
