import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/common/utils/utils.dart';
import 'package:northern_trader/features/auth/controller/auth_controller.dart';

class UserInformationScreen extends ConsumerStatefulWidget {
  static const String routeName = '/user-information';
  const UserInformationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserInformationScreen> createState() =>
      _UserInformationScreenState();
}

class _UserInformationScreenState extends ConsumerState<UserInformationScreen> {
  final TextEditingController nameController = TextEditingController();
  dynamic image; 

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  void storeUserData() async {
    String name = nameController.text.trim();

    if (name.isNotEmpty) {
      ref.read(authControllerProvider).saveUserDataToFirebase(
            context,
            name,
            image,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Stack(
                children: [
                  image == null
                      ? const CircleAvatar(
                          radius: 64,
                          child: Icon(Icons.person, size: 64),
                        )
                      : CircleAvatar(
                          backgroundImage: image is File
                              ? FileImage(image as File)
                              : null,
                          radius: 64,
                          child: image is! File
                              ? FutureBuilder<Uint8List>(
                                  future: (image as dynamic).readAsBytes(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return ClipOval(
                                        child: Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                          width: 128,
                                          height: 128,
                                        ),
                                      );
                                    }
                                    return const Icon(Icons.person, size: 64);
                                  },
                                )
                              : null,
                        ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(
                        Icons.add_a_photo,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: size.width * 0.85,
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: storeUserData,
                    icon: const Icon(
                      Icons.done,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

