import 'dart:io';

import 'package:aggricus_vendor_app/providers/product_provider.dart';
import 'package:aggricus_vendor_app/widgets/category_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
class AddNewProduct extends StatefulWidget {
  static const String id ='addnewproduct-screen';

  @override
  State<AddNewProduct> createState() => _AddNewProductState();
}

class _AddNewProductState extends State<AddNewProduct> {

  final _formKey = GlobalKey<FormState>();
  final List<String> _collections = [
    'Featured Products',
    'Best Selling',
    'Recently Added'
  ];
  String ? dropdownValue;

  final _categoryTextController = TextEditingController();
  final _subCategoryTextController = TextEditingController();
  final _comparedPriceTextController = TextEditingController();
  final _brandTextController = TextEditingController();
  final _lowStockTextController = TextEditingController();
  final _stockQtyTextController = TextEditingController();

  XFile ?  _image;
  bool _visible = false;
  bool _track=false;
  String productName='';
  String aboutProduct='';
  double? productPrice;
  double? comparedPrice;
  String sku='';
  String weight='';
  double? tax;
  int? stockQty;
  @override
  Widget build(BuildContext context) {

    final _provider = Provider.of<ProductProvider>(context);


    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(),
        body: Form(
          key:_formKey,
          child: Column(
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
                          child: Text('Products / Add'),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          if(_formKey.currentState!.validate()){
                           if (_categoryTextController.text.isNotEmpty){
                               if(_image!=null){
                                 EasyLoading.show(status:'Saving...',);
                                 _provider.uploadFile(_image!.path, productName).then((url){
                                   if (url.isNotEmpty)
                                   {     EasyLoading.dismiss();
                                   _provider.saveProductDataToDb(
                                     productName:productName,
                                     description:aboutProduct,
                                     price:productPrice,
                                     comparedPrice:_comparedPriceTextController.text,
                                     collection:dropdownValue,
                                     brand:_brandTextController.text,
                                     sku:sku,
                                     weight:weight,
                                     tax:tax,
                                     stockQty: int.parse(_stockQtyTextController.text),
                                     lowStockQty: int.parse(_lowStockTextController.text),
                                     context: context,
                                   );
                                   setState(() {
                                     _formKey.currentState!.reset();
                                     _categoryTextController.clear();
                                     _subCategoryTextController.clear();
                                     _comparedPriceTextController.clear();
                                     _brandTextController.clear();
                                     _lowStockTextController.clear();
                                     _stockQtyTextController.clear();
                                     dropdownValue = null;
                                     _track = false;
                                     _image = null;
                                     _visible = false;


                                   });
                                   }
                                   else {
                                     _provider.alertDialog(
                                         context:context,
                                         title: 'IMAGE UPLOAD',
                                         content: 'Failed to upload product image');
                                   }
                                 });
                               }
                               else {
                                 _provider.alertDialog(
                                     context:context,
                                     title: 'PRODUCT IMAGE',
                                     content: 'Product Image not selected');
                               }

                           }
                           else {
                            _provider.alertDialog(
                            context: context,
                            title: 'Main Category' ,
                            content: 'Main Category not selected');

                           }
                          }
                        },
                        icon: Icon(Icons.save,color: Colors.white,),
                        label: Text('Save',style: TextStyle(color: Colors.white),),
                        style: TextButton.styleFrom(backgroundColor: Theme.of(context).primaryColor,),
                      ),
                    ],
                  ),
                ),
              ),
              TabBar(
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.black54,
                tabs: [
                  Tab(text:'GENERAL'),
                  Tab(text:'INVENTORY'),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: TabBarView(
                      children: [
                        ListView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    validator:(value) {
                                      if (value!.isEmpty){
                                        return 'Enter product name';
                                      }
                                      setState((){
                                        productName = value;

                                      });
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Product Name*',
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFFE0E0E0),
                                        )
                                      )
                                    ),
                                  ),
                                  TextFormField(
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 5,
                                    maxLength: 500,

                                    validator:(value) {
                                      if (value!.isEmpty){
                                        return 'Enter product description';
                                      }
                                      setState((){
                                        aboutProduct = value;

                                      });
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        labelText: 'About Product*',
                                        labelStyle: TextStyle(color: Colors.grey),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xFFE0E0E0),
                                            )
                                        )
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: (){
                                        _provider.getProductImage().then((image){
                                          setState(() {
                                                  _image = image;
                                          });
                                        } );
                                      },
                                      child: SizedBox(
                                        width: 150,
                                        height: 150,
                                        child: Card(
                                          child: Center(
                                            child: _image == null ? Text('Select Image') : Image.file(File(_image!.path)),
                                            ),
                                          ),
                                        ),
                                    ),
                                    ),
                                  TextFormField(
                                    validator:(value) {
                                      if (value!.isEmpty){
                                        return 'Enter product price';
                                      }
                                      setState((){
                                        productPrice = double.parse(value);

                                      });
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                        labelText: 'Price*',
                                        labelStyle: TextStyle(color: Colors.grey),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xFFE0E0E0),
                                            )
                                        )
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _comparedPriceTextController,
                                    validator:(value) {
                                      if(productPrice!>double.parse(value!)){
                                        return 'Compared price should be higher than price';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                        labelText: 'Compared Price*',
                                        labelStyle: TextStyle(color: Colors.grey),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xFFE0E0E0),
                                            )
                                        )
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      children: [
                                        Text('Collection',style: TextStyle(color:Colors.grey),),
                                        SizedBox(width: 10,),
                                        DropdownButton<String>(
                                          hint: Text('Select Collection'),
                                          value: dropdownValue,
                                          icon:  Icon(Icons.arrow_drop_down),
                                          onChanged:(String ? value){
                                            setState(() {
                                              dropdownValue=value;
                                            });
                                          } ,
                                          items: _collections.map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        )
                                      ],
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _brandTextController,
                                    decoration: InputDecoration(
                                        labelText: 'Brand',
                                        labelStyle: TextStyle(color: Colors.grey),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xFFE0E0E0),
                                            )
                                        )
                                    ),
                                  ),
                                  TextFormField(
                                    validator:(value) {
                                      if (value!.isEmpty){
                                        return 'Enter SKU';
                                      }
                                      setState((){
                                        sku = value;

                                      });
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        labelText: 'SKU',
                                        labelStyle: TextStyle(color: Colors.grey),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xFFE0E0E0),
                                            )
                                        )
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top:20,bottom: 10),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Category',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(width: 10,),
                                        Expanded(
                                          child: AbsorbPointer(
                                            child: TextFormField(
                                              validator:(value) {
                                                if (value!.isEmpty){
                                                  return 'Select Category Name';
                                                }
                                                return null;
                                              },
                                              controller: _categoryTextController,
                                              decoration: InputDecoration(
                                                  hintText: 'not selected',
                                                  labelStyle: TextStyle(color: Colors.grey),
                                                  enabledBorder: UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Color(0xFFE0E0E0),
                                                      )
                                                  )
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit_outlined),
                                          onPressed:(){
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CategoryList();
                                              }
                                            ).whenComplete(() {
                                              setState(() {
                                                _categoryTextController.text = _provider.selectedCategory;
                                                _visible = true;

                                              });
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: _visible,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top:10,bottom:20),
                                      child: Row(
                                        children: [
                                          Text('Sub Category'
                                              ,style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(width: 10,),
                                          Expanded(
                                            child: AbsorbPointer(
                                              child: TextFormField(
                                                validator:(value) {

                                                  return null;
                                                },
                                                controller: _subCategoryTextController,
                                                decoration: InputDecoration(
                                                    hintText: 'not selected',
                                                    labelStyle: TextStyle(color: Colors.grey),
                                                    enabledBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Color(0xFFE0E0E0),
                                                        )
                                                    )
                                                ),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.edit_outlined),
                                            onPressed:(){
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return SubCategoryList();
                                                  }
                                              ).whenComplete(() {
                                                setState(() {
                                                  _subCategoryTextController.text = _provider.selectedSubCategory;

                                                });
                                              });
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    validator:(value) {
                                      if (value!.isEmpty){
                                        return 'Enter Weight';
                                      }
                                      setState(() {
                                        weight=value;
                                      });
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        labelText: 'Weight. eg:- Kg, gm, etc',
                                        labelStyle: TextStyle(color: Colors.grey),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xFFE0E0E0),
                                            )
                                        )
                                    ),
                                  ),
                                  TextFormField(
                                    validator:(value) {
                                      if (value!.isEmpty){
                                        return 'Enter tax %';
                                      }
                                      setState(() {
                                        tax=double.parse(value);
                                      });
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                        labelText: 'Tax %',
                                        labelStyle: TextStyle(color: Colors.grey),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xFFE0E0E0),
                                            )
                                        )
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: Text('Track Inventory'),
                                activeColor: Theme.of(context).primaryColor,
                                subtitle: Text('Switch On to Track Inventory',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                value: _track,
                                onChanged: (selected){
                                  setState(() {
                                    _track =! _track;
                                  });
                                },
                              ),
                              Visibility(
                                visible: _track,
                                child: SizedBox(
                                  height: 300,
                                  width: double.infinity,
                                  child: Card(
                                    elevation: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            controller:_stockQtyTextController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                                labelText: 'Inventory Quantity*',
                                                labelStyle: TextStyle(color: Colors.grey),
                                                enabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0xFFE0E0E0),
                                                    )
                                                )
                                            ),
                                          ),
                                          TextFormField(
                                            controller: _lowStockTextController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                                labelText: 'Inventory low stock quantity',
                                                labelStyle: TextStyle(color: Colors.grey),
                                                enabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0xFFE0E0E0),
                                                    )
                                                )
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
