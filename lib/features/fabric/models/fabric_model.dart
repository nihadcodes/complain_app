class FabricItem {
  final int pid;
  final int report;
  final String merchandiser;
  final String bookNo;
  final DateTime confirmBookingDt;
  final int indentorNo;
  final String supplier;
  final DateTime? delDt;
  final int bookUnitDeptNo;
  final int status;
  final String payMode;
  final double? currencyRate;
  final String paymentTermNo;
  final String buyerName;
  final String? brand;
  final String delLocation;
  final String currency;
  final int delCompany;
  final String bookType;
  final String supplierSource;
  final String payTerm;
  final int totalQty;
  final double totalAmount;
  final String itemType;

  FabricItem({
    required this.pid,
    required this.report,
    required this.merchandiser,
    required this.bookNo,
    required this.confirmBookingDt,
    required this.indentorNo,
    required this.supplier,
    this.delDt,
    required this.bookUnitDeptNo,
    required this.status,
    required this.payMode,
    this.currencyRate,
    required this.paymentTermNo,
    required this.buyerName,
    this.brand,
    required this.delLocation,
    required this.currency,
    required this.delCompany,
    required this.bookType,
    required this.supplierSource,
    required this.payTerm,
    required this.totalQty,
    required this.totalAmount,
    required this.itemType,
  });


  factory FabricItem.fromJson(Map<String, dynamic> json) {
    return FabricItem(
      pid: json['pid'],
      report: json['report'],
      merchandiser: json['merchandiser'],
      bookNo: json['book_no'],
      confirmBookingDt: DateTime.parse(json['confirm_booking_dt']),
      indentorNo: json['indentor_no'],
      supplier: json['supplier'],
      delDt: json['del_dt'] != null ? DateTime.parse(json['del_dt']) : null,
      bookUnitDeptNo: json['book_unit_dept_no'],
      status: json['status'],
      payMode: json['pay_mode'],
      currencyRate: json['currancy_rate']?.toDouble(),
      paymentTermNo: json['payment_term_no'],
      buyerName: json['buyer_name'],
      brand: json['brand'],
      delLocation: json['del_location'],
      currency: json['currancy'],
      delCompany: json['del_company'],
      bookType: json['book_type'],
      supplierSource: json['supplier_source'],
      payTerm: json['pay_term'],
      totalQty: json['total_qty'],
      totalAmount: json['total_amount'].toDouble(),
      itemType: json['item_type'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'pid': pid,
      'report': report,
      'merchandiser': merchandiser,
      'book_no': bookNo,
      'confirm_booking_dt': confirmBookingDt.toIso8601String(),
      'indentor_no': indentorNo,
      'supplier': supplier,
      'del_dt': delDt?.toIso8601String(),
      'book_unit_dept_no': bookUnitDeptNo,
      'status': status,
      'pay_mode': payMode,
      'currancy_rate': currencyRate,
      'payment_term_no': paymentTermNo,
      'buyer_name': buyerName,
      'brand': brand,
      'del_location': delLocation,
      'currancy': currency,
      'del_company': delCompany,
      'book_type': bookType,
      'supplier_source': supplierSource,
      'pay_term': payTerm,
      'total_qty': totalQty,
      'total_amount': totalAmount,
      'item_type': itemType,
    };
  }
}
