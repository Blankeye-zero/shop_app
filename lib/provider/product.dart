import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../secrets/constants.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

//employing optimistic updating...
  Future<void> toggleFavoriteStatus(String token, String userId) async {
    A _obj = new A();
    final url = '${_obj.favUrl(id, userId)}?auth=$token';
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners(); //equivalent to setState() in stateful widgets.
    //patch requests donot return errors unless it is a network one. therefore we are using the if statement...
    try {
      // A patch request worked fine when updating the boolean along with the whole Product parameters, but since we are going to work with only
      //one parameter, isFavorite rn... therefore we are going to use the put request
      //final response = await http.patch(url,
      final response = await http.put(
        url,
        body: json.encode(
          isFavorite,
        ),
      );
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (err) {
      _setFavValue(oldStatus);
    }
  }
}
