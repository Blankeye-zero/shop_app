import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../secrets/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String
      _token; //this is a temporary token variable that holds the token generated by the backend, in our case, firebase.
  DateTime _expiryDate; //stores the expiry DateTime
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    //logic to return boolean
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }

    return null;
  }

  String get userId {
    return _userId;
  }

  //method used to sign the user up

  Future<void> _authenticate(
      String email, String password, String urlPart) async {
    //for info - https://firebase.google.com/docs/reference/rest/auth/
    try {
      final url = Uri.https(
          'identitytoolkit.googleapis.com', 'v1/accounts:$urlPart', A.param);
      final response = await http.post(
        url,
        body: json.encode(
          {'email': email, 'password': password, 'returnSecureToken': true},
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      _autoLogout();
      notifyListeners();
      //working with shared preferences also involves working with futures and thus the need for async and await
      final prefs = await SharedPreferences
          .getInstance(); //This returns a future that eventually returns a shared preferences instance.Now we can use prefs to set persistent key-value pairs.
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString(
          'userData', userData); //we are now storing the map locally
    } catch (e) {
      // Throw error
      print(e);
      throw (e);
    }
  }

  Future<void> signup(String email, String password) async {
    await _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    await _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    //creating an instance to shared pref and retrieving key value pairs from persistent storage
    final sharedpref = await SharedPreferences.getInstance();
    if (!sharedpref.containsKey('userData')) return false;
    final extractedUserData =
        json.decode(sharedpref.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout(); //reinitializing the timer
    return true; // because we need a future that returns a bool on either condition.
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) _authTimer.cancel();
    _authTimer = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear(); //to purge all data
    //prefs.remove('userData'); to remove specific data
  }

  void _autoLogout() {
    if (_authTimer != null) _authTimer.cancel();
    //The difference method returns the diff between two timestamps
    final ttl = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: ttl), logout);
  }
}
