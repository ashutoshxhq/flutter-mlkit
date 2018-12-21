import 'package:flutter/material.dart';
import 'package:mlkit/mlkit.dart';
import 'dart:io';


class TextDetect extends StatefulWidget {
  TextDetect(this._file,this._currentText);
  final List < VisionText > _currentText ;
  final File _file;
  
  _TextDetectState createState() => _TextDetectState(_file,_currentText);
}

class _TextDetectState extends State<TextDetect> {
  _TextDetectState(this._file,this._currentText);
  List < VisionText > _currentText = < VisionText > [];
  File _file;
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Container(
      child: Column(
        children: < Widget > [
          _buildListText(_currentText),
        ],
      ),
    ),
    );
  }

  // Future < Size > _getImageSize(Image image) {
  //   Completer < Size > completer = new Completer < Size > ();
  //   image.image.resolve(new ImageConfiguration()).addListener(
  //     (ImageInfo info, bool _) => completer.complete(
  //       Size(info.image.width.toDouble(), info.image.height.toDouble())));
  //   return completer.future;
  // }

  // Widget _buildImage() {
  //   return SizedBox(
  //     height: 500.0,
  //     child: new Center(
  //       child: _file == null ?
  //       Text('No Image') :
  //       new FutureBuilder < Size > (
  //         future: _getImageSize(Image.file(_file, fit: BoxFit.fitWidth)),
  //         builder: (BuildContext context, AsyncSnapshot < Size > snapshot) {
  //           if (snapshot.hasData) {
  //             return Container(
  //               foregroundDecoration:
  //               TextDetectDecoration(_currentText, snapshot.data),
  //               child: Image.file(_file, fit: BoxFit.fitWidth));
  //           } else {
  //             return new Text('Detecting...');
  //           }
  //         },
  //       ),
  //     ),
  //   );
  // }

  Widget _buildListText(List < VisionText > texts) {
    if (texts == null || texts.length == 0) {
      return Container(child:Center(child:Text('Text Empty')));
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
      title: Text(text),
      dense: true,
    );
  }
}

class TextDetectDecoration extends Decoration {
  final Size _originalImageSize;
  final List < VisionText > _texts;
  TextDetectDecoration(List < VisionText > texts, Size originalImageSize): _texts = texts,
    _originalImageSize = originalImageSize;

  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    return new _TextDetectPainter(_texts, _originalImageSize);
  }
}

class _TextDetectPainter extends BoxPainter {
  final List < VisionText > _texts;
  final Size _originalImageSize;
  _TextDetectPainter(texts, originalImageSize): _texts = texts,
    _originalImageSize = originalImageSize;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = new Paint()..strokeWidth = 2.0..color = Colors.red..style = PaintingStyle.stroke;
    final _heightRatio = _originalImageSize.height / configuration.size.height;
    final _widthRatio = _originalImageSize.width / configuration.size.width;
    for (var text in _texts) {
      final _rect = Rect.fromLTRB(
        offset.dx + text.rect.left / _widthRatio,
        offset.dy + text.rect.top / _heightRatio,
        offset.dx + text.rect.right / _widthRatio,
        offset.dy + text.rect.bottom / _heightRatio);
      canvas.drawRect(_rect, paint);
    }
    canvas.restore();
  }

}