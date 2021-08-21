

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServices {

  User? user = FirebaseAuth.instance.currentUser;
  CollectionReference category = FirebaseFirestore.instance.collection('category');
  CollectionReference products = FirebaseFirestore.instance.collection('products');
  CollectionReference vendorbanner = FirebaseFirestore.instance.collection('vendorbanner');
  CollectionReference coupons = FirebaseFirestore.instance.collection('coupons');
  CollectionReference boys = FirebaseFirestore.instance.collection('boys');
  CollectionReference vendors = FirebaseFirestore.instance.collection('vendors');
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> publishProduct({id}) {
    return products.doc(id).update({
      'published': true
    });
  }

  Future<void> unpublishProduct({id}) {
    return products.doc(id).update({
      'published': false
    });
  }

  Future<void> deleteProduct({id}) {
    return products.doc(id).delete();
  }

  Future<void> saveBanner(url) {
    return vendorbanner.add({
      'imageUrl': url,
      'sellerUid': user!.uid
    });
  }

  Future<void> deleteBanner({id}) {
    return vendorbanner.doc(id).delete();
  }

  Future<void> saveCoupon(
      {document, title, discountRate, expiry, details, active}) {
    if (document == null) {
      return coupons.doc(title).set({
        'title': title,
        'discountRate': discountRate,
        'expiry': expiry,
        'details': details,
        'active': active,
        'sellerId': user!.uid
      });
    }
    return coupons.doc(title).update({
      'title': title,
      'discountRate': discountRate,
      'expiry': expiry,
      'details': details,
      'active': active,
      'sellerId': user!.uid
    });
  }

  Future <DocumentSnapshot> getShopDetails()async{
    final DocumentSnapshot doc = await vendors.doc(user!.uid).get();
    return doc ;
  }
  Future <DocumentSnapshot> getUserDetails(id)async{
    final DocumentSnapshot doc = await users.doc(id).get();
    return doc ;
  }
  Future <void >selectBoys({orderId, location, name, image, phone,email})async{
    final result = orders.doc(orderId).update({
      'deliveryBoy': {
        'location':location,
        'image' : image,
        'name' : name ,
        'phone' : phone,
        'email' : email,
      }
    });
    return result;
  }
}