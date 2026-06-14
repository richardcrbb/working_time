
import 'package:flutter/material.dart';
import 'package:working_time/db/functions.dart';
class Logbook extends StatefulWidget {
  const Logbook({super.key});

  @override
  State<Logbook> createState() => _LogbookState();
}

class _LogbookState extends State<Logbook> {
    
    //! variables
    int currentPage = 0;
    final int itemsPerPage = 6;
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: loadListofHourlogs(currentPage,itemsPerPage), builder: (context, snapshot) {

      if(snapshot.connectionState==ConnectionState.waiting){return Center(child: CircularProgressIndicator());}
      if(!snapshot.hasData || snapshot.data!.isEmpty){return Center(child: Text('There is no data to show.'),);}
      if(snapshot.hasError){return Center(child: Text('Error: ${snapshot.error}'),);}
          
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ListTile(leading: Text('HOURS'),title: Center(child: Text('DESCRIPTION'),),trailing: Text('PAY'),),
          Expanded(
            child: ListView.builder(
                itemCount: snapshot.data!.length-1<itemsPerPage?snapshot.data!.length:itemsPerPage,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: ValueKey(snapshot.data![index].id),
                    direction: DismissDirection.horizontal,
                    confirmDismiss: (direction) async {return await confirmDismiss(direction,context,snapshot.data![index]);},
                    onDismissed: (direction) async {
                      await dismissDeleteItem(context,direction,snapshot.data![index]);
                      setState((){});
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.delete),
                    ),
                    secondaryBackground: Container(
                      color: Colors.indigo,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.settings_rounded),
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 3),
                        borderRadius: BorderRadius.circular(12)
                        ),
                      child: ListTile(
                        leading: CircleAvatar(
                        child: Text('${snapshot.data![index].duration}'),),
                        title: Center(child: Text(snapshot.data![index].location)),
                        subtitle: Text('${dateToMyOwnFormat(snapshot.data![index].start)} until ${timeToMyOwnFormat(snapshot.data![index].finish)}, paid as ${snapshot.data![index].isExtraTime?'Overtime':'Regular'}.'),
                        trailing: Text('${snapshot.data![index].pay} CAD'),
                      ),
                    ),
                  );
                },
              )
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: (){currentPage>0?setState((){currentPage--;}):null;}, icon: Icon(Icons.arrow_back_ios_rounded,size: 50,color: currentPage==0? Colors.grey.shade400:null,),),
              Padding(
                padding: EdgeInsetsGeometry.fromLTRB(10, 0, 10, 0),
                child: Text('${currentPage+1}'),
              ),
              IconButton(onPressed: (){
                snapshot.data!.length>itemsPerPage ? setState((){currentPage++;}):null;}, icon: Icon(Icons.arrow_forward_ios_rounded, size: 50,color: snapshot.data!.length>itemsPerPage ? null:Colors.grey.shade400,)),
            ],
          ),
        ],
      );
    },
    );
  }
}