import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hacollab1/Hackathons/hackathon_screen.dart';
import 'package:hacollab1/widgets/job_widget.dart';

class SearchScreen extends StatefulWidget {

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  final TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = 'Search query';

  Widget _buildSearchField(){
    return TextField(
      controller: _searchQueryController,
      autocorrect: true,
      decoration: const InputDecoration(
        hintText: 'Search for hackathons',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white54),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions(){
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: (){
          _clearSearchQuery();
        },
      ),
    ];
  }

  void _clearSearchQuery(){
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery('');
    });
  }

  void updateSearchQuery(String newQuery){
    setState(() {
      searchQuery = newQuery;
      print(searchQuery);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(decoration: const BoxDecoration(
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
          onPressed: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => hackathons()));
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: _buildSearchField(),
        actions: _buildActions(),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('Projects').where('projTitle', isGreaterThanOrEqualTo: searchQuery)
            .where('recruitment', isEqualTo: true).snapshots(),
        builder: (context, AsyncSnapshot snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(),);
          }
          else if (snapshot.connectionState == ConnectionState.active){
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
                },
              );
            }
            else{
              return const Center(child: Text('There is no hackathon'),);
            }
          }
          return const Center(
            child: Text(
              'Something went wrong',
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30.0),
            ),
          );
        },
      ),
    ),
    );
  }
}
