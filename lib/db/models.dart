
//!   HoursLog

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class HoursLog {

final int? id;
final String location;
final DateTime start;
final DateTime finish;
final double duration;
final bool isExtraTime;
final double pay;

  //     Constructor Normal
  HoursLog({
    this.id,
    required this.location,
    required this.start,
    required this.finish,
    required this.duration,
    required this.isExtraTime,
    required this.pay,});
  
  //       Constructor desde Map, constructor por nombre
  HoursLog.fromMap(Map<String,dynamic> json):
  id = json['id'],
  location=json['location']?? '',
  start= DateTime.tryParse(json['start']?? '')?? DateTime.now(),
  finish=DateTime.tryParse(json['finish']?? '')?? DateTime.now(),
  duration=(json['duration'] ?? 0).toDouble(),
  isExtraTime=json['isExtraTime']==1,
  pay=json['pay'];


  //    Metodo para convertir a Map

  Map<String,dynamic> toMap(){return{ 
    'id':id,
    'location':location,
    'start':start.toIso8601String(),
    'finish':finish.toIso8601String(),
    'duration':duration,
    'isExtraTime':isExtraTime? 1 : 0,
    'pay':pay,
    };
    }

}


//!   WORK LOCATION

class WorkLocation {
  final int? id;
  final String location;
  final double regularPayment;
  final double overtimePayment;

  WorkLocation({
    this.id,
    required this.location,
    required this.regularPayment,
    required this.overtimePayment,
  });

  WorkLocation.fromMap(Map<String,dynamic> json):
    id=json['id'],
    location=json['location']?? '',
    regularPayment=(json['regularPayment']?? 0.0).toDouble(),
    overtimePayment=(json['overtimePayment']?? 0.0).toDouble();

  Map<String,dynamic> toMap (){return {
    'id':id,
    'location':location,
    'regularPayment':regularPayment,
    'overtimePayment':overtimePayment,
    };
  }

}

//!       Filter Frequency List

List<DropdownMenuEntry<String>> frequency = [
  DropdownMenuEntry(value: 'Weekly', label: 'Weekly'),
  DropdownMenuEntry(value: 'Biweekly', label: 'Biweekly'),
  DropdownMenuEntry(value: 'Monthly', label: 'Monthly'),
];

//!       Text Styles
TextStyle titulo = TextStyle(fontSize: 20);
TextStyle pieChartBig = TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.amber);
TextStyle pieChartNormal = TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black54);