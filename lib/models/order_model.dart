class Welcome {
  final bool success;
  final int count;
  final List<Datum> data;

  Welcome({required this.success, required this.count, required this.data});

  factory Welcome.fromJson(Map<String, dynamic> json) {
    return Welcome(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => Datum.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Datum {
  final String id;
  final String user;
  final List<Item> items;
  final double subTotal;
  final num discount;
  final num tax;
  final num deliveryFee;
  final num serviceFee;
  final double grandTotal;
  final Currency currency;
  final Address? address;
  final Payment? payment;
  final String status;
  final List<StatusHistory> statusHistory;
  final num walletUsed;
  final String orderNo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  Datum({
    required this.id,
    required this.user,
    required this.items,
    required this.subTotal,
    required this.discount,
    required this.tax,
    required this.deliveryFee,
    required this.serviceFee,
    required this.grandTotal,
    required this.currency,
    required this.address,
    required this.payment,
    required this.status,
    required this.statusHistory,
    required this.walletUsed,
    required this.orderNo,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json['_id'] ?? '',
      user: json['user']?.toString() ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList(),
      subTotal: (json['subTotal'] ?? 0).toDouble(),
      discount: json['discount'] ?? 0,
      tax: json['tax'] ?? 0,
      deliveryFee: json['deliveryFee'] ?? 0,
      serviceFee: json['serviceFee'] ?? 0,
      grandTotal: (json['grandTotal'] ?? 0).toDouble(),
      currency: currencyFromString(json['currency']),
      address: json['address'] != null
          ? Address.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      payment: json['payment'] != null
          ? Payment.fromJson(json['payment'] as Map<String, dynamic>)
          : null,
      status: json['status'] ?? '',
      statusHistory: (json['statusHistory'] as List<dynamic>? ?? [])
          .map((e) => StatusHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
      walletUsed: json['walletUsed'] ?? 0,
      orderNo: json['orderNo'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      v: (json['__v'] ?? json['v'] ?? 0) as int,
    );
  }
}

/* ===== Address ===== */

class Address {
  final String name;
  final String phone;
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String country;

  Address({
    required this.name,
    required this.phone,
    required this.line1,
    required this.line2,
    required this.city,
    required this.state,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      line1: json['line1'] ?? '',
      line2: json['line2'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
    );
  }
}

/* ===== Currency Enum (server: "$" or "PKR") ===== */

enum Currency { EMPTY, PKR }

Currency currencyFromString(dynamic v) {
  if (v == null) return Currency.EMPTY;
  final s = v.toString().toUpperCase();
  if (s == 'PKR') return Currency.PKR;
  return Currency.EMPTY; // "$" or anything else
}

/* ===== Item ===== */

class Item {
  final String product;
  final String title;
  final String sku;
  final String image;
  final double priceSale;
  final double priceMrp;
  final Currency currency;
  final int qty;

  Item({
    required this.product,
    required this.title,
    required this.sku,
    required this.image,
    required this.priceSale,
    required this.priceMrp,
    required this.currency,
    required this.qty,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      product: json['product']?.toString() ?? '',
      title: json['title'] ?? '',
      sku: json['sku'] ?? '',
      image: json['image'] ?? '',
      priceSale: (json['priceSale'] ?? 0).toDouble(),
      priceMrp: (json['priceMrp'] ?? 0).toDouble(),
      currency: currencyFromString(json['currency']),
      qty: (json['qty'] ?? 0).toInt(),
    );
  }
}

/* ===== Payment ===== */

class Payment {
  final String method;
  final String status;

  Payment({required this.method, required this.status});

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(method: json['method'] ?? '', status: json['status'] ?? '');
  }
}

/* ===== Status History ===== */

class StatusHistory {
  final String status;
  final String note;
  final DateTime at;

  StatusHistory({required this.status, required this.note, required this.at});

  factory StatusHistory.fromJson(Map<String, dynamic> json) {
    return StatusHistory(
      status: json['status'] ?? '',
      note: json['note'] ?? '',
      at: DateTime.tryParse(json['at'] ?? '') ?? DateTime.now(),
    );
  }
}
