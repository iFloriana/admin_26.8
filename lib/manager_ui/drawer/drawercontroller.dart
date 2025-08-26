import 'package:get/get.dart';
import '../../main.dart';

class managerDrawerController extends GetxController {
  var selectedPage = 0.obs;
  var fullname = ''.obs;
  var email = ''.obs;
  var appBarTitle = 'Dashboard'.obs;

  void selectPage(int page) {
    selectedPage.value = page;
  }

  @override
  void onInit() {
    super.onInit();
    getUserDetails();
  }

  Future<void> onLogoutPress() async {
    await prefs.onLogout();
  }

  Future<void> getUserDetails() async {
    final manager = await prefs.getManagerUser();
    fullname.value = manager!.manager!.fullName.toString();
    email.value = manager.manager!.email.toString();
  }
}
