import 'package:flutter/material.dart';
import 'UserRegistration.dart';
import 'HmRegistration.dart';

class chooser extends StatefulWidget {
  const chooser({super.key});
  @override
  State<chooser> createState() => _chooserState();
}

class _chooserState extends State<chooser> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text("Enter House of Food As"),
              centerTitle: true,
              backgroundColor: Color.fromARGB(255, 113, 21, 15),
            ),
            body: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  color: Color.fromARGB(255, 113, 21, 15),
                  elevation: 30,
                  borderRadius: BorderRadius.circular(50),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: InkWell(
                    onTap: () {
                      // Handle the onTap event for the first button
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegistrationPage()),
                    );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Ink.image(
                          image: NetworkImage(
                            'https://i.pinimg.com/564x/a3/da/09/a3da09d7ac9f89a80b8b7418ce7d2f2f.jpg',
                          ),
                          height: 200,
                          width: 300,
                          fit: BoxFit.cover,
                        ),
                        Text(
                          'Home Foodmaker',
                          style: TextStyle(fontSize: 32, color: Colors.white),
                        ),
                        SizedBox(height: 6),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20), // Add spacing between buttons
                Material(
                  color: Color.fromARGB(255, 113, 21, 15),
                  elevation: 30,
                  borderRadius: BorderRadius.circular(50),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: InkWell(
                    onTap: () {
                       Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => userpage()),
                    );
                      // Handle the onTap event for the second button
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Ink.image(
                          image: NetworkImage(
                            'https://img.freepik.com/premium-vector/food-blogger-with-salad-vector-concept_118813-15534.jpg?w=900',
                          ),
                          height: 200,
                          width: 300,
                          fit: BoxFit.cover,
                        ),
                        Text(
                          'A Customer',
                          style: TextStyle(fontSize: 32, color: Colors.white),
                        ),
                        SizedBox(height: 6),
                      ],
                    ),
                  ),
                ),
              ],
            ))));
  }
}