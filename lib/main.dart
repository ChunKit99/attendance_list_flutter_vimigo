import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'AttendanceRecord.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Splash(),
    );
  }
}

// the most early screen, use to check the wherether open onboarding or attendance list
class Splash extends StatefulWidget {
  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<Splash> with AfterLayoutMixin<Splash> {
  // check new user first open
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    // open AttendanceList if not new user
    if (_seen) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AttendanceList()));
    } else {
      await prefs.setBool('seen', true);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => OnBoardingPage()));
    }
  }

  //after running first layout check splash screen record
  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Loading...'),
      ),
    );
  }
}

//11. An onboarding screen / introduction screen should be shown to educate users how to use the app when a new user first opens up the app.
class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  //here is to go attendance list page after finish
  void _onIntroEnd(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AttendanceList()),
    );
  }

  //widget for open image form asset
  Widget _buildImage(String imageName, [double width = 350]) {
    return Image.asset('assets/images/$imageName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      autoScrollDuration: 3000,
      globalHeader: Align(
        alignment: Alignment.topRight,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, right: 16),
            child: _buildImage('image1.jpg', 100),
          ),
        ),
      ),
      globalFooter: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          child: const Text(
            'Let\'s go right away!',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          onPressed: () => _onIntroEnd(context),
        ),
      ),
      pages: [
        PageViewModel(
          title: "View all the attendance list",
          body: "You can view all the attendance list that recorded before.",
          image: _buildImage('image4.jpg'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Add new attendance record",
          body: "You can add new attendance to the list",
          image: _buildImage('image5.jpg'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Toogle time with time ago or other format ",
          body:
              "View the time in time ago format or other format with a click.",
          image: _buildImage('image3.jpg'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Shares Contact Information",
          body: "You can share the contact information to any application",
          image: _buildImage('image2.jpg'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: false,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: true,
      //rtl: true, // Display as right-to-left
      back: const Icon(Icons.arrow_back),
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}

//class for page of list view attendance record, the main page for this application
class AttendanceList extends StatefulWidget {
  const AttendanceList({super.key});

  @override
  _AttendanceListState createState() => _AttendanceListState();
}

class _AttendanceListState extends State<AttendanceList> {
  @override
  void initState() {
    super.initState();

    // Load the time format preference from shared preferences
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _useTimeAgoFormat = prefs.getBool('timeFormat') ?? true;
      });
    });
  }

  // A list of attendance records base on example
  List<AttendanceRecord> _attendanceRecords = [
    AttendanceRecord("Chan Saw Lin", "0152131113", "2020-06-30 16:10:05"),
    AttendanceRecord("Lee Saw Loy", "0161231346", "2020-07-11 15:39:59"),
    AttendanceRecord("Khaw Tong Lin", "0158398109", "2020-08-19 11:10:18"),
    AttendanceRecord("Lim Kok Lin", "0168279101", "2020-08-19 11:11:35"),
    AttendanceRecord("Low Jun Wei", "0112731912", "2020-08-15 13:00:05"),
    AttendanceRecord("Yong Weng Kai", "0172332743", "2020-07-31 18:10:11"),
    AttendanceRecord("Jayden Lee", "0111931233", "2020-08-22 08:10:38"),
    AttendanceRecord("Kong Kah Yan", "0152131113", "2020-07-11 12:00:00"),
    AttendanceRecord("Jasmine Lau", "0162879190", "2020-08-01 12:10:05"),
    AttendanceRecord("Chan Saw Lin", "016783239", "2020-08-23 11:59:05"),
  ];

  // Flag to toggle time format between "time ago" and "dd MMM yyyy, h:mm a"
  bool _useTimeAgoFormat = true;

  // Search keyword
  String _searchKeyword = "";

  //4. The time format also be able to display in other format “dd MMM yyyy, h:mm a” with the change of toggle button
  // Function to toggle time format
  void _toggleTimeFormat() {
    setState(() {
      _useTimeAgoFormat = !_useTimeAgoFormat;
      //5. The time format changes should be keep even if users terminate/kill the app
      // Save the time format preference to shared preferences
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('timeFormat', _useTimeAgoFormat);
      });
    });
  }

  //7. When user successfully add new record to the list, an indicator should be display that user had successfully completed the action
  //Function to display snack bar
  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  //6. Users able to add a new attendance record into the list
  // Function to add new attendance record
  void _addRecord(AttendanceRecord record) {
    setState(() {
      _attendanceRecords.add(record);
      // Show a success message
      showInSnackBar('Record added successfully!');
    });
  }

  void call() {}

  //controller for text edit in add record
  TextEditingController _textFieldControllerName = TextEditingController();
  TextEditingController _textFieldControllerPhone = TextEditingController();
  TextEditingController _textFieldControllerCheckIn = TextEditingController();

  //dialog use for add new record
  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Attendance'),
          content: Column(
            //fit the height of dialog to the textfield and button
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textFieldControllerName,
                decoration: const InputDecoration(hintText: "Name"),
              ),
              TextField(
                controller: _textFieldControllerPhone,
                decoration: const InputDecoration(hintText: "Phone"),
              ),
              TextField(
                controller: _textFieldControllerCheckIn,
                decoration: const InputDecoration(hintText: "Check In Time"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // call function to add attendance record into list
                _addRecord(AttendanceRecord(
                    _textFieldControllerName.text,
                    _textFieldControllerPhone.text,
                    _textFieldControllerCheckIn.text));
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<AttendanceRecord> filteredRecords = _attendanceRecords
        .where((record) => record.name.toLowerCase().contains(_searchKeyword))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Records'),
        actions: <Widget>[
          IconButton(
            // icon access_time means is time ago format, else the date time formate
            icon: Icon(
                _useTimeAgoFormat ? Icons.access_time : Icons.calendar_today),
            // 4. The time format also be able to display in other format “dd MMM yyyy, h:mm a” with the change of toggle button
            onPressed: _toggleTimeFormat,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: (() {
              // for add new record
              //change the value of textfield of check-in time in dialog
              //comment _textFieldControllerName and _textFieldControllerPhone if want to keep the last key in record
              _textFieldControllerName.text = "";
              _textFieldControllerPhone.text = "";
              _textFieldControllerCheckIn.text =
                  DateFormat('yyyy-MM-dd HH:mm:ss')
                      .format(DateTime.now())
                      .toString();
              // open dialog
              _displayTextInputDialog(context);
            }),
          ),
        ],
      ),
      body: Builder(builder: (context) {
        return Container(
          margin: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              //8. Users are able to search through the list based on the keyword that users key in.
              TextField(
                decoration: const InputDecoration(hintText: "Search Name"),
                onChanged: (text) {
                  setState(() {
                    _searchKeyword = text.toLowerCase();
                  });
                },
              ),
              Expanded(
                //10. An indicator should inform the user that “You have reached the end of the list” when the user scrolled to the end of the list.
                child: NotificationListener<ScrollEndNotification>(
                  onNotification: (scrollEnd) {
                    final metrics = scrollEnd.metrics;
                    if (metrics.atEdge) {
                      bool isTop = metrics.pixels == 0;
                      if (!isTop) {
                        showInSnackBar('You have reached the end of the list');
                      }
                    }
                    return true;
                  },
                  child: ListView.builder(
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      //1. Display the records in the form of list view and sorted based on the time.
                      //2. The list of records should be sorted from the most recent to the oldest.
                      filteredRecords.sort((a, b) => b.time.compareTo(a.time));
                      AttendanceRecord record = filteredRecords[index];
                      initializeDateFormatting();
                      // Use a `DateTime` object to format the time of each attendance record
                      DateTime time =
                          DateFormat("yyyy-MM-dd HH:mm:ss").parse(record.time);
                      // 3. The time format should be display in the format of “time ago” eg. 1 hour ago
                      // Display the time in the appropriate format based on the value of `_timeFormatIsTimeAgo`
                      // 4.
                      var formattedTime = _useTimeAgoFormat
                          ? timeago.format(time)
                          : DateFormat('dd MMM yyyy, h:mm a').format(time);
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(record.name),
                        subtitle: Text(formattedTime),
                        trailing: Text(record.ph),
                        onTap: () {
                          // Navigate to the details page for this record
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return AttendanceDetail(
                                  record: record,
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

//9. Users able to see a particular record in another page
// class for open new page when tap item list
class AttendanceDetail extends StatelessWidget {
  const AttendanceDetail({
    super.key,
    required this.record,
  });

  final AttendanceRecord record;

  //combine all information into one text
  String constructShareMessage(String name, String phone, String time) {
    return 'Name: $name\nPhone: $phone\nCheck-in Time: $time';
  }

  //function to share text to other application
  Future<void> share() async {
    await FlutterShare.share(
        title: 'Contact Information',
        text: constructShareMessage(record.name, record.ph, record.time),
        chooserTitle: 'Share Contact Information');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(record.name)),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Center(
          child: Column(
            children: [
              Text('Phone: ${record.ph}'),
              Text('Check-in time: ${record.time}'),
            ],
          ),
        ),
      ),
      //12. Users are able to share the contact information from the attendance records to other applications that are installed.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: share,
        label: const Text('Share'),
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.share),
      ),
    );
  }
}
