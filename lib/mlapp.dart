import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mlkit/mlkit.dart';
import 'dart:async';

class MlApp extends StatefulWidget {
  _MlAppState createState() => _MlAppState();
}

class _MlAppState extends State<MlApp> {

  File _file;
  List<VisionLabel> _currentLabels = <VisionLabel>[];
  List<VisionText> _currentText = <VisionText>[];
  List<VisionFace> _face = <VisionFace>[];  

  VisionFaceDetectorOptions options = new VisionFaceDetectorOptions(
      modeType: VisionFaceDetectorMode.Accurate,
      landmarkType: VisionFaceDetectorLandmark.All,
      classificationType: VisionFaceDetectorClassification.All,
      minFaceSize: 0.15,
      isTrackingEnabled: true);

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
        length: 5,
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Flutter Firebase'),
        bottom: TabBar(
          isScrollable: true,
              tabs: [
                Tab(child: TabItem("RAW IMAGE"),),
                Tab(child: TabItem("TEXTS"),),
                Tab(child: TabItem("LABLES"),),
                Tab(child: TabItem("FACES"),),   
               
              ],
            ),
      ),
      body:TabBarView(
            children: [
              displaySelectedFile(_file),
              _buildBodyText(),
              _buildBody(_file),
              showBody(_file),
              
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
                  await labelsDetector.detectFromBinary(_file?.readAsBytesSync());
              setState(() {
                _currentLabels = currentLabels;
              });

                var currentText = await textDetector.detectFromPath(_file?.path);
                setState(() {
                  _currentText = currentText;                                    
});

              var face =
                await faceDetector.detectFromBinary(_file?.readAsBytesSync(), options);
            setState(() {
              if (face.isEmpty) {
                print('No face detected');
              } else {
                _face = face;
              }
              });
            } catch (e) {
              print(e.toString());
            }
          },
          child: new Icon(Icons.image),
        ),
      ),
    );
  }


// Lable Detection Widgets


Widget _buildBody(File _file) {
    return new Container(
      child: new Column(
        children: <Widget>[ _buildList(_currentLabels)],
      ),
    );
  }

  Widget _buildList(List<VisionLabel> labels) {
    if (labels == null || labels.length == 0 ) {
      return new Text('Empty', textAlign: TextAlign.center);
    }
    return new Expanded(
      child: new Container(    
        child: new ListView.builder(
            padding: const EdgeInsets.all(1.0),
            itemCount: labels.length,
            itemBuilder: (context, i) {
              return _buildRow(labels[i].label, labels[i].confidence.toString());
            }),
      ),
    );
  }

   Widget displaySelectedFile(File file) {
    return new SizedBox(
      height: 100.0,
      width: 150.0,
      child: file == null
          ? new Text('Sorry nothing selected!!')
          : new Image.file(file),
    );
}

  //Display labels
  Widget _buildRow(String label, String confidence) {
    return new ListTile(
      title: new Text(
        "\nLabel: $label \nConfidence: $confidence",
      ),
      dense: true,
    );
  }


// Text Detection Widgets

 Widget _buildImage() {
    return SizedBox(
      height: 500.0,
      child: new Center(
        child: _file == null
            ? Text('No Image')
            : new FutureBuilder<Size>(
                future: _getImageSize(Image.file(_file, fit: BoxFit.fitWidth)),
                builder: (BuildContext context, AsyncSnapshot<Size> snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                        foregroundDecoration:
                            TextDetectDecoration(_currentText, snapshot.data),
                        child: Image.file(_file, fit: BoxFit.fitWidth));
                  } else {
                    return new Text('Detecting...');
                  }
                },
              ),
      ),
    );
  }

  Future<Size> _getImageSize(Image image) {
    Completer<Size> completer = new Completer<Size>();
    image.image.resolve(new ImageConfiguration()).addListener(
        (ImageInfo info, bool _) => completer.complete(
            Size(info.image.width.toDouble(), info.image.height.toDouble())));
    return completer.future;
  }

  Widget _buildBodyText() {
    return Container(
      child: Column(
        children: <Widget>[
          _buildListText(_currentText),
        ],
      ),
    );
  }

  Widget _buildListText(List<VisionText> texts) {
    if (texts == null ||texts.length == 0) {
      return Text('Empty');
    }
    return Expanded(
      child: Container(
        child: ListView.builder(
            padding: const EdgeInsets.all(1.0),
            itemCount: texts.length,
            itemBuilder: (context, i) {
              return _buildRowText(texts[i].text);
            }),
      ),
    );
  }

  Widget _buildRowText(String text) {
    return ListTile(
      title: Text(
        "${text}",
      ),
      dense: true,
    );
  }




Widget showBody(File file) {
    return new Container(
      child: new Stack(
        children: <Widget>[
          _buildFaceImage(),
        ],
      ),
    );
  }

  Widget _buildFaceImage() {
    return new SizedBox(
      height: 500.0,
      child: new Center(
        child: _file == null
            ? new Text('Select image using Floating Button...')
            : new FutureBuilder<Size>(
                future: _getImageSize(Image.file(_file, fit: BoxFit.fitWidth)),
                builder: (BuildContext context, AsyncSnapshot<Size> snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                        foregroundDecoration:
                            FaceTextDetectDecoration(_face, snapshot.data),
                        child: Image.file(_file, fit: BoxFit.fitWidth));
                  } else {
                    return new Text('Please wait...');
                  }
                },
              ),
      ),
    );
  }
}

class TextDetectDecoration extends Decoration {
  final Size _originalImageSize;
  final List<VisionText> _texts;
  TextDetectDecoration(List<VisionText> texts, Size originalImageSize)
      : _texts = texts,
        _originalImageSize = originalImageSize;

  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    return new _TextDetectPainter(_texts, _originalImageSize);
  }
}

