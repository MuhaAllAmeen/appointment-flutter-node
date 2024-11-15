import 'dart:convert';

import 'package:appointment/models/bookingModel.dart';
import 'package:appointment/services/apiService.dart';
import 'package:http/http.dart' as http;

Future<http.Response> addAppointment(BookingModel booking) async {
  try{
    final response = await Apiservice().sendData("/booking/add",
          booking.toJson()
      );
    return response;
  }catch(e){
    rethrow;
  }
}

Future<http.Response> getAllAppointments() async {
  try{
    final response = await Apiservice().fetchData("/booking/all");
    return response;
  }catch(e){
    rethrow;
  }
}

Future<http.Response> deleteAppointment(String id) async{
  
  try{
    final response = await Apiservice().deleteData('/booking/delete/$id');
    return response;
  }catch(e){
    rethrow;
  }
  
}

Future<http.Response> addUserUsingIdToken(String idToken) async {
  
  try{
    final response = await Apiservice().sendData("/user/add",  
    json.encode({'idToken': idToken}));
    return response;
  }catch(e){
    rethrow;
  }
}