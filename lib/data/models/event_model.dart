class EventApiModel {
  final int id;
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String startTime;
  final String endTime;
  final String location;
  final String phone;
  final String status;
  final String? imageUrl;
  final String? scheduleFile;
  final bool publish;
  final int? categoryId;
  final int? typeId;
  final EventCategoryModel? category;
  final ServiceTypeModel? type;
  final List<ServiceSponsorModel> sponsors;

  EventApiModel({
    required this.id,
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.phone,
    required this.status,
    this.imageUrl,
    this.scheduleFile,
    required this.publish,
    this.categoryId,
    this.typeId,
    this.category,
    this.type,
    this.sponsors = const [],
  });

  factory EventApiModel.fromJson(Map<String, dynamic> json) {
    return EventApiModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      location: json['location'] as String,
      phone: json['phone'] as String,
      status: json['status'] as String,
      imageUrl: json['imageUrl'] as String?,
      scheduleFile: json['scheduleFile'] as String?,
      publish: json['publish'] as bool? ?? false,
      categoryId: json['categoryId'] as int?,
      typeId: json['typeId'] as int?,
      category: json['category'] != null
          ? EventCategoryModel.fromJson(
              json['category'] as Map<String, dynamic>,
            )
          : null,
      type: json['type'] != null
          ? ServiceTypeModel.fromJson(json['type'] as Map<String, dynamic>)
          : null,
      sponsors:
          (json['sponsors'] as List<dynamic>?)
              ?.map(
                (e) => ServiceSponsorModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

class EventCategoryModel {
  final int id;
  final String name;
  final String? description;

  EventCategoryModel({required this.id, required this.name, this.description});

  factory EventCategoryModel.fromJson(Map<String, dynamic> json) {
    return EventCategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }
}

class ServiceTypeModel {
  final int id;
  final String name;
  final String? description;

  ServiceTypeModel({required this.id, required this.name, this.description});

  factory ServiceTypeModel.fromJson(Map<String, dynamic> json) {
    return ServiceTypeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }
}

class ServiceSponsorModel {
  final int id;
  final SponsorModel sponsor;

  ServiceSponsorModel({required this.id, required this.sponsor});

  factory ServiceSponsorModel.fromJson(Map<String, dynamic> json) {
    return ServiceSponsorModel(
      id: json['id'] as int,
      sponsor: SponsorModel.fromJson(json['sponsor'] as Map<String, dynamic>),
    );
  }
}

class SponsorModel {
  final int id;
  final String name;
  final String? logoUrl;

  SponsorModel({required this.id, required this.name, this.logoUrl});

  factory SponsorModel.fromJson(Map<String, dynamic> json) {
    return SponsorModel(
      id: json['id'] as int,
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String?,
    );
  }
}
