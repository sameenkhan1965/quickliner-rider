import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:users_app/assistants/assistant_methods.dart';
import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/global/colors.dart';
import 'package:users_app/global/global.dart';
import 'package:users_app/mainScreens/request_screen.dart';
import 'package:users_app/widgets/my_drawer.dart';
import 'package:users_app/configuraton/configuration.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:users_app/widgets/providers/all_drivers_provider.dart';
import 'package:users_app/widgets/providers/broadcast_requests_provider.dart';
import 'package:users_app/widgets/providers/category_transport_provider.dart';
import 'package:users_app/widgets/ui/customer/car_pool/car_pool_widget.dart';

import '../assistants/geofire_assistant.dart';
import '../models/broadcast_model.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  List<BroadcastData> NearbyBroadcastDataList = [];
  Position? userCurrentPosition;


  @override
  void initState() {
    Provider.of<TransportCategoryProvider>(context, listen: false)
        .getAllTransport();
    //Provider.of<AllDriversProvider>(context, listen: false)
      //  .getAllDrivers(context);
    Provider.of<BroadcastRequestProvider>(context, listen: false)
     .getAllBroadcastRequests(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,
      drawer: SizedBox(
        width: 265,
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.black,
          ),
          child: MyDrawer(
            name: userModelCurrentInfo?.name,
            email: userModelCurrentInfo?.email,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //custom hamburger button for drawer
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        sKey.currentState!.openDrawer();
                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.menu,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        const Text('Location'),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: primaryGreen,
                            ),
                            const Text('Islamabad, Pakistan'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 100,
                  child: Consumer<TransportCategoryProvider>(
                    builder: (context, value, child) => ListView.builder(
                        shrinkWrap: true,
                        itemCount: categories.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return getCategoriesContainer(
                              value.allCategories[index].transportName,
                              value.allCategories[index].route);
                        }),
                  ),
                ),

                // Container(
                //     height: 100,
                //     margin: const EdgeInsets.only(left: 29, right: 20, top: 150),
                //     child: Row(children: [
                //       GestureDetector(
                //         onTap: () {
                //           // Navigator.push(context, MaterialPageRoute(builder: (context)=>SoloRide()));
                //         },
                //         child: Container(
                //           height: 65,
                //           decoration: BoxDecoration(
                //               color: Colors.white,
                //               boxShadow: shadowList,
                //               borderRadius: BorderRadius.circular(10)),
                //           child: Align(
                //             child: Image.asset(
                //               'images/logo.png',
                //               height: 50,
                //             ),
                //           ),
                //         ),
                //       ),
                //       GestureDetector(
                //         onTap: () {
                //           Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                   builder: (context) => RequestScreen()));
                //         },
                //         child: Container(
                //           height: 65,
                //
                //           decoration: BoxDecoration(
                //               color: Colors.white,
                //               boxShadow: shadowList,
                //               borderRadius: BorderRadius.circular(10)),
                //           child: Align(
                //             child: Image.asset(
                //               'images/logo.png',
                //               height: 40,
                //             ),
                //           ),
                //         ),
                //       ),
                //       GestureDetector(
                //         onTap: () {
                //           // Navigator.push(context, MaterialPageRoute(builder: (context)=>PermanentRequest()));
                //         },
                //         child: Container(
                //           height: 65,
                //
                //           decoration: BoxDecoration(
                //               color: Colors.white,
                //               boxShadow: shadowList,
                //               borderRadius: BorderRadius.circular(10)),
                //           child: Padding(
                //             padding: const EdgeInsets.only(top: 8.0),
                //             child: Align(
                //               child: Image.asset(
                //                 'images/logo.png',
                //                 height: 40,
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                //       GestureDetector(
                //         onTap: () {
                //           //  Navigator.push(context, MaterialPageRoute(builder: (context)=>ScheduleRequest()));
                //         },
                //         child: Container(
                //           height: 65,
                //           margin: const EdgeInsets.only(left: 20),
                //           decoration: BoxDecoration(
                //               color: Colors.white,
                //               boxShadow: shadowList,
                //               borderRadius: BorderRadius.circular(10)),
                //           child: Expanded(
                //             child: Column(
                //               children: [
                //                 Padding(
                //                   padding: const EdgeInsets.only(top: 8.0),
                //                   child: Align(
                //                     child: Image.asset(
                //                       'images/logo.png',
                //                       height: 40,
                //                     ),
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       ),
                //     ])),
                //
                // Container(
                //     height: 40,
                //     margin: const EdgeInsets.only(left: 29, right: 20, top: 260),
                //     child: Expanded(
                //       child: Row(children: [
                //         GestureDetector(
                //           onTap: () {
                //             // Navigator.push(context, MaterialPageRoute(builder: (context)=>SoloRide()));
                //           },
                //           child: Padding(
                //             padding: const EdgeInsets.only(top: 0),
                //             child: Container(
                //               height: 65,
                //               decoration: BoxDecoration(
                //                   color: Colors.transparent,
                //                   //  boxShadow: shadowList,
                //                   borderRadius: BorderRadius.circular(10)),
                //               child: Expanded(
                //                 child: Column(
                //                   children: const [Text("Solo Ride")],
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ),
                //         GestureDetector(
                //           onTap: () {
                //  Navigator.push(context, MaterialPageRoute(builder: (context)=>GenerateRequest()));
                //           },
                //           child: Padding(
                //             padding: const EdgeInsets.only(top: 0, left: 24),
                //             child: Container(
                //               height: 65,
                //               decoration: BoxDecoration(
                //                   color: Colors.transparent,
                //                   //  boxShadow: shadowList,
                //                   borderRadius: BorderRadius.circular(10)),
                //               child: Expanded(
                //                 child: Column(
                //                   children: const [
                //                     Text("Generate"
                //                         "\n  Request")
                //                   ],
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(top: 0, left: 24),
                //           child: Container(
                //             height: 65,
                //             decoration: BoxDecoration(
                //                 color: Colors.transparent,
                //                 //  boxShadow: shadowList,
                //                 borderRadius: BorderRadius.circular(10)),
                //             child: Expanded(
                //               child: Column(
                //                 children: const [
                //                   Text("Permanent"
                //                       "\n  Request")
                //                 ],
                //               ),
                //             ),
                //           ),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(top: 0, left: 24),
                //           child: Container(
                //             height: 65,
                //             decoration: BoxDecoration(
                //                 color: Colors.transparent,
                //                 //  boxShadow: shadowList,
                //                 borderRadius: BorderRadius.circular(10)),
                //             child: Expanded(
                //               child: Column(
                //                 children: const [
                //                   Text("Schedule"
                //                       "\n  Request")
                //                 ],
                //               ),
                //             ),
                //           ),
                //         ),
                //       ]),
                //     )),

                //***************** Start your journey *********************************
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.greenAccent[30],
                          borderRadius: BorderRadius.circular(10)),
                      child: const Text(
                        'Available Drivers',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          //boxShadow: shadowList,
                          borderRadius: BorderRadius.circular(10)),
                      child: GestureDetector(
                        onTap: () {
                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>AvailableDrivers()));
                        },
                        child: Text(
                          "View all Broadcasts",
                          style: TextStyle(
                              color: primaryGreen, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
                Consumer<BroadcastRequestProvider>(
                  builder: (context, value, child) => ListView.builder(
                      shrinkWrap: true,
                      itemCount: value.allBroadcasts.length,
                      itemBuilder: (context, index) {
                        return getBroadcastRow(
                            origin: value.allBroadcasts[index].originAddress ?? "",
                            destination: value.allBroadcasts[index].destinationAddress1?? "",
                            destination2: value.allBroadcasts[index].destinationAddress2 ?? "",
                            seatNo: value.allBroadcasts[index].noOfSeats ?? "");

                      }),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getCategoriesContainer(String categoryName, Route route) {
    return Container(
      padding: EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, route);
            },
            child: Container(
                padding: const EdgeInsets.only(top: 8.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: shadowList,
                  borderRadius: BorderRadius.circular(10)),
              child: Align(
                child: Image.asset(
                  'images/logo.png',
                  height: 40,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
              child: Text(
            categoryName ?? "",
            textAlign: TextAlign.center,
          )),
        ],
      ),
    );
  }

  Widget getBroadcastRow(
      {required String origin,
      required String destination,
      required String destination2,
      required String seatNo,
      }) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
           // flex: 1,
            child: Container(
              padding: EdgeInsets.only(left: 22, right: 20, top: 15, bottom: 15),
             /* decoration: BoxDecoration(
                color: carType == "quick-go"
                    ? AppColors().greenAccentColor
                    : primaryGreen,
                borderRadius: BorderRadius.circular(20),
                boxShadow: shadowList,
              ),*/
              child: Align(
               child: Image.asset(
               //   'images/${carType}.png',
                 'images/logo.png',
                  fit: BoxFit.contain,
                  height:70,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(left: 2, right: 2, top: 15, bottom: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: shadowList,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Pickup",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(origin.substring(0, 14) + "..."),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "1st Drop off",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(destination.substring(0, 4) + "..."),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "2nd Drop Off",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(destination2.substring(0, 14) + "..."),
                    ],
                  ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "No Of Seats",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(seatNo),
                ],
              ),
              ],
            ),
          ),
          )
        ],
      ),
    );
  }


}
