import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({this.id, this.title, this.quantity, this.price});
//constructors must be defined within the class not outside.
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items}; // Use paranthesis {}
  }

  int get itemCount {
    /* return _items == null ? 0 :  _items.length; */
    return _items.length;
  }

  double get totalAmount {
    var total = 0.00;
    _items.forEach(
        (key, cartItem) => total += cartItem.price * cartItem.quantity);
    return total;
    // .ForEach takes a map of the keys and the values: in this case cart item widget that we created and then iterates through them with the given code block.
  }

  void addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
          (value) => CartItem(
              id: value.id,
              price: value.price,
              quantity: value.quantity + 1,
              title: value
                  .title)); /* the (value) automatically gets the existing selected item*/
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          price: price,
          quantity: 1,
        ),
      );
    }
    notifyListeners(); //always call notifyListeners() whenever you want changes to reflect
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId].quantity > 1) {
      _items.update(
          productId,
          (existingCartItem) => CartItem(
              id: existingCartItem.id,
              title: existingCartItem.title,
              price: existingCartItem.price,
              quantity: existingCartItem.quantity - 1));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }
  //checks whether the items[index].quantity is greater than one or not and adds if the quantity is greater than one and removes it if it is not greater than one.

  void clear() {
    _items = {};
    notifyListeners();
  }
}



// Map.containsKey - iterates through the map to find the given key. 
// Map.putIfAbsent - Adds a new entry to the map if the given key is absent. 
