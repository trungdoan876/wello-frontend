import 'package:flutter/material.dart';

class AddFoodMethodScreen extends StatelessWidget {
  const AddFoodMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theo dõi lượng Calo'),
        leading: const Icon(Icons.arrow_back),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Chọn công cụ tốt nhất để theo dõi bữa ăn của bạn",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildOption(
              icon: Icons.camera_alt_outlined,
              title: "Quét AI",
              subtitle: "Có được thông tin chi tiết đầy đủ về bữa ăn trong một hình ảnh",
              color: Colors.green.shade100,
            ),
            const SizedBox(height: 10),
            const Text("Hoặc"),
            const SizedBox(height: 10),
            _buildOption(
              icon: Icons.search,
              title: "Tìm kiếm thức ăn",
              subtitle: "Thêm bữa ăn từ cơ sở dữ liệu thực phẩm của chúng tôi",
            ),
            const SizedBox(height: 10),
            _buildOption(
              icon: Icons.qr_code,
              title: "Quét mã vạch",
              subtitle: "Nhận thông tin chi tiết về sản phẩm",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
