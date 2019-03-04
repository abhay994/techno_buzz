import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:transparent_image/transparent_image.dart';
import 'web.dart';
import 'package:flutter/gestures.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:launch_review/launch_review.dart';
import 'dart:ui' as ui;
import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:firebase_admob/firebase_admob.dart';

class MainPage extends StatefulWidget {
  String author;
  String title;
  String description;
  String url;
  String urlToImage;
  String publishedAt;
  String content;
  String id;
  String name;

  MainPage({
    Key key,
    @required this.urlToImage,
    @required this.url,
    @required this.description,
    @required this.content,
    @required this.title,
    @required this.name,
  }) : super(key: key);
  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool check = false;

  InterstitialAd myInterstitial = InterstitialAd(
    // Replace the testAdUnitId with an ad unit id from the AdMob dash.
    // https://developers.google.com/admob/android/test-ads
    // https://developers.google.com/admob/ios/test-ads
    adUnitId: 'ca-app-pub-4855672100917117/1803957878',

    listener: (MobileAdEvent event) {
      print("InterstitialAd event is $event");
    },
  );
  static const platform = const MethodChannel('Share');
  static GlobalKey screen2 = new GlobalKey();

  Future<void> _getShare(String filePath,String title) async {
  try {
  final int result =
  await platform.invokeMethod('getShare', {"file": filePath,"strings":title});
  } on PlatformException catch (e) {}
  }


  void screenShot() async {

    RenderRepaintBoundary boundary = screen2.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    var filePath = await ImagePickerSaver.saveFile(
        fileData: byteData.buffer.asUint8List());

    print(filePath);
    final ByteData bytes = await rootBundle.load(filePath);
    _getShare(filePath,widget.title);
    //final ByteData bytes = await rootBundle.load('assets/image.png');
// await EsysFlutterShare.shareImage('myImageTest.png', bytes, 'my image title');
  }


  Future<void> _neverSatisfied() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rate This App'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('How is your experience with us?'),
                InkWell(
                  child: Image.asset('stars.png'),
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Maybe Later',
                style: TextStyle(color: Colors.black26),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Rate Now'),
              onPressed: () {
                Future.delayed(Duration(seconds: 1), () {
                  LaunchReview.launch(
                      androidAppId: "com.ar.techno_buzz", iOSAppId: "585027354");
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
  FirebaseAdMob.instance.initialize(appId:'ca-app-pub-4855672100917117~4707483070');
    // TODO: implement initState
    Future.delayed(const Duration(seconds: 15),(){
  myInterstitial
  ..load()
  ..show(
  anchorType: AnchorType.bottom,
  anchorOffset: 0.0,
  );
  });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text("TechnoBuzz"),
        backgroundColor: Colors.white,
        actions: <Widget>[

          IconButton(
            icon: Icon(
              Icons.share,
              size: 30,
            ),
            onPressed: () {
  screenShot();
  },
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: RepaintBoundary(
                  key: screen2,
                  child: Card(
                    child: Stack(
                      children: <Widget>[
                        Center(child: CircularProgressIndicator()),
                        FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage,
                            fadeInDuration: const Duration(seconds: 2),
                            fadeInCurve: Curves.bounceIn,
                            image: widget.urlToImage,
                            fit: BoxFit.fill,
                            width: MediaQuery.of(context).size.width),
                      ],
                    ),
                    elevation: 4,
                  ),
                ),
              ),
              flex: 3,
            ),
            Expanded(
              child: Container(
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: <Widget>[
                    Container(
                      child: Center(
                        child: Text(
                          widget.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(2),
                    ),
                    Container(
                      child: Padding(
                        padding: EdgeInsets.all(3),
                        child: Text(widget.title.toUpperCase(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                                decorationStyle: TextDecorationStyle.wavy)),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(2),
                    ),

                    Container(
                      child: Padding(
                        padding: EdgeInsets.all(3),
                        child: Text(widget.description,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 15.0,
                                decorationStyle: TextDecorationStyle.wavy)),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(1),
                    ),
                    Container(
                      child: Padding(
                        padding: EdgeInsets.all(3),
                        child: Text(widget.content,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 17.0,
                                decorationStyle: TextDecorationStyle.wavy)),
                      ),
                    ),

                    Container(
                      child: Center(
                        child: FlatButton(
                          child: const Text('Read more...'),
                          onPressed: () {
                            // Perform some action
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Myweb(
                                        url: widget.url, name: widget.name)));
                          },
                        ),
                      ),
                    ),
                    Container(
                     padding: EdgeInsets.all(6.0),
                      height: MediaQuery.of(context).size.height,
                      child: WebView(
                        initialUrl: widget.url,
                        javascriptMode: JavascriptMode.unrestricted,
                        gestureRecognizers: Set()
                          ..add(Factory<VerticalDragGestureRecognizer>(
                              () => VerticalDragGestureRecognizer())),
                      ),
                    ),
                  ],
                ),
              ),
              flex: 6,
            ),
          ],
        ),
      ),
    );
  }








}
