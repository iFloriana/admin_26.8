class Dashboard_model {
  // Root-level fields from API
  int? appointmentCount;
  int? customerCount;
  int? orderCount;
  int? productSales;
  int? totalCommission;

  List<Performance>? performance;
  List<UpcomingAppointments>? upcomingAppointments;
  List<AppointmentsRevenueGraph>? appointmentsRevenueGraph;
  List<TopServices>? topServices;
  List<LineChartDataPoint>? lineChart;
  List<BarChartDataPoint>? barChart;

  Dashboard_model(
      {this.appointmentCount,
      this.customerCount,
      this.orderCount,
      this.productSales,
      this.totalCommission,
      this.performance,
      this.upcomingAppointments,
      this.appointmentsRevenueGraph,
      this.topServices,
      this.lineChart,
      this.barChart});

  Dashboard_model.fromJson(Map<String, dynamic> json) {
    appointmentCount = json['appointmentCount'] ?? json['appointment_count'];
    customerCount = json['customerCount'] ?? json['customer_count'];
    orderCount = json['orderCount'] ?? json['order_count'];
    productSales = json['productSales'] ?? json['product_sales'];
    totalCommission = json['totalCommission'] ?? json['total_commission'];
    if (json['performance'] != null) {
      performance = <Performance>[];
      json['performance'].forEach((v) {
        performance!.add(new Performance.fromJson(v));
      });
    }
    if (json['upcomingAppointments'] != null) {
      upcomingAppointments = <UpcomingAppointments>[];
      json['upcomingAppointments'].forEach((v) {
        upcomingAppointments!.add(new UpcomingAppointments.fromJson(v));
      });
    } else if (json['upcoming_appointments'] != null) {
      upcomingAppointments = <UpcomingAppointments>[];
      json['upcoming_appointments'].forEach((v) {
        upcomingAppointments!.add(new UpcomingAppointments.fromJson(v));
      });
    }
    if (json['appointmentsRevenueGraph'] != null) {
      appointmentsRevenueGraph = <AppointmentsRevenueGraph>[];
      json['appointmentsRevenueGraph'].forEach((v) {
        appointmentsRevenueGraph!.add(new AppointmentsRevenueGraph.fromJson(v));
      });
    } else if (json['appointments_revenue_graph'] != null) {
      appointmentsRevenueGraph = <AppointmentsRevenueGraph>[];
      json['appointments_revenue_graph'].forEach((v) {
        appointmentsRevenueGraph!.add(new AppointmentsRevenueGraph.fromJson(v));
      });
    }
    if (json['topServices'] != null) {
      topServices = <TopServices>[];
      json['topServices'].forEach((v) {
        topServices!.add(new TopServices.fromJson(v));
      });
    } else if (json['top_services'] != null) {
      topServices = <TopServices>[];
      json['top_services'].forEach((v) {
        topServices!.add(new TopServices.fromJson(v));
      });
    }
    if (json['lineChart'] != null) {
      lineChart = <LineChartDataPoint>[];
      json['lineChart'].forEach((v) {
        lineChart!.add(LineChartDataPoint.fromJson(v));
      });
    }
    if (json['barChart'] != null) {
      barChart = <BarChartDataPoint>[];
      json['barChart'].forEach((v) {
        barChart!.add(BarChartDataPoint.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.performance != null) {
      data['performance'] = this.performance!.map((v) => v.toJson()).toList();
    }
    if (this.upcomingAppointments != null) {
      data['upcoming_appointments'] =
          this.upcomingAppointments!.map((v) => v.toJson()).toList();
    }
    if (this.appointmentsRevenueGraph != null) {
      data['appointments_revenue_graph'] =
          this.appointmentsRevenueGraph!.map((v) => v.toJson()).toList();
    }
    if (this.topServices != null) {
      data['top_services'] = this.topServices!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Performance {
  String? name;
  int? appointmentNumber;
  int? totalRevenueAmt;
  double? totalSalesCommissionsAmt;
  int? newCustomersNum;
  int? totalOrdersNum;
  int? totalProductSalesNum;
  int? totalValue;

  Performance(
      {this.name,
      this.appointmentNumber,
      this.totalRevenueAmt,
      this.totalSalesCommissionsAmt,
      this.newCustomersNum,
      this.totalOrdersNum,
      this.totalProductSalesNum,
      this.totalValue});

  Performance.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    appointmentNumber = json['appointment_number'];
    totalRevenueAmt = json['total_revenue_amt'];
    totalSalesCommissionsAmt = json['total_sales_commissions_amt'];
    newCustomersNum = json['new_customers_num'];
    totalOrdersNum = json['total_orders_num'];
    totalProductSalesNum = json['total_product_sales_num'];
    totalValue = json['total_value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['appointment_number'] = this.appointmentNumber;
    data['total_revenue_amt'] = this.totalRevenueAmt;
    data['total_sales_commissions_amt'] = this.totalSalesCommissionsAmt;
    data['new_customers_num'] = this.newCustomersNum;
    data['total_orders_num'] = this.totalOrdersNum;
    data['total_product_sales_num'] = this.totalProductSalesNum;
    data['total_value'] = this.totalValue;
    return data;
  }
}

class UpcomingAppointments {
  // API fields
  String? customerName;
  String? customer_name;
  String? appointmentDate;
  String? appointment_date;
  String? appointmentTime;
  String? appointment_time;
  String? serviceName;
  String? service_name;
  String? customerImage;
  String? customer_image;

  UpcomingAppointments({
    this.customerName,
    this.customer_name,
    this.appointmentDate,
    this.appointment_date,
    this.appointmentTime,
    this.appointment_time,
    this.serviceName,
    this.service_name,
    this.customerImage,
    this.customer_image,
  });

  UpcomingAppointments.fromJson(Map<String, dynamic> json) {
    customerName = json['customerName'] ?? json['customer_name'];
    customer_name = json['customer_name'] ?? json['customerName'];
    appointmentDate = json['appointmentDate'] ?? json['appointment_date'];
    appointment_date = json['appointment_date'] ?? json['appointmentDate'];
    appointmentTime = json['appointmentTime'] ?? json['appointment_time'];
    appointment_time = json['appointment_time'] ?? json['appointmentTime'];
    serviceName = json['serviceName'] ?? json['service_name'];
    service_name = json['service_name'] ?? json['serviceName'];
    customerImage = json['customerImage'] ?? json['customer_image'];
    customer_image = json['customer_image'] ?? json['customerImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['customerName'] = this.customerName;
    data['customer_name'] = this.customer_name;
    data['appointmentDate'] = this.appointmentDate;
    data['appointment_date'] = this.appointment_date;
    data['appointmentTime'] = this.appointmentTime;
    data['appointment_time'] = this.appointment_time;
    data['serviceName'] = this.serviceName;
    data['service_name'] = this.service_name;
    data['customerImage'] = this.customerImage;
    data['customer_image'] = this.customer_image;
    return data;
  }
}

class AppointmentsRevenueGraph {
  String? date;
  int? appointments;
  int? revenue;
  String? name;
  int? totalAppointments;
  int? totalRevenue;

  AppointmentsRevenueGraph(
      {this.date,
      this.appointments,
      this.revenue,
      this.name,
      this.totalAppointments,
      this.totalRevenue});

  AppointmentsRevenueGraph.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    appointments = json['appointments'];
    revenue = json['revenue'];
    name = json['name'];
    totalAppointments = json['total_appointments'];
    totalRevenue = json['total_revenue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['appointments'] = this.appointments;
    data['revenue'] = this.revenue;
    data['name'] = this.name;
    data['total_appointments'] = this.totalAppointments;
    data['total_revenue'] = this.totalRevenue;
    return data;
  }
}

class TopServices {
  String? serviceName;
  String? service_name;
  int? count;
  int? totalCount;
  int? total_count;
  int? totalAmount;
  int? total_amount;

  TopServices({
    this.serviceName,
    this.service_name,
    this.count,
    this.totalCount,
    this.total_count,
    this.totalAmount,
    this.total_amount,
  });

  TopServices.fromJson(Map<String, dynamic> json) {
    serviceName = json['serviceName'] ?? json['service_name'];
    service_name = json['service_name'] ?? json['serviceName'];
    count = json['count'];
    totalCount = json['totalCount'] ?? json['total_count'];
    total_count = json['total_count'] ?? json['totalCount'];
    totalAmount = json['totalAmount'] ?? json['total_amount'];
    total_amount = json['total_amount'] ?? json['totalAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['serviceName'] = this.serviceName;
    data['service_name'] = this.service_name;
    data['count'] = this.count;
    data['totalCount'] = this.totalCount;
    data['total_count'] = this.total_count;
    data['totalAmount'] = this.totalAmount;
    data['total_amount'] = this.total_amount;
    return data;
  }
}

class LineChartDataPoint {
  String? date;
  int? sales;
  LineChartDataPoint({this.date, this.sales});
  LineChartDataPoint.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    sales = json['sales'];
  }
}

class BarChartDataPoint {
  String? date;
  int? sales;
  int? appointments;
  BarChartDataPoint({this.date, this.sales, this.appointments});
  BarChartDataPoint.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    sales = json['sales'];
    appointments = json['appointments'];
  }
}
