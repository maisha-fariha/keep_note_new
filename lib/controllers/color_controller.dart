import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ColorController extends GetxController{
  Rx<Color> selectedColor = Colors.white.obs;

  void changeColor(Color color) {
    selectedColor.value = color;
  }
  void reset() {
    selectedColor.value = Colors.white;
  }
}