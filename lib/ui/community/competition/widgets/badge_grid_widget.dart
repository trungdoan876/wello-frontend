import 'package:flutter/material.dart' hide Badge;
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
      onTap: () => _showBadgeDetails(context),
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

  void _showBadgeDetails(BuildContext context) {
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
            if (badge.isUnlocked)
              Text(
                'Đã đạt được vào: ${badge.unlockedAt?.day}/${badge.unlockedAt?.month}/${badge.unlockedAt?.year}',
                style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.w900, fontSize: 16),
              )
            else
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
