import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hacollab1/Hackathons/hackathon_screen.dart';
import 'package:hacollab1/LoginPage/login_page.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const MaterialApp(
              home: Scaffold(
                  body: Center(
                      child: Text('buckle up..!,App is initializing',
                        style: TextStyle(
                            color: Colors.cyan,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            fontFamily:'Signatra'
                        ),
                      )
                  )
              ),
            );
          }
          else if(snapshot.hasError){
            return const MaterialApp(
              home: Scaffold(
                  body: Center(
                      child: Text('Oops..! something went wrong :(',
                        style: TextStyle(
                            color: Colors.cyan,
                            fontSize: 40,
                            fontWeight: FontWeight.bold
                        ),
                      )
                  )
              ),
            );
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Hacollab',
            theme: ThemeData(
              scaffoldBackgroundColor: Colors.black45,
              primarySwatch: Colors.blue,
            ),
            home: const hackathons(),
          );
        }
    );
  }
}

