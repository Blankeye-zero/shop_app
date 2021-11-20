import 'package:flutter/material.dart';
import 'package:shop_app/widgets/appDrawer.dart';
import '../provider/orders.dart' show Orders;
import 'package:provider/provider.dart';
import '../widgets/order_item.dart';

class OrdersPage extends StatefulWidget {
  static const String routeName = '/orders';

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  Future _ordersFuture;

  Future<void> obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchOrders();
  }

  @override
  void initState() {
    _ordersFuture = obtainOrdersFuture();
    super.initState();
  }

  /*We are storing the fetchOrders() in a Future variable so as to avoid unnecessary sending of requests if ever the widget state is rebuilt. The 
  current setup is so that unnecessary requests are not sent every time the widget state is rebuilt due to some other feature. */

  @override
  /*void initState() {
    _isLoading = true;

    Provider.of<Orders>(context, listen: false).fetchOrders().then((_) {
      setState(() {
        _isLoading = false;
      });
    }); //this is queued at the end. the super.initState() fires first then this comes after.
    super.initState();
  }
  */

  Widget build(BuildContext context) {
    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      //A more elegant alternative to fetching state for widgets of type future
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (context, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (dataSnapshot.connectionState == null) {
            return Center(child: Text("Error in fetching future"));
          } else {
            //consumer is used to avoid entering an infinite loop because the context is derived from global state
            return Consumer<Orders>(
              builder: (ctx, orderData, child) {
                return ListView.builder(
                  itemCount: orderData.orders.length,
                  itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                );
              },
            );
          }
        },
      ),
    );
  }
}
