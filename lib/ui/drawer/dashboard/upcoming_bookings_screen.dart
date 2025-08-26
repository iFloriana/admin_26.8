import 'package:flutter/material.dart';
import 'package:flutter_template/network/model/dashboard_model.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:flutter_template/utils/custom_text_styles.dart';
import 'package:flutter_template/wiget/appbar/commen_appbar.dart';
import 'package:flutter_template/wiget/custome_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class UpcomingBookingsScreen extends StatelessWidget {
  final List<UpcomingAppointments> upcomingAppointments;
  const UpcomingBookingsScreen({Key? key, required this.upcomingAppointments})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'All Upcoming Bookings',
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView.builder(
          itemCount: upcomingAppointments.length,
          itemBuilder: (context, index) {
            final item = upcomingAppointments[index];
            String formattedDate = '';
            if (item.appointmentDate != null &&
                item.appointmentDate!.isNotEmpty) {
              try {
                final dt = DateTime.parse(item.appointmentDate!);
                formattedDate = DateFormat('yyyy-MM-dd').format(dt);
              } catch (e) {
                formattedDate = item.appointmentDate!;
              }
            }
            return Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.account_circle,
                    size: 35.h,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15.h,
                    color: primaryColor,
                  ),
                  title: CustomTextWidget(
                      text: item.customerName ?? '-',
                      textStyle: CustomTextStyles.textFontBold(
                          size: 14.sp,
                          color: black,
                          textOverflow: TextOverflow.ellipsis)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextWidget(
                          text:
                              '$formattedDate | ${item.appointmentTime ?? ''} | ${item.serviceName ?? ''}',
                          textStyle: CustomTextStyles.textFontRegular(
                              size: 12.sp, color: grey)),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 12.h, color: primaryColor),
                          CustomTextWidget(
                              text: '', // You can add time diff logic here
                              textStyle: CustomTextStyles.textFontMedium(
                                  size: 12.sp, color: primaryColor)),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(),
              ],
            );
          },
        ),
      ),
    );
  }
}
