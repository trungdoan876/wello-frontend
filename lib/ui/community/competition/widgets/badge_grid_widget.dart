import 'package:flutter/material.dart' hide Badge;
import 'package:provider/provider.dart';
import '../../../../domain/providers/profile_provider.dart';
import '../../../../domain/providers/competition_provider.dart';
import '../../../../core/utils/auth_helper.dart';
import '../../../../domain/entities/badge.dart' as entity;

class BadgeGridWidget extends StatelessWidget {
  final List<entity.Badge> badges;

  const BadgeGridWidget({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        return BadgeItem(badge: badges[index]);
      },
    );
  }
}

class BadgeItem extends StatelessWidget {
  final entity.Badge badge;

  const BadgeItem({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showBadgeDetails(context, badge),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: badge.isUnlocked ? Colors.white : Colors.grey[50],
              shape: BoxShape.circle,
              boxShadow: badge.isUnlocked
                  ? [
                      BoxShadow(
                        color: const Color(0xFFEBCF23).withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
              border: badge.isUnlocked 
                  ? Border.all(color: const Color(0xFFEBCF23), width: 2.5)
                  : Border.all(color: Colors.grey[300]!, width: 1.5),
            ),
            child: Opacity(
              opacity: badge.isUnlocked ? 1.0 : 0.4,
              child: Image.network(
                badge.iconUrl,
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.emoji_events, 
                  size: 50, 
                  color: badge.isUnlocked ? const Color(0xFFEBCF23) : Colors.grey[400],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: badge.isUnlocked ? FontWeight.w900 : FontWeight.bold,
              color: badge.isUnlocked ? const Color(0xFF3F3D3F) : const Color(0xFF7D7A7D),
            ),
          ),
        ],
      ),
    );
  }

  static void showBadgeDetails(BuildContext context, entity.Badge badge) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: badge.isUnlocked ? Colors.amber.withOpacity(0.1) : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Opacity(
                opacity: badge.isUnlocked ? 1.0 : 0.4,
                child: Image.network(
                  badge.iconUrl,
                  width: 100,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.emoji_events, 
                    size: 100, 
                    color: badge.isUnlocked ? const Color(0xFFEBCF23) : Colors.grey[400]
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              badge.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF7D7A7D), fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Điều kiện: ${badge.criteria}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (badge.isUnlocked) ...[
              Text(
                badge.unlockedAt != null
                    ? 'Đã đạt được vào: ${badge.unlockedAt!.day.toString().padLeft(2, '0')}/${badge.unlockedAt!.month.toString().padLeft(2, '0')}/${badge.unlockedAt!.year}'
                    : 'Đã đạt được',
                style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 20),
              Consumer<ProfileProvider>(
                builder: (context, profileProvider, _) {
                  final isEquipped = profileProvider.profileData?.equippedBadgeId?.toString() == badge.id;
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final credentials = await AuthHelper.getCredentials();
                        final token = credentials?.token ?? '';
                        final userId = credentials?.userId;
                        if (token.isEmpty || userId == null) return;

                        final compProvider = Provider.of<CompetitionProvider>(context, listen: false);
                        bool success;
                        if (isEquipped) {
                          success = await compProvider.unequipBadge(token);
                        } else {
                          success = await compProvider.equipBadge(token, int.parse(badge.id));
                        }

                        if (success) {
                          // Reload profile data to update equipped badge
                          await profileProvider.loadProfile(userId);
                          if (context.mounted) {
                            Navigator.pop(context); // Close bottom sheet
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEquipped 
                                      ? 'Đã hủy trang bị huy hiệu! 🏅' 
                                      : 'Đã trang bị huy hiệu thành công! 🏅',
                                ),
                                backgroundColor: const Color(0xFF22C55E),
                              ),
                            );
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã xảy ra lỗi, vui lòng thử lại!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEquipped ? Colors.grey[300] : const Color(0xFFEBCF23),
                        foregroundColor: isEquipped ? Colors.grey[700] : const Color(0xFF2D2D2D),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        isEquipped ? 'Hủy trang bị' : 'Trang bị',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ] else
              const Text(
                'Chưa đạt được',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
