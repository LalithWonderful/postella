import 'package:flutter/material.dart';

/// Résout une clé d'icône stockée dans le catalogue (`Category.iconKey`,
/// `PhotoTip.iconKey`) en `IconData`. Centralisé ici pour éviter de polluer
/// les fichiers domaine avec un import Material.
IconData iconFor(String key) {
  switch (key) {
    case 'checkroom':
      return Icons.checkroom;
    case 'devices':
      return Icons.devices;
    case 'chair':
      return Icons.chair;
    case 'kitchen':
      return Icons.kitchen;
    case 'menu_book':
      return Icons.menu_book;
    case 'home':
      return Icons.home;
    case 'directions_car':
      return Icons.directions_car;
    case 'sync_alt':
      return Icons.sync_alt;
    case 'category':
      return Icons.category;
    case 'wb_sunny':
      return Icons.wb_sunny;
    case 'photo_camera':
      return Icons.photo_camera;
    case 'photo_camera_front':
      return Icons.photo_camera_front;
    case 'flip_camera_ios':
      return Icons.flip_camera_ios;
    case 'expand':
      return Icons.expand;
    case 'report_problem':
      return Icons.report_problem;
    case 'inventory_2':
      return Icons.inventory_2;
    case 'do_not_disturb_on':
      return Icons.do_not_disturb_on;
    case 'power_settings_new':
      return Icons.power_settings_new;
    case 'badge':
      return Icons.badge;
    case 'door_front':
      return Icons.door_front_door;
    case 'local_offer':
      return Icons.local_offer;
    case 'zoom_in':
      return Icons.zoom_in;
    case 'book':
      return Icons.book;
    case 'flip_to_back':
      return Icons.flip_to_back;
    case 'view_agenda':
      return Icons.view_agenda;
    case 'edit_note':
      return Icons.edit_note;
    case 'apartment':
      return Icons.apartment;
    case 'weekend':
      return Icons.weekend;
    case 'bed':
      return Icons.bed;
    case 'bathtub':
      return Icons.bathtub;
    case 'landscape':
      return Icons.landscape;
    case 'architecture':
      return Icons.architecture;
    case 'straighten':
      return Icons.straighten;
    case 'airline_seat_recline_normal':
      return Icons.airline_seat_recline_normal;
    case 'speed':
      return Icons.speed;
    case 'arrow_left':
      return Icons.arrow_left;
    case 'arrow_right':
      return Icons.arrow_right;
    case 'description':
      return Icons.description;
    default:
      return Icons.label_outline;
  }
}
