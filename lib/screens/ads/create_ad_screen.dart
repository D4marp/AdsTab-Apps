import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/ad_model.dart';
import '../../providers/ad_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CreateAdScreen extends StatefulWidget {
  const CreateAdScreen({super.key});

  @override
  State<CreateAdScreen> createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends State<CreateAdScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Text Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _companyController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  
  // Form fields
  String _category = 'Product';
  String _displayFormat = 'tab';
  String _targetAudience = 'General';
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _imageUrls = [];
  List<File> _selectedImages = []; // Tambah untuk track local images
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _categories = [
    'Product',
    'Service',
    'Event',
    'Job',
    'Real Estate',
    'Automotive',
    'Education',
    'Health',
    'Fashion',
    'Food',
    'Technology',
    'Other'
  ];

  final List<String> _formats = ['tab', 'screen'];
  final List<String> _audiences = [
    'General',
    'Students',
    'Professionals',
    'Businesses',
    'Families',
    'Youth',
    'Seniors'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _companyController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Advertisement'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              CustomTextField(
                controller: _titleController,
                labelText: 'Ad Title',
                hintText: 'Enter advertisement title',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              // Company Name
              CustomTextField(
                controller: _companyController,
                labelText: 'Company Name',
                hintText: 'Your company name',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Company name is required' : null,
              ),
              const SizedBox(height: 16),

              // Description
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Describe your advertisement',
                maxLines: 4,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),

              // Category
              Text('Category',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                items: _categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _category = value ?? ''),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Display Format
              Text('Display Format',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                items: _formats
                    .map((fmt) => DropdownMenuItem(
                          value: fmt,
                          child: Text(fmt == 'tab' ? 'Tab Display' : 'Screen Display'),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _displayFormat = value ?? 'tab'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Target Audience
              Text('Target Audience',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                items: _audiences
                    .map((aud) => DropdownMenuItem(
                          value: aud,
                          child: Text(aud),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _targetAudience = value ?? ''),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Contact Info
              CustomTextField(
                controller: _contactEmailController,
                labelText: 'Contact Email',
                hintText: 'your@email.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _contactPhoneController,
                labelText: 'Contact Phone',
                hintText: '+62...',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Images Section
              Text('Advertisement Images (Multiple)',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              
              // Image Grid Preview
              if (_selectedImages.isNotEmpty)
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            // Image preview
                            Container(
                              width: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedImages[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Remove button
                            Positioned(
                              top: -8,
                              right: -8,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(Icons.close,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              
              const SizedBox(height: 12),
              
              // Upload buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.image),
                      label: const Text('Add Images'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImageFromCamera,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                    ),
                  ),
                ],
              ),
              
              if (_selectedImages.isEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Add at least 1 image for better promotion',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),

              // Budget
              CustomTextField(
                controller: _budgetController,
                labelText: 'Budget',
                hintText: 'Enter budget amount',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Date Range
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start Date',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => _selectDate(context, true),
                          child: Text(_startDate == null
                              ? 'Select Date'
                              : _startDate.toString().split(' ')[0]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('End Date',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => _selectDate(context, false),
                          child: Text(_endDate == null
                              ? 'Select Date'
                              : _endDate.toString().split(' ')[0]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Submit Button
              CustomButton(
                text: 'Create Advertisement',
                onPressed: () => _submitForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxHeight: 1920,
        maxWidth: 1080,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(
            pickedFiles.map((xFile) => File(xFile.path)).toList(),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxHeight: 1920,
        maxWidth: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking photo: $e')),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null) {
      
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one image'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // Upload images to Firebase Storage
        List<String> uploadedImageUrls = [];
        for (var imageFile in _selectedImages) {
          final imageUrl = await context
              .read<AdProvider>()
              .uploadAdImage(imageFile);
          uploadedImageUrls.add(imageUrl);
        }

        _formKey.currentState!.save();

        final newAd = AdModel(
          id: '',
          userId: '', // Will be set from current user
          title: _titleController.text,
          description: _descriptionController.text,
          category: _category,
          imageUrls: uploadedImageUrls,
          displayFormat: _displayFormat,
          startDate: _startDate!,
          endDate: _endDate!,
          isActive: false,
          impressions: 0,
          clicks: 0,
          targetAudience: _targetAudience,
          budget: _budgetController.text,
          createdAt: DateTime.now(),
          contactEmail: _contactEmailController.text,
          contactPhone: _contactPhoneController.text,
          companyName: _companyController.text,
          status: 'draft',
        );

        await context.read<AdProvider>().createAd(newAd);

        // Pop loading dialog
        if (mounted) Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Advertisement created successfully with images!'),
            backgroundColor: Colors.green,
          ),
        );
        
        if (mounted) Navigator.pop(context);
      } catch (e) {
        // Pop loading dialog
        if (mounted) Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating advertisement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
