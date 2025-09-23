import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yummygo/const/constants.dart';
import 'package:yummygo/widget/banner.dart';
import 'package:yummygo/widget/food_items_display.dart';
import 'package:yummygo/widget/my_icon_button.dart';

class MyAppHomeScreen extends StatefulWidget {
  const MyAppHomeScreen({super.key});

  @override
  State<MyAppHomeScreen> createState() => _MyAppHomeScreenState();
}

class _MyAppHomeScreenState extends State<MyAppHomeScreen> {
  String category = "All";
  final CollectionReference categoriesItems = FirebaseFirestore.instance
      .collection("Categorias");
  Query get fileteredRecipes => FirebaseFirestore.instance
      .collection("Complete-Flutter-App")
      .where('category', isEqualTo: category);
  Query get allRecipes =>
      FirebaseFirestore.instance.collection("Complete-Flutter-App");
  Query get selectedRecipes =>
      category == "All" ? allRecipes : fileteredRecipes;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerParts(),
                    mySearchBar(),

                    const BannerToExplore(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    selectedCategory(),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "Quick & Easy",
                          style: TextStyle(
                            fontSize: 20,
                            letterSpacing: 0.1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "View all",
                            style: TextStyle(
                              color: kBannerColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              StreamBuilder(
                stream: selectedRecipes.snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasData) {
                    final List<DocumentSnapshot> recipes =
                        snapshot.data?.docs ?? [];

                    if (recipes.isEmpty) {
                      return Center(
                        child: Text('No recipes found for category: $category'),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 5, left: 15),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: recipes
                              .map((e) => FoodItemsDisplay(documentSnapshot: e))
                              .toList(),
                        ),
                      ),
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> selectedCategory() {
    return StreamBuilder(
      stream: categoriesItems.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
        if (streamSnapshot.hasError) {
          return Center(
            child: Text('Error loading categories: ${streamSnapshot.error}'),
          );
        }

        if (streamSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (streamSnapshot.hasData) {
          // Agregar categoría "All" al inicio
          List<Widget> categoryWidgets = [
            GestureDetector(
              onTap: () {
                setState(() {
                  category = "All";
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: category == "All" ? kprimaryColor : Colors.white,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                margin: const EdgeInsets.only(right: 20),
                child: Text(
                  "All",
                  style: TextStyle(
                    color: category == "All"
                        ? Colors.white
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ];

          // Agregar las categorías de Firebase
          categoryWidgets.addAll(
            List.generate(
              streamSnapshot.data!.docs.length,
              (index) => GestureDetector(
                onTap: () {
                  setState(() {
                    category = streamSnapshot.data!.docs[index]["name"];
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: category == streamSnapshot.data!.docs[index]["name"]
                        ? kprimaryColor
                        : Colors.white,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.only(right: 20),
                  child: Text(
                    streamSnapshot.data!.docs[index]["name"],
                    style: TextStyle(
                      color:
                          category == streamSnapshot.data!.docs[index]["name"]
                          ? Colors.white
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: categoryWidgets),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Padding mySearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 22),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Iconsax.search_normal),
          filled: true,
          fillColor: Colors.white,
          border: InputBorder.none,
          hintText: "Search for recipes",
          hintStyle: TextStyle(color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Row headerParts() {
    return Row(
      children: [
        Text(
          "What are you\ncooking today?",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        const Spacer(),
        MyIconButton(icon: Iconsax.notification, onPressed: () {}),
      ],
    );
  }
}
