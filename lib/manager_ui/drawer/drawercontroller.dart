import 'package:get/get.dart';
import '../../main.dart';

class managerDrawerController extends GetxController {
  var selectedPage = 0.obs;
  var fullname = ''.obs;
  var email = ''.obs;
  var image = ''.obs;
  var appBarTitle = 'Dashboard'.obs;

  void selectPage(int page) {
    selectedPage.value = page;
  }

  @override
  void onInit() {
    super.onInit();
    getUserDetails();
    print("========> u r here");
  }

  Future<void> onLogoutPress() async {
    await prefs.onLogout();
  }

  Future<void> getUserDetails() async {
    final manager = await prefs.getManagerUser();
    fullname.value = manager!.manager!.fullName.toString();
    email.value = manager.manager!.email.toString();
    image.value = manager.manager!.imageUrl.toString();
  }
}
