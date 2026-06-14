import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import './models.dart';
import '../db/db.dart';
import '../screens/layout.dart';
import '../screens/new_log.dart';







//!                       load locations menu-entry from db in a variable

Future<List<DropdownMenuEntry<String>>> loadLocationsMenuEntries () async { 
  
  List<WorkLocation> myLocationsList = await MyDatabase.getLocationsTable();
  return myLocationsList.map((e) {
    return DropdownMenuEntry(value: e.location, label: e.location);
  },).toList();
  }

//!                      load wage in a list

Future<List<WorkLocation>> loadLocations () async {
  return await MyDatabase.getLocationsTable();
}

//!                      day pay
double daypay(double hours, double perHour){
  return hours*perHour;
}


//!                       load list of logs from db in a list variable

Future<List<HoursLog>> loadListofHourlogs (int currentPage,itemsPerPage) async {
  return await MyDatabase.readLogList(currentPage,itemsPerPage);
}

//!                    add new or edit a location as workplace

Future addNewLocation (BuildContext context, [WorkLocation? loc])async{

  WorkLocation? locat = loc; // = null, if you are not editing an old location.
  int? id;
  TextEditingController location = TextEditingController();
  TextEditingController regularPayment = TextEditingController();
  TextEditingController overtimePayment = TextEditingController();
  if(locat!=null){
    id = locat.id;
    location.text=locat.location;
    regularPayment.text=locat.regularPayment.toString();
    overtimePayment.text=locat.overtimePayment.toString();
    }


  return await showModalBottomSheet(context: context,isScrollControlled: true, builder: (context) {
    return Padding(
      padding: EdgeInsetsGeometry.fromLTRB(70, 30, 70, MediaQuery.of(context).viewInsets.bottom +50),
        child: Column(mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your workplace lable.'),
            TextFormField(controller: location,decoration: InputDecoration(hintText: 'Name?'  ),),
            SizedBox(height: 50,),
            Text('Enter your payment for regular time.'),
            TextFormField(controller: regularPayment,decoration: InputDecoration(hintText: 'Regular payment?' ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 50,),
            Text('Enter your payment for overtime.'),
            TextFormField(controller: overtimePayment,decoration: InputDecoration(hintText: 'Overtime payment?' ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          TextButton(onPressed: () async{
            
            //check if location alrady exists
            bool availability = await MyDatabase.getLocationAvailability(location.text);
            //if location exists and is a new entry!, then show error in snackbar and return void from this bottomsheet
            if(locat==null&&!availability && context.mounted){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('\u274C The location already exists.')));
              Navigator.pop(context,);
              return;
            }
            
            //create the new or edited worklocation and save or edit depending on id variable
            WorkLocation loc = WorkLocation(
              id: id,
              location: location.text,
              regularPayment: double.tryParse(regularPayment.text.replaceAll(',', '.')) ?? 0.0,
              overtimePayment: double.tryParse(overtimePayment.text.replaceAll(',', '.')) ?? 0.0,
            );
            if(id==null) {MyDatabase.addNewLocation(loc);}
            else{MyDatabase.editOldLocation(loc);}
            if(context.mounted){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: loc.id==null?Text('\u2705 The location was successfully added.'):Text('\u2705 The location was successfully edited.')));
              Navigator.pop(context,availability);}
            },
           child: Text('SAVE')
          ),
        ],
      ),
    );
  },
  );

}

//!                        confirmation of deleting a location

Future confirmDeleteLocation (BuildContext context){
  return showModalBottomSheet(isDismissible: false,context: context, builder: (context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('This will permanently delete this location. Are you sure you want to continue?'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(onPressed: () => Navigator.pop(context,true), icon: Icon(Icons.check_circle_rounded,size: 60,)),
              IconButton(onPressed: () => Navigator.pop(context,false), icon: Icon(Icons.cancel_rounded,size: 60,)),
        ],)
      ],),
    );
  },);
}




//!                          select start time

Future<DateTime?> selectTimeFunc(BuildContext context, DateTime initialDateAndTime) async {
  DateTime selected = initialDateAndTime;

  return await showModalBottomSheet<DateTime>(
    context: context,
    builder: (context) {
      return SizedBox(
        height: 900,
        child: Column(
          children: [

            SizedBox(height: 350,
              child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  onDateTimeChanged: (value) {
                    selected = value;
                  },
                  initialDateTime: selected,
                  use24hFormat: true,
                ),
            ),

            SizedBox(height: 25,),

            Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.cancel_rounded),
              iconSize: 50,
              ),
              IconButton(
              onPressed: () => Navigator.pop(context,selected),
              icon: Icon(Icons.check_circle_rounded),
              iconSize: 50,
              ),
            ],),
            
            SizedBox(height: 25,),
          ],
        ),
      );
    },
  );
}

//!                          select hours worked

Future<Duration?> hoursWorkedFunc (BuildContext context, Duration durationSelected) async{
  Duration? selected;
  return await showModalBottomSheet(context: context, builder: (context) {
    return Column(children: [
      Flexible(flex: 2,
        child: CupertinoTimerPicker(
          onTimerDurationChanged: (value) => selected = value,
          minuteInterval: 30,
          mode: CupertinoTimerPickerMode.hm,
          initialTimerDuration: durationSelected,
        ),
      ),
      Flexible(flex: 1,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: [
        IconButton(onPressed: () {
        Navigator.pop(context);
        }, icon: Icon(Icons.cancel_rounded, size: 50,)),
        IconButton(onPressed: () {
          Navigator.pop(context,selected);
        }, icon: Icon(Icons.check_circle_rounded, size: 50,))
        ],))
    ],);

  },);
}

//!                           Dismiss to right confirmation

Future<bool?> confirmDismiss (DismissDirection direction,BuildContext context,HoursLog log)async{
  if(direction==DismissDirection.startToEnd){

    return await showDialog<bool>(context: context, builder: (context) {
      return AlertDialog(
        title: Text('Are you sure you want to delete this registry?'),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          IconButton(onPressed: (){Navigator.pop<bool>(context,true);}, icon: Icon(Icons.check_circle_rounded,size: 50,)),
          SizedBox(width: 50,),
          IconButton(onPressed: (){Navigator.pop<bool>(context,false);}, icon: Icon(Icons.cancel_rounded,size: 50,)),
        ],
      );
    },);

  }
  else{

    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Layout(NewLog(isOldLog: log,));
    },));

    return true;

  }
}


//!                           dismiss procedure

Future<void> dismissDeleteItem (BuildContext context ,DismissDirection direction,HoursLog log)async{
  if(direction==DismissDirection.startToEnd){
    await MyDatabase.deleteLog(log);
  }
  
}


//!                          datetime to my Own format

String dateToMyOwnFormat (DateTime date){
  return date.day == DateTime.now().day ? 
    DateFormat("'Today at ' HH:mm").format(date)
    : DateFormat("MMM/dd ' at ' HH:mm").format(date);
}

//!                         datetime month only

String dateToMonthOnly (DateTime date){
  return DateFormat('MMM').format(date).toString();
}

//!                          Hour and Minute format

String timeToMyOwnFormat(DateTime datetime){
  return DateFormat('HH:mm').format(datetime);
}


//!                         duration to my own format

String durationToMyOwnFormat (double duration){
  String format = "$duration Hours.";
  return format;
}

