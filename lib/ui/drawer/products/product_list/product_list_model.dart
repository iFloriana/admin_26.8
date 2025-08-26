import 'dart:convert';

List<Product> productFromJson(String str) {
  final decoded = json.decode(str);
  if (decoded is List) {
    return List<Product>.from(decoded.map((x) => Product.fromJson(x)));
  }
  if (decoded is Map && decoded['data'] is List) {
    final data = decoded['data'] as List;
    return List<Product>.from(data.map((x) => Product.fromJson(x)));
  }
  return [];
}

String productToJson(List<Product> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Product {
  String id;
  List<BranchId> branchId;
  ProductImage? image;
  String productName;
  String description;
  Brand? brandId;
  CategoryId? categoryId;
  TagId? tagId;
  UnitId? unitId;
  int status;
  int hasVariations;
  List<dynamic> variationId;
  List<Variant> variants;
  String salonId;
  int? price;
  int? stock;
  String? sku;
  String? code;
  ProductDiscount? productDiscount;
  String? imageUrl;

  Product({
    required this.id,
    required this.branchId,
    this.image,
    required this.productName,
    required this.description,
    this.brandId,
    this.categoryId,
    this.tagId,
    this.unitId,
    required this.status,
    required this.hasVariations,
    required this.variationId,
    required this.variants,
    required this.salonId,
    this.price,
    this.stock,
    this.sku,
    this.code,
    this.productDiscount,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["_id"],
        branchId: List<BranchId>.from(
            json["branch_id"].map((x) => BranchId.fromJson(x))),
        image:
            json["image"] == null ? null : ProductImage.fromJson(json["image"]),
        productName: json["product_name"],
        description: json["description"],
        brandId:
            json["brand_id"] == null ? null : Brand.fromJson(json["brand_id"]),
        categoryId: json["category_id"] == null
            ? null
            : CategoryId.fromJson(json["category_id"]),
        tagId: json["tag_id"] == null ? null : TagId.fromJson(json["tag_id"]),
        unitId:
            json["unit_id"] == null ? null : UnitId.fromJson(json["unit_id"]),
        status: json["status"],
        hasVariations: json["has_variations"],
        variationId: List<dynamic>.from(json["variation_id"].map((x) => x)),
        variants: List<Variant>.from(
            json["variants"].map((x) => Variant.fromJson(x))),
        salonId: json["salon_id"],
        price: json["price"],
        stock: json["stock"],
        sku: json["sku"],
        code: json["code"],
        productDiscount: json["product_discount"] == null
            ? null
            : ProductDiscount.fromJson(json["product_discount"]),
        imageUrl: json["image_url"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "branch_id": List<dynamic>.from(branchId.map((x) => x.toJson())),
        "image": image?.toJson(),
        "product_name": productName,
        "description": description,
        "brand_id": brandId?.toJson(),
        "category_id": categoryId?.toJson(),
        "tag_id": tagId?.toJson(),
        "unit_id": unitId?.toJson(),
        "status": status,
        "has_variations": hasVariations,
        "variation_id": List<dynamic>.from(variationId.map((x) => x)),
        "variants": List<dynamic>.from(variants.map((x) => x.toJson())),
        "salon_id": salonId,
        "price": price,
        "stock": stock,
        "sku": sku,
        "code": code,
        "product_discount": productDiscount?.toJson(),
        "image_url": imageUrl,
      };
}

class ProductImage {
  String data;
  String contentType;
  String originalName;
  String extension;

  ProductImage({
    required this.data,
    required this.contentType,
    required this.originalName,
    required this.extension,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) => ProductImage(
        data: json["data"],
        contentType: json["contentType"],
        originalName: json["originalName"],
        extension: json["extension"],
      );

  Map<String, dynamic> toJson() => {
        "data": data,
        "contentType": contentType,
        "originalName": originalName,
        "extension": extension,
      };
}

class ProductDiscount {
  String discountType;
  DateTime? startDate;
  DateTime? endDate;
  String discountAmount;

  ProductDiscount({
    required this.discountType,
    this.startDate,
    this.endDate,
    required this.discountAmount,
  });

  factory ProductDiscount.fromJson(Map<String, dynamic> json) =>
      ProductDiscount(
        discountType: json["discount_type"],
        startDate: json["start_date"] == null
            ? null
            : DateTime.parse(json["start_date"]),
        endDate:
            json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
        discountAmount: json["discount_amount"],
      );

  Map<String, dynamic> toJson() => {
        "discount_type": discountType,
        "start_date": startDate?.toIso8601String(),
        "end_date": endDate?.toIso8601String(),
        "discount_amount": discountAmount,
      };
}

class BranchId {
  String id;
  String name;
  String salonId;
  String category;
  int status;
  String contactEmail;
  String contactNumber;
  List<String> paymentMethod;
  List<String> serviceId;
  String address;
  String landmark;
  String country;
  String state;
  String city;
  String postalCode;
  // double latitude;
  // double longitude;
  String description;
  // String image;
  int ratingStar;
  int totalReview;
  DateTime createdAt;
  DateTime updatedAt;
  int v;
  String? imageUrl;

  BranchId({
    required this.id,
    required this.name,
    required this.salonId,
    required this.category,
    required this.status,
    required this.contactEmail,
    required this.contactNumber,
    required this.paymentMethod,
    required this.serviceId,
    required this.address,
    required this.landmark,
    required this.country,
    required this.state,
    required this.city,
    required this.postalCode,
    // required this.latitude,
    // required this.longitude,
    required this.description,
    // required this.image,
    required this.ratingStar,
    required this.totalReview,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    this.imageUrl,
  });

  factory BranchId.fromJson(Map<String, dynamic> json) => BranchId(
        id: json["_id"],
        name: json["name"],
        salonId: json["salon_id"],
        category: json["category"],
        status: json["status"],
        contactEmail: json["contact_email"],
        contactNumber: json["contact_number"],
        paymentMethod: List<String>.from(json["payment_method"].map((x) => x)),
        serviceId: List<String>.from(json["service_id"].map((x) => x)),
        address: json["address"],
        landmark: json["landmark"],
        country: json["country"],
        state: json["state"],
        city: json["city"],
        postalCode: json["postal_code"],
        // latitude: json["latitude"]?.toDouble(),
        // longitude: json["longitude"]?.toDouble(),
        description: json["description"],
        // image: json["image"],
        ratingStar: json["rating_star"],
        totalReview: json["total_review"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        imageUrl: json["image_url"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "salon_id": salonId,
        "category": category,
        "status": status,
        "contact_email": contactEmail,
        "contact_number": contactNumber,
        "payment_method": List<dynamic>.from(paymentMethod.map((x) => x)),
        "service_id": List<dynamic>.from(serviceId.map((x) => x)),
        "address": address,
        "landmark": landmark,
        "country": country,
        "state": state,
        "city": city,
        "postal_code": postalCode,
        // "latitude": latitude,
        // "longitude": longitude,
        "description": description,
        // "image": image,
        "rating_star": ratingStar,
        "total_review": totalReview,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
        "image_url": imageUrl,
      };
}

class Brand {
  String id;
  List<String> branchId;
  dynamic image;
  String name;
  int status;
  String salonId;
  DateTime createdAt;
  DateTime updatedAt;
  int v;
  String? imageUrl;

  Brand({
    required this.id,
    required this.branchId,
    this.image,
    required this.name,
    required this.status,
    required this.salonId,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    this.imageUrl,
  });

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        id: json["_id"],
        branchId: List<String>.from(json["branch_id"].map((x) => x)),
        image: json["image"],
        name: json["name"],
        status: json["status"],
        salonId: json["salon_id"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "branch_id": List<dynamic>.from(branchId.map((x) => x)),
        "image": image,
        "name": name,
        "status": status,
        "salon_id": salonId,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
      };
}

class CategoryId {
  String id;
  List<String> branchId;
  // String image;
  String name;
  List<String> brandId;
  int status;
  String salonId;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  CategoryId({
    required this.id,
    required this.branchId,
    // required this.image,
    required this.name,
    required this.brandId,
    required this.status,
    required this.salonId,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory CategoryId.fromJson(Map<String, dynamic> json) => CategoryId(
        id: json["_id"],
        branchId: List<String>.from(json["branch_id"].map((x) => x)),
        // image: json["image"],
        name: json["name"],
        brandId: List<String>.from(json["brand_id"].map((x) => x)),
        status: json["status"],
        salonId: json["salon_id"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "branch_id": List<dynamic>.from(branchId.map((x) => x)),
        // "image": image,
        "name": name,
        "brand_id": List<dynamic>.from(brandId.map((x) => x)),
        "status": status,
        "salon_id": salonId,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
      };
}

class TagId {
  String id;
  List<String> branchId;
  String name;
  int status;
  String salonId;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  TagId({
    required this.id,
    required this.branchId,
    required this.name,
    required this.status,
    required this.salonId,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory TagId.fromJson(Map<String, dynamic> json) => TagId(
        id: json["_id"],
        branchId: List<String>.from(json["branch_id"].map((x) => x)),
        name: json["name"],
        status: json["status"],
        salonId: json["salon_id"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "branch_id": List<dynamic>.from(branchId.map((x) => x)),
        "name": name,
        "status": status,
        "salon_id": salonId,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
      };
}

class UnitId {
  String id;
  List<String> branchId;
  String name;
  int status;
  String salonId;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  UnitId({
    required this.id,
    required this.branchId,
    required this.name,
    required this.status,
    required this.salonId,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory UnitId.fromJson(Map<String, dynamic> json) => UnitId(
        id: json["_id"],
        branchId: List<String>.from(json["branch_id"].map((x) => x)),
        name: json["name"],
        status: json["status"],
        salonId: json["salon_id"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "branch_id": List<dynamic>.from(branchId.map((x) => x)),
        "name": name,
        "status": status,
        "salon_id": salonId,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
      };
}

class Variant {
  List<Combination> combination;
  int price;
  int stock;
  String sku;
  String code;
  String id;

  Variant({
    required this.combination,
    required this.price,
    required this.stock,
    required this.sku,
    required this.code,
    required this.id,
  });

  factory Variant.fromJson(Map<String, dynamic> json) => Variant(
        combination: List<Combination>.from(
            json["combination"].map((x) => Combination.fromJson(x))),
        price: json["price"],
        stock: json["stock"],
        sku: json["sku"],
        code: json["code"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "combination": List<dynamic>.from(combination.map((x) => x.toJson())),
        "price": price,
        "stock": stock,
        "sku": sku,
        "code": code,
        "_id": id,
      };
}

class Combination {
  String variationType;
  String variationValue;
  String id;

  Combination({
    required this.variationType,
    required this.variationValue,
    required this.id,
  });

  factory Combination.fromJson(Map<String, dynamic> json) => Combination(
        variationType: json["variation_type"],
        variationValue: json["variation_value"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "variation_type": variationType,
        "variation_value": variationValue,
        "_id": id,
      };
}
