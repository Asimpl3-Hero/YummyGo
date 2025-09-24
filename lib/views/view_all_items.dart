import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:yummygo/const/constants.dart';
import 'package:yummygo/widget/food_items_display.dart';
import 'package:yummygo/widget/my_icon_button.dart';

class ViewAllItems extends StatefulWidget {
  const ViewAllItems({super.key});

  @override
  State<ViewAllItems> createState() => _ViewAllItemsState();
}

class _ViewAllItemsState extends State<ViewAllItems> {
  final CollectionReference completeApp = FirebaseFirestore.instance.collection(
    "Complete-Flutter-App",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          SizedBox(width: 15),
          MyIconButton(
            icon: Icons.arrow_back_ios,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Spacer(),
          Text(
            "Quick & Easy",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          MyIconButton(icon: Iconsax.notification, onPressed: () {}),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 15, right: 5),
        child: Column(
          children: [
            StreamBuilder(
              stream: completeApp.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.hasError) {
                  return GridView.builder(
                    itemCount: streamSnapshot.data!.docs.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.78,
                    ),
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot =
                          streamSnapshot.data!.docs[index];

                      return Column(
                        children: [
                          FoodItemsDisplay(documentSnapshot: documentSnapshot),
                          Row(
                            children: [
                              Icon(Iconsax.star1, color: Colors.amberAccent),
                              SizedBox(width: 5),
                              Text(
                                documentSnapshot['rate'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text("/5"),
                              SizedBox(width: 5),
                              Text(
                                "(${documentSnapshot['reviews'.toString()]} Reviews",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }
}
