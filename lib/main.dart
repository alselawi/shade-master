import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadesmaster/widget_shade_master.dart';
import 'package:shadesmaster/widget_primary_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shade Master',
      theme: ThemeData(
        colorScheme: ColorScheme.light(),
        useMaterial3: true,
      ),
      home: const MainPage(title: 'Shade Master'),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});
  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  XFile? imgPicked;

  pickImage(bool camera) async {
    final target = await ImagePicker().pickImage(source: camera ? ImageSource.camera : ImageSource.gallery);
    setState(() {
      imgPicked = target;
    });
  }

  closeImage() {
    setState(() {
      imgPicked = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: imgPicked != null
            ? ShadeMaster(
                img: imgPicked!,
                onClose: closeImage,
              )
            : Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Welcome to Shade Master", style: TextStyle(fontSize: 20)),
                    SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16), // adjust the radius
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 10),
                    buildPickerButtons(),
                    SizedBox(height: 25),
                    Text("Shade Master Version 1.0 /// Developed by Dr. Ali A. Saleem", style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
      ),
    );
  }

  Column buildPickerButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Start with a photo that shows both the teeth and the closest shades"),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            PrimaryButton(
              onPressed: () => pickImage(true),
              title: "Use Camera",
              icon: Icons.camera_alt,
            ),
            SizedBox(width: 10),
            PrimaryButton(
              onPressed: () => pickImage(false),
              title: "Pick Image",
              icon: Icons.folder,
            ),
          ],
        ),
      ],
    );
  }
}
