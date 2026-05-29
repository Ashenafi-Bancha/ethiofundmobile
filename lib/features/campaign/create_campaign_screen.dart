import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/utils/validators.dart';
import '../../providers/campaign_provider.dart';
import '../../services/campaign_service.dart';
import '../../shared/widgets/primary_button.dart';

class CreateCampaignScreen extends ConsumerStatefulWidget {
  const CreateCampaignScreen({super.key});

  @override
  ConsumerState<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends ConsumerState<CreateCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _goalController = TextEditingController();
  String _selectedCategory = 'community';
  bool _isSubmitting = false;
  
  XFile? _imageFile;
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
    return Scaffold(
      appBar: AppBar(title: const Text('Create Campaign')),
      body: ListView(
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
                              : null,
                        ),
                        child: _imageFile == null
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
                      label: 'Publish Campaign',
                      isLoading: _isSubmitting,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await ref.read(campaignServiceProvider).uploadCampaignImage(_imageFile!);
      }

      final campaign = await ref.read(campaignServiceProvider).createCampaign(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            goalAmount: double.parse(_goalController.text.trim()),
            category: _selectedCategory,
            imageUrl: imageUrl,
          );
      ref.invalidate(campaignsProvider);
      if (!mounted) return;
      context.go('/campaigns/${campaign.campaignId}');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Create campaign failed: $error')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}