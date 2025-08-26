class InhouseProductModel {
  final String? message;
  final List<InhouseProductData> data;

  InhouseProductModel({this.message, required this.data});

  factory InhouseProductModel.fromJson(Map<String, dynamic> json) {
    return InhouseProductModel(
      message: json['message'],
      data: List<InhouseProductData>.from(
        json['data'].map((x) => InhouseProductData.fromJson(x)),
      ),
    );
  }
}

class InhouseProductData {
  final String id;
  final Salon? salon;
  final Branch? branch;
  final Staff? staff;
  final List<ProductItem> product;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  InhouseProductData({
    required this.id,
    this.salon,
    this.branch,
    this.staff,
    required this.product,
    this.createdAt,
    this.updatedAt,
  });

  factory InhouseProductData.fromJson(Map<String, dynamic> json) {
    return InhouseProductData(
      id: json['_id'] ?? '',
      salon: json['salon_id'] != null ? Salon.fromJson(json['salon_id']) : null,
      branch:
          json['branch_id'] != null ? Branch.fromJson(json['branch_id']) : null,
      staff: json['staff_id'] != null ? Staff.fromJson(json['staff_id']) : null,
      product: List<ProductItem>.from(
        json['product']?.map((x) => ProductItem.fromJson(x)) ?? [],
      ),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

class Salon {
  final String id;
  final String? salonName;

  Salon({required this.id, this.salonName});

  factory Salon.fromJson(Map<String, dynamic> json) {
    return Salon(
      id: json['_id'] ?? '',
      salonName: json['salon_name'],
    );
  }
}

class Branch {
  final String id;
  final String? name;

  Branch({required this.id, this.name});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['_id'] ?? '',
      name: json['name'],
    );
  }
}

class Staff {
  final String id;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? gender;
  final String? branchId;
  final String? salonId;
  final List<String>? serviceId;
  final int? status;
  final String? image;
  final String? specialization;
  final String? assignedCommissionId;
  final bool? showInCalendar;
  final ShiftTime? assignTime;
  final LunchTime? lunchTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Staff({
    required this.id,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.gender,
    this.branchId,
    this.salonId,
    this.serviceId,
    this.status,
    this.image,
    this.specialization,
    this.assignedCommissionId,
    this.showInCalendar,
    this.assignTime,
    this.lunchTime,
    this.createdAt,
    this.updatedAt,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['_id'] ?? '',
      fullName: json['full_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      gender: json['gender'],
      branchId: json['branch_id'],
      salonId: json['salon_id'],
      serviceId: json['service_id'] != null
          ? List<String>.from(json['service_id'])
          : null,
      status: _parseNumericField(json['status']),
      image: _parseImageField(json['image']),
      specialization: json['specialization'],
      assignedCommissionId: json['assigned_commission_id'],
      showInCalendar: _parseBooleanField(json['show_in_calendar']),
      assignTime: json['assign_time'] != null
          ? ShiftTime.fromJson(json['assign_time'])
          : null,
      lunchTime: json['lunch_time'] != null
          ? LunchTime.fromJson(json['lunch_time'])
          : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Helper method to safely parse boolean fields
  static bool? _parseBooleanField(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }
    return false;
  }

  // Helper method to safely parse image field
  static String? _parseImageField(dynamic imageData) {
    if (imageData == null) return null;
    if (imageData is String) return imageData;
    if (imageData is Map) {
      // If it's a map, try to extract a string value
      // You can customize this based on your API response structure
      return imageData.toString();
    }
    // For any other type, convert to string
    return imageData.toString();
  }

  // Helper method to safely parse numeric fields
  static int? _parseNumericField(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is double) {
      return value.toInt();
    }
    return null;
  }
}

class ShiftTime {
  final String? startShift;
  final String? endShift;

  ShiftTime({this.startShift, this.endShift});

  factory ShiftTime.fromJson(Map<String, dynamic> json) {
    return ShiftTime(
      startShift: json['start_shift'],
      endShift: json['end_shift'],
    );
  }
}

class LunchTime {
  final int? duration;
  final String? timing;

  LunchTime({this.duration, this.timing});

  factory LunchTime.fromJson(Map<String, dynamic> json) {
    return LunchTime(
      duration: _parseNumericField(json['duration']),
      timing: json['timing'],
    );
  }

  // Helper method to safely parse numeric fields
  static int? _parseNumericField(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is double) {
      return value.toInt();
    }
    return null;
  }
}

class ProductItem {
  final Product? product;
  final String? variantId;
  final int? quantity;
  final Variant? variant;

