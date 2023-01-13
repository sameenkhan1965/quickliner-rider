import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:users_app/assistants/assistant_methods.dart';
import 'package:users_app/assistants/geofire_assistant.dart';
import 'package:users_app/global/colors.dart';
import 'package:users_app/global/global.dart';
import 'package:users_app/infoHandler/app_info.dart';
import 'package:users_app/mainScreens/rate_driver_screen.dart';
import 'package:users_app/mainScreens/search_places_screen.dart';
import 'package:users_app/mainScreens/select_nearest_active_driver_screen.dart';
import 'package:users_app/models/active_nearby_available_drivers.dart';
import 'package:users_app/widgets/pay_fare_amount_dialog.dart';
import 'package:users_app/widgets/progress_dialog.dart';
import 'package:users_app/configuraton/configuration.dart';
import 'package:users_app/widgets/ui/customer/car_pool/car_pool_already_rides.dart';

import '../../../providers/permanentProvider.dart';

class PermanentWidget extends StatefulWidget {
  const PermanentWidget({super.key});

  @override
  _PermanentWidgetState createState() => _PermanentWidgetState();
}

class _PermanentWidgetState extends State<PermanentWidget> {


  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  double searchLocationContainerHeight = 360;
  double waitingResponseFromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;

  Position? userCurrentPosition;
  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;
  int noOfSeat = 1;

  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  String userName = "your Name";
  String userEmail = "your Email";

  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;

  List<ActiveNearbyAvailableDrivers> onlineNearByAvailableDriversList = [];

  DatabaseReference? referenceRideRequest;
  String driverRideStatus = "Driver is Coming";
  StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription;

  String userRideRequestStatus = "";
  bool requestPositionInfo = true;
  DateTime? startdate;
  DateTime? enddate;
  TimeOfDay? pickup_orgin_time;
  TimeOfDay? pickup_destination_time;
  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition =
    LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition =
    CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
    await AssistantMethods.searchAddressForGeographicCoOrdinates(
        userCurrentPosition!, context);
    // print("this is your address"+humanReadableAddress);
    //   userName = userModelCurrentInfo!.name!;
    // userEmail = userModelCurrentInfo!.email!;

