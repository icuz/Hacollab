import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Services/global_variables.dart';

class Persistant{
  static List<String> projectCategoryList = [
    'Software',
    'Hardware',
    'Business',
    'Architecture & Design',
    'Web based',
    'Android based',
    'Internet of things (IoT)',
    'Artificial intelligence',
    'Data Science',
    'Machine Learning',
  ];


  void getMyData() async{
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    name = userDoc.get('name');
    userImage = userDoc.get('userImage');
    location = userDoc.get('location');
  }
}