import 'package:aggricus_vendor_app/providers/product_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuWidget extends StatefulWidget {
  final Function(String)? onItemClick;

  const MenuWidget({Key? key, this.onItemClick}) : super(key: key);

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}


class _MenuWidgetState extends State<MenuWidget> {
  User ? user = FirebaseAuth.instance.currentUser;
  var vendorData;
  @override
  void initState() {
getVendorData();
super.initState();
  }
  Future<DocumentSnapshot>getVendorData() async {

    final  result =  await FirebaseFirestore.instance.collection('vendors').doc(user!.uid).get();
    if (mounted) {
      setState(() {
        vendorData = result;
      });
    }
        return result;
  }

  @override
  Widget build(BuildContext context) {
    final _provider =Provider.of<ProductProvider>(context);
    _provider.getShopName(vendorData != null ? vendorData['shopName'] : '');
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 30),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 4,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: FittedBox(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.grey,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: vendorData!=null ? NetworkImage( vendorData['imageUrl']):null,
                      ),
                    ),
                    SizedBox(width: 10,),
                    Text(vendorData!=null ? vendorData['shopName'] : 'Shop Name',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
                  sliderItem('Dashboard', Icons.dashboard_outlined),
                  sliderItem('Product', Icons.shopping_bag_outlined),
                  sliderItem('Banner', CupertinoIcons.photo),
                  sliderItem('Coupons',CupertinoIcons.gift),
                  sliderItem('Orders', Icons.list_alt_outlined),
                  sliderItem('Reports', Icons.stacked_bar_chart),
                  sliderItem('Setting', Icons.settings),
                  sliderItem('LogOut', Icons.arrow_back_ios)

          ],
        ),
      ),
    );
  }

  Widget sliderItem(String title, IconData icons) => InkWell(
    onTap: () {
        widget.onItemClick!(title);
      },
    child: Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE0E0E0)
          ),
        ),
      ),
      child: SizedBox(
        height: 40,
        child: Padding(
          padding: const EdgeInsets.only(left:20),
          child: Row(
            children: [
              Icon(icons,color:Colors.black54,size:18 ,),
              SizedBox(width: 10,),
              Text(title,style: TextStyle(color:Colors.black54,fontSize: 12),),
            ],
          ),
        ),
      ),
        )
  );
}