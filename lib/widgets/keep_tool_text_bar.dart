import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/text_style_controller.dart';
import '../widgets/keep_text_color_bottom_sheet.dart';

class KeepToolTextBar extends StatelessWidget {
  const KeepToolTextBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TextStyleController>();

    return Material(
      elevation: 4,
      color: Color(0xFFF6FAF2),
      child: SizedBox(
        height: 52,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Obx(() => Row(
            children: [
              _btn(Icons.looks_one_outlined,
                      () => controller.heading.value = TextHeading.h1,
                  controller.heading.value == TextHeading.h1),
              _btn(Icons.looks_two_outlined,
                      () => controller.heading.value = TextHeading.h2,
                  controller.heading.value == TextHeading.h2),
              _btn(Icons.text_fields,
                      () => controller.heading.value = TextHeading.normal,
                  controller.heading.value == TextHeading.normal),
              const VerticalDivider(),
              _btn(Icons.format_bold,
                  controller.bold.toggle, controller.bold.value),
              _btn(Icons.format_italic,
                  controller.italic.toggle, controller.italic.value),
              _btn(Icons.format_underline,
                  controller.underline.toggle, controller.underline.value),
              const VerticalDivider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: TextStyleController.availableFonts.contains(
                            controller.fontFamily.value)
                        ? controller.fontFamily.value
                        : 'Default',
                    items: TextStyleController.availableFonts
                        .map(
                          (f) => DropdownMenuItem<String>(
                            value: f,
                            child: Text(
                              f,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      controller.fontFamily.value = val;
                    },
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  KeepTextColorBottomSheet.show(
                    context,
                    selectedColor: Color(controller.textColor.value),
                    onColorSelected: (c) =>
                        controller.textColor.value = c.toARGB32(),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.format_color_text, size: 20),
                      const SizedBox(width: 6),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Color(controller.textColor.value),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16,),
              IconButton(
                icon:Icon(Icons.close),
                onPressed: () {
                  controller.hideToolbar();
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
            ],
          )),
        ),
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap, bool active) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active ? Colors.grey.shade300 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}
