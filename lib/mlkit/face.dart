import 'package:flutter/material.dart';
import 'package:mlkit/mlkit.dart';
import 'dart:async';
import 'dart:io';

class FaceDetect extends StatefulWidget {
  FaceDetect(this._file,this._face);
  final File _file;
  final List < VisionFace > _face ;
  _FaceDetectState createState() => _FaceDetectState(_file,_face);
}

class _FaceDetectState extends State<FaceDetect> {
  _FaceDetectState(this._file,this._face);
  final File _file;
  final List < VisionFace > _face ;
  
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Container(
      child: new Stack(
        children: < Widget > [
          _buildFaceImage(),
          _showDetails(_face)
        ],
      ),
    ),
    );
  }

  Future < Size > _getImageSize(Image image) {
    Completer < Size > completer = new Completer < Size > ();
    image.image.resolve(new ImageConfiguration()).addListener(
      (ImageInfo info, bool _) => completer.complete(
        Size(info.image.width.toDouble(), info.image.height.toDouble())));
    return completer.future;
  }

  Widget _buildFaceImage() {
    return new SizedBox(
      height: 500.0,
      child: new Center(
        child: _file == null ?
        new Text('Select image using Floating Button...') :
        new FutureBuilder < Size > (
          future: _getImageSize(Image.file(_file, fit: BoxFit.fitWidth)),
          builder: (BuildContext context, AsyncSnapshot < Size > snapshot) {
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

class FaceTextDetectDecoration extends Decoration {
  final Size _originalImageSize;
  final List < VisionFace > _texts;
  FaceTextDetectDecoration(List < VisionFace > texts, Size originalImageSize): _texts = texts,
    _originalImageSize = originalImageSize;

  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    return new _FaceTextDetectPainter(_texts, _originalImageSize);
  }
}


Widget _showDetails(List < VisionFace > faceList) {
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
      "",
    ),
    dense: true,
  );
}


void checkData(List < VisionFace > faceList) {
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

class _FaceTextDetectPainter extends BoxPainter {
  final List < VisionFace > _faceLabels;
  final Size _originalImageSize;
  _FaceTextDetectPainter(faceLabels, originalImageSize): _faceLabels = faceLabels,
    _originalImageSize = originalImageSize;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = new Paint()..strokeWidth = 2.0..color = Colors.red..style = PaintingStyle.stroke;

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