import 'package:devconnect/tabs/screens/postrequestscreen.dart';
import 'package:devconnect/tabs/screens/searchscreen.dart';
import 'package:flutter/material.dart';

class WebSearchHeader extends StatelessWidget {
  const WebSearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          'assets/DevConnect.png',
          height: 70,
          width: 100,
          fit: BoxFit.fill,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    alignment: Alignment.topCenter,
                    constraints: BoxConstraints.loose(Size(600, 450)),
                    child: SearchScreen(),
                  );
                },
              );
            },
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'Search',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      alignment: Alignment.topRight,
                      constraints: BoxConstraints.loose(Size(600, 450)),
                      child: Postrequestscreen(),
                    );
                  },
                );
              },
              icon: Icon(
                Icons.person_add,
                size: 35,
              )),
        )
      ],
    );
  }
}
