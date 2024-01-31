import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notch_parking/helper.dart';
import 'firebase_options.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, __) => MaterialApp(
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          alignLabelWithHint: true,
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12.w),
          border: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.black,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8.r)),
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8.r)),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color.fromRGBO(16, 147, 130, 1),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8.r)),
          errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.redAccent,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8.r)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromRGBO(16, 147, 130, 1),
        ),
      ),
      home: const WebViewExample(),
      debugShowCheckedModeBanner: false,
    ),
  ));
}

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample>
    with TickerProviderStateMixin {
  late final WebViewController controller;
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  late Future<Map<String, dynamic>?> data;
  late Future<List<DirectoryItem>?> directoryData;

  final TextEditingController _textFieldController = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();

    data = fetchData();
    directoryData = fetchDirectoryData();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) async {},
          onPageFinished: (String url) async {},
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(
        Uri.parse('https://wearenotch.com/web/webcam/'),
      );
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> fetchData() async {
    var docSnapshot = await FirebaseFirestore.instance
        .collection('reservation')
        .doc('NIhkLoYX0Js0hmjrzs3s')
        .get();

    return docSnapshot.data();
  }

  Future<List<DirectoryItem>?> fetchDirectoryData() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('directory').get();

      List<DirectoryItem> directoryItems = [];

      for (var document in querySnapshot.docs) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        DirectoryItem directoryItem = DirectoryItem.fromMap(data);
        directoryItems.add(directoryItem);
      }

      return directoryItems;
    } catch (e) {
      print('Error fetching data: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Material(
              child: Center(
                  child: SizedBox(
                      height: 64.h,
                      width: 64.w,
                      child: const CircularProgressIndicator(
                        color: Color.fromRGBO(16, 147, 130, 1),
                      ))),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final Map<String, dynamic> myData = snapshot.data!;
            return DefaultTabController(
              length: 2,
              child: KeyboardDismissOnTap(
                child: Scaffold(
                  appBar: AppBar(
                      bottom: TabBar(indicatorColor: Colors.white, tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.video_camera_back_outlined),
                              SizedBox(
                                width: 8.w,
                              ),
                              const Text('Camera',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.list_alt_outlined),
                              SizedBox(
                                width: 8.w,
                              ),
                              const Text('Directory',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
                          ),
                        )
                      ]),
                      backgroundColor: const Color.fromRGBO(16, 147, 130, 1),
                      title: const Text(
                        'Ul. Republike Austrije 33',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  body: TabBarView(
                    children: [
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: WebViewWidget(controller: controller),
                          ),
                          Positioned(
                            top: 255.h,
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Reservation:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                      color:
                                          const Color.fromRGBO(16, 147, 130, 1),
                                    ),
                                  ),
                                  if (myData['message'] != null &&
                                      myData['message'] != '') ...[
                                    SizedBox(height: 4.h),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          bottom: 8.h, left: 4.w),
                                      child: Text(myData['message']),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              bottom: 16.0.h, left: 4.w),
                                          child: Text(
                                            'Written on: ' + myData['date'],
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 40.h,
                            right: 15.w,
                            child: Transform.rotate(
                              angle: 2.4.r,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 34.h),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    FloatingActionButton.large(
                                        onPressed: () =>
                                            FlutterPhoneDirectCaller.callNumber(
                                              myData['rightRamp'],
                                            ),
                                        child: Transform.rotate(
                                            angle: -2.4.r,
                                            child: const Text(
                                              'Right\nRamp',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ))),
                                    SizedBox(width: 22.w),
                                    FloatingActionButton.large(
                                      onPressed: () =>
                                          FlutterPhoneDirectCaller.callNumber(
                                        myData['leftRamp'],
                                      ),
                                      child: Transform.rotate(
                                          angle: -2.4.r,
                                          child: const Text(
                                            'Left\nRamp',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 20.h, horizontal: 20.w),
                        child: FutureBuilder<List<DirectoryItem>?>(
                            future: directoryData,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Material(
                                  child: Center(
                                      child: SizedBox(
                                          height: 64.h,
                                          width: 64.w,
                                          child:
                                              const CircularProgressIndicator(
                                            color:
                                                Color.fromRGBO(16, 147, 130, 1),
                                          ))),
                                );
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                List<DirectoryItem>? directoryItems =
                                    (snapshot.data ?? [])
                                        .where((element) =>
                                            (element.registration ?? '')
                                                .toLowerCase()
                                                .contains(
                                                    _searchText.toLowerCase()))
                                        .toList();
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: _controller,
                                      decoration: InputDecoration(
                                        labelText: 'Search by registration',
                                        labelStyle: const TextStyle(
                                            color: Colors.black),
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.clear,
                                              color: Colors.grey),
                                          onPressed: () {
                                            setState(() {
                                              _controller.clear();
                                              _searchText = '';
                                            });
                                          },
                                        ),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _searchText = value;
                                        });
                                      },
                                    ),
                                    SizedBox(height: 12.h),
                                    Flexible(
                                      child: ListView.separated(
                                          shrinkWrap: true,
                                          itemCount: directoryItems.length,
                                          separatorBuilder: (context, index) =>
                                              SizedBox(height: 8.h),
                                          itemBuilder: (context, index) {
                                            DirectoryItem directoryItem =
                                                directoryItems[index];

                                            return Stack(
                                              children: [
                                                Card(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 20.h,
                                                            horizontal: 12.w),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          directoryItem
                                                                  .registration ??
                                                              '',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Color.fromRGBO(
                                                                    16,
                                                                    147,
                                                                    130,
                                                                    1),
                                                          ),
                                                        ),
                                                        SizedBox(height: 14.h),
                                                        Text(
                                                          directoryItem.owner ??
                                                              '',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(height: 16.h),
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            const Text(
                                                              'Description:',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: 12.w),
                                                            Expanded(
                                                              child: Text(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 5,
                                                                directoryItem
                                                                        .description ??
                                                                    '',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: directoryItem
                                                              .phone !=
                                                          null &&
                                                      directoryItem.phone != '',
                                                  child: Positioned(
                                                      top: 10.h,
                                                      right: 4,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          FlutterPhoneDirectCaller
                                                              .callNumber(
                                                                  directoryItem
                                                                      .phone!);
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          shape:
                                                              const CircleBorder(),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 8.h,
                                                                  horizontal:
                                                                      8.w),
                                                          backgroundColor:
                                                              const Color
                                                                  .fromRGBO(16,
                                                                  147, 130, 1),
                                                          foregroundColor:
                                                              Colors.white,
                                                        ),
                                                        child: const Icon(
                                                            Icons.phone,
                                                            color:
                                                                Colors.white),
                                                      )),
                                                )
                                              ],
                                            );
                                          }),
                                    ),
                                  ],
                                );
                              }
                            }),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }
}
