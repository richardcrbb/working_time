import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:working_time/db/db.dart';
import 'package:working_time/db/functions.dart';
import 'package:working_time/db/models.dart';
import 'package:working_time/db/notifiers.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  
  //! Variables

  TextEditingController frequencyController = TextEditingController();
  TextEditingController offsetController = TextEditingController(text: periodOffset.toString());

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){Navigator.pop(context);setState((){});}, icon: Icon(Icons.arrow_back_ios_rounded)),
        title: Text('SETTINGS'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Text('PAY PERIOD.'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),side: BorderSide(width: 3)),
            child: ListTile(
              title: Center(child: Text('By what frequency do you want to filter your records in the pie chart?')),
            ),
          ),
          FutureBuilder(future: _getFrequencyController(), builder: (context, snapshot) {
            return 
            DropdownMenu(
            dropdownMenuEntries: frequency,
            controller: frequencyController,
            onSelected: (value) async{
              if(value!=null && value.isNotEmpty){
                await MyDatabase.updateFilterFrequency(value);
                setState(() {});
              }
            },
            );  
          },),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),side: BorderSide(width: 3)),
            child: ListTile(
              title: Text('How many periods back would you like to offset? (0 is the current period)'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 150,vertical: 8),
            child: TextField(
              controller: offsetController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              onSubmitted: (value) {
                periodOffset=int.tryParse(value)?? 0;
              },
              ),
          ),
          SizedBox(height: 30,),
          Text('LOCATIONS'),
            ListTile(
              leading: Icon(Icons.home_work_rounded),
              title: Center(child: Text('LABEL'),),
              trailing: IconButton(
                onPressed: ()async{
                  await addNewLocation(context);
                  setState((){});},
                icon: Icon(Icons.add_home_work_rounded)
              ),
              ),
          Flexible(
            flex: 3,
            child: FutureBuilder(future: MyDatabase.getLocationsTable(), builder:(context, snapshot) {
              if(snapshot.connectionState==ConnectionState.waiting){return Center(child: CircularProgressIndicator(),);}
              if(!snapshot.hasData || snapshot.data!.isEmpty){return Center(child: Text('There are not locations added yet.'),);}
              if(snapshot.hasError){return Center(child: Text('Error: ${snapshot.error}'),);}
            
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(side: BorderSide(width: 3,),borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index+1}'),),
                    title: Center(child: Text(snapshot.data![index].location)),
                    subtitle: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Regular pay: ${snapshot.data![index].regularPayment} CAD'),
                        Text('Overtime pay: ${snapshot.data![index].overtimePayment} CAD'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: ()async{
                            bool confirmation = await confirmDeleteLocation(context);
                            if (confirmation){
                              await MyDatabase.deleteLocation(snapshot.data![index]);
                              if(context.mounted){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('\u2705 The locaiton was deleted successfully deleted')));}
                            }
                            setState((){});
                          },
                          icon: Icon(Icons.delete)),
                        IconButton(
                          onPressed: ()async{
                            await addNewLocation(context,snapshot.data![index]);
                            setState((){});},
                          icon: Icon(Icons.settings_outlined)),
                      ],
                    ),
                    
                  ));
              },);
            }, ),
          ),
          
          
        ],
      ));
  }






  //!                                 Callbacks


Future<void> _getFrequencyController ()async{
  String freq = await MyDatabase.getFilterFrequency();
  for (var element in frequency) {
    if(element.value==freq){frequencyController.text=freq;}
    
  }
}
}











