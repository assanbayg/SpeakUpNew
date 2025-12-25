import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:speakup/common/widgets/appbar.dart';
import 'package:speakup/features/speakup/controllers/sprite_controller.dart';
import 'package:speakup/services/sprite_service.dart';
import 'package:speakup/util/constants/colors.dart';
import 'package:speakup/util/constants/sizes.dart';
import 'package:speakup/util/helpers/supabase_helper.dart';

class SpritesScreen extends StatelessWidget {
  const SpritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SpriteController());

    return Scaffold(
      appBar: const SAppBar(
        title: 'Мои персонажи',
        page: 'Sprites',
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadSprites(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(SSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload section
              _buildUploadSection(context, controller),
              const SizedBox(height: SSizes.spaceBtwSections),

              // Available sprites section
              Text(
                'Доступные персонажи',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: SSizes.spaceBtwItems),
              _buildSpritesGrid(context, controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadSection(
      BuildContext context, SpriteController controller) {
    return Container(
      padding: const EdgeInsets.all(SSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: SColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset(
                  'assets/icons/Add_Person.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    SColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Загрузить рисунок',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      'Отправьте свой рисунок на проверку',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SSizes.spaceBtwItems),
          Obx(() {
            if (controller.isUploading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return Row(
              children: [
                Expanded(
                  child: _buildUploadButton(
                    context: context,
                    icon: 'assets/icons/Camera.svg',
                    label: 'Камера',
                    onTap: () => controller.pickFromCamera(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildUploadButton(
                    context: context,
                    icon: 'assets/icons/Document.svg',
                    label: 'Галерея',
                    onTap: () => controller.pickFromGallery(),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: SSizes.sm),
          Text(
            'После проверки рисунок появится в списке доступных персонажей',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton({
    required BuildContext context,
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: SColors.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                icon,
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  SColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: SColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpritesGrid(BuildContext context, SpriteController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      final sprites = controller.availableSprites;
      final userId = SSupabaseHelper.currentUser?.id;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: sprites.length + 1, // +1 for default Speechy
        itemBuilder: (context, index) {
          if (index == 0) {
            // Default Speechy character
            return _buildSpriteCard(
              context: context,
              isDefault: true,
              isSelected: controller.isUsingDefault,
              onTap: () => controller.useDefaultCharacter(),
            );
          }

          final filename = sprites[index - 1];
          final imageUrl = userId != null
              ? SpriteService.getSpriteImageUrl(userId, filename)
              : null;

          return _buildSpriteCard(
            context: context,
            imageUrl: imageUrl,
            filename: filename,
            isSelected: controller.isSelected(filename),
            onTap: () => controller.selectSprite(filename),
          );
        },
      );
    });
  }

  Widget _buildSpriteCard({
    required BuildContext context,
    bool isDefault = false,
    String? imageUrl,
    String? filename,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? SColors.primary : Colors.grey.shade200,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? SColors.primary.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: isDefault
                  ? Image.asset(
                      'assets/images/speechy_default.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                color: Colors.grey.shade400,
                                size: 40,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ошибка загрузки',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Selection indicator
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: SColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),

            // Label at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                child: Text(
                  isDefault
                      ? 'Спичи (по умолчанию)'
                      : _formatFilename(filename!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFilename(String filename) {
    // Remove extension and clean up
    final name = filename.split('.').first;
    return name.replaceAll('_', ' ').replaceAll('-', ' ');
  }
}
