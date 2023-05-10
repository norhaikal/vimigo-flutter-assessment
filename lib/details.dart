import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';

class AttendanceDetails extends StatefulWidget {
  const AttendanceDetails(
      {required this.user, required this.phone, required this.date, super.key});

  final String user;
  final String phone;
  final DateTime date;

  @override
  State<AttendanceDetails> createState() => _AttendanceDetailsState();
}

class _AttendanceDetailsState extends State<AttendanceDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance Details"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // navigate back to the previous screen
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(
                height: 10.0,
              ),
              Row(
                children: [
                  const Text("Name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                ],
              ),
              const SizedBox(height: 20,),
              Row(
                children: [
                  Text(widget.user),
                ],
              ),
              const SizedBox(height: 20,),
              Row(
                children: [
                  const Text("Phone Number", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20,),
              Row(
                children: [
                  Text(widget.phone),
                ],
              ),
              const SizedBox(height: 20,),
              Row(
                children: [
                  const Text("Date", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20,),
              Row(
                children: [
                  Text(DateFormat('dd MMM yyyy, h:mm a')
                                    .format(widget.date)
                                    .toString())
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
