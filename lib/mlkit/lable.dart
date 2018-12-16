import 'package:flutter/material.dart';
import 'package:mlkit/mlkit.dart';
import 'dart:io';

class LableDetect extends StatefulWidget {
  LableDetect(this._currentLabels,this._file);
  final File _file;
  final List < VisionLabel > _currentLabels ;
  
  _LableDetectState createState() => _LableDetectState(_currentLabels,_file);
}

class _LableDetectState extends State<LableDetect> {

  _LableDetectState(this._currentLabels,this._file);
  File _file;
  List < VisionLabel > _currentLabels = < VisionLabel > [];

  @override
  Widget build(BuildContext context) {
    return Container(
       child: Column(
        children: < Widget > [_buildList(_currentLabels)],
      ),
    );
  }

  Widget _buildList(List < VisionLabel > labels) {
    if (labels == null || labels.length == 0) {
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

  
  //Display labels
  Widget _buildRow(String label, String confidence) {
    return new ListTile(
      title: new Text(
        "\nLabel: $label \nConfidence: $confidence",
      ),
      dense: true,
    );
  }
}