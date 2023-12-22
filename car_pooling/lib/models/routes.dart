class Route implements Comparable<Route> {
  String id = ""; // Add a field for document ID
  String userId = ""; // Add a field for user ID
  String fromRoute = "";
  String toRoute = "";
  int price = 0;
  int rating = 2;
  String departureDate = "";
  String tripState = "Pending";

  Route(
      {required this.fromRoute,
      required this.toRoute,
      required this.price,
      this.rating = 3,
      this.departureDate = "7:30 am",
      String id = "",
      String userId = "",
      String tripState = ""});

  // Constructor for creating a Route instance from Firestore data
  Route.fromFirestore(Map<String, dynamic> data)
      : id = data['userId'] ?? "1",
        userId = data['userId'] ?? "1",
        fromRoute = data['source'] ?? "Gate3/4",
        toRoute = data['destination'] ?? "Mohandessin",
        price = data['price'] ?? 10,
        rating = data['rating'] ?? 3, // Use a default rating if not provided
        departureDate = data['time'] ?? "7:30am", // Default time
        tripState = data['tripState'] ?? "Pending"; // Default state

  // Constructor for creating a Route instance for adding to Firestore
  Route.forFirestore({
    required this.userId,
    required this.fromRoute,
    required this.toRoute,
    required this.price,
    this.rating = 3,
    this.departureDate = "7:30 am",
    this.tripState = "Pending",
  });

  // Method to convert Route instance to a map for Firestore
  Map<String, dynamic> toFirestoreMap() {
    return {
      "id": userId,
      'userId': userId,
      'fromRoute': fromRoute,
      'toRoute': toRoute,
      'price': price,
      'rating': rating,
      'departureDate': departureDate,
      'tripState': tripState,
    };
  }

  @override
  int compareTo(Route other) => fromRoute.compareTo(other.fromRoute);
}
