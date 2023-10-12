//implementing the exception class for different kinds of exceptions

//login exceptions

class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

//register exceptions

class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

//generic auth exception

class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
