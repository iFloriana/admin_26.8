import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/route/app_route.dart';
import 'package:flutter_template/ui/drawer/drawer_controller.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/wiget/custome_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../utils/custom_text_styles.dart';
import 'branches/getBranches/getBranchesController.dart';

class DrawerScreen extends StatelessWidget {
  DrawerScreen({super.key});
  final getController = Get.put(Getbranchescontroller());
  @override
  Widget build(BuildContext context) {
    final DrawermenuController getController = Get.put(DrawermenuController());

    final List<DrawerItem> drawerItems = [
      DrawerItem(
          title: 'Dashboard',
          icon: FontAwesomeIcons.gauge,
          route: Routes.dashboardScreen),
      DrawerItem(
          title: 'Booking',
          icon: FontAwesomeIcons.calendarDays,
          route: Routes.appointment),
      DrawerItem(
          title: 'Branches',
          icon: Icons.business_outlined,
          route: Routes.getBranches),
      // ✅ Services will be expandable
      DrawerItem(
        title: 'Services',
        route: '', // parent doesn’t navigate
        icon: Icons.room_service_outlined,
        subItems: [
          DrawerItem(title: 'List', icon: Icons.list, route: Routes.addService),
          DrawerItem(
              title: 'Category',
              icon: Icons.category_outlined,
              route: Routes.addNewCategotyScreen),
          DrawerItem(
              title: 'Sub Category',
              icon: Icons.list_alt_rounded,
              route: Routes.addService),
        ],
      ),
      DrawerItem(
          title: 'Packages',
          icon: Icons.category_outlined,
          route: Routes.GetBranchPackagesScreen),

      DrawerItem(
          title: 'Membership',
          icon: Icons.supervised_user_circle_outlined,
          route: Routes.addBranchMembership),

      DrawerItem(
          title: 'Reports',
          icon: Icons.receipt_outlined,
          route: '', // parent doesn’t navigate
          subItems: [
            DrawerItem(
                title: 'Daily Booking',
                icon: Icons.edit_document,
                route: Routes.DailybookingScreen),
            DrawerItem(
                title: 'Order Report',
                icon: Icons.stacked_line_chart_outlined,
                route: Routes.OrderReportScreen),
            DrawerItem(
                title: 'Overall Booking',
                icon: Icons.book_outlined,
                route: Routes.OverallBookingScreen),
            DrawerItem(
                title: 'Staff Payout',
                icon: Icons.payment,
                route: Routes.Staffpayoutreportscreen),
            DrawerItem(
                title: 'Staff Service',
                icon: Icons.cleaning_services_rounded,
                route: Routes.StaffServiceReportScreen),
            DrawerItem(
                title: 'Customer Package',
                icon: Icons.account_box,
                route: Routes.CustomerPackageReportScreen),
            DrawerItem(
                title: 'Customer Membership',
                icon: Icons.account_box,
                route: Routes.CustomerMembershipReportScreen),
          ]),

      DrawerItem(
          title: 'Products',
          icon: Icons.shopping_cart_checkout_outlined,
          route: '',
          subItems: [
            DrawerItem(
                title: 'All Products',
                icon: Icons.shopping_bag_outlined,
                route: Routes.ProductListScreen),
            DrawerItem(
                title: 'Brands',
                icon: Icons.business_outlined,
                route: Routes.Getbrandsscreen),
            DrawerItem(
                title: 'Category',
                icon: Icons.list_alt_rounded,
                route: Routes.Categoryscreen),
            DrawerItem(
                title: 'Sub Category',
                icon: Icons.category_outlined,
                route: Routes.Subcategoryscreen),
            DrawerItem(
                title: 'Units',
                icon: Icons.ac_unit_outlined,
                route: Routes.Unitsscreen),
            DrawerItem(
                title: 'Tags', icon: Icons.list, route: Routes.Tagsscreen),
            DrawerItem(
                title: 'Product Variation',
                icon: Icons.line_style_sharp,
                route: Routes.VariationGetscreen),
            DrawerItem(
                title: 'Product Cunsumption',
                icon: Icons.update,
                route: Routes.InhouseproductScreen),
          ]),

      DrawerItem(
          title: 'Finance',
          icon: Icons.format_line_spacing_rounded,
          route: '',
          subItems: [
            DrawerItem(
                title: 'Tax',
                icon: Icons.format_textdirection_l_to_r_outlined,
                route: Routes.addtex),
            DrawerItem(
                title: 'Staff Earning',
                icon: Icons.paid_outlined,
                route: Routes.Statffearningscreen),
            DrawerItem(
                title: 'Commition',
                icon: Icons.padding_outlined,
                route: Routes.CommissionListScreen),
            DrawerItem(
                title: 'Coupons',
                icon: Icons.discount_outlined,
                route: Routes.getCoupons),
          ]),

      DrawerItem(
          title: 'Users',
          icon: Icons.supervised_user_circle_outlined,
          route: '',
          subItems: [
            DrawerItem(
                title: 'Manager',
                icon: Icons.manage_accounts_outlined,
                route: Routes.getManager),
            DrawerItem(
                title: 'Staff',
                icon: Icons.person_search_outlined,
                route: Routes.gerStaff),
            DrawerItem(
                title: 'Customer',
                icon: Icons.person_2_outlined,
                route: Routes.customersScreen),
          ]),
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
              onTap: () => Get.toNamed(Routes.Adminprofilescreen),
              child: CircleAvatar(
                radius: 25,
                backgroundColor: secondaryColor, // optional for contrast
                child: Obx(() {
                  final name = getController.fullname.value;
                  final firstLetter =
                      name.isNotEmpty ? name[0].toUpperCase() : '?';
                  return Text(
                    firstLetter,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: white, // match your theme
                    ),
                  );
                }),
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
                    dividerColor: transparent, focusColor: primaryColor),
                child: ExpansionTile(
                  dense: true,
                  leading: Icon(
                    item.icon,
                    size: 18.sp,
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
