import 'package:flutter/material.dart';

import '../models/homestay.dart';
import 'homestay_detail_screen.dart';

class HomestayCard extends StatelessWidget {
  final Homestay homestay;

  const HomestayCard({super.key, required this.homestay});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomestayDetailScreen(homestay: homestay),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (homestay.imageUrl.isNotEmpty)
              Image.network(
                homestay.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(),
              )
            else
              _buildPlaceholder(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    homestay.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${homestay.district}, ${homestay.state}",
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "RM ${homestay.price.toStringAsFixed(2)} / night",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Icon(Icons.image, size: 50, color: Colors.grey),
    );
  }
}
