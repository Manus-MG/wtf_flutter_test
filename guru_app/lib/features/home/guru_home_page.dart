import 'package:flutter/material.dart';

import 'package:wtf_shared/shared.dart';

class GuruHomePage extends StatelessWidget {
  const GuruHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = <_HomeCard>[
      const _HomeCard(
          title: 'Chat with Trainer', icon: Icons.chat_bubble_outline),
      const _HomeCard(
          title: 'Schedule Call', icon: Icons.calendar_month_outlined),
      const _HomeCard(title: 'My Sessions', icon: Icons.receipt_long_outlined),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guru • DK'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: AppRoleBadge(label: 'Member', color: Color(0xFF1769E0)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SectionCard(
              title: 'Welcome back, DK',
              child: Text(
                'Your trainer workspace is ready. Start with chat, schedule a call, or review your sessions.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: cards.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: ListTile(
                      leading: Icon(card.icon, color: const Color(0xFF1769E0)),
                      title: Text(card.title),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCard {
  const _HomeCard({required this.title, required this.icon});

  final String title;
  final IconData icon;
}
