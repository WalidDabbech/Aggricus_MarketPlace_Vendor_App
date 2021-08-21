

import 'package:aggricus_vendor_app/services/firebase_services.dart';
import 'package:aggricus_vendor_app/services/order_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';

class DeliveryBoysList extends StatefulWidget {
  final DocumentSnapshot document;
  const DeliveryBoysList(this.document);

  @override
  _DeliveryBoysListState createState() => _DeliveryBoysListState();
}

class _DeliveryBoysListState extends State<DeliveryBoysList> {
  final FirebaseServices _services = FirebaseServices();
  final OrderServices _orderServices = OrderServices();

  GeoPoint ?  _shopLocation;
@override
  void initState() {
  _services.getShopDetails().then((value) {
    if (value.exists){
      if(mounted)
      {
        setState(() {
          _shopLocation = value['location'];
        });
      }
    }
    else {
     print('No Data');
    }
  });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width:  MediaQuery.of(context).size.width,
        child:Column(
          children: [
            AppBar(
              title: Text('Select Delivery Boy',style: TextStyle(color: Colors.white) ,),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _services.boys.where('accVerified',isEqualTo:true).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.size==0){
                  //TODO:No Boys Screen
                  return Center (child: Text('No Delivery Boys'));
                }

                return Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                          final GeoPoint location = document['location'];
                          final double distanceInMetres = _shopLocation == null ? 0.0 : Geolocator.distanceBetween(_shopLocation!.latitude,_shopLocation!.longitude ,location.latitude ,location.longitude )/1000;
                        if (distanceInMetres> 10 ) {
                          return Container ();
                        }
                          return Column(
                            children: [
                              ListTile(
                                onTap: (){
                                  EasyLoading.show(status: 'Assigning Boys');
                                  _services.selectBoys(orderId : widget.document.id , location : document['location'] , name : document['name'] , image :document['imageUrl'], phone : document['mobile'], email: document['email'] ).then((value) {
                                    EasyLoading.showSuccess('Delivery Boy Assigned Successfully');
                                    Navigator.pop(context);
                                  });

                                },
                                leading: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Image.network(document['imageUrl']),
                                ),
                                title: Text(document['name']),
                                subtitle: Text('${distanceInMetres.toStringAsFixed(0)}KM'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(onPressed: (){
                                      final GeoPoint location = document['location'];
                                      _orderServices.launchMap(location,document['name']);
                                    }, icon: Icon(Icons.map,color: Theme.of(context).primaryColor,)),
                                    IconButton(onPressed: (){
                                      _orderServices.launchCall('tel:${document['mobile']}');
                                    }, icon: Icon(Icons.phone,color: Theme.of(context).primaryColor)),

                                  ],
                                ),
                              ),
                              Divider(height: 2,color:Colors.grey),

                            ],
                          );
                    }).toList(),
                  ),
                );
              },
            )
          ],
        )
      ),
    );
  }
}
