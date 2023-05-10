import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:vimigo_flutter_asessment/details.dart';
import 'package:vimigo_flutter_asessment/main.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/attendance.dart';
import 'data/dataset.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);

  List<Widget> pages = [
    PageOne(),
    PageTwo(),
    PageThree(),
    PageFour(),
    PageFive(),
    PageSix(),
    PageSeven()
  ];

  int currentIndex = 0;
  bool hasCompletedOnboarding = false;

  void completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);
    setState(() {}); // force a rebuild to reflect the new format
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                  onTap: () {
                    if (currentIndex == pages.length - 1) {
                      completeOnboarding();
                      Navigator.of(context)
                          .push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const MyHomePage(title: "Attendance Details"),
                        ),
                      )
                          .then((value) {
                        setState(() {});
                      });
                    } else {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut);
                      setState(() {
                        currentIndex++;
                      });
                    }
                  },
                  child: pages[index]);
            },
          ),
          Padding(
            padding: currentIndex == 0
                ? const EdgeInsets.only(right: 0.0)
                : const EdgeInsets.only(right: 60.0),
            child: Align(
              alignment: currentIndex == 0
                  ? Alignment.bottomCenter
                  : Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: TextButton(
                  onPressed: () {
                    if (currentIndex == pages.length - 1) {
                      completeOnboarding();
                      Navigator.of(context)
                          .push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const MyHomePage(title: "Attendance Details"),
                        ),
                      )
                          .then((value) {
                        setState(() {});
                      });
                    } else {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut);
                      setState(() {
                        currentIndex++;
                      });
                    }
                  },
                  child: currentIndex == pages.length - 1
                      ? const Text(
                          "Start",
                          style: TextStyle(fontSize: 20),
                        )
                      : const Text(
                          "Next",
                          style: TextStyle(fontSize: 20),
                        ),
                ),
              ),
            ),
          ),
          currentIndex == 0
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.only(left: 60.0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 50),
                      child: TextButton(
                        onPressed: () {
                          _pageController.animateToPage(
                              _pageController.page!.toInt() - 1,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut);
                          setState(() {
                            currentIndex--;
                          });
                        },
                        child: const Text(
                          "Before",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class PageOne extends StatelessWidget {
  const PageOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Padding(
          padding: EdgeInsets.only(top: 250.0),
          child: Text(
            "Welcome to the Attendance Records Application!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 30.0, right: 20, left: 20),
          child: Text(
            "The app is designed to help users keep track of their attendance details and view the attendance records of others.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
  }
}

class PageTwo extends StatelessWidget {
  const PageTwo({super.key});

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

  @override
  Widget build(BuildContext context) {
    dataset.sort((a, b) => b.checkIn.compareTo(a.checkIn));

    List<Attendance> attendanceRecords = dataset;

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 100.0),
          child: Text(
            "View attendance records entered by you and others.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 520,
          child: ListView.builder(
            itemCount: attendanceRecords.length,
            itemBuilder: (BuildContext context, int index) {
              final Attendance record = attendanceRecords[index];

              return ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(record.user),
                    InkWell(
                      onTap: () {
                        String contactInfo = "${record.user}  ${record.phone}";
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
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(record.phone.toString()),
                      Text(calculate(record.checkIn).toString()),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class PageThree extends StatefulWidget {
  const PageThree({super.key});

  @override
  State<PageThree> createState() => _PageThreeState();
}

class _PageThreeState extends State<PageThree> {
  bool _isSelected = false;

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

  @override
  Widget build(BuildContext context) {
    dataset.sort((a, b) => b.checkIn.compareTo(a.checkIn));

    List<Attendance> attendanceRecords = dataset;

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 250.0),
          child: Text(
            "Toggle button to switch between different date formats",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 18.0, top: 20.0),
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
                              Colors.black26, Colors.blue, global.position),
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
                    color:
                        Color.lerp(Colors.white, Colors.white, global.position),
                    borderRadius: const BorderRadius.all(Radius.circular(50.0)),
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
        SizedBox(
          height: 100,
          child: ListView.builder(
            itemCount: attendanceRecords.length,
            itemBuilder: (BuildContext context, int index) {
              final Attendance record = attendanceRecords[index];

              if (index == 0) {
                return ListTile(
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
                    padding: const EdgeInsets.only(top: 12.0),
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
                );
              } else {
                return SizedBox();
              }
            },
          ),
        ),
      ],
    );
  }
}

class PageFour extends StatefulWidget {
  const PageFour({super.key});

  @override
  State<PageFour> createState() => _PageFourState();
}

class _PageFourState extends State<PageFour> {
  bool _isFocused = false;
  final _searchformKey = GlobalKey<FormState>();
  final _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    dataset.sort((a, b) => b.checkIn.compareTo(a.checkIn));

    List<Attendance> attendanceRecords = dataset;

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 70.0, bottom: 30.0),
          child: Text(
            "Search for a particular record",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Form(
          key: _searchformKey,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.0),
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
        SizedBox(
          height: 400,
          child: ListView.builder(
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
                    onTap: () {},
                    child: ListTile(
                      title: Row(
                        children: [
                          Text(record.user),
                        ],
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(record.phone.toString()),
                          Text(DateFormat('dd MMM yyyy, h:mm a')
                              .format(record.checkIn)
                              .toString()),
                        ],
                      ),
                    ),
                  );
                }
              } else {
                return InkWell(
                  onTap: () {},
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
                          Text(DateFormat('dd MMM yyyy, h:mm a')
                              .format(record.checkIn)
                              .toString())
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
    );
  }
}

class PageFive extends StatefulWidget {
  const PageFive({super.key});

  @override
  State<PageFive> createState() => _PageFiveState();
}

class _PageFiveState extends State<PageFive> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 200.0, bottom: 20.0),
          child: Text(
            "Add new attendance record by pressing",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            setState(() {
              isSelected = !isSelected;
            });
          },
          child: const Icon(
            Icons.add,
            size: 20.0,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        if (isSelected)
          Form(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                //prevent keyboard from covering text fields
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
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
                      //
                    },
                  )
                ],
              ),
            ),
          )
      ],
    );
  }
}

class PageSix extends StatefulWidget {
  const PageSix({super.key});

  @override
  State<PageSix> createState() => _PageSixState();
}

class _PageSixState extends State<PageSix> {
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

  @override
  Widget build(BuildContext context) {
    dataset.sort((a, b) => b.checkIn.compareTo(a.checkIn));

    List<Attendance> attendanceRecords = dataset;

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 250.0, bottom: 30.0),
          child: Text(
            "Share contact information by pressing",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const Icon(
          Icons.share,
          size: 20.0,
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            itemCount: attendanceRecords.length,
            itemBuilder: (BuildContext context, int index) {
              final Attendance record = attendanceRecords[index];

              if (index == 0) {
                return ListTile(
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
                          size: 18.0,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(record.phone.toString()),
                        Text(DateFormat('dd MMM yyyy, h:mm a')
                            .format(record.checkIn)
                            .toString())
                      ],
                    ),
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ),
      ],
    );
  }
}

class PageSeven extends StatelessWidget {
  const PageSeven({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Padding(
          padding: EdgeInsets.only(top: 250.0),
          child: Text(
            "End of Tutorial!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 30.0, right: 20, left: 20),
          child: Text(
            "Click the Start button below to explore the application now",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
  }
}
