

import 'package:aggricus_vendor_app/services/drawer_services.dart';
import 'package:aggricus_vendor_app/widgets/drawer_menu_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';


class HomeScreen extends StatefulWidget {
static const String id='home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DrawerServices _drawerServices = DrawerServices();
  final GlobalKey<SliderMenuContainerState> _key =
  GlobalKey<SliderMenuContainerState>();
  String title='';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  SliderMenuContainer(
          appBarHeight:80 ,
          key: _key,
          sliderMenuOpenSize: 200,
          title: Text(''),
          trailing:Row(
            children: [
              IconButton(icon:Icon(CupertinoIcons.search), onPressed: () {  },),
              IconButton(icon:Icon(CupertinoIcons.bell), onPressed: () {  },)

            ]
          ),
          sliderMenu: MenuWidget(
            onItemClick: (title) {
              _key.currentState!.closeDrawer();
              if (mounted) {
                setState(() {
                  this.title = title;
                });
              }
            },
          ),
          sliderMain: _drawerServices.drawerScreen(title)),
    );
  }
}
