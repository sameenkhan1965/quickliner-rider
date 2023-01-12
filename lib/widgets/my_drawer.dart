import 'package:flutter/material.dart';
import 'package:users_app/global/global.dart';
import 'package:users_app/models/user_model.dart';
import 'package:users_app/splashScreen/splash_screen.dart';

import '../about/about_screen.dart';
import '../mainScreens/profile_screen.dart';
import '../mainScreens/trips_history_screen.dart';


class MyDrawer extends StatefulWidget
{
  String? name;
  String? email;

  MyDrawer({this.name, this.email});

  @override
  _MyDrawerState createState() => _MyDrawerState();
}



class _MyDrawerState extends State<MyDrawer>
{
  @override
  Widget build(BuildContext context)
  {
    return Drawer(
      backgroundColor: Colors.teal,
      child: ListView(
        children: [
          //drawer header
          Container(
            height: 165,
            color: Colors.white,
            child: DrawerHeader(
              decoration: const BoxDecoration(color: Colors.teal),
              child: Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white,
                  ),

                  const SizedBox(width: 16,),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.name.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Text(
                        widget.email.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const  SizedBox(height: 12.0,),

          //drawer body
          // GestureDetector(
          //   onTap: ()
          //   {
          //     Navigator.push(context, MaterialPageRoute(builder: (c)=> TripsHistoryScreen()));
          //   },
          //   child: const ListTile(
          //     leading: Icon(Icons.history, color: Colors.white54,),
          //     title: Text(
          //       "History",
          //       style: TextStyle(
          //           color: Colors.white
          //       ),
          //     ),
          //   ),
          // ),

          GestureDetector(
            onTap: ()
            {
              Navigator.push(context, MaterialPageRoute(builder: (c)=> ProfileScreen()));
            },
            child: const ListTile(
              leading: Icon(Icons.person, color: Colors.white,),
              title: Text(
                "Visit Profile",
                style: TextStyle(
                    color: Colors.white
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: ()
            {
              Navigator.push(context, MaterialPageRoute(builder: (c)=> AboutScreen()));
            },
            child: const ListTile(
              leading: Icon(Icons.info, color: Colors.white,),
              title: Text(
                "About",
                style: TextStyle(
                    color: Colors.white
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: ()
            {
              fAuth.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (c)=> MySplashScreen(userType: userModelCurrentInfo!.userType??"",)));
            },
            child: const ListTile(
              leading: Icon(Icons.logout, color: Colors.white,),
              title: Text(
                "Sign Out",
                style: TextStyle(
                    color: Colors.white
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
