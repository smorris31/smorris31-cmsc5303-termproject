import 'package:flutter/material.dart';

class WebImage extends Image {
  WebImage({
    required String url, //Image URL.
    required BuildContext context,  //Image content used to build image
    double height = 200.0,
    Key? key,
  }) : super.network(
          url,  //Image URL
          height: height, //Set height
          key: key,
          errorBuilder:
          //If an error happens display Error Icon at set height
              (BuildContext context, Object exception, StackTrace? stackTrace) {
                print('########### web image error: $exception');
            return Icon(
              Icons.error,
              size: height,
            );
          },
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            } else {
              return CircularProgressIndicator(
                //If loadingProgress.expectedTotalBytes is null we are done loading,
                //otherwised get percent done.
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              );
            }
          },
        );
}