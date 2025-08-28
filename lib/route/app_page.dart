import 'package:flutter_template/manager_ui/ManagerProducts/allProducts/addProductsScreen.dart';
import 'package:flutter_template/manager_ui/ManagerProducts/product_list/product_list_screen.dart';
import 'package:flutter_template/manager_ui/ManagerProducts/variations/get/variationGetScreen.dart';
import 'package:flutter_template/ui/auth/login/login_screen.dart';
import 'package:flutter_template/ui/auth/profile/adminProfileScreen.dart';
import 'package:flutter_template/ui/auth/register_packages/register_packages_screen.dart';
import 'package:flutter_template/ui/auth/register/register_screen.dart';
import 'package:flutter_template/ui/drawer/Branchmembership/add/branchMembershipAddScreen.dart';
import 'package:flutter_template/ui/drawer/Branchmembership/get/branchMembershipListScreen.dart';
import 'package:flutter_template/ui/drawer/branches/getBranches/getBranchesScreen.dart';
import 'package:flutter_template/ui/drawer/branches/post_branches_screena.dart/postBranchesScreen.dart';
import 'package:flutter_template/ui/drawer/branches/post_branches_screena.dart/postBranchescontroller.dart';
import 'package:flutter_template/ui/drawer/coupons/addNewCoupon/addCouponScreen.dart';
import 'package:flutter_template/ui/drawer/coupons/couponsScreen.dart';
import 'package:flutter_template/ui/drawer/customers/addCustomer/addCustomerScreen.dart';
import 'package:flutter_template/ui/drawer/customers/customersScreen.dart';
import 'package:flutter_template/ui/drawer/drawer_screen.dart';
import 'package:flutter_template/ui/drawer/manager/addManager/managerScreen.dart';
import 'package:flutter_template/ui/drawer/manager/getManager/getmanagerScreen.dart';
import 'package:flutter_template/ui/drawer/services/addServices/addservicesScreen.dart';
import 'package:flutter_template/ui/drawer/services/categotys/addNewServicesScreen.dart';
import 'package:flutter_template/ui/drawer/services/subCategory/subCategotySCreen.dart';

import 'package:flutter_template/ui/drawer/staff/addNewStaffScreen.dart';
import 'package:flutter_template/ui/drawer/staff/staffDetailsScreen.dart'
    show Staffdetailsscreen;
import 'package:flutter_template/ui/tax/addNewTaxScreen.dart';
import 'package:get/get.dart';
import '../manager_ui/ManagerProducts/Tags/tagsScreen.dart';
import '../manager_ui/ManagerProducts/brand/getBrandsScreen.dart';
import '../manager_ui/ManagerProducts/category/CategoryScreen.dart';
import '../manager_ui/ManagerProducts/subcategory/subcategoryScreen.dart';
import '../manager_ui/ManagerProducts/units/unitsScreen.dart';
import '../manager_ui/coupons/manager_coupons_screen.dart';
import '../manager_ui/customer/edit/manager_edit_customer.dart';
import '../manager_ui/customer/add/manager_post_customer_screen.dart';
import '../manager_ui/customer/manager_get_customer_screen.dart';
import '../manager_ui/dashboard/dashboardScreen.dart';
import '../manager_ui/inhouse_manager/get/inhouseProduct_screen.dart';
import '../manager_ui/manager_appointment_screen/getappointmentManagerScreen.dart';
import '../manager_ui/manager_appointment_screen/managerAppointmentSScreen.dart';
import '../manager_ui/manager_orders/order_report_screen.dart';
import '../manager_ui/manager_packages/manager_packageScreen.dart';
import '../manager_ui/manager_profile/managerProfilescreen.dart';
import '../manager_ui/report/customer_membership/manager_customer_membership_report_screen.dart';
import '../manager_ui/report/customer_packages/manager_customer_package_report_screen.dart';
import '../manager_ui/services_manager/manager_serviceScreen.dart';
import '../manager_ui/staff/manager_staff_screen.dart';
import '../manager_ui/taxes/manager_taxes_screen.dart';
import '../ui/auth/forgot/forgot_screen.dart';
import '../ui/buy_product/buy_product_screen.dart';
import '../ui/drawer/appointment/appointmentScreen.dart';
import '../ui/drawer/branchPackages/getBranchPackagesScreen.dart';
import '../ui/drawer/commission/commission_list_screen.dart';
import '../ui/drawer/dashboard/dashboard_screen.dart';
import '../ui/drawer/products/Tags/tagsScreen.dart';
import '../ui/drawer/products/allProducts/addProductsScreen.dart';
import '../ui/drawer/products/brand/getBrandsScreen.dart';
import '../ui/drawer/products/category/CategoryScreen.dart';
import '../ui/drawer/products/subcategory/subcategoryScreen.dart';
import '../ui/drawer/products/units/unitsScreen.dart';
import '../ui/drawer/products/variations/get/variationGetScreen.dart';
import '../ui/drawer/products/variations/variationScreen.dart';
import '../ui/drawer/reports/customerPackageReport/customer_package_report_screen.dart';
import '../ui/drawer/reports/dailyBooking/dailyBooking_screen.dart';
import '../ui/drawer/reports/orderReport/order_report_screen.dart';
import '../ui/drawer/reports/overallBooking/overall_booking_screen.dart';
import '../ui/drawer/reports/staffServiceReport/staff_service_report_screen.dart';
import '../ui/drawer/staffEarnings/statffEarningScreen.dart';
import '../ui/drawer/staffPayoutRepoer/staffPayoutReportScreen.dart';
import '../ui/inhouse/get/inhouseProduct_screen.dart';
import '../ui/splash/splash_screen.dart';
import 'app_route.dart';
import 'package:flutter_template/ui/drawer/products/product_list/product_list_screen.dart';
import 'package:flutter_template/ui/drawer/customers/edit_customer/edit_customer_screen.dart';

