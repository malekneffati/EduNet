import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminSidebarViewModel extends ChangeNotifier {
  int _selectedIndex = 0;
  final List<String> _menuItems = [
    'Vue d\'ensemble',
    'Cours',
    'Utilisateurs',
    'Paiements',
    'Promotions',
  ];

  int get selectedIndex => _selectedIndex;
  List<String> get menuItems => _menuItems;

  void selectItem(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  String getSelectedItem() {
    return _menuItems[_selectedIndex];
  }
}

// Provider for AdminSidebarViewModel
final adminSidebarProvider = ChangeNotifierProvider<AdminSidebarViewModel>((ref) {
  return AdminSidebarViewModel();
});