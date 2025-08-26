import 'package:flutter_template/main.dart';
import 'package:get/get.dart';

import '../../../../../network/model/variation_product.dart';
import '../../../../../network/network_const.dart';
import '../../../../../wiget/custome_snackbar.dart';

class ManagerVariationGetcontroller extends GetxController {
  var variations = <Data>[].obs;

  @override
  void onInit() {
    super.onInit();
    getVariation();
  }

  Future<void> getVariation() async {
    final loginUser = await prefs.getManagerUser();
    try {
      final response = await dioClient.getData(
        '${Apis.baseUrl}${Endpoints.postVariation}?salon_id=${loginUser!.manager?.salonId}',
        (json) => json,
      );
      if (response != null && response['data'] != null) {
        final List<dynamic> data = response['data'];
        variations.value = data.map((e) => Data.fromJson(e)).toList();
      }

      print(
          '=====> ${Apis.baseUrl}${Endpoints.postVariation}?salon_id=${loginUser!.manager?.salonId}');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to fetch variations: $e');
    }
  }

  Future<void> deleteVariation(String id) async {
    final loginUser = await prefs.getManagerUser();
    try {
      await dioClient.deleteData(
        '${Apis.baseUrl}${Endpoints.postVariation}/$id?salon_id=${loginUser!.manager?.salonId}',
        (json) => json,
      );
      variations.removeWhere((v) => v.sId == id);
      CustomSnackbar.showSuccess('Success', 'Variation deleted successfully');
    } catch (e) {
      CustomSnackbar.showError('Error', 'Failed to delete variation: $e');
    }
  }
}
