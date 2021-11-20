class HttpException implements Exception {
  /*
  We are implementing the abstract class Exception. Object-oriented Programming...
  That simply means that we have to override all of its methods.
  Every class in dart initially extends the Object class that contains a toString() method
  toString() is available on every class 
  */
  final String message;

  HttpException(this.message);

  @override
  String toString() {
    return message; //Instance of HtppException
  }
}
