import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/ui/drawer/Branchmembership/add/branchMembershipAddController.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:get/get.dart';

import '../../../../utils/colors.dart';
import '../../../../utils/custom_text_styles.dart';
import '../../../../utils/validation.dart';
import '../../../../wiget/Custome_button.dart';
import '../../../../wiget/Custome_textfield.dart';
import '../../../../wiget/custome_dropdown.dart';
import '../../../../wiget/custome_text.dart';

class Branchmembershipaddscreen extends StatelessWidget {
  Branchmembershipaddscreen({super.key});
  final Branchmembershipaddcontroller getController =
      Get.put(Branchmembershipaddcontroller());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(title: "Add Branch Membership"),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              spacing: 10,
              children: [
                InputTxtfield_membershipName(),
                subscription_plan(),
                discount_type(),
                InputTxtfield_Membership_Amount(),
                InputTxtfield_discountAmt(),
                InputTxtfield_discription(),
                Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomTextWidget(
                          text: 'Status',
                          textStyle:
                              CustomTextStyles.textFontRegular(size: 14.sp),
                        ),
                        Switch(
                          value: getController.isActive.value,
                          onChanged: (value) {
                            getController.isActive.value = value;
                          },
                          activeColor: primaryColor,
                        ),
                      ],
                    )),
                Btn_Add_membership()
              ],
            )));
  }

  Widget InputTxtfield_discription() {
    return CustomTextFormField(
      controller: getController.descriptionController,
      labelText: 'Description',
      maxLines: 2,
      keyboardType: TextInputType.text,
      validator: (value) => Validation.validatedisscription(value),
    );
  }

  Widget InputTxtfield_membershipName() {
    return CustomTextFormField(
      controller: getController.memberShipNameController,
      labelText: "Name",
      keyboardType: TextInputType.text,
      validator: (value) => Validation.validatename(value),
    );
  }

  Widget subscription_plan() {
    return Obx(() => CustomDropdown<String>(
          value: getController.selected_Subscription_plan.value.isEmpty
              ? null
              : getController.selected_Subscription_plan.value,
          items: getController.Subscription_plan_option,
          hintText: 'Subscription Plan',
          labelText: 'Subscription Plan',
          onChanged: (newValue) {
            if (newValue != null) {
              getController.selected_Subscription_plan.value = newValue;
            }
          },
        ));
  }

  Widget discount_type() {
    return Obx(() => CustomDropdown<String>(
          value: getController.selected_discountType.value.isEmpty
              ? null
              : getController.selected_discountType.value,
          items: getController.discountType_option,
          hintText: 'Discount Type',
          labelText: 'Discount Type',
          onChanged: (newValue) {
            if (newValue != null) {
              getController.selected_discountType.value = newValue;
            }
          },
        ));
  }

  Widget InputTxtfield_discountAmt() {
    return CustomTextFormField(
      controller: getController.discountAmountController,
      labelText: "Discount Amount",
      keyboardType: TextInputType.number,
      validator: (value) => Validation.validateisBlanck(value),
    );
  }

  Widget InputTxtfield_Membership_Amount() {
    return CustomTextFormField(
      controller: getController.membershipAmountController,
      labelText: "Membership Amount",
      keyboardType: TextInputType.number,
      validator: (value) => Validation.validateisBlanck(value),
    );
  }

  Widget Btn_Add_membership() {
    return ElevatedButtonExample(
      text: "Add Membership",
      onPressed: () {
        getController.onBranchAdd();
      },
    );
  }
}
