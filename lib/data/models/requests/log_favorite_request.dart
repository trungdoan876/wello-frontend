class LogFavoriteRequest {
  final int userId;
  final int favoriteId;
  final String date;
  final String mealType;

  LogFavoriteRequest({
    required this.userId,
    required this.favoriteId,
    required this.date,
    required this.mealType,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'favoriteId': favoriteId,
      'date': date,
      'mealType': mealType,
    };
  }
}
