import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlkit/mlkit.dart';
import 'dart:io';
import 'text.dart';
import 'face.dart';
import 'lable.dart';
import 'partials.dart';
import 'about.dart';

class MlApp extends StatefulWidget {
  _MlAppState createState() => _MlAppState();
}

class _MlAppState extends State < MlApp > {

  File _file;
  List < VisionLabel > _currentLabels = < VisionLabel > [];
  List < VisionText > _currentText = < VisionText > [];
  List < VisionFace > _face = < VisionFace > [];
  VisionFaceDetectorOptions options = new VisionFaceDetectorOptions(
    modeType: VisionFaceDetectorMode.Accurate,
    landmarkType: VisionFaceDetectorLandmark.All,
    classificationType: VisionFaceDetectorClassification.All,
    minFaceSize: 0.1,
    isTrackingEnabled: true
  );
  FirebaseVisionFaceDetector faceDetector = FirebaseVisionFaceDetector.instance;
  FirebaseVisionTextDetector textDetector = FirebaseVisionTextDetector.instance;
  FirebaseVisionLabelDetector labelsDetector = FirebaseVisionLabelDetector.instance;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text('Exibition App'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(child: TabItem("RAW IMAGE"), ),
              Tab(child: TabItem("TEXTS"), ),
              Tab(child: TabItem("LABLES"), ),
              Tab(child: TabItem("FACES"), ),
              Tab(child: TabItem("ABOUT"), ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ImageWidget(_file),
            TextDetect(_file,_currentText),
            LableDetect(_currentLabels,_file),
            FaceDetect(_file,_face),
            About()
          ],
        ),

        floatingActionButton: new FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: () async {
            setState(() {
              _file = null;
              _currentLabels = null;
              _currentText = null;
              _face = null;
            });
            try {
              var file =
                await ImagePicker.pickImage(source: ImageSource.gallery);
              setState(() {
                _file = file;
              });

              var currentLabels =
                await labelsDetector.detectFromBinary(_file ?.readAsBytesSync());
              setState(() {
                _currentLabels = currentLabels;
              });

              var currentText = await textDetector.detectFromPath(_file ?.path);
              setState(() {
                _currentText = currentText;
              });
            } catch (e) {
              print(e.toString());
            }

            var face =
                await faceDetector.detectFromBinary(_file?.readAsBytesSync());
              setState(() {
                if (face.isEmpty) {
                  print('No face detected');
                } else {
                  _face = face;
                }
              });
          },
          child: new Icon(Icons.image),
        ),
      ),
    );
  }
}
