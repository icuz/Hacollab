
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hacollab1/Hackathons/hackathon_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HackathonDetailScreen extends StatefulWidget {

  final String uploadedBy;
  final String jobId;

  const HackathonDetailScreen({
    required this.uploadedBy,
    required this.jobId,
});

  @override
  State<HackathonDetailScreen> createState() => _HackathonDetailScreenState();
}

class _HackathonDetailScreenState extends State<HackathonDetailScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? authorName;
  String? userImageURL;
  String? projCategory;
  String? projDescription;
  String? projTitle;
  bool? recruitment;
  Timestamp? postedDateTimeStamp;
  Timestamp? deadlineDateTimeStamp;
  String? postedDate;
  String? deadLineDate;
  String? locationEvent = '';
  String? emailEvent = '';
  String? emailUser = '';
  int applicants = 0;
  bool isDeadLineAvailable = true;
  bool showComment =false;
  late Timer _timer;

  void getJobData() async{
    final DocumentSnapshot userDoc = await FirebaseFirestore
        .instance.collection('users')
        .doc(widget.uploadedBy)
        .get();

    if(userDoc == null){
      return;
    }
    else{
      setState(() {
        authorName = userDoc.get('name');
        userImageURL = userDoc.get('userImage');
        emailUser = userDoc.get('email');
      });
    }
    final DocumentSnapshot jobDatabase = await FirebaseFirestore.instance.collection('Projects').doc(widget.jobId).get();

    if(jobDatabase == null){
      return;
    }
    else{
      setState(() {
        projTitle = jobDatabase.get('projTitle');
        projDescription = jobDatabase.get('projDescription');
        recruitment = jobDatabase.get('recruitment');
        emailEvent = jobDatabase.get('email');
        locationEvent = jobDatabase.get('location');
        applicants = jobDatabase.get('applicants');
        postedDateTimeStamp = jobDatabase.get('createdAt');
        deadlineDateTimeStamp = jobDatabase.get('deadlineDateTimeStamp');
        deadLineDate = jobDatabase.get('deadlineDate');
        var postDate = postedDateTimeStamp!.toDate();
        postedDate = '${postDate.year}-${postDate.month}-${postDate.day}';
        var date = deadlineDateTimeStamp!.toDate();
        isDeadLineAvailable = date.isAfter(DateTime.now());
      });

    }
  }

  @override
  void initState() {
    super.initState();
    getJobData();
    _timer = Timer.periodic(const Duration(seconds:1), (_) => _onPressed());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onPressed() {
    getJobData();
  }

  Widget dividerWidget(){
    return Column(
      children: const [
        SizedBox(height: 10,),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        SizedBox(height: 10,),
      ],
    );
  }

  applyForEvent(){
    var Uriparams =Uri(
      scheme: 'https',
      host: 'docs.google.com',
      path: '/forms/d/e/1FAIpQLSfpTZ_jmbfJnq3dENS7oJ1S_Tbzl0z0IJqtOxSf5Ws7KHKrfA/viewform',
      //path: emailUser,
    );
    launchUrl(Uriparams);
    addNewApplicant();
  }

  applicantList(){
    var Uriparams =Uri(
      scheme: 'https',
      host: 'docs.google.com',
      path: '/spreadsheets/d/1ghc39ZReau83rUiNe59Jxn0eOZKLTcxrUOQU8Fk1gV4',
      //path: emailUser,
    );
    launchUrl(Uriparams);
  }

  brouchure(){
    var Uriparams =Uri(
      scheme: 'https',
      host: 'www.flickr.com',
      path: '/photos/197448362@N08/',
      //path: emailUser,
    );
    launchUrl(Uriparams);
  }

  void addNewApplicant() async{
    var docRef  = FirebaseFirestore.instance.collection('Projects').doc(widget.jobId);
    docRef.update({
      'applicants': applicants + 1,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 40,color: Colors.white,),
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => hackathons()));
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            projTitle == null
                                ?
                                'Join us now'
                                :
                                projTitle!,
                            maxLines: 3,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 3,
                                  color: Colors.grey,
                                ),
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                  image: NetworkImage(
                                    userImageURL == null
                                        ?
                                        'https://www.pngall.com/wp-content/uploads/5/User-Profile-PNG-High-Quality-Image.png'
                                        :
                                        userImageURL!,
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authorName == null
                                        ?
                                        ''
                                        :
                                        authorName!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 5,),
                                  Text(
                                    locationEvent!,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        dividerWidget(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              applicants.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight:FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 6,),
                            const Text(
                              'Applicants',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(width: 10,),
                            const Icon(
                              Icons.how_to_reg_sharp,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10,),
                        Center(
                          child: Text(
                              isDeadLineAvailable ?'Actively Recruiting, send your application:' : 'Deadline passed away.',
                            style: TextStyle(
                              color: isDeadLineAvailable
                                  ?
                                  Colors.green
                                  :
                                  Colors.red,
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6,),
                        Center(
                          child: MaterialButton(
                            onPressed: (){
                              applyForEvent();
                            },
                            color: Colors.blueAccent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                'Apply Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6,),
                        Center(
                          child: MaterialButton(
                            onPressed: (){
                              applicantList();
                            },
                            color: Colors.blueAccent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                'See applicants',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6,),
                        Center(
                          child: MaterialButton(
                            onPressed: (){
                              brouchure();
                            },
                            color: Colors.blueAccent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                'check Boucher',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        dividerWidget(),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Text(
                          projDescription == null
                              ?
                              ''
                              :
                              projDescription!,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Center(
                          child: MaterialButton(
                            onPressed:_onPressed,
                            color: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                '',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
