import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:yummygo/const/constants.dart';

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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: StreamBuilder(
          stream: completeApp.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${streamSnapshot.error}',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            if (streamSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!streamSnapshot.hasData || streamSnapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No items found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return GridView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 10,
                mainAxisSpacing: 15,
              ),
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 120,
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                color: Colors.grey[200],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                child: Image.network(
                                  documentSnapshot["image"] ?? '',
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.error,
                                        color: Colors.red,
                                        size: 30,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.white,
                                child: InkWell(
                                  onTap: () {},
                                  child: Icon(
                                    Iconsax.heart,
                                    color: Colors.black,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              documentSnapshot["name"] ?? 'No name',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Iconsax.flash_1,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  "${documentSnapshot['cal'] ?? '0'} Cal",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  " • ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.grey,
                                    fontSize: 9,
                                  ),
                                ),
                                Icon(
                                  Iconsax.clock,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  "${documentSnapshot['time'] ?? '0'} Min",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Iconsax.star1,
                                  color: Colors.amberAccent,
                                  size: 12,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  documentSnapshot['rate'] ?? '0',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                                Text("/5", style: TextStyle(fontSize: 10)),
                                SizedBox(width: 4),
                                Text(
                                  "(${documentSnapshot['reviews']?.toString() ?? '0'})",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
