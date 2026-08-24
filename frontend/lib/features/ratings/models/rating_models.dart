/// Person 5 — Ratings module data model
class Review {
  final String reviewerName;
  final int stars;
  final String? text;
  final String date;

  const Review({
    required this.reviewerName,
    required this.stars,
    this.text,
    required this.date,
  });
}