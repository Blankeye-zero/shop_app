import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/pages/edit_screen.dart';
import 'package:shop_app/provider/products.dart';
import '../pages/edit_screen.dart';

class UserProductWidget extends StatelessWidget {
  //const UserProductWidget({ Key? key }) : super(key: key);
  final String title;
  final String imageUrl;
  final String id;

  UserProductWidget(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessengerState();
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).errorColor,
              ),
              onPressed: () async {
                try {
                  Provider.of<Products>(context, listen: false).delete(id);
                } catch (err) {
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Text('Deletion failed'),
                    ),
                  );
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.brown),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditProductScreen.routeName, arguments: id);
                //we are passing the id value as an argument using context while we switch to the other screen.
              },
            ),
          ],
        ),
      ),
    );
  }
}
