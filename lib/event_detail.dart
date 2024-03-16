import 'package:flutter/material.dart';
import 'package:mu_fest/model/event.dart';

class EventDetailsPage extends StatelessWidget {
  final Event event;

  EventDetailsPage({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 52, 171, 231),
        title: Text('Event Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.eventName,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Mooli',
                  ),
                ),
                SizedBox(height: 16.0),
                _buildDetailRow('Department', event.department),
                _buildDetailRow('Event Name', event.eventName),
                _buildDetailRow('Date', _buildDateText(event.date)),
                _buildDetailRow(
                    'Timing', _buildTimingText(event.startTime, event.endTime)),
                _buildDetailRow('Location', _buildLocationText(event.location)),
                _buildDetailRow('Coordinator',
                    _buildCoordinatorText(event.coordinatorNames)),
                _buildDetailRow('Type', event.type),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildDateText(List<String> dates) {
    return dates.join(', ');
  }

  String _buildTimingText(List<String> startTimes, List<String> endTimes) {
    List<String> timingList = [];
    for (int i = 0; i < startTimes.length; i++) {
      timingList.add('${startTimes[i]} to ${endTimes[i]}');
    }
    return timingList.join(', ');
  }

  String _buildLocationText(List<String> locations) {
    return locations.join(', ');
  }

  String _buildCoordinatorText(List<String> coordinatorNames) {
    return coordinatorNames.join(', ');
  }

  Widget _buildDetailRow(String label, String value) {
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
              value,
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
}
