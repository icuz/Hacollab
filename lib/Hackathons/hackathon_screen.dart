
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hacollab1/Search/search_project.dart';
import 'package:hacollab1/widgets/bottom_nav_bar.dart';
import 'package:hacollab1/widgets/job_widget.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../Persistent/persistant.dart';
class hackathons extends StatefulWidget {
  const hackathons({Key? key}) : super(key: key);

  @override
  State<hackathons> createState() => _hackathonsState();
}

class _hackathonsState extends State<hackathons> {

  String? jobCategoryFilter;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String oneSignalAppId = "54169325-c724-47cf-b66e-d6ac10a32cd9";

  Future<void> initPlatformState() async {
    OneSignal.shared.setAppId(oneSignalAppId);
    OneSignal.shared
        .promptUserForPushNotificationPermission()
        .then((accepted) {});
  }

  void initState() {
    super.initState();
    initPlatformState();
    Persistant persistentObject = Persistant();
    persistentObject.getMyData();
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
                           jobCategoryFilter = Persistant.projectCategoryList[index];
                        });
                        Navigator.canPop(context) ? Navigator.pop(context) : null;
                        print(
                          'projectCategoryList[index], ${Persistant.projectCategoryList[index]}'
                        );
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
                child: const Text('Close',style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                ),
              ),
              TextButton(
                  onPressed: (){
                    setState(() {
                      jobCategoryFilter = null;
                    });
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                  },
                child: const Text('Cancel Filter', style: TextStyle(color: Colors.white),),
              ),
            ],
          );
        }
    );
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
        bottomNavigationBar: BottomNavigationBarForApp(indexNum: 0),
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromRGBO(235, 89, 82, 100),Color.fromRGBO(27, 68, 143, 100) ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: [0.2,0.9],
              ),
            ),
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
              icon: const Icon(Icons.filter_list_rounded, color: Colors.white,),
            onPressed: (){
              _showTaskCategoriesDialoge(size: size);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded,color: Colors.white,),
              onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => SearchScreen()));
              },
            )
          ],
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('Projects')
              .where('projCategory', isEqualTo: jobCategoryFilter)
              .where('recruitment', isEqualTo: true)
              .orderBy('createdAt', descending: false)
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator(),);
            }
            else if(snapshot.connectionState == ConnectionState.active){
              if(snapshot.data?.docs.isNotEmpty == true){
                return ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (BuildContext context, int index){
                    return JobWidget(
                        jobTitle: snapshot.data?.docs[index]['projTitle'],
                        jobDescription: snapshot.data?.docs[index]['projDescription'],
                        jobId: snapshot.data?.docs[index]['projId'],
                        uploadedBy: snapshot.data?.docs[index]['uploadedBy'],
                        userImage: snapshot.data?.docs[index]['userImage'],
                        name: snapshot.data?.docs[index]['name'],
                        recruitment: snapshot.data?.docs[index]['recruitment'],
                        email: snapshot.data?.docs[index]['email'],
                        location: snapshot.data?.docs[index]['location'],
                    );
                  }
                );
              }
              else{
                return const Center(
                  child: Text('There are no current events/hackathons/projects.please login'),
                );
              }
            }
            return const Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
        )
      ),
    );
  }
}
