/*import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


// Grafico Circular 

Widget construirGraficoCircular(Map<String, double> datos, BuildContext context) {
  
  //verifica si no hay datos para hacer el grafico
  if (datos.isEmpty) {return Center(child: Text("No hay datos disponibles"));}

  final colores = [
    Colors.red, Colors.blue, Colors.green, Colors.orange,
    Colors.indigo, Colors.teal, Colors.pink, Colors.brown,
  ];

  double total = datos.values.fold(0, (sum, val) => sum + val);
  
  // Variable para controlar la visibilidad del tooltip
  int touchedIndex =0;
  bool showTooltip = false;
  double currentAmount = 0;
  Offset tooltipPosition = Offset.zero;
  double sectionMargin = 2;

  return StatefulBuilder(
    builder: (context, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 250,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sections: datos.entries.toList().asMap().entries.map((entry) {
                      
                      final index = entry.key;
                      final value = entry.value.value;
                      final cat = entry.value.key;
                      final color = colores[index % colores.length];
                      final bool isTouched = showTooltip && touchedIndex == index ;
                      
                      return PieChartSectionData(
                        value: value,
                        title: cat,
                        titlePositionPercentageOffset: isTouched ? .99 : .5,
                        color: color,
                        radius: isTouched ? 150 : 120,
                        titleStyle: isTouched ? 
                        
                          const TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                          )
                          :
                          const TextStyle(
                          fontSize: 12, 
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          ),
                      );
                    }).toList(),
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          if (pieTouchResponse?.touchedSection != null && pieTouchResponse!.touchedSection!.touchedSectionIndex >= 0) {
                          final section = pieTouchResponse.touchedSection!;
                          final category = datos.keys.elementAt(section.touchedSectionIndex);
                          final amount = datos[category]!;
                          
                          if (event is FlLongPressStart || 
                              event is FlLongPressMoveUpdate ||
                              event is FlPanStartEvent ||
                              event is FlPanUpdateEvent) {
                            setState(() {
                              showTooltip = true;
                              currentAmount = amount;
                              tooltipPosition = event.localPosition!;
                              touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                              sectionMargin = 10;
                            });
                          }
                          
                          if (event is FlLongPressEnd || event is FlPanEndEvent) {
                            setState(() {
                              showTooltip = false;
                              sectionMargin = 2;
                            });
                          }
                        } else if (event is FlLongPressEnd || event is FlPanEndEvent) {
                          setState(() {
                            showTooltip = false;
                            sectionMargin = 2;
                          });
                        }
                      },
                      enabled: true,
                      longPressDuration: const Duration(milliseconds: 100),
                    ),
                    centerSpaceRadius: 0,
                    sectionsSpace: sectionMargin,
                    startDegreeOffset: 180,
                  ),
                  duration: Duration(milliseconds: 100),
                ),
                if (showTooltip)
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 200),
                    left: tooltipPosition.dx - 70,
                    top: tooltipPosition.dy -100,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        '${NumberFormat("#,##0", "es_COP").format(currentAmount)} pesos.',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Total de gastos del mes de ${DateFormat('MMMM', 'es_CO').format(DateTime.now())}:",
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            NumberFormat.currency(locale: 'es_CO', symbol: 'COP', decimalDigits: 0).format(total),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      );
    },
  );
}
*/
