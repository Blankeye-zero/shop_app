import 'dart:convert';
//Used to convert dart objects to Json in this module...
import 'package:flutter/material.dart';
import 'package:shop_app/models/httpException.dart';
import '../provider/product.dart';
import 'package:http/http.dart' as http;
import '../secrets/constants.dart';

class Products with /*mixin?*/ ChangeNotifier {
  final String token;
  Products(this.token, this._items);
  A _obj = new A();
  List<Product> _items = [];

/* The filter using Provider.of method has been commented out as the products overview page has been made into a stateful widget.
this property must never be directly accessible from the outside.
var _showFavoritesOnly = false;
*/
  List<Product> get favoriteItems {
    return _items.where((proditem) => proditem.isFavorite).toList();
  }

  List<Product> get items {
    return [..._items];
  }

  /* List<Product> get items {
     if (_showFavoritesOnly) {
       return _items.where((prodItem) => prodItem.isFavorite).toList();
     } else
    return [..._items];
    }
a copy of the original private list for security reasons rather than directly interacting with the original _items we will be referencing the copy.
adding a getter to access the private list of class "Products" .We are referencing to the private list _items by using getter and then make a copy of it using the spreader "..." operator. therefore, we have two //lists rn.
all objects in dart are reference types. if we used the _items list directly, then we would be using a pointer directly to the private list which we donot want because of security.

   void showFavoritesOnly() {
     _showFavoritesOnly = true;
     notifyListeners();
   }

   void showAll() {
     _showFavoritesOnly = false;
     notifyListeners();
   }
 There might be  a poroblem here. here, the filter state is managed Appwide instead of widget wide. We need to change that.
 Look at the notifynotifyListeners() method. This enables to switch the favorites boolean value app wide. therefore if we were to implement another screen or page, then we would be unintentionally applying
 the filterstate to that page as well thereby only selectively rendering widgets on the screen.

 It seems like we should manage filtering logic on a widget wide scope and not on a global scope.
*/
  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchProducts() async {
    //In some apis, we need to encode the api key in the url header in order to authenticate
    try {
      final getResponse = await http.get('${_obj.productUrl}?auth=$token');
      final productExtract =
          json.decode(getResponse.body) as Map<String, dynamic>;
      if (productExtract == null) {
        return;
      }
      final List<Product> catalog = [];
      productExtract.forEach((key, value) {
        catalog.add(
          Product(
            id: key,
            title: value['title'],
            description: value['description'],
            price: value['price'],
            imageUrl: value['imageUrl'],
            isFavorite: value['isFavorite'],
          ),
        );
      });
      _items = catalog;
      notifyListeners();
      //  print(json.decode(getResponse.body));
    } catch (err) {
      print(err);
      throw (err);
    }
  }

  Future<void> addProducts(Product product) async {
    //return http.post()

    try {
      final value = await http.post(
        '${_obj.productUrl}?auth=$token',
        body: json.encode({
          'title': product.title,
          'descripton': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavorite': product.isFavorite
        }),
      );
      final addproduct = Product(
          id: json.decode(value.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(addproduct);
      notifyListeners();
    } catch (err) {
      print(err);
      throw err;
    }

    /*return http .post ().then(). catchError() is a pretty viable method. But there is also a well known alternative that is try, catch{}
    the return could be omitted once we declare the code block as async and use await to wrap the http.post() method.
    
    The try catch block is more readable and abstract than the .then
    () and catchError() method which seems to be dart specific.
    
    .then((value) {
    ...
    })
    
    .catchError((err) {
      ...
      },);
   
    In an official development environment, we could send this err message to our analytical team's server who would work on that.
    
    we are creating an error from the caught error. SO that we could use this error object in another place. In our case, we need to change the _isLoading boolean to false.
      
    we are declaring the addProducts method as type Future.
    The future returns a data of type void.
    Here we return the http.post.then() method .
    print(json.decode (value.body))
    here we are using the firebase id directly to reference the Product element on the client.
    the id is created by firebase and is sent to the client for this exact purpose in case we need to send
    requests for the modification of data.
    value is just a https response, therefore it prolly has headers , status and a body....
    The post body takes a json format object. JSON is Javascript Object Notation - A format for storing and transmitting data that is particularly well readable by machines.
    Json data is similar to mapping or dictionaries in that it resembles the key value structure.
    a post request also needs to define what kind of data that we want to send to the url.
    we can configure the http headers that we are posting if we are talking with a personalized api.
    alternatively we can use _items.insert(0, addProduct); to insert the product at the start of the List...
    With the .then() method, we are coding asynchronously because of the involvemnet of futures in this case, the .post() method.
    The .post() method returns a value of type future, the .then() method accepts the value and then executes code as instructed for different types of values.
    Enums <-> Futures <-> Error - Handling <-> are used here.
    Firebase sends us the id of the DB entry..
    */
  }

/*Updating data through PATCH requests to a server
 */
  Future<void> update(String id, Product newProduct) async {
    final index = _items.indexWhere((element) => element.id == id);

    try {
      if (index >= 0) {
        final url = '${_obj.giveId(id)}?auth=$token';
        /*A patch request has to carry data
        Make sure that the keys that we are using here matches that of the keys used in firebase
        As the patch request will try to merge this data to an existing data through overwriting
        If the data dosent exist, then it will add the data
        */
        final response = await http.patch(
          url,
          body: json.encode(
            {
              'title': newProduct.title,
              'description': newProduct.description,
              'imageUrl': newProduct.imageUrl,
              'price': newProduct.price,
            },
          ),
        );
        print(json.decode(response.body));
        _items[index] = newProduct;
        notifyListeners();
      }
    } on Exception catch (e) {
      print(e);

      return;
    }

    /*else {
      print('...');
    the else check wont be executed by design...
    }
    */
  }

//Using optimisting updating....
//Optimisting updating is where we immediately update the state on the client and would roll it back only if we receive an error from the server side.

  Future<void> delete(String id) async {
    final url = '${_obj.giveId(id)}?auth=$token';
    final index = _items.indexWhere((element) => element.id == id);
    var product = _items[index];

    final response = await http.delete(url);
    _items.removeAt(index);
    notifyListeners();

    if (response.statusCode >= 400) {
      _items.insert(index, product);
      notifyListeners();
      throw HttpException("Could not delete product id : $id");
    }
    product = null;
  }
}
