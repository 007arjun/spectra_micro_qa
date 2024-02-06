import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../sql_helper.dart';

class EditProfileWidget extends StatefulWidget {
  final Map<String, dynamic> userData;

  EditProfileWidget({Key? key, required this.userData}) : super(key: key);

  @override
  _EditProfileWidgetState createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  late ImagePicker _imagePicker;
  String? _pickedImagePath;

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
    _initControllers();
  }

  void _initControllers() {
    _nameController.text = widget.userData['name'] ?? '';
    _emailController.text = widget.userData['email'] ?? '';
    _phoneController.text = widget.userData['phone'] ?? '';
    _pickedImagePath = widget.userData['profileImage'] ?? '';
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImagePath = pickedFile.path;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFf7572d),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _pickedImagePath != null
                        ? FileImage(File(_pickedImagePath!)) as ImageProvider<Object>
                        : AssetImage('assets/prof.png'),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Color(0xFFf7572d),
                      radius: 20,
                      child: IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                        onPressed: _pickImageFromGallery,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildTextField('Username', _nameController),
              SizedBox(height: 16),
              _buildTextField('Email', _emailController),
              SizedBox(height: 16),
              _buildTextField('Phone Number', _phoneController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await SQLHelper().updateUser(
                    widget.userData['email'],
                    _nameController.text,
                    _emailController.text,
                    _phoneController.text,
                    _pickedImagePath ?? 'assets/profile.jpg',
                  );

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFf7572d),
                  fixedSize: Size(100, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Text(
                  'SAVE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(35.0),
        ),
      ),
    );
  }
}
