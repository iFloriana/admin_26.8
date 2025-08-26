import 'package:get/get.dart';
import '../../../main.dart';
import '../../../network/model/branch_package_model.dart';
import '../../../network/network_const.dart';
import '../../../wiget/custome_snackbar.dart';
import '../../network/model/manager_branch_package_model.dart';

class ManagerPackagecontroller extends GetxController {
  final RxList<ManagerBranchPackageModel> packages = <ManagerBranchPackageModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getBranchPackages();
  }
  
  Future<void> getBranchPackages() async {
    isLoading.value = true;
    final loginUser = await prefs.getManagerUser();
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}/branchPackages/by-branch?salon_id=${loginUser?.manager?.salonId}&branch_id=${loginUser?.manager?.branchId?.sId}',
        (json) => json,
      );

      if (response != null) {
        final List<dynamic> packagesData = response['data'] ?? [];
        packages.value = packagesData
            .map((package) => ManagerBranchPackageModel.fromJson(package))
            .toList();
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to fetch packages: $e');
      packages.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePackage(String packageId) async {
    try {
      final loginUser = await prefs.getManagerUser();
      isLoading.value = true;
      final response = await dioClient.deleteData(
        '${Apis.baseUrl}${Endpoints.branchPackages}/$packageId?salon_id=${loginUser!.manager?.salonId}',
        (json) => json,
      );

      if (response != null) {
        packages.removeWhere((package) => package.id == packageId);
        CustomSnackbar.showSuccess('Success', 'Package deleted successfully');
      }
      getBranchPackages();
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to delete package: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
