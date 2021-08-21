
import 'dart:io';

import 'package:aggricus_vendor_app/providers/product_provider.dart';
import 'package:aggricus_vendor_app/services/firebase_services.dart';
import 'package:aggricus_vendor_app/widgets/category_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditViewProduct extends StatefulWidget {
  final String productId;
  const EditViewProduct({required this.productId});
  @override
  _EditViewProductState createState() => _EditViewProductState();
}

class _EditViewProductState extends State<EditViewProduct> {
  final FirebaseServices _services = FirebaseServices();
  final _formKey = GlobalKey<FormState>();
  final _brandTextController = TextEditingController();
  final _skuTextController = TextEditingController();
  final _productNameTextController = TextEditingController();
  final _weightTextController = TextEditingController();
  final _priceTextController = TextEditingController();
  final _comparedPriceTextController = TextEditingController();
  final _descriptionText = TextEditingController();
  final _categoryTextController = TextEditingController();
  final _subCategoryTextController = TextEditingController();
  final _stockTextController = TextEditingController();
  final _lowStockTextController = TextEditingController();
  final _taxTextController = TextEditingController();
  final List<String> _collections = [
    'Featured Products',
    'Best Selling',
    'Recently Added'
  ];

  String ? dropdownValue;


  DocumentSnapshot ? doc;
  double ? discount ;
  String ? image;
  String ? categoryImage;
  XFile ? _image;
  bool _visible = false;
  bool _editing = true;
  @override
  void initState() {
    getProductDetails();
    super.initState();
  }

