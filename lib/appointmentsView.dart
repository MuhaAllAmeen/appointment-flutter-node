import 'dart:convert';

import 'package:appointment/models/bookingModel.dart';
import 'package:appointment/services/service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Appointmentsview extends StatefulWidget {
  const Appointmentsview({super.key});

  @override
  State<Appointmentsview> createState() => _AppointmentsviewState();
}

class _AppointmentsviewState extends State<Appointmentsview> {
  List appointments = [];

  void onDeletePressed(String? id) async {
    print("ss $id");
    if (id!=null){
      Response response = await deleteAppointment(id);
      if (response.statusCode == 200){
        Response response = await getAllAppointments();
        setState(() {
          appointments = jsonDecode(response.body);
        });
      }
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointments"),
      ),
      body: FutureBuilder(future: getAllAppointments(), 
        builder:(context, snapshot) {
          switch (snapshot.connectionState){
            case ConnectionState.none:
              return const Center(child: Text("No Bookings"));

            case ConnectionState.waiting:
            return const Center(child: SizedBox(width: 50,height: 50, child: Center(child: CircularProgressIndicator(),)));
            
            case ConnectionState.active:
              return const Center(child: Text("Active"),);
            
            case ConnectionState.done:
              appointments = jsonDecode(snapshot.data!.body) ;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: appointments.map((appointment){
                      BookingModel booking = BookingModel.fromMap(appointment);
                      return Column(
                        children: [
                          Container(
                            color: Colors.blue[200],
                            // width: 300,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Full Name: "),
                                      Text(booking.user.fullName)
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Phone: "),
                                      Text(booking.user.phone)
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Service: "),
                                      Text(booking.service)
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Date: "),
                                      Text("${booking.date.day.toString()}/${booking.date.month.toString()}/${booking.date.year.toString()}")
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Time: "),
                                      Text(booking.time.format(context))
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Location: "),
                                      Text(booking.location)
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          TextButton(onPressed: () => onDeletePressed(appointment['id']), child: Text("Delete")),
                          const SizedBox(height: 10,)
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
          }
          }

      ),
    );
  }
  
  
}