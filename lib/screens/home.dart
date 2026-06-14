import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:working_time/db/db.dart';
import 'package:working_time/db/functions.dart';
import 'package:working_time/db/notifiers.dart';
import '../db/models.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  late Future<List<Map<String,dynamic>>> _dbList;
  late Future<List<Map<String,dynamic>>> _dbAnnualRegistries;
  final List<Color> colors = [Color(0xff666547),Color(0xfffb2e01),Color(0xff6fcb9f),Color(0xffffe28a),Color(0xfffffeb3),];
  int _touchedIndex = -1;
  bool applyNewAttributes = false;
  bool showMyToolTip = false;
  String _cadEarned = 'MY DEFAULT TEXT';
  Offset myToolTipPosition = Offset(0, 0);

  
  @override
  initState(){
    super.initState();
    _dbList = MyDatabase.getFilteredRegistries(periodOffset);
    _dbAnnualRegistries = MyDatabase.getGroupedAnnualRegistries();

  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Center(child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text('SUMMARY',style: titulo,),
        ),),
        Flexible(
          flex: 4,
          child: FutureBuilder(
            future: _dbList,
            builder: (BuildContext context, AsyncSnapshot<List<Map<String,dynamic>>> snapshot) {
              if(snapshot.connectionState==ConnectionState.waiting) {return const Center(child: CircularProgressIndicator(),);}
              if(snapshot.hasError){return Center(child: Text('Error: ${snapshot.error}'),);}
              if(!snapshot.hasData || snapshot.data!.isEmpty){ if (periodOffset>0){periodOffset=0;settingsNotifier.value++;} else{return const Center(child: Text('There is no registries yet.'),);}}
              
              double totalCAD=0;
              
              for (Map element in snapshot.data!) { totalCAD += element['total_pay'];}
              
              return Column(
                children: [
                  SizedBox(
                    height: 300,
                    child: Stack(
                      children: [
                        PieChart(PieChartData(
                          sections: snapshot.data!.asMap().entries.map((e) {
                            
                            //variables y set de _totalCAD
                            int index = e.key;
                            Map<String,dynamic> log = e.value;
                        
                            //actualiza variable encargada de redibujar las propiedades visuales del grafico ---- tambien asigna el valor de dolares ganados de la seccion tocada:
                            if(_touchedIndex==index){
                              applyNewAttributes=true;
                              _cadEarned = e.value['total_pay'].toString();
                            }
                            else{
                              applyNewAttributes=false;
                            }
                            
                            return PieChartSectionData(
                              value: log['total_pay'],
                              color: colors[index%colors.length],
                              radius: applyNewAttributes? 150 :120,
                              borderSide: BorderSide(width: 0),
                              title: '${log['location']}',
                              titlePositionPercentageOffset: applyNewAttributes? .9: .7,
                              titleStyle: applyNewAttributes? pieChartBig: pieChartNormal,
                            );},).toList(),
                          centerSpaceRadius: 0,
                          sectionsSpace: 2,
                          startDegreeOffset: 180,
                          pieTouchData: PieTouchData(
                            enabled: true,
                            longPressDuration: Duration(milliseconds: 100),
                            touchCallback: (event, response) {
                              if( !event.isInterestedForInteractions ||response == null|| response.touchedSection ==null ){
                                setState((){_touchedIndex=-1;applyNewAttributes=false;showMyToolTip=false;});
                              }
                              else{
                                if(response.touchedSection!=null&&response.touchedSection!.touchedSectionIndex!=-1){
                                  setState((){
                                    _touchedIndex=response.touchedSection!.touchedSectionIndex;
                                    myToolTipPosition=response.touchLocation;});
                                    showMyToolTip = true;
                                  }
                              }
                            }
                          )
                        ),
                        ),
                        if (showMyToolTip) AnimatedPositioned(
                          duration: Duration(milliseconds: 200),
                          top: myToolTipPosition.dy-100,
                          left: myToolTipPosition.dx-70,
                          child: Container(
                            padding:EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [BoxShadow(color: Colors.black26,blurRadius: 10)],
                            ),
                            child: Text('$_cadEarned CAD',style: pieChartBig,),),
                        ),
                      ]//list of stack
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(onPressed: () async {
                        List listlocal = await MyDatabase.getFilteredRegistries(periodOffset+1);
                        if (listlocal.isEmpty){periodOffset=0;settingsNotifier.value++;}
                        else{ periodOffset++; settingsNotifier.value++;}
                      },
                       icon: Icon(Icons.arrow_back_ios,),style: IconButton.styleFrom( visualDensity: VisualDensity.compact),
                      ),
                      Column(children: [
                        Text('You made \$${totalCAD==0 ? '_' : totalCAD} CAD from:',style: titulo,),
                        Text('${dateToMyOwnFormat(filterStartDay)} to ${dateToMyOwnFormat(filterEndDay)}')
                      ],),
                      IconButton(onPressed: () {if(periodOffset>0){periodOffset--; settingsNotifier.value++;}
                      }, icon: Icon(Icons.arrow_forward_ios), style: IconButton.styleFrom(visualDensity: VisualDensity.compact),color: periodOffset==0? Colors.grey.shade400:null,)
                    ],
                  ),
                ],
              ) ;
            },
          ),
        ),
        Flexible(
          flex: 3,
          child: FutureBuilder(
            future: _dbAnnualRegistries,
            builder: (context, snapshot) {
              if(snapshot.connectionState==ConnectionState.waiting) {return const Center(child: CircularProgressIndicator(),);}
              if(snapshot.hasError){return Center(child: Text('Error: ${snapshot.error}'),);}
              if(!snapshot.hasData || snapshot.data!.isEmpty){return const Center(child: Text('There is no registries yet.'),);}
              
              //Finds the last month of data, used to make the 12 months list.
              String lastKnownMonth = snapshot.data![snapshot.data!.length-1]['month'];
              DateTime lastKnownMonthDateTime = DateTime(
                int.parse(lastKnownMonth.substring(0,4)),
                int.parse(lastKnownMonth.substring(4)),
                1
              );
              int counter = 1;

              //12 months list!

              List<MapEntry<String,double>> myOrderedList = List.generate(12, (index) {
                
                //create MapEntry with existing data
                if(snapshot.data!.length>index){
                  String month = snapshot.data![index]['month'];
                  double pay = snapshot.data![index]['total_monthly_pay'].toDouble() ?? 0;

                  DateTime monthDatetime = DateTime.now().copyWith(
                    year: int.tryParse(month.substring(0,4))??2026,
                    month: int.tryParse(month.substring(4))??1,
                    day: 1,
                  );

                  return MapEntry(dateToMonthOnly(monthDatetime), pay);
                }
                //creates a MapEntry with the correct month and value 0
                else{
                  DateTime month = lastKnownMonthDateTime.copyWith(month: lastKnownMonthDateTime.month-counter);
                  counter ++;
                  return MapEntry(dateToMonthOnly(month), 0);
                }
              },) ;

              myOrderedList=myOrderedList.reversed.toList();
              
              
              //widgetsubt
              return Column(children: [
                SizedBox(height: 260,child: BarChart(
                  BarChartData(
                    barGroups:  myOrderedList.asMap().entries.map((e) {
                      int index = e.key;
                      double pay = e.value.value;
                
                      return BarChartGroupData(
                        x: index,
                        barRods: [BarChartRodData(toY: pay)],
                        //showingTooltipIndicators: 
                        );
                    },).toList(),
                     //maxY: 3000,
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(),
                      topTitles: const AxisTitles(),
                      leftTitles: AxisTitles(
                        sideTitleAlignment: SideTitleAlignment.outside,
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          maxIncluded: false,
                          minIncluded: false,
                        ),
                      ),
                      bottomTitles:  AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta){
                            return SideTitleWidget(
                              angle: 4.71239,
                              meta: meta,
                              child: Text(
                                myOrderedList[int.parse(meta.formattedValue)].key
                              ),
                            );
                          }
                        ),
                      ),
                    )
                
                  
                  ),
                ),)
              ],);
            }
          ),)
      ],
    );
  }
}