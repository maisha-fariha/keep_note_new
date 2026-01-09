import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/color_controller.dart';
import 'keep_color_picker.dart';

class KeepColorBottomSheet {
  static void show(BuildContext context) {
    final colorController = Get.find<ColorController>();

    // Save the current color so we can revert if cancelled
    // final previousColor = colorController.selectedColor.value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 12),
              Obx(
                    () => KeepColorPicker(
                  selectedColor: colorController.selectedColor.value,
                  onColorSelected: colorController.changeColor,
                ),
              ),
               SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // Revert color if cancelled
                      // colorController.selectedColor.value = previousColor;
                      Navigator.pop(context);
                    },
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      // Commit color and close sheet
                      Navigator.pop(context);
                    },
                    child:Text("Done"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
