import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mu_fest/event_detail.dart';
import 'package:mu_fest/model/event.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Event> events = [];
  String selectedCategory = 'All';
  String selectedDepartment = 'All';
  String selectedDate = 'All';
  bool showCurrentEvents = false;
  List<String> departmentOptions = ['All'];

  @override
  void initState() {
    super.initState();
    loadEvents().then((loadedEvents) {
      setState(() {
        events = loadedEvents;
        departmentOptions
            .addAll(Set.from(events.map((event) => event.department)));
      });
    });
  }

  Future<List<Event>> loadEvents() async {
    try {
      String jsonData = await rootBundle.loadString('assets/data/data.json');

      if (jsonData != null) {
        List<dynamic> jsonList = json.decode(jsonData);
        List<Event> loadedEvents = jsonList.map((json) {
          return Event(
            id: json['id'],
            department: json['department'],
            eventName: json['eventName'],
            date: List<String>.from(json['date'] ?? []),
            startTime: List<String>.from(json['startTime'] ?? []),
            endTime: List<String>.from(json['endTime'] ?? []),
            location: List<String>.from(json['location'] ?? []),
            coordinatorNames: List<String>.from(json['coordinatorNames'] ?? []),
            type: json['type'],
          );
        }).toList();
        return loadedEvents;
      } else {
        print('Failed to load data. JSON data is null.');
        return [];
      }
    } catch (e) {
      print('Failed to load data. Error: $e');
      return [];
    }
  }

  List<Event> getFilteredEvents() {
    return events.where((event) {
      bool departmentMatches =
          selectedDepartment == 'All' || event.department == selectedDepartment;
      bool categoryMatches =
          selectedCategory == 'All' || event.type == selectedCategory;
      bool currentEventsMatch = !showCurrentEvents || isCurrentEvent(event);
      bool dateMatches =
          selectedDate == 'All' || event.date.contains(selectedDate);

      return departmentMatches &&
          categoryMatches &&
          currentEventsMatch &&
          dateMatches;
    }).toList();
  }

  bool isCurrentEvent(Event event) {
    DateTime now = DateTime.now();

    for (int i = 0; i < event.startTime.length; i++) {
      // Check if the start time is "Full day/Anytime"
      if (event.startTime[i] == "Full day/Anytime") {
        // If it's "Full day/Anytime", consider it as a current event
        return true;
      }

      // Otherwise, parse the start and end times as before
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime eventStartTime = parseEventTime(event.startTime[i]);
      DateTime eventEndTime = parseEventTime(event.endTime[i]);

      eventStartTime = DateTime(
        today.year,
        today.month,
        today.day,
        eventStartTime.hour,
        eventStartTime.minute,
      );
      eventEndTime = DateTime(
        today.year,
        today.month,
        today.day,
        eventEndTime.hour,
        eventEndTime.minute,
      );

      if (now.isAfter(eventStartTime) && now.isBefore(eventEndTime)) {
        return true;
      }
    }

    return false;
  }

  DateTime parseEventTime(String timeString) {
    if (timeString == "Full day/Anytime") {
      // For "Full day/Anytime", return a DateTime representing the start of the day
      return DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
    } else {
      // Split the time string into hours and minutes
      List<String> parts = timeString.split(' ');

      // Check if the parts list has at least two elements
      if (parts.length >= 2) {
        String timePart = parts[0];
        String periodPart = parts[1];

        // If the time part contains a colon, it's in hours:minutes format
        if (timePart.contains(':')) {
          List<String> hourMinute = timePart.split(':');
          int hour = int.parse(hourMinute[0]);
          int minute = int.parse(hourMinute[1]);

          // Adjust hour if it's PM and not 12 (since 12 PM is already correct)
          if (periodPart == 'PM' && hour != 12) {
            hour += 12;
          }

          // Return the parsed time as a DateTime
          return DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day, hour, minute);
        } else {
          // Handle other time formats as needed
          // For example, handle "2 PM" differently
          // You can add more cases as required
          if (timePart == '2') {
            // Handle "2 PM" separately
            return DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day, 14, 0);
          }
        }
      }
    }

    // Default return statement
    return DateTime.now(); // Or any other default value you want to return
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 52, 171, 231),
        title: Text(
          'Events',
          style: TextStyle(fontFamily: 'Mooli', fontSize: 24),
        ),
        actions: [
          DropdownButton<String>(
            value: selectedCategory,
            onChanged: (value) {
              setState(() {
                selectedCategory = value!;
              });
            },
            items: [
              DropdownMenuItem(
                value: 'All',
                child: Text('All', style: TextStyle(fontFamily: 'Mooli')),
              ),
              DropdownMenuItem(
                value: 'Tech',
                child: Text('Tech', style: TextStyle(fontFamily: 'Mooli')),
              ),
              DropdownMenuItem(
                value: 'NonTech',
                child: Text('Non-Tech', style: TextStyle(fontFamily: 'Mooli')),
              ),
              DropdownMenuItem(
                value: 'Fun',
                child: Text('Fun', style: TextStyle(fontFamily: 'Mooli')),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              _showFilterDialog();
            },
            icon: Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: () {
              _refreshEvents();
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: getFilteredEvents().length,
                itemBuilder: (context, index) {
                  final event = getFilteredEvents()[index];
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        event.eventName,
                        style: TextStyle(
                          fontFamily: 'Mooli',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 2),
                          Text(
                            'Type: ${event.type}',
                            style: TextStyle(
                              fontFamily: 'Mooli',
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 1),
                          _buildDetailRow("Date:", event.date)
                        ],
                      ),
                      onTap: () {
                        Get.to(() => EventDetailsPage(event: event));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title:
                  Text('Filter Events', style: TextStyle(fontFamily: 'Mooli')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Department:', style: TextStyle(fontFamily: 'Mooli')),
                    DropdownButtonFormField<String>(
                      value: selectedDepartment,
                      onChanged: (value) {
                        setState(() {
                          selectedDepartment = value!;
                        });
                      },
                      items: departmentOptions.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option,
                              style: TextStyle(fontFamily: 'Mooli')),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('Date:', style: TextStyle(fontFamily: 'Mooli')),
                    DropdownButtonFormField<String>(
                      value: selectedDate,
                      onChanged: (value) {
                        setState(() {
                          selectedDate = value!;
                        });
                      },
                      items: ['All', '13-03-24', '14-03-24', '15-03-24']
                          .map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option,
                              style: TextStyle(fontFamily: 'Mooli')),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    CheckboxListTile(
                      title: Text(
                        'Show Current Running Events',
                        style: TextStyle(fontFamily: 'Mooli'),
                      ),
                      value: showCurrentEvents,
                      onChanged: (value) {
                        setState(() {
                          showCurrentEvents = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text('Cancel', style: TextStyle(fontFamily: 'Mooli')),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {});
                    Get.back();
                  },
                  child: Text('Done', style: TextStyle(fontFamily: 'Mooli')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, List<String> values) {
    String formattedValues =
        values.join(', '); // Join dates with a comma separator
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Mooli',
            ),
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              formattedValues,
              style: TextStyle(
                fontSize: 16.0,
                fontFamily: 'Mooli',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _refreshEvents() {
    loadEvents().then((loadedEvents) {
      setState(() {
        events = loadedEvents;
      });
    });
  }
}
