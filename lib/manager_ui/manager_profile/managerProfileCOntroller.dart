import 'package:get/get.dart';
import '../../main.dart';

class Managerprofilecontroller extends GetxController {
  var fullname = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var image = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getUserDetails();
  }

  Future<void> getUserDetails() async {
    final salonDetails = await prefs.getManagerUser();
    fullname.value = salonDetails!.manager!.fullName.toString();
    phone.value = salonDetails.manager!.contactNumber.toString();
    email.value = salonDetails.manager!.email.toString();
    image.value = salonDetails.manager!.imageUrl.toString();
  }
}
