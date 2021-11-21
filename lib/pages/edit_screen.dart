import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/product.dart';
import '../provider/products.dart';

class EditProductScreen extends StatefulWidget {
  //const EditProductScreen({ Key? key }) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();

  static const routeName = '/edit-products';
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _pricenode = FocusNode();
  final _descriptionNode = FocusNode();
  final _imageurlController = TextEditingController();
  final _imageUrlnode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct =
      Product(id: null, title: '', description: '', price: 0, imageUrl: '');
  //This Product object gets updated whenever the _saveform method is called...
  //Global key is a generic type thus we can add angular brackets to mention any specific data taype that we are working with.
//FormState gets imported with material.dart.
  var _isInit = true;
  var _isLoading = false; //for displating a loading buffer.
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageurl': '',
  };
  //values that are set for new product and we will simply override them in didChangeDepencies if we have edited a product.
  //here we use mapping but can also be done using a seperate class and accessing the properties using an object.
  @override
  void initState() {
    _imageUrlnode.addListener(
        _updateImageUrl); //points to the function whenever the focus goes out of scope.
    super.initState();
  }
  //ModalRoute.of(context).settings.arguments dosent work with initState()

  @override
  void dispose() {
    _imageUrlnode.removeListener(_updateImageUrl);
    _pricenode.dispose();
    _descriptionNode.dispose();
    _imageurlController.dispose();
    _imageUrlnode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      //We are only passing one argument here so this works...
      //for validating if we are creating a new product or edit an existing product since creating  a new product means no id is passed as an argument
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          //text Form fields only work with strings thus we convert the price to  a string
          //'imageurl': _editedProduct.imageUrl, wont work -
          'imageurl': '',
        };
        _imageurlController.text = _editedProduct
            .imageUrl; //this works and now to reference this in the build method.
        //overriding initValues to updated values using didChangeDependencies
      }
    }
    _isInit = false;
    super.didChangeDependencies();
    //must call super in order to invoke overriden method...
  }

  void _updateImageUrl() {
    if (!_imageUrlnode.hasFocus) {
      if (!_imageurlController.text.startsWith('https') ||
          ((!_imageurlController.text.endsWith('png') &&
              !_imageurlController.text.endsWith('jpeg')))) {
        return;
      }

      setState(() {});
    } //we update the imageurl when we lose focus.
  }

  Future<void> _saveForm() async {
    // We use a global key to interact with a widget from inside our code...
    final isValid = _form.currentState.validate();
    if (!isValid) return;
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    /*
    we have to reflect this change in the user interface...
    For implementing Loading Buffer... we also have to set the boolean to false once we are done with the uploading of the request.
    checking to see if the id is null or not. if null, then we are adding a product, not null means we are editing an existing product.
    */
    if (_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .update(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            //addProducts() returns a future therefore this is prone to error....
            .addProducts(_editedProduct);
      } catch (err) {
        await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('Error occurred!'),
                  content: Text('Something went wrong'),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text('okay'))
                  ],
                ));
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
      /*We are commenting out the finally block since we are using await in all the three cases above */
    }
    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pop();
  }
  /*   we are forwarding the edited product to the Products class' add product method.
     The .then() method is possible because we have declared addProducts Method as a Future.
    Here the page will only pop once the data is stored. this also allows for more sophisticated error handling using the catch error method.

    save is a method provided by the state object of Form Widget which saves the form.
    it will trigger a method on every textFormField that allows you to take the data and process it however we want. Example of what can be done: store it to a global map that collects all text inputs...
    Implemented the try-catch and Finally block instead of .then() and .catchError() for Error Handling...
  */

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator(), //rendering loading buffer using the boolean value _isLoading.
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                //key to id a particular widget.
                //we can also set stuff like auto validation, onChanged etc.,
                //OnWillPop stops dismissing the page if the user is still editing it.
                //if autovalidate is set to true it will execute a given function that takes a value and returns a value upon every keystroke.
                //how could we trigger validation if autovalidate is not set to true? By using the global variable keys.
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues['title'],
                      //initialValue parameter is for displaying initial values when nothing is entered. used to display the properties of already existing products
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_pricenode),
                      onSaved: (value) {
                        _editedProduct = Product(
                            title: value,
                            price: _editedProduct.price,
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite);
                        /*to create a new product that overrides the existing _editedProduct Product fields for which this particular widget it responsible*/
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please Provide a value';
                        }
                        return null;
                        //if we return a null, then this is treated as there is no error and the input is correct
                        //if we return a text, then it is treated like an error text and displayed when there are discrepancies in the input according to the condition given.
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(
                        labelText: 'Price',
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _pricenode,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_descriptionNode),
                      onSaved: (value) {
                        _editedProduct = Product(
                            title: _editedProduct.title,
                            price: double.parse(
                                value), //converts value of String type to double.
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite);
                      },
                      validator: (value) {
                        if (value.isEmpty && double.tryParse(value) == null) {
                          return 'Please Provide a correct value';
                        }
                        if (double.parse(value) < 0) {
                          return 'Please enter a number greater than zero';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                      focusNode: _descriptionNode,
                      onSaved: (value) {
                        _editedProduct = Product(
                            title: _editedProduct.title,
                            price: _editedProduct.price,
                            description: value,
                            imageUrl: _editedProduct.imageUrl,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a description';
                        }
                        if (value.length < 10) {
                          return 'Should be atleast 10 characters long';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageurlController.text.isEmpty
                              ? Text('Enter a Url')
                              : FittedBox(
                                  child: Image.network(
                                  _imageurlController.text,
                                  fit: BoxFit.cover,
                                )),
                        ),
                        //TextFormField by default takes as much width as it can get when it is placed inside a row which dosent constrain it, it gives an error
                        //It executes when it loses focus too
                        Expanded(
                          child: TextFormField(
                              /*initialValue: _initValues['imageurl'], - wont work 
                        because this field also involves a controller and if a controller 
                        is involved then it should be used to set a initial value
                        */
                              decoration:
                                  InputDecoration(labelText: 'Imageurl'),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageurlController,
                              focusNode: _imageUrlnode, //keeps track of focus
                              onEditingComplete: () {
                                setState(() {}); //forces an update
                              },
                              onFieldSubmitted: (_) {
                                _saveForm();
                              },
                              //onFieldSubmitted expects a function that takes a string value and saveform dosent take a string value
                              onSaved: (value) {
                                _editedProduct = Product(
                                    title: _editedProduct.title,
                                    price: _editedProduct.price,
                                    description: _editedProduct.description,
                                    imageUrl: value,
                                    id: _editedProduct.id,
                                    isFavorite: _editedProduct.isFavorite);
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please Provide a valid url';
                                }
                                if (!value.startsWith('https')) {
                                  return 'Please enter a url that starts with https';
                                }
                                // if ((!value.endsWith('png') &&
                                //   !value.endsWith('jpeg'))) {
                                // return 'Please enter a valid url that returns an image of type png or jpeg';
                                // }
                                //just because something ends with a jpeg it dosent mean that it is necessarily an image
                                return null;
                              }),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
