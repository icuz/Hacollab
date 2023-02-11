import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hacollab1/Hackathons/hackathon_screen.dart';
import 'package:hacollab1/Hackathons/upload_hackathon.dart';
import 'package:hacollab1/Search/profile_company.dart';
import 'package:hacollab1/Search/search_companies.dart';
import 'package:hacollab1/user_state.dart';

class BottomNavigationBarForApp extends StatelessWidget {

  int indexNum = 0;

  BottomNavigationBarForApp({required this.indexNum});

  void _logout(context){
    final FirebaseAuth _auth = FirebaseAuth.instance;

    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          backgroundColor: Colors.black54,
          title: Row(
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'sign out',
                  style: TextStyle(color: Colors.white, fontSize: 28),
                ),
              ),
            ],
          ),
          content: const Text(
            'Do you want to logout ?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          actions: [

            TextButton(
              onPressed: (){
                Navigator.canPop(context) ? Navigator.pop(context) : null;
              },
              child: const Text('No', style: TextStyle(color: Colors.green, fontSize: 18),),
            ),
            TextButton(
              onPressed: (){
                _auth.signOut();
                Navigator.canPop(context) ? Navigator.pop(context) : null;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> userState()));
              },
              child: const Text('Yes', style: TextStyle(color: Colors.green, fontSize: 18),),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      color: Colors.black26,
      backgroundColor: const Color.fromRGBO(27, 68, 143, 100),
      buttonBackgroundColor: Colors.black26,
      height: 50,
      index: indexNum,
      items: const [
        Icon(Icons.integration_instructions_outlined, size:19,color: Colors.white,),
        Icon(Icons.people_alt_outlined, size: 19,color:Colors.white,),
        Icon(Icons.add_circle_outline_outlined, size: 19,color:Colors.white,),
        Icon(Icons.account_circle_outlined, size: 19,color:Colors.white,),
        Icon(Icons.exit_to_app, size: 19,color:Colors.white,),

      ],
      animationDuration: const Duration(
        milliseconds: 300,
      ),
      animationCurve: Curves.bounceInOut,
      onTap: (index){
        if(index==0){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>hackathons()));
        }
        else if(index == 1){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>AllParticipantScreen()));
        }
        else if(index == 2){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>Uploadhackthon()));
        }
        else if(index == 3){
          final FirebaseAuth _auth = FirebaseAuth.instance;
          final User? user = _auth.currentUser;
          final String uid = user!.uid;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>ProfileScreen(
            userID: uid,
          )));
        }
        else if(index == 4){
          _logout(context);
        }
      },
    );
  }
}
