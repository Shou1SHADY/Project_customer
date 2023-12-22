class HistoryItem {
  final String userId;
  final String source;
  final String destination;
  final String tripState;
  final String time;
  final int price;
  final String driver;

  HistoryItem({
    required this.userId,
    required this.source,
    required this.destination,
    required this.tripState,
    required this.time,
    required this.price,
    required this.driver,
  });
}