class _TextDetectPainter extends BoxPainter {
  final List<VisionText> _texts;
  final Size _originalImageSize;
  _TextDetectPainter(texts, originalImageSize)
      : _texts = texts,
        _originalImageSize = originalImageSize;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = new Paint()
      ..strokeWidth = 2.0
      ..color = Colors.red
      ..style = PaintingStyle.stroke;
    // print("original Image Size : ${_originalImageSize}");

    final _heightRatio = _originalImageSize.height / configuration.size.height;
    final _widthRatio = _originalImageSize.width / configuration.size.width;
    for (var text in _texts) {
      // print("text : ${text.text}, rect : ${text.rect}");
      final _rect = Rect.fromLTRB(
          offset.dx + text.rect.left / _widthRatio,
          offset.dy + text.rect.top / _heightRatio,
          offset.dx + text.rect.right / _widthRatio,
          offset.dy + text.rect.bottom / _heightRatio);
      // print("_rect : ${_rect}");
      canvas.drawRect(_rect, paint);
    }

    // print("offset : ${offset}");
    // print("configuration : ${configuration}");

    final rect = offset & configuration.size;

    // print("rect container : ${rect}");
    canvas.restore();
}

}

class FaceTextDetectDecoration extends Decoration {
  final Size _originalImageSize;
  final List<VisionFace> _texts;
  FaceTextDetectDecoration(List<VisionFace> texts, Size originalImageSize)
      : _texts = texts,
        _originalImageSize = originalImageSize;

  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    return new _FaceTextDetectPainter(_texts, _originalImageSize);
  }
}


Widget _showDetails(List<VisionFace> faceList) {
  if (faceList == null || faceList.length == 0) {
    return new Text('', textAlign: TextAlign.center);
  }
  return new Container(
    child: new ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: faceList.length,
      itemBuilder: (context, i) {
        checkData(faceList);
        return _buildRow(
            faceList[0].hasLeftEyeOpenProbability,
            faceList[0].headEulerAngleY,
            faceList[0].headEulerAngleZ,
            faceList[0].leftEyeOpenProbability,
            faceList[0].rightEyeOpenProbability,
            faceList[0].smilingProbability,
            faceList[0].trackingID);
      },
    ),
  );
}

//For checking and printing different variables from Firebase
void checkData(List<VisionFace> faceList) {
  final double uncomputedProb = -1.0;
  final int uncompProb = -1;

  for (int i = 0; i < faceList.length; i++) {
    Rect bounds = faceList[i].rect;
    print('Rectangle : $bounds');

    VisionFaceLandmark landmark =
        faceList[i].getLandmark(FaceLandmarkType.LeftEar);

    if (landmark != null) {
      VisionPoint leftEarPos = landmark.position;
      print('Left Ear Pos : $leftEarPos');
    }

    if (faceList[i].smilingProbability != uncomputedProb) {
      double smileProb = faceList[i].smilingProbability;
      print('Smile Prob : $smileProb');
    }

    if (faceList[i].rightEyeOpenProbability != uncomputedProb) {
      double rightEyeOpenProb = faceList[i].rightEyeOpenProbability;
      print('RightEye Open Prob : $rightEyeOpenProb');
    }

    if (faceList[i].trackingID != uncompProb) {
      int tID = faceList[i].trackingID;
      print('Tracking ID : $tID');
    }
  }
}

/*
    HeadEulerY : Head is rotated to right by headEulerY degrees 
    HeadEulerZ : Head is tilted sideways by headEulerZ degrees
    LeftEyeOpenProbability : left Eye Open Probability
    RightEyeOpenProbability : right Eye Open Probability
    SmilingProbability : Smiling probability
    Tracking ID : If face tracking is enabled
  */
Widget _buildRow(
    bool leftEyeProb,
    double headEulerY,
    double headEulerZ,
    double leftEyeOpenProbability,
    double rightEyeOpenProbability,
    double smileProb,
    int tID) {
  return ListTile(
    title: new Text(
      "\nLeftEyeProb: $leftEyeProb \nHeadEulerY : $headEulerY \nHeadEulerZ : $headEulerZ \nLeftEyeOpenProbability : $leftEyeOpenProbability \nRightEyeOpenProbability : $rightEyeOpenProbability \nSmileProb : $smileProb \nFaceTrackingEnabled : $tID",
    ),
    dense: true,
  );
}

class _FaceTextDetectPainter extends BoxPainter {
  final List<VisionFace> _faceLabels;
  final Size _originalImageSize;
  _FaceTextDetectPainter(faceLabels, originalImageSize)
      : _faceLabels = faceLabels,
        _originalImageSize = originalImageSize;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = new Paint()
      ..strokeWidth = 2.0
      ..color = Colors.red
      ..style = PaintingStyle.stroke;

    final _heightRatio = _originalImageSize.height / configuration.size.height;
    final _widthRatio = _originalImageSize.width / configuration.size.width;
    for (var faceLabel in _faceLabels) {
      final _rect = Rect.fromLTRB(
          offset.dx + faceLabel.rect.left / _widthRatio,
          offset.dy + faceLabel.rect.top / _heightRatio,
          offset.dx + faceLabel.rect.right / _widthRatio,
          offset.dy + faceLabel.rect.bottom / _heightRatio);

      canvas.drawRect(_rect, paint);
    }
}


}

class TabItem extends StatelessWidget {
    final String title;
    TabItem(this.title);
    @override
    Widget build(BuildContext context) {
      return Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16
          )
        ),
      );
    }
  }