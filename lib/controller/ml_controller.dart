import 'dart:io';

import 'package:google_ml_kit/google_ml_kit.dart';

class GoogleMLController {
  static const minConfidence = 0.6;

  static Future<List<dynamic>> getImageLables({
    //this will return a list of string
    required File photo,
  })async {
    //Create input image file Object
    var inputImage = InputImage.fromFile(photo);
    //Create image labler object
    final imageLabeler = GoogleMlKit.vision.imageLabeler();
    //run imagelabeler
    final List<ImageLabel> imageLabels = await imageLabeler.processImage(inputImage);
    imageLabeler.close();

    var results = <dynamic>[];
    for (var i in imageLabels) {
      //this includes image name
      //confidence is 0 - 1
      if (i.confidence >= minConfidence) {
        //search in Google is case sensitive so we should keep lower case
        results.add(i.label.toLowerCase());
      }
    }
    
    return results;
  }

  static Future<List<dynamic>> getImageText({
    required File photo,
  }) async {
    //Create input image file Object
    var inputImage = InputImage.fromFile(photo);
    //Create text Detector object
    print('#### $inputImage #######');
    final imageTextDetector = GoogleMlKit.vision.textDetector();
    //run imagelabeler
    final RecognisedText textDetector = await imageTextDetector.processImage(inputImage);

    String text = textDetector.text;
    print('##### image Text $text ########');
    var results = <dynamic>[];
    for (TextBlock block in textDetector.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          results.add(word.text);
          print('####### ${word.text} ###########');
        }
      }
    }
    return results;
  }
}