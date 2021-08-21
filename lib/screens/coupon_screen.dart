import 'package:aggricus_vendor_app/screens/add_edit_coupon_screen.dart';
import 'package:aggricus_vendor_app/services/firebase_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CouponScreen extends StatelessWidget {
static const String id ='coupon-screen';
  @override
  Widget build(BuildContext context) {
    final FirebaseServices _services = FirebaseServices();
    return Scaffold(
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: _services.coupons.where('sellerId',isEqualTo: _services.user!.uid ).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(),);
            }

            return Column(
              children: [
                Row(
                  mainAxisAlignment : MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        onPressed: (){
                          Navigator.pushNamed(context, AddEditCoupon.id);
                        },
                        style: TextButton.styleFrom(backgroundColor: Theme.of(context).primaryColor,),
                        child: Text('Add new Coupon',style: TextStyle(color: Colors.white),),),
                    ),
                  ],
                ),
                FittedBox(
                  child: DataTable(columns: <DataColumn> [
                    DataColumn(label: Text('Title'),),
                    DataColumn(label: Text('Rate'),),
                    DataColumn(label: Text('Status'),),
                    DataColumn(label: Text('Expiry'),),
                    DataColumn(label: Text('Info'),),
                    ],
                    rows: _couponList(snapshot.data,context)),
                )
              ],
            );
          },
        ),
      ),
    );
  }
  List<DataRow>_couponList(QuerySnapshot ? snapshot,context){
    final List<DataRow> newList = snapshot!.docs.map((DocumentSnapshot document){
      if (document.exists){
        final date = document['expiry'];
        final expiry = DateFormat.yMMMd().add_jm().format(date.toDate());
        return DataRow(cells:[
              DataCell(Text(document['title'])),
              DataCell(Text(document['discountRate'].toString())),
              DataCell(Text(document['active'] ? 'Active' : 'Inactive'),),
              DataCell(Text(expiry.toString())),
              DataCell(IconButton(
                icon:Icon(Icons.info_outline_rounded),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>AddEditCoupon(document: document,),),);
                },))
        ],);

      }
    }).map((e) => e as DataRow).toList();
    return newList;
  }
}
