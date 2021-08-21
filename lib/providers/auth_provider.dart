


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

class AuthProvider extends ChangeNotifier{
 XFile? image;
bool isPicAvail=false;
String pickerError='';
String error='';

//shop data
double ? shopLatitude;
double ? shopLongitude;
String ? shopAddress;
String ? placeName;
String email='';
  Future<XFile?> getImage() async{
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

  Future getCurrentAddress() async {
    final Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    shopLatitude=_locationData.latitude;
    shopLongitude=_locationData.longitude;
    notifyListeners();
    final coordinates = Coordinates(_locationData.latitude, _locationData.longitude);
    final _addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    final shopAddress = _addresses.first;
    this.shopAddress = shopAddress.addressLine;
    placeName = shopAddress.featureName;
    notifyListeners();
    return shopAddress;
  }

  Future<UserCredential?> registerVendor(email,password)async{
    this.email = email;
    notifyListeners();
    UserCredential? userCredential;
    try {
       userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        error='The password provided is too weak.';
        notifyListeners();
        print(error);
      } else if (e.code == 'email-already-in-use') {
        error='The account already exists for that email.';
        notifyListeners();
        print(error);
      }
    } catch (e) {
      error=e.toString();
      notifyListeners();
      print(e);
    }
    return userCredential;

  }

  Future<UserCredential?> loginVendor(email,password)async{
    this.email = email;
    notifyListeners();
    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
    } on FirebaseAuthException catch (e) {
      error=e.code;
      notifyListeners();
    } catch (e) {
      error=e.toString();
      notifyListeners();
      print(e);
    }
    return userCredential;

  }

  Future<void> resetPassword(email)async{
    this.email = email;
    notifyListeners();
    try {
       await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      error=e.code;
      notifyListeners();
    } catch (e) {
      error=e.toString();
      notifyListeners();
      print(e);
    }
  }

  Future<void>saveVendorDataToDb(
      {required String url, required String shopName, required String mobile, required String dialog})async
  {
    final User? user =FirebaseAuth.instance.currentUser;
   final DocumentReference _vendors =  FirebaseFirestore.instance.collection('vendors').doc(user!.uid);
   _vendors.set({
      'uid':user.uid,
      'shopName':shopName,
      'mobile':mobile,
      'emil':email,
      'dialog':dialog,
      'address':'${placeName}:${shopAddress}',
      'location':GeoPoint(shopLatitude!.toDouble(),shopLongitude!.toDouble()),
      'shopOpen':true,
      'rating':0.0,
      'totalRating':0,
      'isTopPicked':false,
      'imageUrl' :url,
      'accVerified':false,
   });
   return null;

  }


}