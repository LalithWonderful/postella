import 'appliances.dart';
import 'books.dart';
import 'car_lease_transfer.dart';
import 'car_sale.dart';
import 'category.dart';
import 'electronics.dart';
import 'fashion.dart';
import 'furniture.dart';
import 'other.dart';
import 'real_estate.dart';

/// Catalogue MVP des catégories supportées par Postella, dans l'ordre
/// d'affichage souhaité dans l'UI.
///
/// Ajouter une catégorie = créer un fichier `<id>.dart` à côté, l'importer
/// ici et l'ajouter à la liste.
const List<Category> kCatalog = [
  fashionCategory,
  electronicsCategory,
  furnitureCategory,
  appliancesCategory,
  booksCategory,
  realEstateCategory,
  carSaleCategory,
  carLeaseTransferCategory,
  otherCategory,
];

/// Retourne la catégorie par son id, ou null si introuvable.
Category? findCategory(String id) {
  for (final category in kCatalog) {
    if (category.id == id) return category;
  }
  return null;
}
