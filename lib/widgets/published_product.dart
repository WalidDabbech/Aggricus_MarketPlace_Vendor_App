
import 'package:aggricus_vendor_app/screens/edit_view_product.dart';
import 'package:aggricus_vendor_app/services/firebase_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PublishedProducts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirebaseServices _services = FirebaseServices();
    return Container(
      child: StreamBuilder(
        stream:
        _services.products.where('published', isEqualTo:
        true).snapshots(),
        builder: (context, AsyncSnapshot <QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong..');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return SingleChildScrollView(
            child: FittedBox(
              child: DataTable(
                showBottomBorder: true,
                dataRowHeight: 60,
                headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                columns: <DataColumn>[
                  DataColumn(
                    label: Expanded(child: Text('Product')),
                  ),
                  DataColumn(
                    label: Text('Image'),
                  ),
                  DataColumn(
                    label: Text('Info'),
                  ),
                  DataColumn(
                    label: Text('Actions'),
                  ),
                ],
                rows: _productDetails(snapshot.data, context),
              ),
            ),
          );
        },
      ),
    );
  }

  List<DataRow> _productDetails(QuerySnapshot ? snapshot, context) {
    final List<DataRow> newList = snapshot!.docs.map((DocumentSnapshot document) {
      if (document.exists) {
        return DataRow(cells: [
          DataCell(Container(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Row(
                children: [
                  Text(
                    'Name: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize:
                    15),
                  ),
                  Expanded(
                      child: Text(document['productName'],
                          style: TextStyle(fontSize: 15))),
                ],
              ),
              subtitle: Row(
                children: [
                  Text(
                    'SKU: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize:
                    12),
                  ),
                  Text(document['sku'], style: TextStyle(fontSize:
                  12)),
                ],
              ),
            ),
          )),
          DataCell(Container(
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Row(
                children: [
                  Image.network(
                    document['productImage'],
                    width: 50,
                  ),
                ],
              ),
            ),
          )),
          DataCell(IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditViewProduct(
                    productId: document['productId'],
                  ),
                ),
              );
            },
            icon: Icon(Icons.info_outline),
          )),
          DataCell(popUpButton(document.data())),
        ]);
      }
    }).map((e) => e as DataRow).toList();
    return newList;
  }

  Widget popUpButton(data, {BuildContext? context}) {
    final FirebaseServices _services = FirebaseServices();

    return PopupMenuButton<String>(
        onSelected: (String value) {
          if (value == 'unpublish') {
            _services.unpublishProduct(
              id: data['productId'],
            );
          }

          if (value == 'delete') {
            _services.deleteProduct(id: data['productId']);
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'unpublish',
            child: ListTile(
              leading: Icon(Icons.check),
              title: Text('UnPublish'),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete_outline),
              title: Text('Delete Product'),
            ),
          ),
        ]);
  }
}