import 'package:aggricus_vendor_app/services/firebase_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';

class AddEditCoupon extends StatefulWidget {
  static const String id ='update-coupon';

  final DocumentSnapshot ? document;
  const AddEditCoupon({this.document});

  @override
  _AddEditCouponState createState() => _AddEditCouponState();
}

class _AddEditCouponState extends State<AddEditCoupon> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseServices _services = FirebaseServices();
  DateTime  _selectedDate = DateTime.now();
  var dateText = TextEditingController();
  var title = TextEditingController();
  var details = TextEditingController();
  var discount = TextEditingController();


  bool _active = false ;
  _selectDate(context) async{
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        final String formattedText = DateFormat('yyyy-MM-dd').format(_selectedDate);
        dateText.text = formattedText;
      });
    }
  }
  @override
  void initState() {
    if(widget.document != null){
      setState(() {
        title.text = widget.document!['title'];
        discount.text = widget.document!['discountRate'].toString();
        details.text =widget.document!['details'];
        dateText.text = widget.document!['expiry'].toDate().toString();
        _active = widget.document!['active'];
      });
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Text('Add / Edit Coupon',style: TextStyle(color: Colors.white),),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child:Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextFormField(
                  controller: title,
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Enter Coupon title';
                    }
                    return null;
                  },
                    decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                    labelText: 'Coupon title',
                    labelStyle: TextStyle (color:Colors.grey),
                    contentPadding: EdgeInsets.zero
                  ),
                ),
                TextFormField(
                  controller: discount,
                  keyboardType: TextInputType.number,
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Enter Discount %';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                      labelText: 'Discount %',
                      labelStyle: TextStyle (color:Colors.grey),
                      contentPadding: EdgeInsets.zero
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: dateText,
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Apply Expiry Date';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                      labelText: 'Apply Expiry Date',
                      labelStyle: TextStyle (color:Colors.grey),
                      contentPadding: EdgeInsets.zero,
                      suffixIcon: InkWell(
                          onTap: (){
                            _selectDate(context);
                          },
                          child: Icon(Icons.date_range_outlined,color: Theme.of(context).primaryColor,))
                  ),
                ),
                TextFormField(
                  controller: details,
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Enter Coupon Details';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                      labelText: 'Coupon Details',
                      labelStyle: TextStyle (color:Colors.grey),
                      contentPadding: EdgeInsets.zero
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title : Text('Activate Coupon'),
                  value : _active,
                  onChanged: (bool newValue){
                    setState(() {
                      _active = !_active;
                    });
                  },
                ),
                const SizedBox(height: 20,),
                Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(backgroundColor: Theme.of(context).primaryColor,),
                          onPressed: () {
                            if (_formKey.currentState!.validate()){
                              EasyLoading.show(status: 'Please wait...');
                              _services.saveCoupon(
                                document: widget.document,
                                title: title.text.toUpperCase(),
                                discountRate: int.parse(discount.text),
                                details: details.text,
                                expiry: _selectedDate,
                                active: _active
                              ).then((value) {
                                setState(() {
                                  title.clear();
                                  discount.clear();
                                  details.clear();
                                  dateText.clear();
                                  _active = false;
                                });
                                EasyLoading.showSuccess('Coupon Saved Successfully');
                              });
                            }
                          },
                          child: Text('Submit',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),),
                      ),
                    ],
                ),
              ],
            ),
          ),

        ),
      ),
    );
  }
}
