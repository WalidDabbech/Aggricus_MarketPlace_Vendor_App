import 'package:aggricus_vendor_app/screens/add_newproduct_screen.dart';
import 'package:aggricus_vendor_app/widgets/published_product.dart';
import 'package:aggricus_vendor_app/widgets/unpublished_product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body:Column(
          children: [
            Material(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Container(
                        child: Row(
                          children: [
                            Text('Products'),
                            SizedBox(width: 10,),
                            CircleAvatar(
                              backgroundColor:Colors.black54,
                              maxRadius:8,
                              child: FittedBox(
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Text('20',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                ),
                              ),

                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AddNewProduct.id);
                      },
                      icon: Icon(Icons.add,color: Colors.white,),
                      label: Text('Add New',style: TextStyle(color: Colors.white),),
                      style: TextButton.styleFrom(backgroundColor: Theme.of(context).primaryColor,),

                    ),

                  ],
                ),
              ),
            ),
            TabBar(
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Theme.of(context).primaryColor,
              tabs:[
                Tab(text: 'PUBLISHED',),
                Tab(text: 'UNPUBLISHED')
              ]
            ),
            Expanded(
              child:Container(
                child: TabBarView(
                  children: [
                    PublishedProducts(),
                    UnPublishedProducts(),
                  ],
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
}
