class Event {
  final String id;
  final String department;
  final String eventName;
  final List<String> date;
  final List<String> startTime;
  final List<String> endTime;
  final List<String> location;
  final List<String> coordinatorNames;
  final String type;

  Event({
    required this.id,
    required this.department,
    required this.eventName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.coordinatorNames,
    required this.type,
  });
}
