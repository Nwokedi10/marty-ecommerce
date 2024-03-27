import 'dart:convert';


class PaginatedTopUpModel {
  int? totalSize;
  String? limit;
  int? offset;
  List<TopUpModel>? orders;

  PaginatedTopUpModel({this.totalSize, this.limit, this.offset, this.orders});

  PaginatedTopUpModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'].toString();
    offset = (json['offset'] != null && json['offset'].toString().trim().isNotEmpty) ? int.parse(json['offset'].toString()) : null;
    if (json['orders'] != null) {
      orders = [];
      json['orders'].forEach((v) {
        orders!.add(TopUpModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }

}

class TopUpModel {
  int? id;
  int? userId;
  double? orderAmount;
  String? createdAt;
  String? status;

  TopUpModel(
      {this.id,
        this.userId,
        this.orderAmount,
        this.status,
        this.createdAt,
      });

  TopUpModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    orderAmount = json['amount'].toDouble();
    status = json['status'].toDouble();
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['amount'] = orderAmount;
    data['status'] = status;
    data['created_at'] = createdAt;
    return data;
  }
}

