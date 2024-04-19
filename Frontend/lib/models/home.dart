import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  String userInput = '';
  List<dynamic> recommendedCourses = [];

  Future<void> fetchRecommendedCourses(userInput) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/recommend'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{'input': userInput}),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          recommendedCourses = List.from(data['courses']); // Convert to list
        });
      } else {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching courses: $e');
      // Handle the error here (e.g., show an error message in the UI)
    }
  }

  void showCourseDetails(dynamic course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetails(course: course),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: const Text(
              'Course Recommender',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            )
        ),
        backgroundColor: Color.fromRGBO(71, 70, 67, 0.8),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                onChanged: (value){
                  setState(() {
                    userInput=value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(width: 3,)
                  ),
                  hintText: 'Enter the course name',
                  suffixIcon: IconButton(
                    onPressed: (){
                      fetchRecommendedCourses(userInput);
                    },
                    icon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),
            Text(
              'Recommended Courses:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10,),
            Expanded(
                child:ListView.builder(
                  itemCount: recommendedCourses.length,
                  itemBuilder: (BuildContext context,int index){
                    final course=recommendedCourses[index];
                    return ListTile(
                      title: Text(recommendedCourses[index]['title']),
                      subtitle: Text('Dificulty:'+' '+recommendedCourses[index]['difficulty']),
                      onTap: (){
                        showCourseDetails(course);
                      },
                    );
                  },
                )
            )
          ],
        ),
      ),
    );
  }
}

class CourseDetails extends StatelessWidget {
  final dynamic course;
  const CourseDetails({Key? key, required this.course}):super(key:key);


  _launchURL()async{
    Uri _url= Uri.parse(course['link']);
    if (await launchUrl(_url)){
      await launchUrl(_url);
    }
    else{
      throw 'Could not launch $_url';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8.0,),
            Text(course['description'],
            style: TextStyle(
              fontSize: 15,
            ),),
            SizedBox(height: 8.0,),
            Text(
              'Rating:'+' '+course['rating'],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),),
            SizedBox(height: 8.0,),
            Text(
              'Link to the course',
              style:TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            InkWell(
              onTap: _launchURL,
              child: Text(
                course['link'],
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          ],
        )
      ),
    );
  }
}
