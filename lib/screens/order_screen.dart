import 'package:aggricus_vendor_app/providers/order_provider.dart';
import 'package:aggricus_vendor_app/services/order_services.dart';
import 'package:aggricus_vendor_app/widgets/order_summary_card.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final OrderServices _orderServices = OrderServices();
  User ? user = FirebaseAuth.instance.currentUser;
  int tag = 0;
  List<String> options = [
    'All Orders', 'Ordered', 'Accepted', 'Picked Up',
    'On the way', 'Delivered',
  ];


  @override
  Widget build(BuildContext context) {
    final _orderProvider = Provider.of<OrderProvider>(context);
    return Scaffold(
      backgroundColor:Colors.grey[200],
      body: Column(
        children: [
          Container(
            height: 40,
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).primaryColor,
            child: Center(
              child: Text('My Orders',
              style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
            ),
          ),
          Container(
            height: 56,
            width: MediaQuery.of(context).size.width,
            child: ChipsChoice<int>.single(
              choiceStyle: C2ChoiceStyle(borderRadius:
              BorderRadius.all(Radius.circular(3))),
              value: tag,
              onChanged: (val) {
                if (val==0){
                  setState(() {
                    _orderProvider.filterOrder(null);
                  });
                }
                setState(() {
                  tag = val;
                  if (tag>0) {
                    _orderProvider.filterOrder(options[val]);
                  }
                });
              },
              choiceItems: C2Choice.listFrom<int, String>(
                source: options,
                value: (i, v) => i,
                label: (i, v) => v,
              ),
            ),
          ),
          Container(
              child:StreamBuilder<QuerySnapshot>(
                stream: _orderServices.orders.where('seller.sellerName',isEqualTo:user!.uid).where('orderStatus',isEqualTo: _orderProvider.status).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data!.size==0){
                    //TODO:No Orders Screen
                    return Center (child: Text(tag>0 ? 'No ${options[tag]} orders':'No Orders. Continue Shopping'),);
                  }

                  return Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: snapshot.data!.docs.map((DocumentSnapshot document) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom:4),
                          child: OrderSummaryCard(document),
                        );
                      }).toList(),
                    ),
                  );
                },
              )
          ),
        ],
      ),
    );
  }
 
}
