import 'dart:convert';

import 'package:appointment/models/bookingModel.dart';
import 'package:http/http.dart' as http;

Future<http.Response> sendToFireStore(BookingModel booking) async {
  final response = await http.post(Uri.parse('http://192.168.0.144:3000/booking/add'),
      headers: {"Content-Type": "application/json"},
      body: booking.toJson()
      );
  return response;

}

Future<http.Response> getAllAppointments() async {
    final response = await http.get(Uri.parse('http://192.168.0.144:3000/booking/all'));
    return response;

}

Future<http.Response> deleteAppointment(String id) async{
  final response = await http.delete(Uri.parse('http://192.168.0.144:3000/booking/delete/$id'));
  return response;
}