class AppPages {
  static const initial = Routes.splashScreen;
  static final routes = [
    GetPage(
        name: Routes.productListScreen,
        page: () => ProductListScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.splashScreen,
        page: () => SplashScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.loginScreen,
        page: () => LoginScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.drawerScreen,
        page: () => DrawerScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.registerScreen,
        page: () => RegisterScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.packagesScreen,
        page: () => PackagesScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.dashboardScreen,
        page: () => DashboardScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.forgotScreen,
        page: () => ForgotScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.appointment,
        page: () => Appointmentscreen(),
        transition: Transition.rightToLeft),
    GetPage(
      name: Routes.adminprofilescreen,
      page: () => Adminprofilescreen(),
    ),
    GetPage(
        name: Routes.addNewStaff,
        page: () => Addnewstaffscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.addNewCategotyScreen,
        page: () => AddNewCategotyScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.addService,
        page: () => AddNewService(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.gerStaff,
        page: () => Staffdetailsscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.addtex,
        page: () => Addnewtaxscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.getCoupons,
        page: () => CouponsScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.addCoupon,
        page: () => AddCouponScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.addSubcategory,
        page: () => Subcategotyscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.postBranchs,
        page: () => Postbranchesscreen(),
        binding: BindingsBuilder(() {
          Get.lazyPut<Postbranchescontroller>(() => Postbranchescontroller());
        }),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.getBranches,
        page: () => GetBranchesScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.managerScreen,
        page: () => Managerscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.getManager,
        page: () => Getmanagerscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.customersScreen,
        page: () => CustomersScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.addCustomer,
        page: () => Addcustomerscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.addBranchMembership,
        page: () => BranchMembershipListScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.addVariationscreen,
        page: () => Variationscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.branchmembershipaddscreen,
        page: () => Branchmembershipaddscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.placeOrder,
        page: () => BuyProductScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.editCustomer,
        page: () => EditCustomerScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.addProductScreen,
        page: () => AddProductScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.managerDashboard,
        page: () => ManagerDashboardScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.GetBranchPackagesScreen,
        page: () => GetBranchPackagesScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.CustomerPackageReportScreen,
        page: () => CustomerPackageReportScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.CustomerMembershipReportScreen,
        page: () => ManagerCustomerMembershipReportScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.DailybookingScreen,
        page: () => DailybookingScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.OrderReportScreen,
        page: () => OrderReportScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.OverallBookingScreen,
        page: () => OverallBookingScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.Staffpayoutreportscreen,
        page: () => Staffpayoutreportscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.StaffServiceReportScreen,
        page: () => StaffServiceReportScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.ProductListScreen,
        page: () => ProductListScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.Getbrandsscreen,
        page: () => Getbrandsscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.Categoryscreen,
        page: () => Categoryscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.Subcategoryscreen,
        page: () => Subcategoryscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.Unitsscreen,
        page: () => Unitsscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.Tagsscreen,
        page: () => Tagsscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.VariationGetscreen,
        page: () => VariationGetscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.InhouseproductScreen,
        page: () => InhouseproductScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.Statffearningscreen,
        page: () => Statffearningscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.CommissionListScreen,
        page: () => CommissionListScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.Adminprofilescreen,
        page: () => Adminprofilescreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.Managerappointmentsscreen,
        page: () => Managerappointmentsscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.Getappointmentmanagerscreen,
        page: () => Getappointmentmanagerscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.ManagerDashboardScreen,
        page: () => ManagerDashboardScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.ManagerServicescreen,
        page: () => ManagerServicescreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.ManagerPackagescreen,
        page: () => ManagerPackagescreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.MenagerStaffScreen,
        page: () => ManagerStaffScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.ManagerCouponsScreen,
        page: () => ManagerCouponsScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.ManagerTaxesScreen,
        page: () => ManagerTaxesScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.ManagerGetStaffScreen,
        page: () => ManagerGetStaffScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.ManagerPostCustomerScreen,
        page: () => ManagerPostCustomerScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.ManagerEditCustomer,
        page: () => ManagerEditCustomer(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.ManagerCustomerPackageReportScreen,
        page: () => ManagerCustomerPackageReportScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.ManagerINhouseScreen,
        page: () => ManagerGetInHouseProductScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.ManagerProductListScreen,
        page: () => ManagerProductListScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.ManagerGetbrandsscreen,
        page: () => ManagerGetbrandsscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.ManagerCategoryscreen,
        page: () => ManagerCategoryscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.ManagerSubcategoryscreen,
        page: () => ManagerSubcategoryscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.ManagerTagsscreen,
        page: () => ManagerTagsscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.ManagerUnitsscreen,
        page: () => ManagerUnitsscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.ManagerVariationGetscreen,
        page: () => ManagerVariationGetscreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.ManagerAddProductScreen,
        page: () => ManagerAddProductScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.ManagerOrderReportScreen,
        page: () => ManagerOrderReportScreen(),
        transition: Transition.rightToLeft),
    GetPage(
        name: Routes.Managerprofilescreen,
        page: () => Managerprofilescreen(),
        transition: Transition.rightToLeft),
  ];
}
