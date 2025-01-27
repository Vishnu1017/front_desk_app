import 'package:flutter/material.dart';
import 'package:front_desk_app/visitor.dart';
import 'package:front_desk_app/visitor_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController(); // Add email controller
  final _purposeController = TextEditingController();
  final _personToMeetController = TextEditingController();
  File? _photo;
  File? _idProof;

  Future<void> _pickImage(bool isIdProof) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 40,
      maxWidth: 600,
      maxHeight: 600,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);

      try {
        final image = img.decodeImage(file.readAsBytesSync());
        if (image == null) {
          _showSnackBar('Failed to decode image.');
          return;
        }
        final compressedImage = img.encodeJpg(image, quality: 50);
        final compressedFile = File(pickedFile.path)
          ..writeAsBytesSync(compressedImage);

        setState(() {
          if (isIdProof) {
            _idProof = compressedFile;
          } else {
            _photo = compressedFile;
          }
        });
      } catch (e) {
        _showSnackBar('Error processing image: $e');
      }
    } else {
      _showSnackBar(
          isIdProof ? 'No ID proof image selected' : 'No photo selected');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 8.0,
          child: Container(
            margin: const EdgeInsets.only(top: 10.0),
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Text(
                      'Fill out the form below to check in.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(_nameController, 'Name'),
                    const SizedBox(height: 16),
                    _buildTextField(_phoneController, 'Phone', isPhone: true),
                    const SizedBox(height: 16),
                    _buildTextField(_emailController, 'Email',
                        isEmail: true), // Email field
                    const SizedBox(height: 16),
                    _buildTextField(_purposeController, 'Purpose of Visit'),
                    const SizedBox(height: 16),
                    _buildTextField(_personToMeetController, 'Person to Meet'),
                    const SizedBox(height: 20),
                    _buildImageSection(_photo, 'No photo selected.'),
                    const SizedBox(height: 10),
                    _buildElevatedButton(
                        'Capture Photo', () => _pickImage(false)),
                    const SizedBox(height: 20),
                    _buildImageSection(_idProof, 'No ID proof selected.'),
                    const SizedBox(height: 10),
                    _buildElevatedButton(
                        'Capture ID Proof', () => _pickImage(true)),
                    const SizedBox(height: 20),
                    _buildCheckInButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Visitor Check-In',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.yellow.shade800,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.yellow.shade700, Colors.yellow.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(File? image, String placeholder) {
    return image == null
        ? Center(
            child: Text(placeholder,
                style: TextStyle(color: Colors.grey.shade600)),
          )
        : Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Image.file(
              image,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          );
  }

  ElevatedButton _buildElevatedButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow.shade800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black)),
    );
  }

  ElevatedButton _buildCheckInButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState?.validate() == true) {
          if (_photo == null) {
            // Show a message if the photo is not captured
            _showSnackBar('Please capture a photo before checking in.');
            return;
          }

          final visitor = Visitor(
            name: _nameController.text,
            phone: _phoneController.text,
            email: _emailController.text, // Add email to visitor
            purpose: _purposeController.text,
            personToMeet: _personToMeetController.text,
            checkInTime: DateTime.now(),
            photoPath: _photo?.path,
            idProofPath: _idProof?.path,
          );
          Provider.of<VisitorManager>(context, listen: false).checkIn(visitor);
          Navigator.of(context).pop();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow.shade800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      child: const Text('Check In', style: TextStyle(color: Colors.black)),
    );
  }

  TextFormField _buildTextField(
    TextEditingController controller,
    String label, {
    bool isPhone = false,
    bool isEmail = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        labelStyle: TextStyle(color: Colors.yellow.shade800),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.yellow.shade800, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      keyboardType: isPhone
          ? TextInputType.phone
          : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (isPhone && !RegExp(r'^\d{10}$').hasMatch(value)) {
          return 'Please enter a valid 10-digit phone number';
        }
        if (isEmail &&
            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }
}
