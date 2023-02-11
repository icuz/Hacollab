
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hacollab1/Services/global_methods.dart';
import 'package:uuid/uuid.dart';
import 'package:hacollab1/Hackathons/hackathon_details.dart';

import '../Persistent/persistant.dart';
import '../Services/global_variables.dart';
import '../widgets/bottom_nav_bar.dart';

class Uploadhackthon extends StatefulWidget {

  @override
  State<Uploadhackthon> createState() => _UploadhackthonState();
}

class _UploadhackthonState extends State<Uploadhackthon> {

  final TextEditingController _jobCategoryController =TextEditingController(text: 'select Project Category');
  final TextEditingController _jobTitleController =TextEditingController();
  final TextEditingController _jobDescriptionController =TextEditingController();
  final TextEditingController _deadlineController =TextEditingController(text: 'Project deadline date');

  final _formkey = GlobalKey<FormState>();
  DateTime? picked;
  Timestamp? deadlineDateTimeStamp;
  bool _isLoading = false;

  @override
  void dispose(){
    super.dispose();
    _jobCategoryController.dispose();
    _jobTitleController.dispose();
    _jobDescriptionController.dispose();
    _deadlineController.dispose();
  }

  Widget _textTitles({required String label}){
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _textFormFileds({
  required String valueKey,
    required TextEditingController controller,
    required bool enabled,
    required Function fct,
    required int maxLength,
}){
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: (){
          fct();
        },
        child:TextFormField(
          validator: (value){
            if(value!.isEmpty){
              return 'Value is missing';
            }
            return null;
          },
          controller: controller,
          enabled: enabled,
          key: ValueKey(valueKey),
          style: const TextStyle(
            color: Colors.white38,
          ),
          maxLines: valueKey == 'ProjectDescription' ? 4 : 1,
          maxLength: maxLength,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.black54,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            )
          ),
        ),
      ),
    );
}

_showTaskCategoriesDialoge({required Size size }){
    showDialog(
        context: context,
        builder: (ctx){
          return AlertDialog(
            backgroundColor: Colors.black54,
            title: const Text(
              'Project Category',
              textAlign: TextAlign.center,
              style:TextStyle(fontSize: 20,color: Colors.white),
            ),
            content: Container(
              width: size.width *0.9,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: Persistant.projectCategoryList.length,
                itemBuilder: (ctx, index){
                  return InkWell(
                    onTap: (){
                      setState(() {
                        _jobCategoryController.text =Persistant.projectCategoryList[index];
                      });
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.arrow_right_alt_outlined,
                          color: Colors.grey,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            Persistant.projectCategoryList[index],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              ),
            ),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: const Text('Cancel',style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),),
              ),
            ],
          );
        }
    );
}

  void _pickDeadDialog() async{
    picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(
            const Duration(days: 0),
        ),
        lastDate: DateTime(2100),
    );
    if(picked != null){
      setState(() {
        _deadlineController.text ='${picked!.year} - ${picked!.month} - ${picked!.day}';
        deadlineDateTimeStamp = Timestamp.fromMicrosecondsSinceEpoch(picked!.microsecondsSinceEpoch);
      });
    }
  }

  void _uploadTask() async {
    final projId = const Uuid().v4();
    User? user = FirebaseAuth.instance.currentUser;
    final _uid = user?.uid;
    final isValid = _formkey.currentState!.validate();

    if (isValid) {
      if (_deadlineController.text == 'Choose job Deadline date' ||
          _jobCategoryController.text == 'Choose job category') {
        GlobalMethods.showErrorDialog(
            error: 'Please pick everything', ctx: context
        );
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseFirestore.instance.collection('Projects').doc(projId).set(
            {
              'projId': projId,
              'uploadedBy': _uid,
              'email': user?.email,
              'projTitle': _jobTitleController.text,
              'projDescription': _jobDescriptionController.text,
              'DeadlineDate': _deadlineController.text,
              'deadlineDateTimeStamp': deadlineDateTimeStamp,
              'projCategory': _jobCategoryController.text,
              'jobComenets': [],
              'recruitment': true,
              'createdAt': Timestamp.now(),
              'name': name,
              'userImage': userImage,
              'location': location,
              'applicants': 0,
            });
        await Fluttertoast.showToast(
          msg: 'The task has been uploaded',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 18.0,
        );
        _jobTitleController.clear();
        _jobDescriptionController.clear();
        setState(() {
          _jobCategoryController.text = 'Choose job category';
          _deadlineController.text = 'Choose job Deadline date';
        });
      }catch(error){
        {
          setState(() {
            _isLoading = false;
          });
          GlobalMethods.showErrorDialog(error: error.toString(), ctx: context);
        }
      }
      finally{
        setState(() {
          _isLoading = false;
        });
      }
    }
    else{
      print('Its not valid');
    }
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromRGBO(235, 89, 82, 100),Color.fromRGBO(27, 68, 143, 100) ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          stops: [0.2,0.9],
        ),
      ),
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBarForApp(indexNum: 2,),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Card(
              color: Colors.white10,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10,),
                    const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Please fill all fields',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 40,
                            fontWeight: FontWeight.w100,
                            fontFamily: 'Signatra'
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    const Divider(
                      thickness: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: _formkey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _textTitles(label: 'Project Category:'),
                            _textFormFileds(
                                valueKey: 'ProjectCategory',
                                controller: _jobCategoryController,
                                enabled: false,
                                fct:(){
                                  _showTaskCategoriesDialoge(size: size);
                                },
                                maxLength: 100,
                            ),
                            _textTitles(label: 'Project Title :'),
                            _textFormFileds(
                                valueKey: 'ProjectTitle',
                                controller: _jobTitleController,
                                enabled: true,
                                fct: (){},
                                maxLength: 100,
                            ),
                            _textTitles(label: 'Project Description'),
                            _textFormFileds(
                              valueKey: 'ProjectDescription',
                              controller: _jobDescriptionController,
                              enabled: true,
                              fct: (){},
                              maxLength: 500,
                            ),
                            _textTitles(label: 'Project Deadline'),
                            _textFormFileds(
                              valueKey: 'ProjectDeadline',
                              controller: _deadlineController,
                              enabled: false,
                              fct: (){
                                _pickDeadDialog();
                              },
                              maxLength: 50,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 30),
                        child: _isLoading
                          ? const CircularProgressIndicator()
                            : MaterialButton(
                          onPressed: (){
                            _uploadTask();
                          },
                          color: Colors.black,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Post Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:FontWeight.normal,
                                    fontSize: 25,
                                    fontFamily: 'Signatra',
                                  ),
                                ),
                                SizedBox(width: 9,),
                                Icon(
                                  Icons.upload,
                                  color: Colors.white54,
                                )
                              ],
                            ),
                          ),
                        )
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
