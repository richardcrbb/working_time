import 'package:flutter/material.dart';

//!                   INDEX
ValueNotifier<int> selectedIndexNotifier = ValueNotifier<int>(0);

//!                   DARK MODE
ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(true);

//!                 SETTINGS
ValueNotifier<int> settingsNotifier = ValueNotifier(0);

//!                 GLOBAL VARIABLE PERIODS BACK
int periodOffset = 0;

//!                 FILTER PARAMETERS
late DateTime filterStartDay;
late DateTime filterEndDay;
