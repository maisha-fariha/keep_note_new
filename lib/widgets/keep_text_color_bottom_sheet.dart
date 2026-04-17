import 'package:flutter/material.dart';

class KeepTextColorBottomSheet {
  static const List<Color> _palette = <Color>[
    Colors.black,
    Color(0xFF424242),
    Colors.blueGrey,
    Colors.indigo,
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.orange,
    Colors.deepOrange,
    Colors.red,
    Colors.purple,
    Colors.brown,
    Colors.white,
  ];

  static void show(
    BuildContext context, {
    required Color selectedColor,
    required ValueChanged<Color> onColorSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF6FAF2),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Text color',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _palette.map((c) {
                  final isSelected = c.toARGB32() == selectedColor.toARGB32();
                  return GestureDetector(
                    onTap: () {
                      onColorSelected(c);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey.shade500,
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 18,
                              color: c.computeLuminance() > 0.55
                                  ? Colors.black
                                  : Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

