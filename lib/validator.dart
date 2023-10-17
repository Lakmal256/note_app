class StringValidators {
  StringValidators._();

  static bool isEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }
}
