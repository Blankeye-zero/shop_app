import 'package:flutter/material.dart';

class CustomRoute<T> extends MaterialPageRoute<T> {
//Material Page route is used to create on the fly page routes.
//It is a generic class therefore for explicit specificity we use the <T> which means type? We should be only changing the animation with this definition
  CustomRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    //  this method overrides the basic transition and allows us to create custom transitions...
    if (settings.name == '/') {
      return child;
    }
    //returning a fadetransition when changing to a different screen
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    if (route.settings.name == '/') {
      return child;
    }
    //returning a fadetransition when changing to a different screen
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
