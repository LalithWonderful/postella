import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../application/create_ad_controller.dart';
import '../../domain/categories/catalog.dart';
import '../router.dart';
import '../widgets/photo_tip_card.dart';
import '../widgets/primary_button.dart';

class PhotosPage extends ConsumerStatefulWidget {
  const PhotosPage({super.key});

  @override
  ConsumerState<PhotosPage> createState() => _PhotosPageState();
}

class _PhotosPageState extends ConsumerState<PhotosPage> {
  final _picker = ImagePicker();
  bool _picking = false;

  Future<void> _pickFromCamera() => _pick(ImageSource.camera);

  Future<void> _pickFromGallery() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final files = await _picker.pickMultiImage(imageQuality: 85);
      if (files.isEmpty) return;
      ref
          .read(createAdControllerProvider.notifier)
          .addPhotos(files.map((f) => f.path).toList());
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _pick(ImageSource source) async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final file = await _picker.pickImage(source: source, imageQuality: 85);
      if (file == null) return;
      ref.read(createAdControllerProvider.notifier).addPhotos([file.path]);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(createAdControllerProvider);
    final categoryId = draft.categoryId;
    if (categoryId == null) {
      // Sécurité : si on atterrit ici sans catégorie sélectionnée, on renvoie
      // l'utilisateur au picker plutôt que d'afficher un état cassé.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.createCategory);
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    final category = kCatalog.firstWhere((c) => c.id == categoryId);
    final theme = Theme.of(context);
    final canContinue = draft.photos.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(category.label)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Ajoute des photos',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Au moins une photo nette est nécessaire pour générer une annonce.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PhotoGrid(
                    paths: draft.photos,
                    onRemove: (path) => ref
                        .read(createAdControllerProvider.notifier)
                        .removePhoto(path),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _picking ? null : _pickFromCamera,
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: const Text('Caméra'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _picking ? null : _pickFromGallery,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Galerie'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Conseils photo',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final tip in category.photoTips) ...[
                    PhotoTipCard(tip: tip),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: PrimaryButton(
                label: 'Continuer',
                onPressed: canContinue
                    ? () => context.push(AppRoutes.createDetails)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.paths, required this.onRemove});

  final List<String> paths;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    if (paths.isEmpty) {
      final theme = Theme.of(context);
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          'Aucune photo pour le moment',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: paths.length,
      itemBuilder: (context, i) {
        final path = paths[i];
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(File(path), fit: BoxFit.cover),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => onRemove(path),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
