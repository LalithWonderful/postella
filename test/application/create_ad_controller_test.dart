import 'package:flutter_test/flutter_test.dart';
import 'package:postella/application/create_ad_controller.dart';

void main() {
  group('CreateAdController', () {
    test('setCategory réinitialise le draft avec la catégorie choisie', () {
      final c = CreateAdController()
        ..addPhotos(['/tmp/old.jpg'])
        ..setField('brand', 'Apple');

      c.setCategory('electronics');

      expect(c.state.categoryId, 'electronics');
      expect(c.state.photos, isEmpty);
      expect(c.state.details, isEmpty);
    });

    test('addPhotos accumule sans écraser', () {
      final c = CreateAdController()
        ..setCategory('fashion')
        ..addPhotos(['/tmp/a.jpg'])
        ..addPhotos(['/tmp/b.jpg', '/tmp/c.jpg']);

      expect(c.state.photos, ['/tmp/a.jpg', '/tmp/b.jpg', '/tmp/c.jpg']);
    });

    test('removePhoto retire le chemin demandé', () {
      final c = CreateAdController()
        ..setCategory('fashion')
        ..addPhotos(['/tmp/a.jpg', '/tmp/b.jpg']);

      c.removePhoto('/tmp/a.jpg');

      expect(c.state.photos, ['/tmp/b.jpg']);
    });

    test('setField supprime la clé si la valeur est null ou vide', () {
      final c = CreateAdController()
        ..setCategory('fashion')
        ..setField('brand', 'Levi\'s');

      expect(c.state.details['brand'], 'Levi\'s');

      c.setField('brand', null);
      expect(c.state.details.containsKey('brand'), isFalse);

      c.setField('brand', '');
      expect(c.state.details.containsKey('brand'), isFalse);
    });

    test('reset remet à zéro', () {
      final c = CreateAdController()
        ..setCategory('fashion')
        ..addPhotos(['/tmp/a.jpg']);

      c.reset();

      expect(c.state.categoryId, isNull);
      expect(c.state.photos, isEmpty);
      expect(c.state.details, isEmpty);
    });
  });
}
