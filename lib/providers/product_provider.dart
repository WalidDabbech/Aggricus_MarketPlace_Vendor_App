


import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class ProductProvider with ChangeNotifier {
  XFile? image;
  bool isPicAvail=false;
  String pickerError='';
  String error='';
  String selectedCategory='';
  String selectedSubCategory='' ;
  String shopName='';
  String categoryImage='';
  String productUrl='';

  getShopName(shopName){
    this.shopName = shopName;
  }

  resetProvider(){
    selectedCategory='';
    selectedSubCategory='' ;
    shopName='';
    categoryImage='';
    productUrl='';
    notifyListeners();

  }

  selectCategory(mainCategory,categoryImage){
  selectedCategory = mainCategory;
  this.categoryImage = categoryImage;
  notifyListeners();
}

  selectSubCategory(selected){
    selectedSubCategory =selected;
    notifyListeners();
  }

  Future<String> uploadFile(filePath,productName) async {
    final File file = File(filePath);
    final timeStamp = Timestamp.now().microsecondsSinceEpoch;
    final FirebaseStorage _storage = FirebaseStorage.instance;
    try {
      await _storage.ref('productImage/$shopName/$productName$timeStamp').putFile(file);
    } on FirebaseException catch (e) {
      print(e.code);
    }
    final String downloadURL = await _storage
        .ref('productImage/$shopName/$productName$timeStamp')
        .getDownloadURL();
    productUrl = downloadURL;
    notifyListeners();
    return downloadURL;
  }

  Future<XFile?> getProductImage() async{
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery,imageQuality: 20);
    if (pickedFile != null){
      image = XFile(pickedFile.path);
      notifyListeners();
    }
    else {
      pickerError='No image selected.';
      print(pickerError);
      notifyListeners();
    }
    return image;
  }
  
  alertDialog({context, title, content}){
    showCupertinoDialog(context: context, builder:(BuildContext context){
      return CupertinoAlertDialog(
        title:Text(title),
        content:Text(content),
        actions: [
          CupertinoDialogAction(onPressed: (){
            Navigator.pop(context);
          },child: Text('OK'),)
        ],
      );
    });
  }

  Future<void>saveProductDataToDb(
      {
        productName,
        description,
        price,
        comparedPrice,
        collection,
        brand,
        sku,
        weight,
        tax,
        stockQty,
        lowStockQty,
        context,
        productUrl
      }
      ) async {
    final timeStamp = DateTime.now().microsecondsSinceEpoch;
    final User? user = FirebaseAuth.instance.currentUser;
    final CollectionReference _products = FirebaseFirestore.instance.collection('products');
    try {
      _products.doc(timeStamp.toString()).set({
        'seller' : {'shopName': shopName,'sellerUid' : user!.uid},
        'productName': productName,
        'description' : description,
        'price' : price ,
        'comparedPrice' : comparedPrice,
        'collection' : collection,
        'brand' : brand,
        'sku' : sku,
        'category' : {'mainCategory' : selectedCategory,'subCategory':selectedSubCategory,'categoryImage' : categoryImage},
        'weight':weight,
        'tax' : tax,
        'stockQty' : stockQty,
        'lowStockQty' : lowStockQty,
        'published' : false,
        'productId' : timeStamp.toString(),
        'productImage' : this.productUrl
      });
      alertDialog(
        context : context,
        title : 'SAVE DATA',
        content :'Product Details saved successfully'
      );
    }
    catch (e){
      alertDialog(
          context : context,
          title : 'SAVE DATA',
          content :e.toString()
      );
    }
    return null;
  }

  Future<void>updateProduct(
      {
        productName,
        description,
        price,
        comparedPrice,
        collection,
        brand,
        sku,
        weight,
        tax,
        stockQty,
        lowStockQty,
        context,
        productUrl,
        productId,
        image,
        category,
        subCategory,
        categoryImage
      }
      ) async {
    final CollectionReference _products = FirebaseFirestore.instance.collection('products');
    try {
      _products.doc(productId).update({
        'productName': productName,
        'description' : description,
        'price' : price ,
        'comparedPrice' : comparedPrice,
        'collection' : collection,
        'brand' : brand,
        'sku' : sku,
        'category' : {'mainCategory' : category,'subCategory':subCategory,'categoryImage' : this.categoryImage},
        'weight':weight,
        'tax' : tax,
        'stockQty' : stockQty,
        'lowStockQty' : lowStockQty,
        'productImage' : this.productUrl
      });
      alertDialog(
          context : context,
          title : 'SAVE DATA',
          content :'Product Details saved successfully'
      );
    }
    catch (e){
      alertDialog(
          context : context,
          title : 'SAVE DATA',
          content :e.toString()
      );
    }
    return null;
  }

}