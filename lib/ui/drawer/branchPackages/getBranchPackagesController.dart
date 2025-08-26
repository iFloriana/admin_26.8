import 'package:get/get.dart';
import '../../../main.dart';
import '../../../network/model/branch_package_model.dart';
import '../../../network/network_const.dart';
import '../../../wiget/custome_snackbar.dart';

class GetBranchPackagesController extends GetxController {
  final RxList<BranchPackageModel> packages = <BranchPackageModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getBranchPackages();
  }

  Future<void> getBranchPackages() async {
    isLoading.value = true;
    final loginUser = await prefs.getUser();
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.branchPackages}?salon_id=${loginUser!.salonId}',
        (json) => json,
      );

      if (response != null) {
        final List<dynamic> packagesData = response['data'] ?? [];
        packages.value = packagesData
            .map((package) => BranchPackageModel.fromJson(package))
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
      final loginUser = await prefs.getUser();
      isLoading.value = true;
      final response = await dioClient.deleteData(
        '${Apis.baseUrl}${Endpoints.branchPackages}/$packageId?salon_id=${loginUser!.salonId}',
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
