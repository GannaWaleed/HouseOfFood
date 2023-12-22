import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:house_of_food/MyProfilePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class HomePage2 extends StatefulWidget {
  final String userId;

  HomePage2({required this.userId});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage2> {
  List<String> ratedChefs = [];
  Set<String> ratedUsers = Set<String>();
  List<Chef> chefs = [];
  double userRating = 0;
  Future<String> fetchData() async {
    // Replace this with your logic to fetch the latest data
    await Future.delayed(Duration(seconds: 2)); // Simulating a delay
    return 'Latest Data';
  }

  void refreshHomePage() {
    setState(() {
      // You can update any state variables or perform other actions needed for refreshing
    });
  }

  @override
  Widget build(BuildContext context) {
    //  String userId = widget.userId; // Access userId using widget.userId
    return Scaffold(
      backgroundColor: Colors.grey[350],
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 113, 21, 15),
        title: Text('House Of Food'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(),
                ),
              );
              // Navigate to the cart page
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // Open the drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MyProfilePage(userId: widget.userId)),
              );
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          // Text('Welcome', style: TextStyle(
          //                 fontSize: 22.0,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //),
          // GridView of chefs
          Expanded(
            child: FutureBuilder(
              future: getChefs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<Chef> chefs = snapshot.data as List<Chef>;
                  return buildChefsGrid(chefs);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChefsGrid(List<Chef> chefs) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: chefs.length,
      itemBuilder: (context, index) {
        Chef chef = chefs[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodPage(chef: chef),
              ),
            );
            // Navigate to the sections page for the selected chef
          },
          child: Card(
            color: Color.fromARGB(255, 162, 156, 156),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 50,
                  color: Color.fromARGB(255, 113, 21, 15),
                ), // Replace with actual restaurant icon
                SizedBox(height: 10),
                Text(
                  chef.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5),
                SizedBox(width: 5),
                // Display availability indicator
                Icon(
                  chef.isAvailable ? Icons.check_circle : Icons.cancel,
                  color: chef.isAvailable ? Colors.green : Colors.red,
                ),
                GestureDetector(
                  onTap: () {
                    if (ratedUsers.contains(widget.userId)) {
                      // User has already rated a chef
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('You have already rated a chef.'),
                          duration: Duration(seconds: 1),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      // User hasn't rated this chef yet, show the rating dialog
                      showRatingDialog(chef.id);

                      // Mark the chef as rated
                      ratedChefs.add(chef.id);

                      // User has already rated, show the ratings for the chef
                      showChefRatings(chef.id);
                    }
                  },
                  child: Icon(Icons.star),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String getCurrentUserId() {
    // Implement the logic to get the current user ID
    // For example, if you are using Firebase Authentication:
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  Future<List<Chef>> getChefs() async {
    // Fetch chefs from the HmRegistration collection in Firebase
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('isHomeMaker', isEqualTo: true)
        .get();

    List<Chef> chefs = [];
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      // Fetch availability status from the database (assuming a field named 'isAvailable')
      bool isAvailable = false; // Default value

      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('isAvailable')) {
        // Safely retrieve 'isAvailable' field
        dynamic availableData = data['isAvailable'];
        if (availableData is bool) {
          isAvailable = availableData;
        }
      }

      // Safely retrieve 'firstName' and 'lastName' fields
      String name = '';
      if (data != null &&
          data.containsKey('firstName') &&
          data.containsKey('lastName')) {
        name = '${data['firstName']} ${data['lastName']}';
      }

      chefs.add(
        Chef(
          id: doc.id,
          name: name,
          isAvailable: isAvailable,
        ),
      );
    }
    return chefs;
  }

  Future<List<String>> getChefRatings(String chefId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot ratingsQuery = await firestore
        .collection('ratings')
        .where('chefId', isEqualTo: chefId)
        .get();

    List<String> ratingsList = [];
    for (QueryDocumentSnapshot ratingDoc in ratingsQuery.docs) {
      String userId = ratingDoc['userId'];
      double rating = ratingDoc['rating'];

      // Retrieve user's first name
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userId).get();
      String firstName = userDoc['firstName'];

      ratingsList.add('$firstName rated you $rating');
    }

    return ratingsList;
  }

  void showChefRatings(String chefId) async {
    List<String> ratings = await getChefRatings(chefId);

    // Show the ratings using a dialog or any other UI element
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Your Ratings'),
          content: Column(
            children: ratings.map((rating) => Text(rating)).toList(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showRatingDialog(String chefId) async {
    String userId = getCurrentUserId();

    // Check if the current user is the same as the chef
    if (userId == chefId) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Chefs cannot rate themselves.'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.red,
      ));
      return;
    }
    if (ratedUsers.contains(widget.userId)) {
      // You can show a message or handle it as you prefer
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have already rated.'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        backgroundColor:
        Color.fromARGB(255, 113, 21, 15);
        return AlertDialog(
          title: Text(
            'Rate Chef',
            style: TextStyle(
              color: Color.fromARGB(255, 113, 21, 15),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.1,
              ),
              child: Column(
                children: [
                  RatingBar.builder(
                    initialRating: userRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 40.0,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        userRating = rating;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 113, 21, 15), //button's fill color
                onPrimary: Colors.white,
              ),
              onPressed: () {
                saveRating(chefId, userRating);
                setState(() {
                  // Reset userRating to its initial state after submitting the rating
                  userRating = 0;
                  ratedUsers.add(widget.userId);
                });
                Navigator.pop(context);
              },
              child: Text(
                'Submit',
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

  Future<void> saveRating(String chefId, double userRating) async {
    // Get the current user ID (you need to implement this)
    String userId = getCurrentUserId();

    // Create a Rating object
    Rating rating = Rating(userId: userId, chefId: chefId, rating: userRating);

    // Save the rating to Firebase
    await FirebaseFirestore.instance.collection('ratings').add({
      'userId': rating.userId,
      'chefId': rating.chefId,
      'rating': rating.rating.toInt(), // Convert double to int
      // Add other fields if needed
    });

    // Update the local chef object with the new rating
    Chef chef = chefs.firstWhere((c) => c.id == chefId);
    chef.ratings.add(rating);
    for (Chef chef in chefs) {
      if (chef.id == chefId) {
        chef.ratings.add(rating);
        break;
      }
    }
  }
}

class Chef {
  final String id;
  final String name;
  final bool isAvailable;
  List<Rating> ratings = [];

  Chef({required this.id, required this.name, required this.isAvailable});
}

class Rating {
  final String userId;
  final String chefId;
  final double rating;

  Rating({
    required this.userId,
    required this.chefId,
    required this.rating,
  });
}

//////////////////////////////////////////////////////////////////////////////

class FoodPage extends StatelessWidget {
  final Chef chef;

  FoodPage({required this.chef});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 113, 21, 15),
        title: Text('Food - ${chef.name}'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(),
                ),
              );
              // Navigate to the cart page
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: getFoodItems(chef.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<FoodItem> foodItems = snapshot.data as List<FoodItem>;
            return buildFoodItemsList(context, chef.id, foodItems);
          }
        },
      ),
    );
  }

  Widget buildFoodItemsList(
      BuildContext context, String chefId, List<FoodItem> foodItems) {
    return ListView.builder(
      itemCount: foodItems.length,
      itemBuilder: (context, index) {
        FoodItem foodItem = foodItems[index];
        return ListTile(
          /// Display the food item photo using CircleAvatar
          leading: CircleAvatar(
            radius: 35,
            backgroundImage: NetworkImage(foodItem.photo),
          ),
          title: Text(
            foodItem.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Description: ${foodItem.description}, Price: ${foodItem.price}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          trailing: SizedBox(
            width: 100.0,
            height: 40.0,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 113, 21, 15),
              ),
              onPressed: () {
                // Add the selected food item to the cart
                addToCart(context, chef.id, foodItem);
              },
              child: Text('Buy'),
            ),
          ),
        );
      },
    );
  }
}

