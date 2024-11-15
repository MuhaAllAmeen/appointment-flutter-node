import 'package:appointment/home.dart';
import 'package:appointment/models/bookingModel.dart';
import 'package:appointment/models/userModel.dart';
import 'package:appointment/services/authService.dart';
import 'package:appointment/services/firestoreService.dart';
import 'package:appointment/utils/genericDialog.dart';
import 'package:flutter/material.dart';


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
  final _formKey = GlobalKey<FormState>();
  List<String> services = ["PCR-Test","Covid Care"];
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isLoading = false;

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

  Future<void> onBookPressed(BuildContext context) async {
    if (_formKey.currentState!.validate()){
      isLoading = true;
      BookingModel booking = BookingModel(service: serviceController.text, date: selectedDate, time: selectedTime, location: addressController.text, 
                                            user: UserModel(email: emailController.text,fullName: nameController.text, phone: phoneController.text));
      try{
        Response response = await addAppointment(booking);
        if (response.statusCode == 200){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Booked"))
          );
          nameController.clear();
          phoneController.clear();
          addressController.clear();
          emailController.clear();
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("There was something wrong"))
          );
        }
      }catch(e){
        await showGenericDialog(context: context, title: "Error", content: "There was something wrong", optionBuilder:() => {"OK":null},);
      }
      
      isLoading = false;
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("The details you have entered is not valid"))
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
      appBar: AppBar(
        backgroundColor: Colors.blue[200],
        leading: PopupMenuButton(
          onSelected: (value) async{
            if (value == "Logout"){
              final loggedOut =  await AuthService().logout();
              if (loggedOut) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(context) => Home(isLoggedIn: false,),), (Route)=>false); 
            }
          },
          itemBuilder:(context) {
          
          return <PopupMenuEntry>[
            const PopupMenuItem(
              value: "Logout",
              child:Text("Logout")
              )
          ];
        },),
        toolbarHeight: 40,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
          child: Form(
            key: _formKey,
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
                  TextFormField(
                    controller: nameController,  
                    validator: (value) {
                      if (value == null || value.isEmpty){
                        return "Input Your Name";
                      }
                      if (value.length<2 || value.length>40){
                        return "Invalid name length";
                      }
                      final RegExp nameRegExp = RegExp(r'^(?!.*<[^>]+>)(?!.*\s{2,})[A-Za-z]+(?:\s[A-Za-z]+)*$');
                      if (!nameRegExp.hasMatch(value)){
                        return "Invalid Name Format";
                      }
                      return null;
                    },     
                    ),
                    
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Email"),
                  TextFormField(
                    controller: emailController,  
                    validator: (value) {
                      if (value == null || value.isEmpty){
                        return "Input Your Email";
                      }
                      final RegExp emailRegExp = RegExp(r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|.(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
                      if (!emailRegExp.hasMatch(value)){
                        return "Invalid Email Format";
                      }
                      return null;
                    },     
                    ),
                    
                ],
              ),
               Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Phone"),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty){
                          return "Input Your Phone Number";
                        }
                        if (value.length!=10){
                          return "Your Phone number should have 10 digits";
                        }
                        if (!value.startsWith("05")){
                          return "Your number should start with 05";
                        }
                        final RegExp phoneRegExp = RegExp(r'^(?!\s)(\d+)(?!\s)$');
                      if (!phoneRegExp.hasMatch(value)){
                        return "Invalid Phone Format";
                      }
                        return null;
                      },  
                    )
                    
                  ],
                
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Service"),
                    DropdownButtonFormField(
                      hint: const Text("Select a Service"),        
                      items: services.map((service) => 
                              DropdownMenuItem(child: Text(service), value: service,)).toList(),
                      onChanged: (value) {
                        if(value!=null )serviceController.text = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty){
                          return "Select a Service";
                        }
                        return null;
                      },
                    )
                      
                      // controller: serviceController,
                      // initialSelection: services[0],
                      // dropdownMenuEntries: services.map((service) => 
                      // DropdownMenuEntry<String>(value: service, label: service)).toList())
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
                    TextFormField(
                      controller: addressController,
                      validator: (value) {
                        if (value == null || value.isEmpty){
                          return "Input Your Address";
                        }
                        if (value.length<3){
                          return "Enter Valid address";
                        }
                        return null;
                      },  
                    )
                  ],
                ),
                TextButton(
                onPressed: isLoading ? null : () {
                  // Booking logic here
                  onBookPressed(context);
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
                child: isLoading ? const Center(child: CircularProgressIndicator(),): const Text("Book"),
              ),
            ],
                      ),
          )
      ),
    )
    );
  }
}