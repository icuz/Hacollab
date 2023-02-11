import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hacollab1/Hackathons/hackathon_screen.dart';
import 'package:hacollab1/LoginPage/login_page.dart';

class userState extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnaphot) {
          if (userSnaphot.data == null) {
            print('user is not logged in yet');
            return login();
          }
          else if (userSnaphot.hasData) {
            print('user is already logged in.');
            return hackathons();
          }

          else if (userSnaphot.hasError) {
            return const Scaffold(
              body: Center(
                child: Text('An err has occured. try again later'),
              ),
            );
          }

          else if (userSnaphot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return const Scaffold(
            body: Center(
              child: Text('something went wrong'),
            ),
          );
        }
    );
  }
}
