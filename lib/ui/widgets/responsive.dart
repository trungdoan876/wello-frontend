// lib/utils/responsive.dart
//% màn hình thay vì số cố định
// lấy kích thước màn hình sau đó nhân với % để điều chỉnh kích thước responsive
import 'package:flutter/material.dart';

extension Responsive on BuildContext {
  double w(double percent) => MediaQuery.of(this).size.width * percent; // % chiều rộng màn hình
  double h(double percent) => MediaQuery.of(this).size.height * percent; // % chiều cao màn hình
  double sp(double percent) => MediaQuery.of(this).size.shortestSide * percent / 100; // % fontSize theo màn hình 
}