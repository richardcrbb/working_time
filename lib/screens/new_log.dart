import 'package:flutter/material.dart';
import 'package:working_time/db/models.dart';
import '../db/functions.dart';
import '../db/db.dart';



class NewLog extends StatefulWidget {
  final HoursLog? isOldLog;
  const NewLog({super.key,this.isOldLog});

  @override
  State<NewLog> createState() => _NewLogState();
}

class _NewLogState extends State<NewLog> {

  //!                      Form Key
  final _formKey = GlobalKey<FormState>();
  //!                      Variables
  int? idVar;
  double? pay;
  double? wageRegular;
  double? wageOvertime;
  DateTime initialDateAndTime = DateTime.now();
  Duration durationSelected =Duration();
  double? durationSelectedinHours;
  DateTime endDateAndTime = DateTime.now();
  bool isExtraTime = false;
  //!                     Controllers
  TextEditingController locationController =TextEditingController();
  TextEditingController startControllerEdited =TextEditingController();
  TextEditingController hoursWorkedController = TextEditingController();
  
  //!                   DB -> Locations and Locations Entries
  late List<WorkLocation> workloc;
  late Future<List<DropdownMenuEntry<String>>> locations;
  //!                      Initial State
  @override
  void initState(){
    super.initState();
    locations =loadLocationsMenuEntries();
    _loadOldLogProperties();
  }
  //!                      Dispose the memory
  @override
  void dispose(){
    super.dispose();
    locationController.dispose();
    startControllerEdited.dispose();
    hoursWorkedController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
        SizedBox(height: 10,),
        //! LOCATION FIELD
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FutureBuilder(
              future: locations,
              builder:(context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting){return CircularProgressIndicator();}
                if(snapshot.hasError){return Text('Error getting locations from DB ${snapshot.error}');}
                if(!snapshot.hasData){return Text('Error: locations is null');}
                return DropdownMenuFormField(
                  dropdownMenuEntries: snapshot.data!,
                  hintText: 'Choose a workplace',
                  width:250,
                  controller: locationController,
                  onSelected: (locatselect) async{
                    if(locatselect!=null && locatselect.isNotEmpty ){await loadwages(locatselect);}
                  },
                  );
              },
            ),
            Text('Or'),
            IconButton(
              onPressed:() async {
                await addNewLocation(context);
                setState(() {locations =loadLocationsMenuEntries();});},
              icon: Icon(Icons.add_home_work_rounded)),
          ],
        ),
        //! START FIELD
        Row(
          children: [
            Flexible(
                  child: TextFormField(
                      textAlign: TextAlign.center,
                      controller: startControllerEdited,
                      decoration: InputDecoration(hintText: 'Select Start Time'),
                      readOnly: true,
                    ),
            ),
            SizedBox(width: 10,),
            IconButton(onPressed: () async{
              DateTime? result = await selectTimeFunc(context,initialDateAndTime);
                if(result != null){
                  initialDateAndTime = result;
                  setState((){
                    startControllerEdited.text = dateToMyOwnFormat(initialDateAndTime);
                    });
                    if(durationSelectedinHours!=null){
                      endDateAndTime = initialDateAndTime.add(durationSelected);
                    }
                }
              },
              icon: Icon(Icons.timelapse)
            ),
          ],
        ),
        //! HOURS WORKED
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: hoursWorkedController,
              readOnly: true,
              textAlign: TextAlign.center,
              decoration: InputDecoration(hintText: 'Select Hours Worked',),
              ),
          ),
          IconButton(onPressed: () async{
            Duration? result = await hoursWorkedFunc(context,durationSelected);
                if(result != null){
                  durationSelected=result;
                  durationSelectedinHours=(result.inMinutes/60).toDouble();
                  endDateAndTime = initialDateAndTime.add(durationSelected);
                  calculateDayPay();
                  setState((){
                    hoursWorkedController.text = durationToMyOwnFormat(durationSelectedinHours!);
                    });
                }
          }, icon: Icon(Icons.timelapse))
          ],
        ),
        //! isExtraTime Switch Tile
        SwitchListTile(value: isExtraTime,
          onChanged:(value) => setState(() {isExtraTime=value;calculateDayPay();}),
          title: Text('Will this be paid as overtime?'),
        ),
        //! PAY
        Text('You earned ${pay??'_'} CAD.'),
        //! SAVE BUTTON
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(onPressed: () {
              if(context.mounted && widget.isOldLog!=null){
                clearFormCallBack();
                Navigator.pop(context);
                }
              clearFormCallBack();
            } , icon: Icon(Icons.cancel_rounded, size: 60,)),
            IconButton(onPressed: () async {
              await saveHoursLog();
              if(context.mounted && widget.isOldLog!=null){Navigator.pop(context);}
            }, icon: Icon(Icons.check_circle_rounded,size: 60,))
          ],
        ),
        SizedBox(height: 10,)
      ], //child finished
      )
    );
  }

















  //!                               Callbacks



  //!    Clear Form

  void clearFormCallBack(){

    _formKey.currentState?.reset();

    locationController.clear();
    startControllerEdited.clear();
    hoursWorkedController.clear();
    initialDateAndTime = DateTime.now();
    durationSelected =Duration();
    durationSelectedinHours = null;
    endDateAndTime = DateTime.now();
    isExtraTime = false;
    pay=null;

    setState(() {});
  }

  //!  Load Old Properties

  Future<void> _loadOldLogProperties ()async{
    if (widget.isOldLog != null){
      final HoursLog oldLog = widget.isOldLog!;

        //                      Variables
      idVar=oldLog.id;
      initialDateAndTime = oldLog.start;
      durationSelected= Duration(minutes: (oldLog.duration*60).toInt());
      durationSelectedinHours = oldLog.duration;
      endDateAndTime = oldLog.finish;
      isExtraTime = oldLog.isExtraTime;
      pay=oldLog.pay;
      //                     Controllers
      locationController.text = oldLog.location;
      startControllerEdited.text  = dateToMyOwnFormat(oldLog.start);
      hoursWorkedController.text = durationToMyOwnFormat(oldLog.duration);

      await loadwages(oldLog.location);
    }
  } 

  //!           load wages

  Future loadwages (String locatselect) async{

    workloc = await loadLocations();
      for (WorkLocation element in workloc) {
        if(element.location==locatselect){
          wageOvertime=element.overtimePayment;
          wageRegular=element.regularPayment;
        }
      }
      calculateDayPay();
      setState((){});

  }

  //!           Calculate Daypay

  void calculateDayPay(){
    if(locationController.text.isNotEmpty && durationSelectedinHours!=null){
      double rawpay;
      if(isExtraTime){rawpay = durationSelectedinHours!*wageOvertime!;}
      else{rawpay=durationSelectedinHours!*wageRegular!;}

      pay= (rawpay*100).round()/100;
    }
  }



  //! Save HoursLog

  Future<void> saveHoursLog ()async{
  
    return await showModalBottomSheet(
      isDismissible: false,
      context: context,
      builder: (context) {
      
      HoursLog item=HoursLog(
        id: idVar,
        location: locationController.text,
        start: initialDateAndTime,
        finish: endDateAndTime,
        duration: durationSelectedinHours?? 0,
        isExtraTime: isExtraTime,
        pay: pay?? 0,
        );

      Future<int> id = widget.isOldLog==null ? MyDatabase.insertLog(item) : MyDatabase.updateLog(item);

      
      return FutureBuilder(future: id, builder: (context, snapshot) {
        if(snapshot.connectionState ==ConnectionState.waiting){return Center(child: CircularProgressIndicator(),);}
        if(snapshot.hasError){return Center(child: Column(children: [Text('Error: ${snapshot.error}'),TextButton(onPressed: () {Navigator.pop(context);}, child: Text('EXIT'))],),);}
        if(!snapshot.hasData){return Center(child: Column(children: [Text('Error: The database did not confirmed the insertion.'),TextButton(onPressed: () {Navigator.pop(context);}, child: Text('EXIT'))],),);}
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                Text(widget.isOldLog==null?
                  'Succesful Insertion: id ${snapshot.data}.'
                  : 'Succesful Updated ${snapshot.data} Log.'
                ),
                IconButton(onPressed: () {
                  Navigator.pop(context);
                  clearFormCallBack();
                }, icon: Icon(Icons.check_circle_rounded,size: 80,))
                ],
                ),
          ),
        );
      },);
      },);
      
  }



}