void addToCart(BuildContext context, String chefId, FoodItem foodItem) {
  // Add the selected food item to the cart
  Cart.addToCart(context, chefId, foodItem);
}

Future<List<FoodItem>> getFoodItems(String userId) async {
  String currentUserChefId = Cart.getCurrentUserChefId();
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('Food')
      .where('chefId', isEqualTo: userId)
      .get();

  List<FoodItem> foodItems = [];
  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    // Check if the 'photo' field is present in the document
    // Cast doc.data() to Map<String, dynamic>?
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    // Check if the 'photo' field is present in the document

    foodItems.add(FoodItem(
      chefId: userId,
      name: doc['name'],
      description: doc['description'],
      price: doc['price'],
      photo: doc['photo'],
    ));
  }
  return foodItems;
}

class FoodItem {
  final String chefId;
  final String name;
  final String description;
  final String price;
  final String photo;

  FoodItem({
    required this.chefId,
    required this.name,
    required this.description,
    required this.price,
    required this.photo,
  });
}

////////////////////////////////////////////////////////////////////////////////
class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        backgroundColor: Color.fromARGB(255, 113, 21, 15),
      ),
      body: Column(
        children: [
          // Display cart items here
          Expanded(
            child: ListView.builder(
              itemCount: Cart.items.length,
              itemBuilder: (context, index) {
                CartItem cartItem = Cart.items[index];
                FoodItem item = cartItem.foodItem;
                return ListTile(
                  title: Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price: ${item.price}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              // Remove the selected item from the cart
                              Cart.removeFromCart(cartItem.chefId, item);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Item removed from cart'),
                                      duration: Duration(seconds: 1)));
                              setState(() {});
                            },
                          ),
                          Text(
                            'Quantity: ${cartItem.quantity}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              // Increase the quantity of the selected item
                              Cart.addToCart(context, cartItem.chefId, item);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Label to display the total price
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Price: ${calculateTotalPrice()}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
          // Button to place the order
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color.fromARGB(255, 113, 21, 15),
            ),
            onPressed: () {
              // Implement logic to place the order
              // This can involve sending an order to the backend, showing a confirmation dialog, etc.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order placed! , The Chef Will Contact You'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(
              'Place Order',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: const Color.fromARGB(255, 249, 249, 249),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double calculateTotalPrice() {
    // Calculate the total price based on the prices of items in the cart
    double totalPrice = 0.0;
    for (CartItem cartItem in Cart.items) {
      totalPrice += double.parse(cartItem.foodItem.price) * cartItem.quantity;
    }
    return totalPrice;
  }
}

class Cart {
  static List<CartItem> items = [];

  static void addToCart(
      BuildContext context, String chefId, FoodItem foodItem) {
    // Get the current user's chefId (you need to obtain this from your authentication or user management system)
    String currentUserChefId =
        getCurrentUserChefId(); // Replace this with your actual logic

    // Check if the cart is empty or if the items in the cart belong to the same chef
    if (items.isEmpty || items.every((item) => item.chefId == chefId)) {
      // Check if the current user is trying to add an item from their own food page
      if (chefId == currentUserChefId) {
        // Show an error SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chefs cannot order from their own food page'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // Check if the item is already in the cart
        CartItem existingItem = items.firstWhere(
          (item) =>
              item.chefId == chefId && item.foodItem.name == foodItem.name,
          orElse: () => CartItem(chefId: chefId, foodItem: foodItem),
        );

        if (items.contains(existingItem)) {
          // If the item is already in the cart, increment the quantity
          existingItem.quantity++;
        } else {
          // If the item is not in the cart, add it
          items.add(existingItem);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item added to cart'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      // Display an error or prevent adding items from different chefs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot add items from different chefs to the cart'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static void removeFromCart(String chefId, FoodItem foodItem) {
    // Check if the item is in the cart
    if (items.any((item) =>
        item.chefId == chefId && item.foodItem.name == foodItem.name)) {
      // If the item is in the cart, decrease the quantity
      CartItem existingItem = items.firstWhere(
        (item) => item.chefId == chefId && item.foodItem.name == foodItem.name,
      );

      if (existingItem.quantity > 1) {
        // Decrease the quantity if it's greater than 1
        existingItem.quantity--;
      } else {
        // Remove the item if the quantity is 1
        items.remove(existingItem);
      }
    }
  }

  static String getCurrentUserChefId() {
    // Assuming you have Firebase Authentication initialized in your app
    FirebaseAuth auth = FirebaseAuth.instance;

    // Get the current user
    User? user = auth.currentUser;

    // Check if the user is signed in
    if (user != null) {
      // Access the user's UID (chefId in this case)
      String chefId = user.uid;
      return chefId;
    } else {
      // Handle the case where the user is not signed in
      // You might want to return a default or handle it according to your app's requirements
      return 'defaultChefId';
    }
  }
}

class CartItem {
  final String chefId;
  final FoodItem foodItem;
  int quantity;

  CartItem({required this.chefId, required this.foodItem, this.quantity = 1});
}

class OrderPage extends StatefulWidget {
  final String chefId;

  OrderPage({required this.chefId});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
        backgroundColor: Color.fromARGB(255, 113, 21, 15),
      ),
      body: FutureBuilder<List<Order>>(
        future: fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Order>? orders = snapshot.data;
            return ListView.builder(
              itemCount: orders?.length ?? 0,
              itemBuilder: (context, index) {
                Order order = orders![index];
                return ListTile(
                  title: Text('User: ${order.userName}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phone: ${order.userPhone}'),
                      Text('Address: ${order.userAddress}'),
                      Text('Food Items:'),
                      for (var item in order.orderItems)
                        Text(
                            '${item.foodItem.name} - Quantity: ${item.quantity}'),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Order>> fetchOrders() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('chefId', isEqualTo: widget.chefId)
        .get();

    print("asldkjsadlmsadlmasdmlamklsdmaa  ${querySnapshot.docs.length}");

    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Order(
        userId: data['userId'],
        chefId: data['chefId'],
        userName: data['userName'],
        userPhone: data['phone'],
        userAddress: data['address'],
        orderItems: (data['orderItems'] as List<dynamic>).map((orderItem) {
          Map<String, dynamic> foodData = orderItem['foodItem'];
          FoodItem foodItem = FoodItem(
            chefId: foodData['chefId'], // Replace 'chefId' with the actual key
            name: foodData['name'],
            description: foodData['description'],
            price: foodData['price'],
            photo: foodData['photo'],
          );
          return OrderItem(foodItem: foodItem, quantity: orderItem['quantity']);
        }).toList(),
        orderTotal: data['orderTotal'],
      );
    }).toList();
  }
}

class Order {
  String userId;
  String userName;
  String userPhone;
  String userAddress;
  String chefId;
  List<OrderItem> orderItems;
  double orderTotal;

  Order({
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.userAddress,
    required this.chefId,
    required this.orderItems,
    required this.orderTotal,
  });
}

class OrderItem {
  FoodItem foodItem;
  int quantity;

  OrderItem({required this.foodItem, required this.quantity});
}