  Future<void>getProductDetails()async{
    _services.products.doc(widget.productId).get().then((DocumentSnapshot document) {
      if (document.exists){
        setState(() {
          doc =document;
          _brandTextController.text = document['brand'];
          _skuTextController.text = document['sku'];
          _productNameTextController.text = document['productName'];
          _weightTextController.text = document['weight'];
          _priceTextController.text = document['price'].toString();
          _comparedPriceTextController.text= document['comparedPrice'].toString();
          final  difference = int.parse(_comparedPriceTextController.text)-double.parse(_priceTextController.text );
          discount = difference/int.parse(_comparedPriceTextController.text)*100;
          image = document['productImage'];
          _descriptionText.text = document['description'];
          _categoryTextController.text = document['category']['mainCategory'];
          _subCategoryTextController.text = document['category']['subCategory'];
          dropdownValue = document['collection'];
          _stockTextController.text = document['stockQty'].toString();
          _lowStockTextController.text = document['lowStockQty'].toString();
          _taxTextController.text = document['tax'].toString();
          categoryImage = document['category']['categoryImage'].toString();

        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    final _provider = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color : Colors.white
        ),
        actions: [
          TextButton(
            onPressed: (){
              setState(() {
                _editing = false;
              });
            },
            child:Text('Edit',style: TextStyle(color:Colors.white),),
          ),
        ],
      ),
      bottomSheet: Container(
        height:60 ,
        child: Row(
          children: [
            Expanded(child: InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(color:Colors.black87 , child: Center(child: Text('Cancel',style: TextStyle(color:Colors.white),)),))),
            Expanded(child: AbsorbPointer(
              absorbing: _editing,
              child: InkWell(
                  onTap: (){
                    if (_formKey.currentState!.validate()){
                      EasyLoading.show(status: 'Saving...');
                      if(_image!=null){
                        _provider.uploadFile(_image!.path, _productNameTextController.text)
                            .then((url){
                            if (url.isNotEmpty){
                              EasyLoading.dismiss();
                              _provider.updateProduct(
                                context: context,
                                productName: _productNameTextController.text,
                                weight: _weightTextController.text,
                                tax: double.parse(_taxTextController.text),
                                stockQty: int.parse(_stockTextController.text),
                                sku: _skuTextController.text,
                                price: double.parse(_priceTextController.text),
                                lowStockQty: int.parse(_lowStockTextController.text),
                                description: _descriptionText.text,
                                collection: dropdownValue,
                                brand: _brandTextController.text,
                                comparedPrice: int.parse(_comparedPriceTextController.text),
                                productId: widget.productId,
                                image: image,
                                category: _categoryTextController.text,
                                subCategory: _subCategoryTextController.text,
                                categoryImage:categoryImage,
                              );

                            }

                        });
                      }
                      else {
                        _provider.updateProduct(
                      context: context,
                      productName: _productNameTextController.text,
                      weight: _weightTextController.text,
                      tax: double.parse(_taxTextController.text),
                      stockQty: int.parse(_stockTextController.text),
                      sku: _skuTextController.text,
                      price: double.parse(_priceTextController.text),
                      lowStockQty: int.parse(_lowStockTextController.text),
                      description: _descriptionText.text,
                      collection: dropdownValue,
                      brand: _brandTextController.text,
                      comparedPrice: int.parse(_comparedPriceTextController.text),
                      productId: widget.productId,
                      image: image,
                      category: _categoryTextController.text,
                      subCategory: _subCategoryTextController.text,
                      categoryImage:categoryImage,);
                      EasyLoading.dismiss();
                      }
                      _provider.resetProvider();
                    }
                  },
                  child: Container(color:Colors.pinkAccent,child: Center(child: Text('Save',style: TextStyle(color:Colors.white),)),)),
            )),
          ],
        ),
      ),
      body: doc == null ?  Center(child: CircularProgressIndicator()): Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: [
                AbsorbPointer(
                  absorbing: _editing,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 80,
                            height: 40,
                            child: TextFormField(
                              controller: _brandTextController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10,right: 10),
                                hintText: 'Brand',
                                hintStyle: TextStyle(color: Colors.grey),
                                border:OutlineInputBorder(),
                                filled: true,
                                fillColor: Theme.of(context).primaryColor.withOpacity(.1),
                              ) ,
                            ),
                          ),
                         Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Text('SKU : '),
                             Container(
                               width: 50,
                               child: TextFormField(
                                 controller: _skuTextController,
                                 style: TextStyle(fontSize: 12),
                                 decoration: InputDecoration(
                                   contentPadding: EdgeInsets.zero,
                                   border:InputBorder.none,
                                 ) ,
                               ),
                             ),
                           ],
                         ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                        child: TextFormField(
                          controller: _productNameTextController,
                          style: TextStyle(fontSize: 30),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            border:InputBorder.none,
                          ) ,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        child: TextFormField(
                          controller: _weightTextController,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            border:InputBorder.none,
                          ) ,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            child: TextFormField(
                              controller: _priceTextController,
                              style: TextStyle(fontSize: 18),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                border:InputBorder.none,
                                prefixText: 'DT'
                              ) ,
                            ),
                          ),
                          Container(
                            width: 80,
                            child: TextFormField(
                              controller: _comparedPriceTextController,
                              style: TextStyle(fontSize: 15,decoration: TextDecoration.lineThrough ),
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  border:InputBorder.none,
                                  prefixText: 'DT'
                              ) ,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: Colors.red,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left:8,right: 8),
                              child: Text('${discount!.toStringAsFixed(0)}% OFF',style: TextStyle(color:Colors.white),),
                            ),
                          ),
                        ],
                      ),
                      Text('Inclusive of all Taxes',style: TextStyle(color: Colors.grey,
                          fontSize: 12
                      ),),
                     InkWell(
                       onTap: (){
                         _provider.getProductImage().then((image){
                           setState(() {
                             _image = image;
                           });
                         });
                       },
                       child: Padding(
                         padding : const EdgeInsets.all(8.0),
                         child :  _image != null ? Image.file(File(_image!.path),height: 300,) : Image.network(image.toString(),height: 300,)
                       ),
                     ),
                      Text('About This Product',style: TextStyle(fontSize: 20),),
                      Padding(
                          padding : const EdgeInsets.all(8.0),
                          child :TextFormField(
                            controller:_descriptionText ,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            style: TextStyle(
                              color: Colors.grey
                            ),
                            decoration: InputDecoration(
                              border:InputBorder.none
                            ),
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
                            Visibility(
                              visible: _editing ? false : true,
                              child: IconButton(
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
                              ),
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
                                      if (value!.isEmpty){
                                        return 'Select SubCategory Name';
                                      }
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
                      Row(
                        children: [
                          Text('Stock :'),
                          Expanded(
                            child: TextFormField(
                              controller: _stockTextController,
                              style: TextStyle(color: Colors.grey),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                border:InputBorder.none,
                              ) ,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Low Stock :'),
                          Expanded(
                            child: TextFormField(
                              controller: _lowStockTextController,
                              style: TextStyle(color: Colors.grey),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                border:InputBorder.none,
                              ) ,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Tax %:'),
                          Expanded(
                            child: TextFormField(
                              controller: _taxTextController,
                              style: TextStyle(color: Colors.grey),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                border:InputBorder.none,
                              ) ,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 60,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }
}
