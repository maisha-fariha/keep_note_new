import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/text_style_controller.dart';

class KeepToolTextBar extends StatelessWidget {
  const KeepToolTextBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TextStyleController>();

    return Material(
      elevation: 4,
      color: Color(0xFFF6FAF2),
      child: SizedBox(
        height: 48,
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
