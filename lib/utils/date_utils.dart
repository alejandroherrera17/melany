import 'package:intl/intl.dart';

String formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

String formatMonth(DateTime date) => DateFormat('MMMM yyyy').format(date);

DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month);
