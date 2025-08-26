class Validation {
  // Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }

    // Regular expression for basic email validation
    String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    RegExp regex = RegExp(emailPattern);

    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    String phonePattern = r'^\d{10}$';
    RegExp regex = RegExp(phonePattern);

    if (!regex.hasMatch(value)) {
      return 'Please enter a valid 10-digit mobile number';
    }

    return null;
  }

  static String? validatename(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Name';
    }

    return null;
  }

  static String? validateSalary(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Salary';
    }

    return null;
  }
   static String? validateDuration(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Salary';
    }

    return null;
  }
  static String? validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please Select Time';
    }

    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Address';
    }
    if (value.length < 10) {
      return 'Please enter a valid Address';
    }
    return null;
  }

  static String? validatedisscription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Discription';
    }
    if (value.length < 10) {
      return 'Please enter a valid Discription';
    }
    return null;
  }

  static String? validationPincode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Pincode';
    }
    if (value.length < 6) {
      return 'Please enter a valid Pincode';
    }
    return null;
  }

  static String? validateisBlanck(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Details';
    }
    return null;
  }
}
