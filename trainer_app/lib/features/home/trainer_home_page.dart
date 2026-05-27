import 'package:flutter/material.dart';

import 'package:wtf_shared/shared.dart';

class TrainerHomePage extends StatelessWidget {
  const TrainerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_TileItem>[
      const _TileItem('Members', Icons.people_outline),
      const _TileItem('Chats', Icons.chat_outlined),
      const _TileItem('Requests', Icons.rule_folder_outlined),
      const _TileItem('Sessions', Icons.event_note_outlined),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainer • Aarav'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: AppRoleBadge(label: 'Trainer', color: Color(0xFFE50914)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {},
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, size: 34, color: const Color(0xFFE50914)),
                    const SizedBox(height: 12),
                    Text(item.label,
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TileItem {
  const _TileItem(this.label, this.icon);

  final String label;
  final IconData icon;
}
