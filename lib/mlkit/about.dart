import 'package:flutter/material.dart';



class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
        Text("This app is created for Computer Science exibition of Tender Heart Sr. Sec School.", 
        style: TextStyle(
          fontSize: 20
        ),
        ),
        SizedBox(height:20),
        Text("Developed By: Ashutosh Dubey", 
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20
        ),
        ),
        SizedBox(height:20),
        
        Text("Team Members of Project:", 
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 25
        ),
        ),
        SizedBox(height:10),
        Text("1. Ashutosh Dubey", 
        style: TextStyle(
          fontSize: 20
        ),
        ),
        Text("2. Shubham Jha", 
        style: TextStyle(
          fontSize: 20
        ),
        ),
        Text("3. Ankit Raj", 
        style: TextStyle(
          fontSize: 20
        ),
        ),
        Text("4. Jai Prakash", 
        style: TextStyle(
          fontSize: 20
        ),
        ),
        
        Text("5. Yash Raj", 
        style: TextStyle(
          fontSize: 20
        ),
        ),
        ],
      ) 
    );
  }
}