import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/qari.dart';
import '../state/app_settings.dart';

class QariPickerSheet extends StatelessWidget {
  const QariPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final selected = settings.selectedQariKey;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.headphones_rounded),
                const SizedBox(width: 8),
                Text("Pilih Qari", style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 8),
            ...qariOptions.map((q) {
              return RadioListTile<String>(
                value: q.key,
                groupValue: selected,
                onChanged: (v) {
                  if (v == null) return;
                  settings.setQariKey(v);
                  Navigator.pop(context);
                },
                title: Text(q.name),
                subtitle: Text("Kode: ${q.key}"),
              );
            }),
          ],
        ),
      ),
    );
  }
}
