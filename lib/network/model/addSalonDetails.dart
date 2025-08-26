class AddsalonDetails {
  String? name;
  String? description;
  String? address;
  String? contactNumber;
  String? contactEmail;
  String? openingTime;
  String? closingTime;
  String? category;
  int? status;
  String? packageId;
  String? signupId;

  AddsalonDetails(
      {this.name,
      this.description,
      this.address,
      this.contactNumber,
      this.contactEmail,
      this.openingTime,
      this.closingTime,
      this.category,
      this.status,
      this.packageId,
      this.signupId});

  AddsalonDetails.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    description = json['description'];
    address = json['address'];
    contactNumber = json['contact_number'];
    contactEmail = json['contact_email'];
    openingTime = json['opening_time'];
    closingTime = json['closing_time'];
    category = json['category'];
    status = json['status'];
    packageId = json['package_id'];
    signupId = json['signup_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['description'] = this.description;
    data['address'] = this.address;
    data['contact_number'] = this.contactNumber;
    data['contact_email'] = this.contactEmail;
    data['opening_time'] = this.openingTime;
    data['closing_time'] = this.closingTime;
    data['category'] = this.category;
    data['status'] = this.status;
    data['package_id'] = this.packageId;
    data['signup_id'] = this.signupId;
    return data;
  }
}
