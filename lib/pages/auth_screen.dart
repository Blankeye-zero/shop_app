import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    //final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10, 0);

    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        //The Stack widget allows us to place widgets on top of each other in a three dimensional space
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  //Simplay a colour gradient
                  Colors.blueGrey,
                  Colors.blue,
                  Colors.blueAccent,
                  Colors.brown,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1, 1, 0],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                //centering the authentication form
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      //This is used to offset the MyShop container
                      //Matrix4 returns an object that describes the transformation of a container
                      //rotationZ is used to rotate in the z axis
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: //transformConfig,
                          Matrix4.rotationZ(-8 * pi / 180)..translate(-10.0),
                      // The .. operator calls the translate and then returns what the previous statement returns in this case, the rotationZ
                      //this operator returns what seems to take two lines and a variable and returns the same in a line.
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: Theme.of(context).colorScheme.primary,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 20,
                            color: Theme.of(context).colorScheme.secondary,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'Shopper',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontFamily: 'BungeeInline',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  //SingleTickerProviderStateMixin provided by material.dart brings to the table an array of functions that are used by the AnimationController and the vsync param.
  //It also lets a widget know when a frame update is due - animations need that information to play smoothly
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  //we need a timer iterable that fires every 60 ms to change to container height gradually...
  //but flutter already has an animation controller class so dont need to reinvent the wheel.
  //var containerHeight = 260;
  AnimationController _animator; // A class provided by flutter
  Animation<Offset>
      _slideAnimator; // An animation object - an entity that we are going to animate - in this case the Size.
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    //Both the _animator and _heightAnimator must be initialized once a state object is created.
    super.initState();
    //Animation COntroller gets a vsync param where we give it a pointer to a widget where it only plays the animation once the widget is rendered.
    _animator =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _slideAnimator = Tween<Offset>(begin: Offset(0, -1.5), end: Offset(0, 0))
        .animate(
            CurvedAnimation(parent: _animator, curve: Curves.fastOutSlowIn));
    _opacityAnimation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _animator, curve: Curves.easeIn));
    // _heightAnimator.addListener(() =>
    //     setState(() {})); //rerunning the build method to redraw the screen.
    // //experiment with different animations of Curves.*
    //Tween class is generic and we have to mention the type of what we are going to animate between two values..
    //Tween itself wont animate values, it just returns them.. We have to call .animate.
  }

  @override
  void dispose() {
    super.dispose();
    _animator.dispose();
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occured'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false)
            .login(_authData['email'], _authData['password']);
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false)
            .signup(_authData['email'], _authData['password']);
      }
    } on Exception catch (e) {
      String errorMessage = 'Authentication Failed';
      if (e.toString().contains('EMAIL_EXISTS')) {
        errorMessage = "This Email address is already in use";
      } else if (e.toString().contains('INVALID_EMALID')) {
        errorMessage = "This is not a valid email address";
      } else if (e.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak';
      } else if (e.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Email not found';
      } else if (e.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid Password';
      } else {
        return;
      }
      _showError(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _animator.forward(); //controller.forward() starts the animation
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _animator.reverse(); //reversing the animation.
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer
          /*Without manually setting up a listener to the animation, we are using the AnimatedBuilder Widget
      for custom animation, we use the animated builder but for well known/ predefined animation, we use Animated Containers;
       AnimatedBuilder(
        animation: _heightAnimator,
        builder: (ctx, ch) => Container*/
          (
        height: _authMode == AuthMode.Signup ? 320 : 260,
        duration: Duration(milliseconds: 300),
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        curve: Curves.easeIn,
        /*height: _heightAnimator.value.height,
        constraints: BoxConstraints(minHeight: _heightAnimator.value.height),
        We donot need our own controller since animated container smoothly transitions between two values on its own.
        Therefore height animator isnt needed with animated container, maybe with animated builder
        */
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        // child: ch),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                /*if (_authMode == AuthMode.Signup) 
                We originally used an if statement to adjust the dimensions of the signup box, but we could do this using a built in fade transition widget
                The FadeTransition widget takes an argument opacity in order to function. The opacity could be made dynamic with the help of an explicitly 
                defined controller */
                AnimatedContainer(
                  constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                      maxHeight: _authMode == AuthMode.Signup ? 120 : 0),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  //The more animations that we nest into each other, The more inefficient the overall performance of the application gets
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimator,
                      child: TextFormField(
                        enabled: _authMode == AuthMode.Signup,
                        decoration:
                            InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: _authMode == AuthMode.Signup
                            ? (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match!';
                                } else
                                  return null;
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  TextButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(30),
                    // ),
                    // padding:

                    // color: Theme.of(context).primaryColor,
                    // textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                TextButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  // padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  // textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
