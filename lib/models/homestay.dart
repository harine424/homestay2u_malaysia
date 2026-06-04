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
    // Looking specifically for the 'price_min' column from your lecturer's database
    var rawPrice = json["price_min"] ?? json["price"] ?? "0";

    // Clean it up just in case there are letters
    var cleanPrice = rawPrice.toString().replaceAll(RegExp(r'[^0-9\.]'), '');

    return Homestay(
      id: (json["id"] ?? "").toString(),
      name: (json["name"] ?? "No Name").toString(),
      state: (json["state"] ?? "Unknown State").toString(),
      district: (json["district"] ?? "Unknown District").toString(),
      price: double.tryParse(cleanPrice) ?? 0.0,
      description: (json["description"] ?? "No description available.")
          .toString(),
      imageUrl: (json["image_url"] ?? json["image"] ?? "").toString(),
    );
  }
}
