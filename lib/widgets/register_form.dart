import 'dart:io';

import 'package:aggricus_vendor_app/providers/auth_provider.dart';
import 'package:aggricus_vendor_app/screens/home_screen.dart';
import 'package:aggricus_vendor_app/screens/login_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterForm extends StatefulWidget {

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _cPasswordTextController = TextEditingController();
  final _addressTextController = TextEditingController();
  final _nameTextController = TextEditingController();
  final _dialogTextController = TextEditingController();


  String email='';
  String password='';
  String mobile='';
  String shopName='';

  bool _isLoading = false;

  Future<String> uploadFile(filePath) async {
    final File file = File(filePath);
    final FirebaseStorage _storage = FirebaseStorage.instance;
    try {
      await _storage.ref('uploads/shopProfilePic/${_nameTextController.text}').putFile(file);
    } on FirebaseException catch (e) {
      print(e.code);
    }
    final String downloadURL = await _storage
        .ref('uploads/shopProfilePic/${_nameTextController.text}')
        .getDownloadURL();
    return downloadURL;
  }
  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);
    scaffoldMessage(message){
      return ScaffoldMessenger
          .of(context)
          .showSnackBar(SnackBar(content: Text(message)));

    }
    return _isLoading ? CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
    ) :  Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              cursorColor: Theme.of(context).primaryColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter Shop Name';
                }
                setState(() {
                  _nameTextController.text=value;
                });
                setState(() {
                  shopName=value;
                });
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.add_business,color: Theme.of(context).primaryColor,),
                labelText: 'Business Name',
                labelStyle: TextStyle(color:Theme.of(context).primaryColor,),
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2, color: Theme.of(context).primaryColor,
                  ),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              maxLength: 8,
              keyboardType: TextInputType.phone,
              cursorColor: Theme.of(context).primaryColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter Mobile Number';
                }
                setState(() {
                  mobile=value;
                });
                return null;
              },
              decoration: InputDecoration(
                prefixText: '+216',
                prefixIcon: Icon(Icons.phone_android,color: Theme.of(context).primaryColor,),
                labelText: 'Mobile Number',
                labelStyle: TextStyle(color:Theme.of(context).primaryColor,),
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2, color: Theme.of(context).primaryColor,
                  ),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              controller: _emailTextController,
              keyboardType: TextInputType.emailAddress,
              cursorColor: Theme.of(context).primaryColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter Email';
                }
                final bool _isValid = EmailValidator.validate(_emailTextController.text);
                if (!_isValid){
                  return 'Invalid Email Format';
                }
                setState(() {
                  email=value;
                });
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email_outlined,color: Theme.of(context).primaryColor,),
                labelText: 'Email',
                labelStyle: TextStyle(color:Theme.of(context).primaryColor,),
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2, color: Theme.of(context).primaryColor,
                  ),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              obscureText: true,
              controller: _passwordTextController,
              cursorColor: Theme.of(context).primaryColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter Password';
                }
                if (value.length<6){
                  return 'Minimum 6 characters';
                }
                setState(() {
                  password=value;
                });
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.vpn_key_outlined,color: Theme.of(context).primaryColor,),
                labelText: 'Password',
                labelStyle: TextStyle(color:Theme.of(context).primaryColor,),
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2, color: Theme.of(context).primaryColor,
                  ),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              controller: _cPasswordTextController,
              obscureText: true,
              cursorColor: Theme.of(context).primaryColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter Confirm Password';
                }
                if (value.length<6){
                  return 'Minimum 6 characters';
                  }
                if (_cPasswordTextController.text!=_passwordTextController.text){
                  return 'Password dosen\'t match';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.vpn_key_outlined,color: Theme.of(context).primaryColor,),
                labelText: 'Confirm Password',
                labelStyle: TextStyle(color:Theme.of(context).primaryColor,),
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2, color: Theme.of(context).primaryColor,
                  ),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              maxLines: 5,
              controller: _addressTextController,
              cursorColor: Theme.of(context).primaryColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please press navigation Button';
                }
                if (_authData.shopLatitude==null){
                  'Please press navigation Button';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.contact_mail_outlined,color: Theme.of(context).primaryColor,),
                labelText: 'Business Location',
                labelStyle: TextStyle(color:Theme.of(context).primaryColor,),
                suffixIcon: IconButton(onPressed: () {
                  _addressTextController.text='Locating...\n Please wait...';
                  _authData.getCurrentAddress().then((address) {
                      if(address!=null){
                        _addressTextController.text='${_authData.placeName}\n${_authData.shopAddress}';
                      }
                      else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not find location ... Try again')));
                      }
                  });
                }, icon:Icon(Icons.location_searching,color: Theme.of(context).primaryColor,) ,),
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2, color: Theme.of(context).primaryColor,
                  ),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              cursorColor: Theme.of(context).primaryColor,
              onChanged: (value){
                _dialogTextController.text=value;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.comment,color: Theme.of(context).primaryColor,),
                labelText: 'Shop Dialog',
                labelStyle: TextStyle(color:Theme.of(context).primaryColor,),
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2, color: Theme.of(context).primaryColor,
                  ),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          SizedBox(height: 20,),
          Row(
            children:[ Expanded(
              child: TextButton(
                  style: TextButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                  onPressed: () {
                    if(_authData.isPicAvail==true){
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading=true;
                        });
                        _authData.registerVendor(email, password).then((credential) {
                          if(credential!.user!.uid.isNotEmpty){
                                uploadFile(_authData.image!.path).then((url) {
                                  if(url.isNotEmpty){

                                    _authData.saveVendorDataToDb(url: url,
                                        shopName: shopName,
                                        mobile: mobile,
                                        dialog: _dialogTextController.text);
                                          setState(() {
                                            _isLoading=false;
                                          });
                                          Navigator.pushReplacementNamed(context, HomeScreen.id);


                                  }
                                  else {
                                    scaffoldMessage('Filed to upload shop Profile Pic');
                                  }
                                });
                          }
                          else {
                            scaffoldMessage(_authData.error);
                          }
                        });
                      }

                    }else {
                      scaffoldMessage('Shop Profile Pic need to be Added');

                    }

                  },
                  child: Text('Register',style: TextStyle(color: Colors.white),)),
            ),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, LoginScreen.id);
                },
                child: RichText(text: TextSpan(
                    text:'',
                    children: [
                      TextSpan(text:'Already have an account ?'
                          ,style:TextStyle(color: Colors.black) ),
                      TextSpan(text:'Login'
                          ,style:TextStyle(
                              fontWeight: FontWeight.bold,
                              color:Colors.red
                          ) ),
                    ]
                ),
                ),),
            ],
          ),
          
        ],
      ),
    );
  }
}
