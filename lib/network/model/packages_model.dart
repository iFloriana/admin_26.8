class Package_model {
  String? sId;
  String? packageName;
  String? description;
  int? price;
  List<String>? servicesIncluded;
  String? expirationDate;
  String? subscriptionPlan;
  int? iV;

  Package_model(
      {this.sId,
      this.packageName,
      this.description,
      this.price,
      this.servicesIncluded,
      this.expirationDate,
      this.subscriptionPlan,
      this.iV});

  Package_model.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    packageName = json['package_name'];
    description = json['description'];
    price = json['price'];
    servicesIncluded = json['services_included'].cast<String>();
    expirationDate = json['expiration_date'];
    subscriptionPlan = json['subscription_plan'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['package_name'] = this.packageName;
    data['description'] = this.description;
    data['price'] = this.price;
    data['services_included'] = this.servicesIncluded;
    data['expiration_date'] = this.expirationDate;
    data['subscription_plan'] = this.subscriptionPlan;
    data['__v'] = this.iV;
    return data;
  }
}
