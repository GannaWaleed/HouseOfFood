import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'HomePage2.dart';
import 'dart:convert';
import 'Login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfilePage extends StatefulWidget {
  final String userId;

  MyProfilePage({
    required this.userId,
  });

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  TextEditingController foodNameController = TextEditingController();
  TextEditingController foodDescriptionController = TextEditingController();
  TextEditingController foodPriceController = TextEditingController();
  TextEditingController foodPhotoController = TextEditingController();
  String selectedCategory = 'chicken'; // Default category
  List<String> categories = [
    'chicken',
    'pasta',
    'vegetables',
    'soup',
    'seafood',
    'dessert',
    'salad',
    'other',
  ];
  List<Map<String, dynamic>> foodList = [];
  late bool isAvailable;
  @override
  void initState() {
    super.initState();
    // Load foodList when the widget is initialized
    fetchAvailabilityFromFirestore();
    loadFoodList();
    clearFoodList();
    // Load foodList for the current chef
    fetchFoodFromFirestore();
  }

  @override
  void dispose() {
    // Save or persist the foodList data when the widget is disposed
    saveFoodList();
    super.dispose();
  }

  Future<void> saveFoodList() async {
    // Store foodList in a persistent storage, like SharedPreferences or a database
    // For simplicity, you can use SharedPreferences for this example
    final prefs = await SharedPreferences.getInstance();
    final foodListJson = jsonEncode(foodList);
    prefs.setString('foodList', foodListJson);
  }

  Future<void> loadFoodList() async {
    final prefs = await SharedPreferences.getInstance();
    final foodListJson = prefs.getString('foodList');
    if (foodListJson != null) {
      setState(() {
        foodList = List<Map<String, dynamic>>.from(
          jsonDecode(foodListJson),
        );
      });
    } else {
      // If foodList is not found in SharedPreferences, fetch from Firestore
      fetchFoodFromFirestore();
    }
  }

  Future<void> fetchFoodFromFirestore() async {
    // Fetch only the food items for the current chef (widget.userId)
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Food')
        .where('chefId', isEqualTo: widget.userId)
        .get();

    setState(() {
      foodList = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  void clearFoodList() {
    setState(() {
      foodList.clear();
    });
  }

  // New method to navigate to ChefOrdersPage
  void navigateToChefOrdersPage(String chefName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderPage(chefId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 113, 21, 15),
        title: Text(
          'My Profile',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        actions: [
          // Add a logout button to the app bar
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Navigate to the LoginPage.dart when the logout button is pressed
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
          // Add an icon to express orders when the user is a home maker
          FutureBuilder(
            future: getUserInfo(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              } else if (snapshot.data!['isHomeMaker']) {
                // If the user is a home maker, show an icon to express orders
                return IconButton(
                  icon: Icon(Icons.notifications), // Change the icon as needed
                  onPressed: () {
                    // Get the chef's name from the user data
                    String chefName =
                        '${snapshot.data!['firstName']} ${snapshot.data!['lastName']}';
                    // Navigate to the ChefOrdersPage
                    navigateToChefOrdersPage(chefName);
                  },
                );
              } else {
                return Container(); // Return an empty container if not a home maker
              }
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User Information:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.black,
                ),
              ),
              FutureBuilder(
                future: getUserInfo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.data!['isHomeMaker']) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name: ${snapshot.data!['firstName']} ${snapshot.data!['lastName']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Phone: ${snapshot.data!['phone']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Email: ${snapshot.data!['email']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 20),
                        new Row(children: <Widget>[
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(
                                  255, 113, 21, 15), //button's fill color
                              onPrimary: Colors.white,
                            ),
                            onPressed: () {
                              showFoodInputDialog();
                            },
                            icon: Icon(Icons.add),
                            label: Text(
                              'Add Food',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          SizedBox(height: 20, width: 140),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(
                                  255, 113, 21, 15), //button's fill color
                              onPrimary: Colors.white,
                            ),
                            onPressed: () {
                              // Add any customer-specific functionality here
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        HomePage2(userId: widget.userId)),
                              );
                            },
                            icon: Icon(Icons.home),
                            label: Text(
                              'Home',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                        ]),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(
                                255, 113, 21, 15), //button's fill color
                            onPrimary: Colors.white,
                          ),
                          onPressed: () {
                            // Update availability status locally and in Firestore
                            bool newAvailability =
                                !isAvailable; // Toggle the availability
                            setState(() {
                              isAvailable = newAvailability;
                            });
                            updateAvailability(newAvailability);
                          },
                          child: Text(
                            isAvailable ? 'Available' : 'Unavailable',
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Food Categories:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: Colors.black,
                          ),
                        ),
                        buildFoodList(),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name: ${snapshot.data!['firstName']} ${snapshot.data!['lastName']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Phone: ${snapshot.data!['phone']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Email: ${snapshot.data!['email']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateAvailability(bool availability) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({'isAvailable': availability}).then((value) {
      // Update successful
      print('Availability updated to: $availability');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Availability updated to: $availability'),
          duration: Duration(seconds: 1),
          backgroundColor: Color.fromARGB(255, 149, 194, 207),
        ),
      );
      setState(() {
        isAvailable = availability;
      });
    }).catchError((error) {
      // Update failed
      print('Failed to update availability: $error');
    });
  }

  void refreshProfilePage() {
    // Implement any logic needed to refresh the profile page
    // For example, you can use setState if there's any state to update.
    setState(() {
      // Update any other state variables or perform actions needed for refreshing
    });
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    return userSnapshot.data() as Map<String, dynamic>;
  }

  void showFoodInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add Food',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Radio buttons for food categories
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Category:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    DropdownButton<String>(
                      value: selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Text fields for food name, description, and price
                Text(
                  "Food Name",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
                  child: TextFormField(
                    controller: foodNameController,
                    decoration: InputDecoration(
                        hintText: "Enter the Food Name",
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(
                                color:
                                    const Color.fromARGB(210, 158, 158, 158))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(
                                color:
                                    const Color.fromARGB(202, 158, 158, 158)))),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid food name.';
                      } else if (containsNumbers(value)) {
                        return 'Name Should not contain number';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 9),
                Text(
                  "Food Description",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
                  child: TextFormField(
                    controller: foodDescriptionController,
                    decoration: InputDecoration(
                        hintText: "Enter the Food Description",
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),


                        contentPadding:
                            EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(
                                color:
                                    const Color.fromARGB(210, 158, 158, 158))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(
                                color:
                                    const Color.fromARGB(202, 158, 158, 158)))),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid food description.';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 9),
                Text(
                  "Food Price",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
                  child: TextFormField(
                    controller: foodPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: "Enter the Food Price",
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(
                                color:
                                    const Color.fromARGB(210, 158, 158, 158))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(
                                color:
                                    const Color.fromARGB(202, 158, 158, 158)))),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid food price.';
                      } else if (containsLetters(value)) {
                        return 'Price should not contain letters';
                      }
                      return null;
                    },
                  ),
                ),
                Text(
                  "Food Photo",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
                  child: TextFormField(
                    controller: foodPhotoController,
                    decoration: InputDecoration(
                        hintText: "Add the Food photo",
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(
                                color:
                                    const Color.fromARGB(210, 158, 158, 158))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(
                                color:
                                    const Color.fromARGB(202, 158, 158, 158)))),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid food photo.';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 9),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 113, 21, 15), //button's fill color
                onPrimary: Colors.white,
              ),
              onPressed: () {
                addFood();
                Navigator.pop(context);
              },
              child: Text(
                'Add',
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 113, 21, 15), //button's fill color
                onPrimary: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildRadio(String category) {
    return Row(
      children: [
        Radio(
          value: category,
          groupValue: selectedCategory,
          onChanged: (String? value) {
            setState(() {
              selectedCategory = value!;
            });
          },
        ),
        Text(category),
      ],
    );
  }

  void addFood() async {
    bool isUrl = isImageUrl(foodPhotoController.text);

    if (!isUrl) {
      showSnackbar('Please enter a valid image URL.', Colors.red);
      return;
    }

    if (foodNameController.text.isEmpty) {
      showSnackbar('Please enter a valid food name.', Colors.red);
      return;
    }

    if (foodDescriptionController.text.isEmpty) {
      showSnackbar('Please enter a valid food description.', Colors.red);
      return;
    }

    if (foodPriceController.text.isEmpty ||
        containsLetters(foodPriceController.text)) {
      showSnackbar('Please enter a valid numeric food price.', Colors.red);
      return;
    }

    Map<String, dynamic> foodData = {
      'chefId': widget.userId,
      'category': selectedCategory,
      'name': foodNameController.text,
      'description': foodDescriptionController.text,
      'price': foodPriceController.text,
      'photo': foodPhotoController.text,
    };

    setState(() {
      foodList.add(foodData);
    });

    FirebaseFirestore.instance.collection('Food').add(foodData);

    foodNameController.clear();
    foodDescriptionController.clear();
    foodPriceController.clear();
    foodPhotoController.clear();

    showSnackbar('Food added successfully!', Colors.green);
  }

  void showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        backgroundColor: color,
      ),
    );
  }

  bool isImageUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget buildFoodList() {
    return Column(
      children: [
        for (var food in foodList)
          ListTile(
            title: Text(
              '${food['category']}: ${food['name']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            subtitle: Text(
              'Description: ${food['description']}, Price: ${food['price']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            trailing: IconButton(
              //button's fill color

              icon: Icon(
                Icons.delete,
                color: Color.fromARGB(255, 113, 21, 15),
              ),
              onPressed: () {
                deleteFood(food);
              },
            ),
          ),
      ],
    );
  }

  void deleteFood(Map<String, dynamic> food) {
    setState(() {
      foodList.remove(food);
    });

    // Add code to delete food from Firebase collection 'Food'
    FirebaseFirestore.instance
        .collection('Food')
        .where('name', isEqualTo: food['name'])
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });
  }

  Future<void> fetchAvailabilityFromFirestore() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      // Set the initial availability status
      setState(() {
        isAvailable =
            (userSnapshot.data() as Map<String, dynamic>)['isAvailable'] ??
                false;
      });
    } catch (error) {
      // Handle the error, e.g., log it or show a default value
      print('Error fetching availability: $error');
      setState(() {
        isAvailable = false; // Set a default value in case of an error
      });
    }
  }

  bool containsLetters(String value) {
    // Check if the string contains any letters
    return RegExp(r'[a-zA-Z]').hasMatch(value);
  }

  bool containsNumbers(String value) {
// Check if the string containsany numeric digits
    return RegExp(r'\d').hasMatch(value);
  }
  }
  