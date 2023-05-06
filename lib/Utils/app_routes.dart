import 'package:get/get.dart';
import 'package:transmission_surgicals/Screen/Dashboard/dashboard.dart';
import 'package:transmission_surgicals/Screen/login.dart';
import '../Screen/Invoice/View/create_invoice.dart';
import '../Screen/Invoice/View/invoice_list.dart';
import '../Screen/RoadChallan/View/challan_list.dart';
import '../Screen/RoadChallan/View/create_challan.dart';
import '../Screen/splash_screen.dart';

appRoutes()=>[
  GetPage(
    name: '/splash-screen',
    page: () => SplashScreen(),
    transition: Transition.fade,
    transitionDuration: Duration(milliseconds: 300),
  ),

  GetPage(
    name: '/login',
    page: () => Login(),
    transition: Transition.fade,
    transitionDuration: Duration(milliseconds: 300),
  ),

  GetPage(
    name: '/dashboard',
    page: () => Dashboard(),
    transition: Transition.fade,
    transitionDuration: Duration(milliseconds: 300),
  ),

  GetPage(
    name: '/invoice-list',
    page: () => InvoiceList(),
    transition: Transition.fade,
    transitionDuration: Duration(milliseconds: 300),
  ),

  GetPage(
    name: '/create-invoice',
    page: () => InvoiceCreate(),
    transition: Transition.fade,
    transitionDuration: Duration(milliseconds: 300),
  ),

  GetPage(
    name: '/challan-invoice',
    page: () => ChallanList(),
    transition: Transition.fade,
    transitionDuration: Duration(milliseconds: 300),
  ),

  GetPage(
    name: '/create-challan',
    page: () => CreateChallan(),
    transition: Transition.fade,
    transitionDuration: Duration(milliseconds: 300),
  ),


];