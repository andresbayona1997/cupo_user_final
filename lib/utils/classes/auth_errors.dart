class AuthErrors {

  static String getErrorMsg(String code) {
    String _errorMessage;
    switch(code) {
      case 'ERROR_WEAK_PASSWORD': 
        _errorMessage = 'La contraseña es muy debil';
        break;
      case 'ERROR_INVALID_EMAIL':
        _errorMessage = 'El email es invalido';
        break;
      case 'ERROR_EMAIL_ALREADY_IN_USE':
        _errorMessage = 'Este email ya esta en uso';
        break;
      case 'ERROR_WRONG_PASSWORD':
        _errorMessage = 'La contraseña es incorrecta';
        break;  
      case 'ERROR_USER_NOT_FOUND':
        _errorMessage = 'El usuario no existe';
        break;
      case 'ERROR_INVALID_CREDENTIAL':
        _errorMessage = 'Las credenciales han expirado';
        break;
      case 'ERROR_USER_DISABLED':
        _errorMessage = 'Usuario deshabilitado';
        break;
      case 'ERROR_OPERATION_NOT_ALLOWED':
        _errorMessage = 'Operación no permitida';
        break;
      case 'ERROR_INVALID_ACTION_CODE': 
        _errorMessage = 'Codigo invalido';
        break;
      case 'ERROR_SESSION_EXPIRED':
        _errorMessage = 'El codigo ha expirado';
        break;
      default: 
        _errorMessage = 'A ocurrido un error';  
    }
    return _errorMessage;
  }
}