import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assessment/data/attendance.dart';
import 'package:flutter_assessment/data/dataset.dart';
import 'package:flutter_assessment/details.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboardingscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasCompletedOnboarding =
      prefs.getBool('hasCompletedOnboarding') ?? false;
  runApp(MyApp(hasCompletedOnboarding: hasCompletedOnboarding));
}

class MyApp extends StatelessWidget {
  final bool hasCompletedOnboarding;

  const MyApp({super.key, required this.hasCompletedOnboarding});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: hasCompletedOnboarding
            ? const MyHomePage(title: 'Attendance Record')
            : OnBoardingScreen());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isSelected = false;
  bool _isFocused = false;
  bool _showListHasEnded = false;
  final _searchformKey = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();
  final _focusNode = FocusNode();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadApp();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          _showListHasEnded = true;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("End Of List")));
      } else {
        setState(() {
          _showListHasEnded = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneNumberController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int _calculateMonthsDifference(DateTime now, DateTime givenTime) {
    int months = (now.year - givenTime.year) * 12;
    months -= givenTime.month;
    months += now.month;
    return months <= 0 ? 0 : months;
  }

  String calculate(DateTime givenTime) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(givenTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else {
      int months = _calculateMonthsDifference(now, givenTime);
      return '$months months ago';
    }
  }

  void _loadApp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool format = prefs.getBool('_isSelected') ?? false;
    setState(() {
      _isSelected = format;
    });
  }

  void _toggleSwitch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('_isSelected', _isSelected);
    setState(() {}); // force a rebuild to reflect the new format
  }

  void _toggleAttendance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dataset', _isSelected);
    setState(() {}); // force a rebuild to reflect the new format
  }

  Future<void> createAttendance() async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  //prevent keyboard from covering text fields
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration:
                        const InputDecoration(labelText: 'Phone Number'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blueAccent),
                    ),
                    child: const Text(
                      "Add Attendance",
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate() == true) {
                        dataset.add(Attendance(
                            user: _usernameController.text,
                            phone: _phoneNumberController.text,
                            checkIn: DateTime.now()));
                        //Hide bottom sheet
                        setState(() {});
                        Navigator.of(context).pop();
                        Flushbar(
                          flushbarPosition: FlushbarPosition.TOP,
                          margin: const EdgeInsets.all(8),
                          borderRadius: BorderRadius.circular(8),
                          title: 'Successful addition',
                          message: 'Attendance added to the list',
                          icon: const Icon(
                            Icons.check,
                            color: Colors.white,
                          ),
                          backgroundColor: Colors.blue,
                          duration: const Duration(seconds: 3),
                        ).show(context);
                      }
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    //Sort the dataset based on the date
    dataset.sort((a, b) => b.checkIn.compareTo(a.checkIn));

    List<Attendance> attendanceRecords = dataset;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: CustomAnimatedToggleSwitch<bool>(
              current: _isSelected,
              values: const [false, true],
              dif: 0.0,
              indicatorSize: const Size.square(30.0),
              animationDuration: const Duration(milliseconds: 200),
              animationCurve: Curves.linear,
              onChanged: (b) => setState(() => _isSelected = b),
              iconBuilder: (context, local, global) {
                return const SizedBox();
              },
              defaultCursor: SystemMouseCursors.click,
              onTap: () {
                setState(() {
                  _isSelected = !_isSelected;
                });
                _toggleSwitch();
              },
              iconsTappable: false,
              wrapperBuilder: (context, global, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                        left: 10.0,
                        right: 10.0,
                        height: 20.0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color.lerp(
                                Colors.black26, Colors.white, global.position),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50.0)),
                          ),
                        )),
                    child,
                  ],
                );
              },
              foregroundIndicatorBuilder: (context, global) {
                return SizedBox.fromSize(
                  size: global.indicatorSize,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color.lerp(
                          Colors.white, Colors.black, global.position),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(50.0)),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black38,
                            spreadRadius: 0.05,
                            blurRadius: 1.1,
                            offset: Offset(0.0, 0.8))
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10.0,
            ),
            Form(
              key: _searchformKey,
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5.0),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: _isFocused ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        //Add a TextEditingController to track value of TextFormField
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: "Search",
                          border: InputBorder.none,
                        ),
                        focusNode: _focusNode,
                        onChanged: (value) {
                          setState(() {});
                        },
                        validator: (value) {
                          if (value == null) {
                            return "Please enter some text";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Container(
              height: 590,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: attendanceRecords.length,
                itemBuilder: (BuildContext context, int index) {
                  final Attendance record = attendanceRecords[index];

                  if (_focusNode.hasFocus && _searchController.text != '') {
                    if (record.user
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase()) ||
                        record.user
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase())) {
                      return InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (context) => AttendanceDetails(
                                user: record.user,
                                phone: record.phone,
                                date: record.checkIn,
                              ),
                            ),
                          )
                              .then((value) {
                            setState(() {});
                          });
                        },
                        child: ListTile(
                          title: Row(
                            children: [
                              Text(record.user),
                              InkWell(
                                onTap: () {
                                  String contactInfo =
                                      "${record.user}  ${record.phone}";
                                  Share.share(contactInfo);
                                },
                                child: const Icon(
                                  Icons.share,
                                  size: 14.0,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(record.phone.toString()),
                              _isSelected
                                  ? Text(DateFormat('dd MMM yyyy, h:mm a')
                                      .format(record.checkIn)
                                      .toString())
                                  : Text(calculate(record.checkIn).toString()),
                            ],
                          ),
                        ),
                      );
                    }
                  } else {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (context) => AttendanceDetails(
                              user: record.user,
                              phone: record.phone,
                              date: record.checkIn,
                            ),
                          ),
                        )
                            .then((value) {
                          setState(() {});
                        });
                      },
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(record.user),
                            InkWell(
                              onTap: () {
                                String contactInfo =
                                    "${record.user}  ${record.phone}";
                                Share.share(contactInfo);
                              },
                              child: const Icon(
                                Icons.share,
                                size: 14.0,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(record.phone.toString()),
                              _isSelected
                                  ? Text(DateFormat('dd MMM yyyy, h:mm a')
                                      .format(record.checkIn)
                                      .toString())
                                  : Text(calculate(record.checkIn).toString()),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createAttendance,
        tooltip: 'Add Attendance',
        child: const Icon(Icons.add),
      ),
    );
  }
}
