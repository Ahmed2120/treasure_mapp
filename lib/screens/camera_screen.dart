import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:treasure_mapp/services/controller.dart';
import 'package:treasure_mapp/screens/picture_screen.dart';
import '../model/place.dart';

class CameraScreen extends StatefulWidget {
  final Place place;

  const CameraScreen(this.place, {Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  // late Place place;
  late CameraController _controller;

  late List<CameraDescription> cameras;
  late CameraDescription camera;
  late Widget cameraPreview;
  late Image image;

  Future setCamera() async {
    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      camera = cameras.first;
    }
  }

  @override
  void initState() {
    cameraPreview = const Center(
      child: Icon(
        Icons.camera_enhance,
        size: 200,
      ),
    );
    setCamera().then((_) {
      _controller = CameraController(camera, ResolutionPreset.max);
      _controller.initialize().then((snapshot) {
        cameraPreview = Center(
          child: CameraPreview(_controller),
        );
        setState(() {
          cameraPreview = cameraPreview;
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          cameraPreview,
          Positioned(
            child: IconButton(
              onPressed: ()async{
                final path = join((await getTemporaryDirectory()).path, '${DateTime.now()}.png');
                (await _controller.takePicture()).saveTo(path);
                Provider.of<Controller>(context, listen: false).setImg(path);
                Navigator.pop(context, path);
              },
              icon: const Icon(Icons.camera, color: Colors.white, size: 50,),
            ),
            bottom: dSize.height * 0.1,
            left: dSize.width * 0.44,
          )
        ],
      ),
    );
  }
}