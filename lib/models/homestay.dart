class Homestay {
  final String id;
  final String name;
  final String state;
  final String district;
  final double price;
  final String description;
  final String imageUrl;

  const Homestay({
    required this.id,
    required this.name,
    required this.state,
    required this.district,
    required this.price,
    required this.description,
    required this.imageUrl,
  });

  factory Homestay.fromJson(Map<String, dynamic> json) {
    return Homestay(
      id: (json["id"] ?? "").toString(),
      name: (json["name"] ?? "No Name").toString(),
      state: (json["state"] ?? "Unknown State").toString(),
      district: (json["district"] ?? "Unknown District").toString(),
      price: double.tryParse(json["price"].toString()) ?? 0.0,
      description: (json["description"] ?? "No description available.")
          .toString(),
      imageUrl: (json["image"] ?? json["image_url"] ?? "").toString(),
    );
  }
}
