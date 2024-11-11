// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:appointment/models/userModel.dart';
import 'package:flutter/material.dart';

class BookingModel {
  final String service;
  final DateTime date;
  final TimeOfDay time;
  final String location;
  final UserModel user;
  String? id;

  BookingModel({
    required this.service,
    required this.date,
    required this.time,
    required this.location,
    required this.user, 
    String? id
  });

  BookingModel copyWith({
    String? id,
    String? service,
    DateTime? date,
    TimeOfDay? time,
    String? location,
  }) {
    return BookingModel(
      id: id ?? this.id,
      service: service ?? this.service,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      user: user ?? this.user 
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'service': service,
      'date': date.millisecondsSinceEpoch,
      'time': {"hour":time.hour,"minute":time.minute},
      'location': location,
      'user': user.toMap()
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      service: map['service'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      time: TimeOfDay(hour: map["time"]["hour"], minute: map["time"]["minute"]) ,
      location: map['location'] as String,
      user: UserModel.fromMap(map['user']),
      id: map['id'] as String
    );
  }

  String toJson() => json.encode(toMap());

  factory BookingModel.fromJson(String source) => BookingModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BookingModel(service: $service, date: $date, time: $time, location: $location)';
  }

  @override
  bool operator ==(covariant BookingModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.service == service &&
      other.date == date &&
      other.time == time &&
      other.location == location && 
      other.user == user;
  }

  @override
  int get hashCode {
    return service.hashCode ^
      date.hashCode ^
      time.hashCode ^
      location.hashCode;
  }
}