  ProductItem({
    this.product,
    this.variantId,
    this.quantity,
    this.variant,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      product: json['product_id'] != null
          ? Product.fromJson(json['product_id'])
          : null,
      variantId: json['variant_id'],
      quantity: _parseNumericField(json['quantity']),
      variant:
          json['variant'] != null ? Variant.fromJson(json['variant']) : null,
    );
  }

  // Helper method to safely parse numeric fields
  static int? _parseNumericField(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is double) {
      return value.toInt();
    }
    return null;
  }
}

class Product {
  final String id;
  final String? productName;
  final String? description;
  final List<String>? branchId;
  final String? brandId;
  final String? categoryId;
  final String? tagId;
  final String? unitId;
  final int? status;
  final bool? hasVariations;
  final List<Variant>? variants;
  final String? sku;
  final String? image;
  final String? code;
  final String? salonId;
  final int? price;
  final int? stock;
  final ProductDiscount? productDiscount;

  Product({
    required this.id,
    this.productName,
    this.description,
    this.branchId,
    this.brandId,
    this.categoryId,
    this.tagId,
    this.unitId,
    this.status,
    this.hasVariations,
    this.variants,
    this.salonId,
    this.price,
    this.stock,
    this.image,
    this.code,
    this.sku,
    this.productDiscount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      productName: json['product_name'],
      description: json['description'],
      branchId: json['branch_id'] != null
          ? List<String>.from(json['branch_id'])
          : null,
      brandId: json['brand_id'],
      categoryId: json['category_id'],
      tagId: json['tag_id'],
      unitId: json['unit_id'],
      status: _parseNumericField(json['status']),
      hasVariations: _parseHasVariations(json['has_variations']),
      variants: json['variants'] != null
          ? List<Variant>.from(json['variants'].map((x) => Variant.fromJson(x)))
          : null,
      sku: json['sku'] ?? '',
      image: _parseImageField(json['image']),
      code: json['code'],
      salonId: json['salon_id'],
      price: _parseNumericField(json['price']),
      stock: _parseNumericField(json['stock']),
      productDiscount: json['product_discount'] != null
          ? ProductDiscount.fromJson(json['product_discount'])
          : null,
    );
  }

  // Helper method to safely parse image field
  static String? _parseImageField(dynamic imageData) {
    if (imageData == null) return null;
    if (imageData is String) return imageData;
    if (imageData is Map) {
      // If it's a map, try to extract a string value
      // You can customize this based on your API response structure
      return imageData.toString();
    }
    // For any other type, convert to string
    return imageData.toString();
  }

  // Helper method to safely parse numeric fields
  static int? _parseNumericField(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is double) {
      return value.toInt();
    }
    return null;
  }

  // Helper method to safely parse has_variations field
  static bool? _parseHasVariations(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }
    return false;
  }
}

class Variant {
  final String id;
  final int? price;
  final int? stock;
  final String? sku;
  final String? code;
  final List<VariationCombination>? combination;

  Variant({
    required this.id,
    this.price,
    this.stock,
    this.sku,
    this.code,
    this.combination,
  });

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      id: json['_id'] ?? '',
      price: _parseNumericField(json['price']),
      stock: _parseNumericField(json['stock']),
      sku: json['sku'],
      code: json['code'],
      combination: json['combination'] != null
          ? List<VariationCombination>.from(
              json['combination'].map((x) => VariationCombination.fromJson(x)),
            )
          : null,
    );
  }

  // Helper method to safely parse numeric fields
  static int? _parseNumericField(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is double) {
      return value.toInt();
    }
    return null;
  }
}

class VariationCombination {
  final String? variationType;
  final String? variationValue;
  final String? id;

  VariationCombination({
    this.variationType,
    this.variationValue,
    this.id,
  });

  factory VariationCombination.fromJson(Map<String, dynamic> json) {
    return VariationCombination(
      variationType: json['variation_type'],
      variationValue: json['variation_value'],
      id: json['_id'],
    );
  }
}

class ProductDiscount {
  final String? discountType;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? discountAmount;

  ProductDiscount({
    this.discountType,
    this.startDate,
    this.endDate,
    this.discountAmount,
  });

  factory ProductDiscount.fromJson(Map<String, dynamic> json) {
    return ProductDiscount(
      discountType: json['discount_type'],
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      discountAmount: _parseDiscountAmount(json['discount_amount']),
    );
  }

  // Helper method to safely parse discount amount
  static int? _parseDiscountAmount(dynamic amount) {
    if (amount == null) return null;
    if (amount is int) return amount;
    if (amount is String) {
      return int.tryParse(amount);
    }
    if (amount is double) {
      return amount.toInt();
    }
    return null;
  }
}
