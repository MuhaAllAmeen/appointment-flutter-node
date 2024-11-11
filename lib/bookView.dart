import 'package:appointment/models/bookingModel.dart';
import 'package:appointment/models/userModel.dart';
import 'package:appointment/services/service.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // Add this import at the top of your file
import 'dart:typed_data';

import 'package:http/http.dart';

class BookView extends StatefulWidget {
  const BookView({super.key});

  @override
  State<BookView> createState() => _BookViewState();
}

class _BookViewState extends State<BookView> {
  TextEditingController nameController =  TextEditingController();
  TextEditingController phoneController =  TextEditingController();
  TextEditingController emailController =  TextEditingController();
  TextEditingController serviceController = TextEditingController();
  TextEditingController addressController = TextEditingController(); 
  List<String> services = ["PCR-Test","Covid Care"];
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2025));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
  Future<void> _selectTime(BuildContext context) async{
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> onBookPressed() async {
    BookingModel booking = BookingModel(service: serviceController.text, date: selectedDate, time: selectedTime, location: addressController.text, 
                                          user: UserModel(fullName: nameController.text, phone: phoneController.text));
    Response response = await sendToFireStore(booking);
    if (response.statusCode == 200){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booked"))
      );
      nameController.clear();
      phoneController.clear();
      addressController.clear();
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("There was something wrong"))
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    serviceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
          child: Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Book an Appointment", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              const SizedBox(height: 20,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Full Name"),
                  TextField(
                    controller: nameController,  
                    
                    ),
                    
                  
                ],
              ),
               Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Phone"),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                    )
                    
                  ],
                
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Service"),
                    DropdownMenu(
                      controller: serviceController,
                      initialSelection: services[0],
                      dropdownMenuEntries: services.map((service) => 
                      DropdownMenuEntry<String>(value: service, label: service)).toList())
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      child: const Text('Select date'),
                    ),
                    Text("Date Selected: ${selectedDate.day.toString()}/${selectedDate.month.toString()}")
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => _selectTime(context),
                      child: const Text('Select Time'),
                    ),
                    Text("Time Selected: ${selectedTime.hour.toString()}:${selectedTime.minute.toString()}")
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Your Location"),
                    TextField(
                      controller: addressController,
                    )
                  ],
                ),
                TextButton(
                onPressed: () {
                  // Booking logic here
                  onBookPressed();
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                      // If the button is pressed, return green, otherwise blue
                      if (states.contains(WidgetState.pressed)) {
                        return Colors.green;
                      }
                      return Colors.blue[200];
                    }),
                ),
                child: const Text("Book"),
              ),
            ],
                      ),
        )
      ),
    )
    );
  }
}