import 'package:flutter/material.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
 
class MyApp extends StatelessWidget { 
  @override 
  Widget build(BuildContext context) { 
    return MaterialApp( 
      home: HomePage(), 
    ); 
  } 
} 
 
class HomePage extends StatelessWidget { 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar( 
        title: Row( 
          children: [ 
            Text('House of Food'), 
            SizedBox(width: 16.0), 
            SearchWidget(), 
          ], 
        ), 
      ), 
      body: Center( 
        child: Text('Home Page Content'), 
      ), 
      bottomNavigationBar: BottomNavigationBar( 
        currentIndex: 0, 
        onTap: (index) { 
          // Handle tab switching here 
        }, 
        items: [ 
          BottomNavigationBarItem( 
            icon: Icon(Icons.home), 
            label: 'Home', 
          ), 
          BottomNavigationBarItem( 
            icon: Icon(Icons.shopping_cart), 
            label: 'Cart', 
          ), 
          BottomNavigationBarItem( 
            icon: Icon(Icons.person), 
            label: 'My Profile', 
          ), 
        ], 
      ), 
    ); 
  } 
} 
 
class SearchWidget extends StatelessWidget { 
  @override 
  Widget build(BuildContext context) { 
    return Container( 
      padding: EdgeInsets.symmetric(horizontal: 8.0), 
      decoration: BoxDecoration( 
        borderRadius: BorderRadius.circular(8.0), 
        color: Colors.white, 
      ), 
      child: Row( 
        children: [ 
          Icon(Icons.search), 
          SizedBox(width: 8.0), 
          Text('Search'), 
        ], 
      ), 
    ); 
  } 
} 
 
class ProfilePage extends StatelessWidget { 
  final String userId; // Pass the user ID to retrieve data from Firestore 
  final bool isChef; 
 
  ProfilePage({required this.userId, required this.isChef}); 
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar( 
        title: Text('My Profile'), 
      ), 
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>( 
        future: isChef 
            ? FirebaseFirestore.instance.collection('chefs').doc(userId).get() 
            : FirebaseFirestore.instance.collection('users').doc(userId).get(), 
        builder: (context, snapshot) { 
          if (snapshot.connectionState == ConnectionState.waiting) { 
            return CircularProgressIndicator(); 
          } 
 
          if (!snapshot.hasData) { 
            return Text('No data found.'); 
          } 
 
          Map<String, dynamic> userData = snapshot.data!.data() ?? {}; 
 
          return Column( 
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [ 
              ListTile( 
                title: Text('My Account'), 
                subtitle: Column( 
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [ 
                    Text('Name: ${userData['name']}'), 
                    Text('Address: ${userData['address']}'), 
                    Text('Phone Number: ${userData['phone']}'), 
                  ], 
                ), 
              ), 
              if (isChef) 
                ListTile( 
                  title: Text('Edition'), 
                  // Add functionality for chef's edition here 
                ), 
              ListTile( 
                title: Text('Settings'), 
                subtitle: Column( 
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [ 
                    Text('Language'), 
                    ElevatedButton( 
                      onPressed: () { 
                        // Handle language settings 
                      }, 
                      child: Text('Logout'), 
                    ), 
                  ], 
                ), 
              ), 
            ], 
          ); 
        }, 
      ), 
    ); 
  } 
}