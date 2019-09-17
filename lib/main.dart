import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:async';

class MyEvent {
  final int id;
  final String name;
  final DateTime startingDateAndTime;
  final DateTime endingDateAndTime;

  MyEvent(
      {this.id, this.name, this.startingDateAndTime, this.endingDateAndTime});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startingDateAndTime': startingDateAndTime,
      'endingDateAndTime': endingDateAndTime
    };
  }
}

// Example holidays
final Map<DateTime, List> _holidays = {
  DateTime(2019, 1, 1): ['New Year\'s Day'],
  DateTime(2019, 1, 6): ['Epiphany'],
  DateTime(2019, 2, 14): ['Valentine\'s Day'],
  DateTime(2019, 4, 21): ['Easter Sunday'],
  DateTime(2019, 4, 22): ['Easter Monday'],
};

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Table Calendar Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Calender'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  Map<DateTime, List> _events;
  List _selectedEvents;
  AnimationController _animationController;
  CalendarController _calendarController;
  TimeOfDay _time = TimeOfDay.now();

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked =
        await showTimePicker(context: context, initialTime: _time);

    if (picked != null) {
      print('Selected Time: ${_time.toString()}');
      setState(() {
        _time = picked;
      });
    }
  }

  static const platform = const MethodChannel("flutter.rapid.programers.calender");

  //Calling Function from Native Code
  Future<void> createBackgroundService() async {
    try{
      final dynamic ob = await platform.invokeMethod('craeteBackgroudService');
    } on PlatformException catch (e) {
      print('Error Code: ${e.code}\nError Message: ${e.message}\nError Details: ${e.details}');
    }
  }

  @override
  void initState() {
    super.initState();
    final _selectedDay = DateTime.now();

    _events = {
      _selectedDay.subtract(Duration(days: 30)): [
        'Event A0',
        'Event B0',
        'Event C0'
      ],
      _selectedDay.subtract(Duration(days: 27)): ['Event A1'],
      _selectedDay.subtract(Duration(days: 20)): [
        'Event A2',
        'Event B2',
        'Event C2',
        'Event D2'
      ],
      _selectedDay.subtract(Duration(days: 16)): ['Event A3', 'Event B3'],
      _selectedDay.subtract(Duration(days: 10)): [
        'Event A4',
        'Event B4',
        'Event C4'
      ],
      _selectedDay.subtract(Duration(days: 4)): [
        'Event A5',
        'Event B5',
        'Event C5'
      ],
      _selectedDay.subtract(Duration(days: 2)): ['Event A6', 'Event B6'],
      _selectedDay: [
        'Event A7',
        'Event B7',
        'Event C7',
        'Event D7',
        'Event D7',
        'Event E7',
        'Event F7',
        'Event G7'
      ],
      _selectedDay.add(Duration(days: 1)): [
        'Event A8',
        'Event B8',
        'Event C8',
        'Event D8'
      ],
      _selectedDay.add(Duration(days: 3)):
          Set.from(['Event A9', 'Event A9', 'Event B9']).toList(),
      _selectedDay.add(Duration(days: 7)): [
        'Event A10',
        'Event B10',
        'Event C10'
      ],
      _selectedDay.add(Duration(days: 11)): ['Event A11', 'Event B11'],
      _selectedDay.add(Duration(days: 17)): [
        'Event A12',
        'Event B12',
        'Event C12',
        'Event D12'
      ],
      _selectedDay.add(Duration(days: 22)): ['Event A13', 'Event B13'],
      _selectedDay.add(Duration(days: 26)): [
        'Event A14',
        'Event B14',
        'Event C14'
      ],
    };

    _selectedEvents = _events[_selectedDay] ?? [];

    _calendarController = CalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.event,
              color: Colors.white,
            ),
            iconSize: 30,
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          // Switch out 2 lines below to play with TableCalendar's settings
          //-----------------------
          _buildTableCalendar(),
          // _buildTableCalendarWithBuilders(),
          const SizedBox(height: 8.0),
          _buildButtons(),
          const SizedBox(height: 8.0),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  // Simple TableCalendar configuration (using Styles)
  Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      events: _events,
      holidays: _holidays,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.deepOrange[400],
        todayColor: Colors.deepOrange[200],
        markersColor: Colors.brown[700],
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle:
            TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Colors.deepOrange[400],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
    );
  }

  // More advanced TableCalendar configuration (using Builders & Styles)
  // Widget _buildTableCalendarWithBuilders() {
  //   return TableCalendar(
  //     locale: 'pl_PL',
  //     calendarController: _calendarController,
  //     events: _events,
  //     holidays: _holidays,
  //     initialCalendarFormat: CalendarFormat.month,
  //     formatAnimation: FormatAnimation.slide,
  //     startingDayOfWeek: StartingDayOfWeek.sunday,
  //     availableGestures: AvailableGestures.all,
  //     availableCalendarFormats: const {
  //       CalendarFormat.month: '',
  //       CalendarFormat.week: '',
  //     },
  //     calendarStyle: CalendarStyle(
  //       outsideDaysVisible: false,
  //       weekendStyle: TextStyle().copyWith(color: Colors.blue[800]),
  //       holidayStyle: TextStyle().copyWith(color: Colors.blue[800]),
  //     ),
  //     daysOfWeekStyle: DaysOfWeekStyle(
  //       weekendStyle: TextStyle().copyWith(color: Colors.blue[600]),
  //     ),
  //     headerStyle: HeaderStyle(
  //       centerHeaderTitle: true,
  //       formatButtonVisible: false,
  //     ),
  //     builders: CalendarBuilders(
  //       selectedDayBuilder: (context, date, _) {
  //         return FadeTransition(
  //           opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
  //           child: Container(
  //             margin: const EdgeInsets.all(4.0),
  //             padding: const EdgeInsets.only(top: 5.0, left: 6.0),
  //             color: Colors.deepOrange[300],
  //             width: 100,
  //             height: 100,
  //             child: Text(
  //               '${date.day}',
  //               style: TextStyle().copyWith(fontSize: 16.0),
  //             ),
  //           ),
  //         );
  //       },
  //       todayDayBuilder: (context, date, _) {
  //         return Container(
  //           margin: const EdgeInsets.all(4.0),
  //           padding: const EdgeInsets.only(top: 5.0, left: 6.0),
  //           color: Colors.amber[400],
  //           width: 100,
  //           height: 100,
  //           child: Text(
  //             '${date.day}',
  //             style: TextStyle().copyWith(fontSize: 16.0),
  //           ),
  //         );
  //       },
  //       markersBuilder: (context, date, events, holidays) {
  //         final children = <Widget>[];

  //         if (events.isNotEmpty) {
  //           children.add(
  //             Positioned(
  //               right: 1,
  //               bottom: 1,
  //               child: _buildEventsMarker(date, events),
  //             ),
  //           );
  //         }

  //         if (holidays.isNotEmpty) {
  //           children.add(
  //             Positioned(
  //               right: -2,
  //               top: -2,
  //               child: _buildHolidaysMarker(),
  //             ),
  //           );
  //         }

  //         return children;
  //       },
  //     ),
  //     onDaySelected: (date, events) {
  //       _onDaySelected(date, events);
  //       _animationController.forward(from: 0.0);
  //     },
  //     onVisibleDaysChanged: _onVisibleDaysChanged,
  //   );
  // }

  // Widget _buildEventsMarker(DateTime date, List events) {
  //   return AnimatedContainer(
  //     duration: const Duration(milliseconds: 300),
  //     decoration: BoxDecoration(
  //       shape: BoxShape.rectangle,
  //       color: _calendarController.isSelected(date)
  //           ? Colors.brown[500]
  //           : _calendarController.isToday(date)
  //               ? Colors.brown[300]
  //               : Colors.blue[400],
  //     ),
  //     width: 16.0,
  //     height: 16.0,
  //     child: Center(
  //       child: Text(
  //         '${events.length}',
  //         style: TextStyle().copyWith(
  //           color: Colors.white,
  //           fontSize: 12.0,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildHolidaysMarker() {
  //   return Icon(
  //     Icons.add_box,
  //     size: 20.0,
  //     color: Colors.blueGrey[800],
  //   );
  // }

  Widget _buildButtons() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: new SizedBox(
                height: 40.0,
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Event Name'),
                ),
              ),
            ),
            Expanded(
                child: SizedBox(
              height: 40.0,
              child: new GestureDetector(
                onTap: () {
                  _selectTime(context);
                },
                child: new Text('${_time.toString()}'),
              ),
            )),
            Expanded(
                child: SizedBox(
              height: 40.0,
              child: new GestureDetector(
                onTap: () {
                  _selectTime(context);
                },
                child: new Text('${_time.toString()}'),
              ),
            )),
          ],
        ),
        const SizedBox(height: 8.0),
        RaisedButton(
          child: Text('Add Event'),
          onPressed: () {
            // _calendarController.setSelectedDay(DateTime(2019, 7, 10),
            //     runCallback: true);
            showDialog(
              context: context,
              builder: (BuildContext context) => AddEvent(
                eventDate: _calendarController.selectedDay,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEventList() {
    return ListView(
      children: _selectedEvents
          .map((event) => Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.8),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: SizedBox(
                        height: 80,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: ListTile(
                          title: Text(event.toString()),
                          subtitle: Text('At ${event.toString()}'),
                          onTap: () => print('$event tapped!'),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        print('Delete Event ${event.toString()}');
                      },
                      child: Expanded(
                        child: SizedBox(
                          height: 20,
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class AddEvent extends StatefulWidget {
  final DateTime eventDate;
  AddEvent({@required this.eventDate});
  @override
  State<StatefulWidget> createState() {
    return _AddEventState(date: eventDate.toIso8601String());
  }
}

class _AddEventState extends State<AddEvent> {
  String date;
  TimeOfDay _time = TimeOfDay.now();
  _AddEventState({this.date});
  @override
  Widget build(BuildContext context) {
    return new Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      elevation: 2.0,
      backgroundColor: Colors.white,
      child: dialogContent(context),
    );
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked =
        await showTimePicker(context: context, initialTime: _time);

    if (picked != null) {
      print('Selected Time: ${_time.toString()}');
      setState(() {
        _time = picked;
      });
    }
  }

  Widget dialogContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Add Event",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: new SizedBox(
                    height: 60.0,
                    child: TextFormField(
                      maxLines: 1,
                      decoration: InputDecoration(
                          labelText: 'Event Name', alignLabelWithHint: true),
                    ),
                  ),
                ),
              ]),
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: SizedBox(
                    height: 40.0,
                    width: MediaQuery.of(context).size.width / 2.1,
                    child: new GestureDetector(
                      onTap: () {
                        _selectTime(context);
                      },
                      child: new RichText(
                          text: TextSpan(
                              text: 'Start Time:\n',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                              children: <TextSpan>[
                            TextSpan(
                                text:
                                    '${MaterialLocalizations.of(context).formatTimeOfDay(_time)}',
                                style: TextStyle(color: Colors.lightBlue))
                          ])),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 40.0,
                    width: MediaQuery.of(context).size.width / 2.1,
                    child: new GestureDetector(
                      onTap: () {
                        _selectTime(context);
                      },
                      child: new RichText(
                          text: TextSpan(
                              text: 'End Time:\n',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                              children: <TextSpan>[
                            TextSpan(
                                text:
                                    '${MaterialLocalizations.of(context).formatTimeOfDay(_time)}',
                                style: TextStyle(color: Colors.lightBlue))
                          ])),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RaisedButton(
                padding: EdgeInsets.all(10),
                child: Text('Add'),
                autofocus: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                onPressed: () {},
              )
            ],
          )
        ],
      ),
    );
  }
}
