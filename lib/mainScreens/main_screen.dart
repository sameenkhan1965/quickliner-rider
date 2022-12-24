import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:users_app/assistants/assistant_methods.dart';
import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/global/global.dart';
import 'package:users_app/mainScreens/request_screen.dart';
import 'package:users_app/widgets/my_drawer.dart';
import 'package:users_app/configuraton/configuration.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:users_app/widgets/providers/category_transport_provider.dart';
import 'package:users_app/widgets/ui/customer/car_pool/car_pool_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    Provider.of<TransportCategoryProvider>(context,listen:false).getAllTransport();
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
            name: userModelCurrentInfo!.name,
            email: userModelCurrentInfo!.email,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    builder: (context,value,child)=>ListView.builder(
                        shrinkWrap: true,
                        itemCount: categories.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return getCategoriesContainer(value.allCategories[index].transportName,MaterialPageRoute(
                              builder: (context) => CarPoolWidget()));
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

                //***************** Braodcasts *********************************
                GestureDetector(
                  onTap: () {
                    //Navigator.push(context, MaterialPageRoute(builder: (context)=>Screen2()));
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: primaryGreen,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: shadowList,
                          ),
                          child: Align(
                            child: Hero(
                                tag: 1,
                                child: Image.asset(
                                  'images/quick-bolan.png',
                                  fit: BoxFit.contain,
                                  height: 50,
                                )),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: shadowList,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Abdur Rehman\n"
                            "Carry Dabba"
                            "\n(RLA-395)",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    //Navigator.push(context, MaterialPageRoute(builder: (context)=>Screen2()));
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: primaryGreen,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: shadowList,
                          ),
                          child: Align(
                            child: Hero(
                                tag:2,
                                child: Image.asset(
                                  'images/quick-bolan.png',
                                  fit: BoxFit.contain,
                                  height: 50,
                                )),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: shadowList,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Abdur Rehman\n"
                            "Carry Dabba"
                            "\n(RLA-395)",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    //Navigator.push(context, MaterialPageRoute(builder: (context)=>Screen2()));
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: primaryGreen,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: shadowList,
                          ),
                          child: Align(
                            child: Hero(
                                tag: 3,
                                child: Image.asset(
                                  'images/quick-bolan.png',
                                  fit: BoxFit.contain,
                                  height: 50,
                                )),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: shadowList,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Abdur Rehman\n"
                                "Carry Dabba"
                                "\n(RLA-395)",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                // Container(
                //   height: 220,
                //   margin: const EdgeInsets.only(left: 20, right: 20, top: 570),
                //   child: Row(
                //     children: [
                //       Expanded(
                //         child: Stack(
                //           children: [
                //             Container(
                //               height: 170,
                //               decoration: BoxDecoration(
                //                 color: primaryGreen,
                //                 borderRadius: BorderRadius.circular(20),
                //                 boxShadow: shadowList,
                //               ),
                //               margin: const EdgeInsets.only(top: 5),
                //             ),
                //             Align(
                //               child: Image.asset('images/mehranimg.png'),
                //             )
                //           ],
                //         ),
                //       ),
                //       Expanded(
                //           child: Container(
                //         padding: const EdgeInsets.only(
                //             right: 30, left: 20, top: 30, bottom: 40),
                //         margin: const EdgeInsets.only(top: 0, bottom: 20),
                //         decoration: BoxDecoration(
                //             color: Colors.white,
                //             boxShadow: shadowList,
                //             borderRadius: const BorderRadius.only(
                //                 topRight: Radius.circular(20),
                //                 bottomRight: Radius.circular(20))),
                //         child: const Text(
                //           "Sameen Khan\n"
                //           "Suzuki Mehran"
                //           "\n(RUA-115)",
                //           style: TextStyle(fontSize: 15),
                //         ),
                //       ))
                //     ],
                //   ),
                // ),
                // SizedBox(
                //   height: 220,
                //   child: Row(
                //     children: [
                //       Expanded(
                //         child: Stack(
                //           children: [
                //             Container(
                //               height: 170,
                //               decoration: BoxDecoration(
                //                 color: primaryGreen,
                //                 borderRadius: BorderRadius.circular(20),
                //                 boxShadow: shadowList,
                //               ),
                //               margin: const EdgeInsets.only(top: 5),
                //             ),
                //             Align(
                //               child: Image.asset('images/carry-dabba.png'),
                //             )
                //           ],
                //         ),
                //       ),
                //       Expanded(
                //           child: Container(
                //         margin: const EdgeInsets.only(top: 0, bottom: 20),
                //         decoration: BoxDecoration(
                //             color: Colors.white,
                //             boxShadow: shadowList,
                //             borderRadius: const BorderRadius.only(
                //                 topRight: Radius.circular(20),
                //                 bottomRight: Radius.circular(20))),
                //         child: Text(
                //           "Ali Raza\n"
                //           "Carry Dabba"
                //           "\n(LIA-335)",
                //           textAlign: TextAlign.center,
                //           style: TextStyle(fontSize: 15),
                //         ),
                //       ))
                //     ],
                //   ),
                // ),
                //
                // const SizedBox(
                //   height: 50,
                // ),
                //
                // Container(
                //   margin: const EdgeInsets.only(top: 100, left: 130),
                //   height: 40,
                //   child: const Text(
                //     'Start Your Journey',
                //     style: TextStyle(
                //       fontWeight: FontWeight.bold,
                //       fontSize: 18,
                //       color: Colors.black,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getCategoriesContainer(String categoryName,Route route) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: (){
            Navigator.push(
                context,
                route);
          },
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: shadowList,
                borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Align(
                child: Image.asset(
                  'images/logo.png',
                  height: 40,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(child: Text(categoryName)),
      ],
    );
  }
}