    initializeGeoFireListener();
    AssistantMethods.readTripsKeysForOnlineUser(context);
  }

  @override
  void initState() {
    super.initState();

    checkIfLocationPermissionAllowed();

  }

  saveRideRequestInformation() {
    //1. save the RideRequest Information
    referenceRideRequest = FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .push(); //push is for generating a random unique id

    var originLocation =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationLocation =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    //for lat and lang
    Map originLocationMap = {
      //yh ggogle map ni hai yh bs aik obj type hai jo key ki basis py work krta hai or save krta
      //"key" : value
      "latitude": originLocation!.locationLatitude.toString(),
      "longitude": originLocation.locationLongitude.toString(),
    };

    Map destinationLocationMap = {
      //yh ggogle map ni hai yh bs aik obj type hai jo key ki basis py work krta hai or save krta
      //"key" : value
      "latitude": destinationLocation!.locationLatitude.toString(),
      "longitude": destinationLocation.locationLongitude.toString(),
    };

    //saving in databse the complete information of user
    Map userInformationMap = {
      "origin": originLocationMap,
      "destination": destinationLocationMap,
      "time": DateTime.now().toString(),
      "userName": userModelCurrentInfo!.name,
      "userPhone": userModelCurrentInfo!.phone,
      "originAddress": originLocation.locationName,
      "destinationAddress": destinationLocation.locationName,
      "driverId": "waiting",
      "rideType":"permanentRide",
      "noOfSeats":'$noOfSeat',
      "startDate":DateFormat('yyyy-MM-dd').format(startdate!),
      "endDate":DateFormat('yyyy-MM-dd').format(enddate!),
      "pickupOriginTime":"${DateFormat('hh:mm a').format(DateFormat("h:m").parse("${pickup_orgin_time?.hour}:${pickup_orgin_time?.minute}"))}",
      "pickupDestinationTime":"${DateFormat('hh:mm a').format(DateFormat("h:m").parse("${pickup_destination_time?.hour}:${pickup_destination_time?.minute}"))}",
      "fareAmount":"0",
      "distance":tripDirectionDetailsInfo != null ? tripDirectionDetailsInfo!.distance_text! : "",
      "duration": tripDirectionDetailsInfo != null ? tripDirectionDetailsInfo!.duration_text!:""
    };

    referenceRideRequest!.set(userInformationMap);
    // Provider.of<PermanentRideProvider>(context, listen: false)
    //     .getScheduleRide(context);
    tripRideRequestInfoStreamSubscription =
        referenceRideRequest!.onValue.listen((eventSnap) async {
          if (eventSnap.snapshot.value == null) {
            return;
          }

          if ((eventSnap.snapshot.value as Map)["car_details"] != null) {
            setState(() {
              driverCarDetails =
                  (eventSnap.snapshot.value as Map)["car_details"].toString();
            });
          }

          if ((eventSnap.snapshot.value as Map)["driverPhone"] != null) {
            setState(() {
              driverPhone =
                  (eventSnap.snapshot.value as Map)["driverPhone"].toString();
            });
          }

          if ((eventSnap.snapshot.value as Map)["driverName"] != null) {
            setState(() {
              driverName =
                  (eventSnap.snapshot.value as Map)["driverName"].toString();
            });
          }

          if ((eventSnap.snapshot.value as Map)["status"] != null) {
            userRideRequestStatus =
                (eventSnap.snapshot.value as Map)["status"].toString();
          }

          if ((eventSnap.snapshot.value as Map)["driverLocation"] != null) {
            double driverCurrentPositionLat = double.parse(
                (eventSnap.snapshot.value as Map)["driverLocation"]["latitude"]
                    .toString());
            double driverCurrentPositionLng = double.parse(
                (eventSnap.snapshot.value as Map)["driverLocation"]["longitude"]
                    .toString());

            LatLng driverCurrentPositionLatLng =
            LatLng(driverCurrentPositionLat, driverCurrentPositionLng);

            //status = accepted
            if (userRideRequestStatus == "accepted") {
              updateArrivalTimeToUserPickupLocation(driverCurrentPositionLatLng);
            }

            //status = arrived
            if (userRideRequestStatus == "arrived") {
              setState(() {
                driverRideStatus = "Driver has Arrived";
              });
            }

            //status = ontrip
            if (userRideRequestStatus == "ontrip") {
              updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng);
            }
            //status = ended
            if (userRideRequestStatus == "ended") {
              if ((eventSnap.snapshot.value as Map)["fareAmount"] != null) {
                double fareAmount = double.parse(
                    (eventSnap.snapshot.value as Map)["fareAmount"].toString());

                var response = await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext c) => PayFareAmountDialog(
                    fareAmount: fareAmount,
                  ),
                );

                if (response == "cashPayed") {
                  //user can rate the driver now
                  if ((eventSnap.snapshot.value as Map)["driverId"] != null) {
                    String assignedDriverId =
                    (eventSnap.snapshot.value as Map)["driverId"].toString();

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => RateDriverScreen(
                              assignedDriverId: assignedDriverId,
                            )));

                    referenceRideRequest!.onDisconnect();
                    tripRideRequestInfoStreamSubscription!.cancel();
                  }
                }
              }
            }
          }
        });

    onlineNearByAvailableDriversList =
        GeoFireAssistant.activeNearbyAvailableDriversList;
    searchNearestOnlineDrivers();
  }

  updateArrivalTimeToUserPickupLocation(driverCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      LatLng userPickUpPosition =
      LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

      var directionDetailsInfo =
      await AssistantMethods.obtainOriginToDestinationDirectionDetails(
        driverCurrentPositionLatLng,
        userPickUpPosition,
      );

      if (directionDetailsInfo == null) {
        return;
      }

      setState(() {
        driverRideStatus =
        "Driver is Coming :: ${directionDetailsInfo.duration_text}";
      });

      requestPositionInfo = true;
    }
  }

  updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      var dropOffLocation =
          Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

      LatLng userDestinationPosition = LatLng(
          dropOffLocation!.locationLatitude!,
          dropOffLocation!.locationLongitude!);

      var directionDetailsInfo =
      await AssistantMethods.obtainOriginToDestinationDirectionDetails(
        driverCurrentPositionLatLng,
        userDestinationPosition,
      );

      if (directionDetailsInfo == null) {
        return;
      }

      setState(() {
        driverRideStatus =
        "Going towards Destination :: ${directionDetailsInfo.duration_text}";
      });

      requestPositionInfo = true;
    }
  }

  searchNearestOnlineDrivers() async {
    //no active driver available
    if (onlineNearByAvailableDriversList.length == 0) {
      //cancel/delete the RideRequest Information
      referenceRideRequest!.remove();
      setState(() {
        polyLineSet.clear();
        markersSet.clear();
        circlesSet.clear();
        pLineCoOrdinatesList.clear();
      });

      Fluttertoast.showToast(
          msg:
          "No Online Nearest Driver Available. Search Again after some time, Restarting App Now.");

      //dealy kr re restart 3 sec
      // Future.delayed(const Duration(milliseconds: 4000), ()
      // {
      //   Navigator.pop(context);
      //   // SystemNavigator.pop();//refresh our app
      // });

      return;
    }

    //active driver available
    await retrieveOnlineDriversInformation(onlineNearByAvailableDriversList);

    var response = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => SelectNearestActiveDriversScreen(
                referenceRideRequest: referenceRideRequest)));

    if (response == "driverChoosed") {
      FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(chosenDriverId!)
          .once()
          .then((snap) {
        if (snap.snapshot.value != null) {
          //send notification to that specific driver
          sendNotificationToDriverNow(chosenDriverId!);

          //Display Waiting Response UI from a Driver
          showWaitingResponseFromDriverUI();

          //Response from a Driver
          FirebaseDatabase.instance
              .ref()
              .child("drivers")
              .child(chosenDriverId!)
              .child("newRideStatus")
              .onValue
              .listen((eventSnapshot) {
            //1. driver has cancel the rideRequest :: Push Notification
            // (newRideStatus = idle)
            if (eventSnapshot.snapshot.value == "idle") {
              Fluttertoast.showToast(
                  msg:
                  "The driver has cancelled your request. Please choose another driver.");

              Future.delayed(const Duration(milliseconds: 3000), () {
                Fluttertoast.showToast(msg: "Please Restart App Now.");

                // SystemNavigator.pop();
              });
            }

            //2. driver has accept the rideRequest :: Push Notification
            // (newRideStatus = accepted)
            if (eventSnapshot.snapshot.value == "accepted") {
              //design and display ui for displaying assigned driver information
              showUIForAssignedDriverInfo();
            }
          });
        } else {
          Fluttertoast.showToast(msg: "This driver do not exist. Try again.");
        }
      });
    }
  }

  showUIForAssignedDriverInfo() {
    setState(() {
      waitingResponseFromDriverContainerHeight = 0;
      searchLocationContainerHeight = 0;
      assignedDriverInfoContainerHeight = 240;
    });
  }

  showWaitingResponseFromDriverUI() {
    setState(() {
      searchLocationContainerHeight = 0;
      waitingResponseFromDriverContainerHeight = 220;
    });
  }

  sendNotificationToDriverNow(String chosenDriverId) {
    //assign/SET rideRequestId to newRideStatus in
    // Drivers Parent node for that specific choosen driver
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(chosenDriverId)
        .child("newRideStatus")
        .set(referenceRideRequest!.key);

    //automate the push notification service
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(chosenDriverId)
        .child("token")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        String deviceRegistrationToken = snap.snapshot.value.toString();

        //send Notification Now
        AssistantMethods.sendNotificationToDriverNow(
          deviceRegistrationToken,
          referenceRideRequest!.key.toString(),
          context,
        );

        Fluttertoast.showToast(msg: "Notification sent Successfully.");
      } else {
        Fluttertoast.showToast(msg: "Please choose another driver.");
        return;
      }
    });
  }

  retrieveOnlineDriversInformation(List onlineNearestDriversList) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");
    for (int i = 0; i < onlineNearestDriversList.length; i++) {
      await ref
          .child(onlineNearestDriversList[i].driverId.toString())
          .once()
          .then((dataSnapshot) {
        var driverKeyInfo =
            dataSnapshot.snapshot.value; //value le k aa ra db se
        dList.add(driverKeyInfo);
        //print("driver's key info" + dList.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    createActiveNearByDriverIconMarker();
    return Scaffold(

      body: Stack(children: [
        GoogleMap(
          padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
          mapType: MapType.normal,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          initialCameraPosition: _kGooglePlex,
          polylines: polyLineSet,
          markers: markersSet,
          circles: circlesSet,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;

            //for black theme google map
            // blackThemeGoogleMap();

            setState(() {
              bottomPaddingOfMap = 240;
            });

            locateUserPosition();
          },
        ),

        // Positioned(
        //   top: 40,
        //   left: 14,
        //   child: GestureDetector(
        //     onTap: () {
        //       //restart-refresh-minimize app progmatically
        //       // SystemNavigator.pop();
        //       Future.delayed(Duration(milliseconds: 10),(){
        //
        //       Navigator.pop(context);
        //       });
        //     },
        //     child: const CircleAvatar(
        //       backgroundColor: Colors.grey,
        //       child: Icon(
        //         Icons.close,
        //         color: Colors.black54,
        //       ),
        //     ),
        //   ),
        // ),

        ///  ui for searching location
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedSize(
            curve: Curves.easeIn,
            duration: const Duration(milliseconds: 120),
            child: Container(
              height: searchLocationContainerHeight,
              decoration:  BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  children: [
                    ///  from
                    Row(
                      children: [
                         Icon(
                          Icons.add_location_alt_outlined,
                          color: AppColors.whiteColor,
                        ),
                        const SizedBox(
                          width: 12.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text(
                              "From",
                              style:
                              TextStyle(color:AppColors.whiteColor, fontSize: 12),
                            ),
                            Text(
                              Provider.of<AppInfo>(context)
                                  .userPickUpLocation !=
                                  null
                                  ? "${(Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0, 24)}..."
                                  : "not getting address",
                              style:  TextStyle(
                                  color: AppColors.whiteColor, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: size.height*0.010),
                     Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.whiteColor,
                    ),
                    SizedBox(height: size.height*0.010),
                    /// to
                    GestureDetector(
                      onTap: () async {
                        //go to search places screen
                        var responseFromSearchScreen = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (c) => SearchPlacesScreen()));

                        if (responseFromSearchScreen == "obtainedDropoff") {
                          //draw routes - draw polyline
                          await drawPolyLineFromOriginToDestination();
                        }
                      },
                      child: Row(
                        children: [
                           Icon(
                            Icons.add_location_alt_outlined,
                            color: AppColors.whiteColor,
                          ),
                          const SizedBox(
                            width: 12.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text(
                                "To",
                                style:
                                TextStyle(color:AppColors.whiteColor,fontSize: 12),
                              ),
                              Text(
                                Provider.of<AppInfo>(context)
                                    .userDropOffLocation !=
                                    null
                                    ? Provider.of<AppInfo>(context)
                                    .userDropOffLocation!
                                    .locationName!
                                    : "Where to go?",
                                style:  TextStyle(
                                    color: AppColors.whiteColor, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height*0.010),
                     Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.whiteColor,
                    ),
                    SizedBox(height: size.height*0.010),
                    Row(
                      children: [
                         Icon(
                          Icons.event_seat,
                          color: AppColors.whiteColor,
                        ),
                         SizedBox(
                          width: 12.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text(
                              "No of Seats",
                              style:
                              TextStyle(color:AppColors.whiteColor,fontSize: 12),
                            ),
                            Text(
                              '${noOfSeat}',
                              style:  TextStyle(
                                  color: AppColors.whiteColor, fontSize: 14),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                            onPressed: noOfSeat<6 ? () {
                              setState(() {
                                noOfSeat++;
                              });
                            }:null,
                            icon: Icon(Icons.add,color:AppColors.whiteColor)),
                        IconButton(
                            onPressed: noOfSeat>1 ? () {
                              setState(() {
                                noOfSeat--;
                              });
                            }:null,
                            icon: Icon(Icons.remove,color:AppColors.whiteColor,))
                      ],
                    ),

                     Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.whiteColor,
                    ),
                    SizedBox(height: size.height*0.010),
                    /// start date   end date
                    Row(
                      children: [

                        Column(
                          children: [
                            const Text(
                              "Start Date",
                              style: TextStyle(color: AppColors.whiteColor, fontSize: 12),
                            ),
                            const SizedBox(
                              width: 12.0,
                            ),
                            /// Start  date
                            GestureDetector(
                              child: startdate != null
                                  ? Text(
                                '${startdate!}'.substring(0, 10),
                                style: const TextStyle(
                                    color: AppColors.whiteColor),
                              )
                                  : const Icon(
                                Icons.calendar_month,
                                color: Colors.white,
                              ),
                              onTap: () {
                                startDate();
                              },
                            ),
                          ],
                        ),


                        const Spacer(),

                        Column(
                          children: [
                            const Text(
                              "End DATE",
                              style: TextStyle(color:AppColors.whiteColor, fontSize: 12),
                            ),
                            const SizedBox(
                              width: 12.0,
                            ),
                            /// End data is here
                            GestureDetector(
                              child: enddate != null
                                  ? Text(
                                '${enddate!}'.substring(0, 10),
                                style: const TextStyle(
                                    color: AppColors.whiteColor),
                              )
                                  : const Icon(
                                Icons.calendar_month,
                                color: Colors.white,
                              ),
                              onTap: () {
                                endDate();
                              },
                            ),
                          ],
                        )

                      ],
                    ),
                    SizedBox(height: size.height*0.010),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.whiteColor,
                    ),
                    SizedBox(height: size.height*0.010),
                    /// pick time origim and time destination
                    Row(
                      children: [


                        /// pickup time destination
                        Column(
                          children: [
                            const Text(
                              "Pick Up Time Origin",
                              style: TextStyle(color: AppColors.whiteColor, fontSize: 12),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            /// pick up destination time
                            GestureDetector(
                              child: pickup_orgin_time != null
                                  ? Text('${DateFormat('hh:mm a').format(DateFormat("h:m").parse("${pickup_orgin_time?.hour}:${pickup_orgin_time?.minute}"))}',

                                style: const TextStyle(
                                    color: AppColors.whiteColor),
                              )
                                  : const Icon(
                                Icons.time_to_leave,
                                color: Colors.white,
                              ),
                              onTap: () {
                                pickup_origin_Time();
                              },
                            ),
                          ],
                        ),


                        const Spacer(),

                        /// pick up time destination
                        Column(
                          children: [
                            const Text(
                              "Pick  Up Time Destination",
                              style: TextStyle(color:AppColors.whiteColor, fontSize: 12),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),

                            /// pick time is here
                            GestureDetector(
                              child: pickup_destination_time != null
                                  ? Text(
                                '${DateFormat('hh:mm a').format(DateFormat("h:m").parse("${pickup_destination_time?.hour}:${pickup_destination_time?.minute}"))}',
                                style: TextStyle(
                                    color: AppColors.whiteColor),
                              )
                                  : Icon(
                                Icons.time_to_leave,
                                color: AppColors.whiteColor,
                              ),
                              onTap: () {
                                pickup_destination_Time();
                              },
                            ),
                          ],
                        )

                      ],
                    ),
                    SizedBox(height: size.height*0.010),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.whiteColor,
                    ),
                    SizedBox(height: size.height*0.010),
                    Row(
                      // mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // /// already have ride button is here
                        // Container(
                        //   height:50,
                        //   width: 150,
                        //   child: ElevatedButton(
                        //     onPressed: () {
                        //
                        //         Navigator.push(context, MaterialPageRoute(builder: (context)=>CarPoolAlreadyRides()));
                        //         // saveRideRequestInformation();
                        //
                        //     },
                        //     style: ElevatedButton.styleFrom(
                        //         padding: EdgeInsets.all(5),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(10)
                        //       ),
                        //         primary: Colors.white,
                        //         textStyle:  const TextStyle(
                        //           color: AppColors.primaryColor,
                        //             fontSize: 15, fontWeight: FontWeight.bold)),
                        //     child:Text(
                        //       "Already Available \n Rides",
                        //       style:TextStyle(
                        //           color: AppColors.primaryColor,
                        //           fontSize: 15, fontWeight: FontWeight.bold),
                        //       textAlign: TextAlign.center,
                        //     ),
                        //   ),
                        // ),
                        /// create ride button ishere
                        Container(
                          height: 50,
                          width: 300,
                          child: ElevatedButton(
                            onPressed: () {
                              if (Provider.of<AppInfo>(context, listen: false).userDropOffLocation != null


                              ) {
                                saveRideRequestInformation();
                                // Navigator.pop(context);
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Please select destination location");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.all(5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                primary: Colors.white,
                                textStyle:  const TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            child: const Text(
                              "Create Ride ",
                              style:TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),


                  ],
                ),
              ),
            ),
          ),
        ),

        ///ui for waiting response from driver
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: waitingResponseFromDriverContainerHeight,
            decoration:  BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.9),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: AnimatedTextKit(
                  repeatForever: true,
                  animatedTexts: [
                    FadeAnimatedText(
                      'Waiting for Response\nfrom Driver',
                      duration: const Duration(seconds: 6),
                      textAlign: TextAlign.center,
                      textStyle: const TextStyle(
                          fontSize: 30.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    ScaleAnimatedText(
                      'Please wait...',
                      duration: const Duration(seconds: 10),
                      textAlign: TextAlign.center,
                      textStyle: const TextStyle(
                          fontSize: 32.0,
                          color: Colors.white,
                          fontFamily: 'Canterbury'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        /// ui for displaying assigned driver information
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: assignedDriverInfoContainerHeight,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.9),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// status of ride
                    Center(
                      child: Text(
                        driverRideStatus,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20.0,
                    ),

                    const Divider(
                      height: 2,
                      thickness: 2,
                      color:AppColors.whiteColor,
                    ),

                    const SizedBox(
                      height: 20.0,
                    ),

                    //driver vehicle details
                    Text(
                      driverCarDetails,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.whiteColor,
                      ),
                    ),

                    const SizedBox(
                      height: 2.0,
                    ),

                    /// driver name
                    Text(
                      driverName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.whiteColor,
                      ),
                    ),

                    const SizedBox(
                      height: 20.0,
                    ),

                    const Divider(
                      height: 2,
                      thickness: 2,
                      color: AppColors.whiteColor,
                    ),

                    const SizedBox(
                      height: 20.0,
                    ),
                    /// call driver button
                    Container(
                      height: 45,
                      width: 200,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          ),
                          primary: AppColors.whiteColor
                        ),
                        icon: const Icon(
                          Icons.phone_android,
                          color: Colors.white,
                          size: 22,
                        ),
                        label: const Center(
                          child:  Text(
                            "Call Driver",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ))
      ]),
    );
  }


  startDate() async {
    DateTime? dateTime;
    dateTime = await showDatePicker(
        currentDate: startdate,
        context: context,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(
            DateTime.now().year, DateTime.now().month + 6, DateTime.now().day));
    setState(() {
      startdate = dateTime;
    });
    return startdate;
  }

  endDate() async {
    DateTime? dateTime;
    dateTime = await showDatePicker(
        currentDate: enddate,
        context: context,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(
            DateTime.now().year, DateTime.now().month + 6, DateTime.now().day));
    setState(() {
      enddate = dateTime;
    });
    return enddate;
  }

  pickup_origin_Time() async {
    TimeOfDay? timeOfDay;
    timeOfDay = await showTimePicker(
        initialEntryMode: TimePickerEntryMode.dialOnly,
        context: context,
        initialTime: TimeOfDay.now());
    // print("cuurent time--->> ${DateFormat("h:m").parse("${timeOfDay?.hour}:${timeOfDay?.minute}")}");
    // DateFormat('hh:mm a').format(DateFormat("h:m").parse("${timeOfDay?.hour}:${timeOfDay?.minute}"));
    setState(() {
      pickup_orgin_time = timeOfDay;
    });
    return pickup_orgin_time;
  }


  pickup_destination_Time() async {
    TimeOfDay? timeOfDay;
    timeOfDay = await showTimePicker(
        initialEntryMode: TimePickerEntryMode.dialOnly,
        context: context,
        initialTime: TimeOfDay.now());
    setState(() {
      pickup_destination_time = timeOfDay;
    });
    return pickup_destination_time;
  }
  Future<void> drawPolyLineFromOriginToDestination() async {
    var originPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(
        originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!,
        destinationPosition.locationLongitude!);

    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Please wait...",
      ),
    );

    var directionDetailsInfo =
    await AssistantMethods.obtainOriginToDestinationDirectionDetails(
        originLatLng, destinationLatLng); //directions le re hain
    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });

    Navigator.pop(context);

    print("These are points = ");
    print(directionDetailsInfo!.e_points);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList =
    pPoints.decodePolyline(directionDetailsInfo!.e_points!);

    pLineCoOrdinatesList.clear();

    if (decodedPolyLinePointsResultList.isNotEmpty) {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoOrdinatesList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.blue,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoOrdinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      infoWindow:
      InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      infoWindow: InfoWindow(
          title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );

    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });
  }

  initializeGeoFireListener() {
    Geofire.initialize("activeDrivers");

    Geofire.queryAtLocation(
        userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
        //whenever any driver become active/online
          case Geofire.onKeyEntered:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver =
            ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            GeoFireAssistant.activeNearbyAvailableDriversList
                .add(activeNearbyAvailableDriver);
            if (activeNearbyDriverKeysLoaded == true) {
              displayActiveDriversOnUsersMap();
            }
            break;

        //whenever any driver become non-active/offline
          case Geofire.onKeyExited:
            GeoFireAssistant.deleteOfflineDriverFromList(map['key']);
            displayActiveDriversOnUsersMap();
            break;

        //whenever driver moves - update driver location
          case Geofire.onKeyMoved:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver =
            ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            GeoFireAssistant.updateActiveNearbyAvailableDriverLocation(
                activeNearbyAvailableDriver);
            displayActiveDriversOnUsersMap();
            break;

        //display those online/active drivers on user's map
          case Geofire.onGeoQueryReady:
            activeNearbyDriverKeysLoaded = true;
            displayActiveDriversOnUsersMap();
            break;
        }
      }

      setState(() {});
    });
  }

  displayActiveDriversOnUsersMap() {

      markersSet.clear();
      circlesSet.clear();

      Set<Marker> driversMarkerSet = Set<Marker>();

      for (ActiveNearbyAvailableDrivers eachDriver
      in GeoFireAssistant.activeNearbyAvailableDriversList) {
        LatLng eachDriverActivePosition =
        LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);

        Marker marker = Marker(
          markerId: MarkerId("driver${eachDriver.driverId!}"),
          position: eachDriverActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
        );

        driversMarkerSet.add(marker);
      }

      setState(() {
        markersSet = driversMarkerSet;

    });
  }

  createActiveNearByDriverIconMarker() {
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration =
      createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car.png")
          .then((value) {
        activeNearbyIcon = value;
      });
    }
  }
}
