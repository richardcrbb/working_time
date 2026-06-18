import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
//import 'package:google_fonts/google_fonts.dart';
import './db/notifiers.dart';
import './screens/settings.dart';
import './screens/home.dart';
import './screens/logbook.dart';
import './screens/new_log.dart';

void main (){
  runApp(const MyApp());
}

List pages =[
  Home(),
  Logbook(),
  NewLog(),
  ];

class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder:(context, bool isDarkMode,_){return MaterialApp(
        builder: (context, child) {
          final mediaQueryData = MediaQuery.of(context);
          return MediaQuery(data: mediaQueryData.copyWith(
            textScaler: mediaQueryData.textScaler.clamp(maxScaleFactor: 1.0)
          ), child: child?? const Placeholder());
        },
        debugShowCheckedModeBanner: false,
        themeMode: isDarkMode? ThemeMode.dark:ThemeMode.light,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.red,
          //textTheme: GoogleFonts.playfairDisplayTextTheme(),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.red,
          //textTheme: GoogleFonts.eduAuVicWaNtHandTextTheme(),
        ),
        home: ValueListenableBuilder(valueListenable: selectedIndexNotifier, builder: (context, selectedIndex, _) {
          return Scaffold(
          appBar: AppBar(
            title: Text('Working Hours',), 
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: (){isDarkModeNotifier.value=!isDarkMode;}, 
                icon: isDarkMode? Icon(Icons.light_mode_rounded):Icon(Icons.dark_mode)
              ),
              Builder(builder: (context) {
                return IconButton(onPressed: () async {
                   await Navigator.push(context, MaterialPageRoute(builder: (context) {return Settings();},));
                   settingsNotifier.value++;
                  },
                  icon: Icon(Icons.settings_applications_outlined)
              );},)
            ],
          ),
          body: Center(
            child: Container(
                  constraints: BoxConstraints(maxWidth: 450),
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 20),
                  child: ValueListenableBuilder(valueListenable: settingsNotifier, builder: (_, settingsNotifierValue, _) {
                    return KeyedSubtree(
                      key: ValueKey(settingsNotifierValue),//reconstruye los estados cuando cambia el notifier.
                      child: pages[selectedIndex]);
                  },),),
          ),
          bottomNavigationBar: NavigationBar(destinations: [
                        NavigationDestination(icon: Icon(Icons.home_work_rounded), label: 'Home'),
                        NavigationDestination(icon: Icon(Icons.article_outlined), label: 'Logbook'),
                        NavigationDestination(icon: Icon(Icons.add_home_work_rounded), label: 'New Log'),
                      ],
                      onDestinationSelected: (index){selectedIndexNotifier.value=index;},
                      selectedIndex:selectedIndex
                      ),
        );
        },),
      );});
  }
}