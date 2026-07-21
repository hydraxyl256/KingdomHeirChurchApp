import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/widgets/app_button.dart';
import 'package:kingdom_heir/core/widgets/app_text_field.dart';
import 'package:kingdom_heir/features/profile/presentation/providers/profile_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _picker = ImagePicker();
  bool _isSaving = false;
  bool _isUploadingAvatar = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile == null) return;

    setState(() => _isUploadingAvatar = true);

    final error = await ref
        .read(currentProfileProvider.notifier)
        .uploadAndUpdateAvatar(File(pickedFile.path));

    if (mounted) {
      setState(() => _isUploadingAvatar = false);
      if (error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  AppLocalizations.of(context)!.avatarUpdatedSuccessfully,),),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    final error =
        await ref.read(currentProfileProvider.notifier).updateProfileInfo(
              fullName: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
            );

    if (mounted) {
      setState(() => _isSaving = false);
      if (error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.profileSavedSuccessfully),),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myProfile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: AppLocalizations.of(context)!.settings,
            onPressed: () => context.push(RouteNames.settings),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (profile) {
          // Initialize controllers if empty
          if (_nameController.text.isEmpty && profile.fullName.isNotEmpty) {
            _nameController.text = profile.fullName;
          }
          if (_phoneController.text.isEmpty && profile.phone != null) {
            _phoneController.text = profile.phone!;
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              // Avatar Section
              Builder(
                builder: (context) {
                  final scheme = Theme.of(context).colorScheme;
                  return Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              scheme.primary.withValues(alpha: 0.2),
                          backgroundImage: profile.avatarUrl != null
                              ? NetworkImage(profile.avatarUrl!)
                              : null,
                          child: profile.avatarUrl == null
                              ? Text(
                                  profile.fullName.isNotEmpty
                                      ? profile.fullName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 40,
                                    color: scheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        if (_isUploadingAvatar)
                          Positioned.fill(
                            child: Center(
                              child: CircularProgressIndicator(
                                color: scheme.primary,
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _isUploadingAvatar ? null : _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: scheme.onPrimary,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Read-only fields
              AppTextField(
                controller: TextEditingController(text: profile.email),
                label: 'Email Address',
                readOnly: true,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller:
                    TextEditingController(text: profile.role.toUpperCase()),
                label: 'Account Role',
                readOnly: true,
                prefixIcon: Icons.verified_user_outlined,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Editable fields
              AppTextField(
                controller: _nameController,
                label: 'Full Name',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _phoneController,
                label: 'Phone Number',
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: AppSpacing.xxl),

              AppButton(
                label: 'Save Changes',
                isLoading: _isSaving,
                onPressed: _saveProfile,
              ),
            ],
          );
        },
      ),
    );
  }
}
