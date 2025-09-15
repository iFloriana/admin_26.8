import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/manager_ui/drawer/drawercontroller.dart';
import 'package:flutter_template/route/app_route.dart';
import 'package:flutter_template/utils/app_images.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/custome_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../network/network_const.dart';
import '../../utils/custom_text_styles.dart';

class ManagerDrawerScreen extends StatelessWidget {
  ManagerDrawerScreen({super.key});
  final getController = Get.put(managerDrawerController());
  @override
  Widget build(BuildContext context) {
    final List<DrawerItem> drawerItems = [
      DrawerItem(
          title: 'Dashboard',
          icon: FontAwesomeIcons.gauge,
          route: Routes.ManagerDashboardScreen),
      DrawerItem(
          title: 'Booking',
          icon: FontAwesomeIcons.calendarDays,
          route: Routes.Managerappointmentsscreen),
      DrawerItem(
        title: 'Services',
        route: Routes.ManagerServicescreen, // parent doesn’t navigate
        icon: Icons.room_service_outlined,
      ),
      DrawerItem(
        title: 'packages',
        route: Routes.ManagerPackagescreen, // parent doesn’t navigate
        icon: Icons.room_service_outlined,
      ),
      DrawerItem(
          title: 'Users',
          icon: Icons.supervised_user_circle_outlined,
          route: '',
          subItems: [
            DrawerItem(
                title: 'Staff',
                icon: Icons.manage_accounts_outlined,
                route: Routes.MenagerStaffScreen),
            DrawerItem(
                title: 'Customer',
                icon: Icons.person_search_outlined,
                route: Routes.ManagerGetStaffScreen),
          ]),
      DrawerItem(
          title: 'Reports',
          icon: Icons.receipt_outlined,
          route: '', // parent doesn’t navigate
          subItems: [
            DrawerItem(
                title: 'Customer Package',
                icon: Icons.edit_document,
                route: Routes.ManagerCustomerPackageReportScreen),
            DrawerItem(
                title: 'Customer Membership',
                icon: Icons.stacked_line_chart_outlined,
                route: Routes.ManagerCustomerMembershipReportScreen)
          ]),
      DrawerItem(
          title: 'Finance',
          icon: Icons.format_line_spacing_rounded,
          route: '',
          subItems: [
            DrawerItem(
                title: 'Tax',
                icon: Icons.format_textdirection_l_to_r_outlined,
                route: Routes.ManagerTaxesScreen),
            DrawerItem(
                title: 'Coupons',
                icon: Icons.paid_outlined,
                route: Routes.ManagerCouponsScreen),
          ]),
      DrawerItem(
          title: 'Products',
          icon: Icons.shopping_cart_checkout_outlined,
          route: '',
          subItems: [
            DrawerItem(
                title: 'All Products',
                icon: Icons.shopping_bag_outlined,
                route: Routes.ManagerProductListScreen),
            DrawerItem(
                title: 'Brands',
                icon: Icons.business_outlined,
                route: Routes.managerGetbrandsscreen),
            DrawerItem(
                title: 'Category',
                icon: Icons.list_alt_rounded,
                route: Routes.ManagerCategoryscreen),
            DrawerItem(
                title: 'Sub Category',
                icon: Icons.category_outlined, 
                route: Routes.ManagerSubcategoryscreen),
            DrawerItem(
                title: 'Units',
                icon: Icons.ac_unit_outlined,
                route: Routes.ManagerUnitsscreen),
            DrawerItem(
                title: 'Tags',
                icon: Icons.list,
                route: Routes.ManagerTagsscreen),
            // DrawerItem(
            //     title: 'Product Variation',
            //     icon: Icons.line_style_sharp,
            //     route: Routes.ManagerVariationGetscreen),
          ]),
      DrawerItem(
          title: 'orders',
          icon: Icons.paid_outlined,
          route: Routes.ManagerOrderReportScreen),
      DrawerItem(
          title: 'Product Cunsumption',
          icon: Icons.edit_document,
          route: Routes.ManagerINhouseScreen),
      DrawerItem(
        title: 'Logout',
        icon: Icons.logout,
        route: '',
        isLogout: true,
      ),
    ];

    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: primaryColor),
            currentAccountPicture: GestureDetector(
              onTap: () => Get.toNamed(Routes.Managerprofilescreen),
              child: CircleAvatar(
                radius: 25,
                backgroundImage: getController.image.value == ''
                    ? const AssetImage(AppImages.placeholder) as ImageProvider
                    : NetworkImage(
                        '${Apis.pdfUrl}${getController.image.value}?v=${DateTime.now().millisecondsSinceEpoch}',
                      ),
              ),
            ),
            accountName: Obx(() => CustomTextWidget(
                  text: getController.fullname.value.toString(),
                  textStyle: CustomTextStyles.textFontMedium(
                      size: 12.sp, color: white),
                )),
            accountEmail: Obx(() => CustomTextWidget(
                  text: getController.email.value,
                  textStyle: CustomTextStyles.textFontMedium(
                      size: 12.sp, color: white),
                )),
          ),
          ...drawerItems.map((item) {
            if (item.subItems.isNotEmpty) {
              return Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  focusColor: primaryColor,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  iconColor:
                      Colors.grey[800], // color of the arrow when expanded
                  collapsedIconColor: Colors.grey[800],
                  dense: true,
                  leading: Icon(
                    item.icon,
                    size: 18.sp,
                    color: Colors.grey[800],
                  ),
                  title: CustomTextWidget(
                    text: item.title,
                    textStyle: CustomTextStyles.textFontMedium(size: 13.sp),
                  ),
                  children: item.subItems.map((sub) {
                    return Padding(
                      padding: EdgeInsets.only(left: 15.w),
                      child: ListTile(
                        dense: true,
                        leading: Icon(sub.icon, size: 16.sp),
                        title: CustomTextWidget(
                          text: sub.title,
                          textStyle:
                              CustomTextStyles.textFontMedium(size: 12.sp),
                        ),
                        onTap: () async {
                          Navigator.pop(context);
                          if (sub.isLogout) {
                            await getController.onLogoutPress();
                          } else {
                            Get.offAllNamed(sub.route);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            } else {
              // ✅ Normal list tile
              return ListTile(
                dense: true,
                leading: Icon(item.icon, size: 18.sp),
                title: CustomTextWidget(
                  text: item.title,
                  textStyle: CustomTextStyles.textFontMedium(size: 13.sp),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  if (item.isLogout) {
                    await getController.onLogoutPress();
                  } else {
                    Get.offAllNamed(item.route);
                  }
                },
              );
            }
          }).toList(),
        ],
      ),
    );
  }
}

class DrawerItem {
  final String title;
  final IconData? icon;
  final String route;
  final bool isLogout;
  final List<DrawerItem> subItems;

  DrawerItem({
    required this.title,
    this.icon,
    required this.route,
    this.isLogout = false,
    this.subItems = const [],
  });
}
