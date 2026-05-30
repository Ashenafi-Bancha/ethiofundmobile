import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/utils/validators.dart';
import '../../providers/campaign_provider.dart';
import '../../services/campaign_service.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/primary_button.dart';

class EditCampaignScreen extends ConsumerStatefulWidget {
  const EditCampaignScreen({super.key, required this.campaignId});

  final String campaignId;

  @override
  ConsumerState<EditCampaignScreen> createState() => _EditCampaignScreenState();
}

class _EditCampaignScreenState extends ConsumerState<EditCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _goalController = TextEditingController();
  String _selectedCategory = 'community';
  bool _isSubmitting = false;
  bool _loaded = false;

  XFile? _imageFile;
  String? _existingImageUrl;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked != null) {
        setState(() => _imageFile = picked);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parsedId = int.tryParse(widget.campaignId);
    if (parsedId == null) {
      return const Scaffold(body: Center(child: Text('Invalid campaign id')));
    }

    final campaignAsync = ref.watch(campaignDetailProvider(parsedId));

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Campaign')),
      body: campaignAsync.when(
        loading: () => const LoadingWidget(message: 'Loading campaign...'),
        error: (error, stackTrace) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(campaignDetailProvider(parsedId)),
        ),
        data: (campaign) {
          if (!_loaded) {
            _titleController.text = campaign.title;
            _descriptionController.text = campaign.description;
            _goalController.text = campaign.goalAmount.toStringAsFixed(0);
            _selectedCategory = campaign.category;
            _existingImageUrl = campaign.imageUrl;
            _loaded = true;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: double.infinity,
                            height: 180,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                              image: _imageFile != null
                                  ? DecorationImage(
                                      image: FileImage(File(_imageFile!.path)),
                                      fit: BoxFit.cover,
                                    )
                                  : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(_existingImageUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null),
                            ),
                            child: _imageFile == null && (_existingImageUrl == null || _existingImageUrl!.isEmpty)
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo_outlined, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap to select campaign image',
                                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: 'Campaign title'),
                          validator: (value) => validateRequired(value, 'Campaign title'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 5,
                          decoration: const InputDecoration(labelText: 'Description'),
                          validator: (value) => validateRequired(value, 'Description'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _goalController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Goal amount', prefixText: 'ETB '),
                          validator: validateCampaignGoal,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(labelText: 'Category'),
                          items: const [
                            DropdownMenuItem(value: 'community', child: Text('Community')),
                            DropdownMenuItem(value: 'education', child: Text('Education')),
                            DropdownMenuItem(value: 'health', child: Text('Health')),
                            DropdownMenuItem(value: 'startup', child: Text('Startup')),
                            DropdownMenuItem(value: 'emergency', child: Text('Emergency')),
                          ],
                          onChanged: (value) {
                            if (value != null) setState(() => _selectedCategory = value);
                          },
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          label: 'Save Changes',
                          isLoading: _isSubmitting,
                          onPressed: () => _submit(parsedId),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submit(int campaignId) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      String? imageUrl = _existingImageUrl;
      if (_imageFile != null) {
        imageUrl = await ref.read(campaignServiceProvider).uploadCampaignImage(File(_imageFile!.path));
      }

      await ref.read(campaignServiceProvider).updateCampaign(campaignId, {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'goal_amount': double.parse(_goalController.text.trim()),
        'category': _selectedCategory,
        'image_url': imageUrl,
      });
      ref.invalidate(campaignDetailProvider(campaignId));
      ref.invalidate(campaignsProvider);
      if (!mounted) return;
      context.go('/campaigns/$campaignId');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $error')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}