import 'package:get/get.dart';
import '../../main.dart';

class DrawermenuController extends GetxController {
  var selectedPage = 0.obs;
  var fullname = ''.obs;
  var email = ''.obs;
  var appBarTitle = 'Dashboard'.obs;

  void selectPage(int page) {
    selectedPage.value = page;
  }
//4.5
  @override
  void onInit() {
    super.onInit();
    getUserDetails();
  }

  Future<void> onLogoutPress() async {
    await prefs.onLogout();
  }

  Future<void> getUserDetails() async {
    final salonDetails = await prefs.getRegisterdetails();
    fullname.value = salonDetails!.admin!.fullName.toString();
    email.value = salonDetails.admin!.email.toString();
  }
}
