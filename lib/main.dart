import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:launch_review/launch_review.dart';
import 'nextpage.dart';
import 'dart:ui' as ui;
import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


void main() => runApp(MyApp());
String imgUrl = "";

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TechnoBuzz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: new Color(0xffffffff),
          accentColor: new Color(0xff000000)
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.

          ),
      home: news(),
    );
  }
}

class news extends StatefulWidget {
  @override
  _newsState createState() => new _newsState();
}

class _newsState extends State<news> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static const platform = const MethodChannel('Share');

  Future<void> _getShare(String filePath, String title) async {
    try {
      final int result = await platform
          .invokeMethod('getShare', {"file": filePath, "strings": title});
    } on PlatformException catch (e) {}
  }

  static GlobalKey screen = new GlobalKey();

  String ca;
  int rate;
  List<Article> list;
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
                _assignRate();
                Future.delayed(Duration(seconds: 1), () {
                  LaunchReview.launch(
                      androidAppId: "com.ar.techno_buzz",
                      iOSAppId: "585027354");
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  InterstitialAd myInterstitial = InterstitialAd(
    // Replace the testAdUnitId with an ad unit id from the AdMob dash.
    // https://developers.google.com/admob/android/test-ads
    // https://developers.google.com/admob/ios/test-ads
    adUnitId: 'ca-app-pub-4855672100917117/1803957878',

    listener: (MobileAdEvent event) {
      print("InterstitialAd event is $event");
    },
  );

  BannerAd myBanner = BannerAd(
    // Replace the testAdUnitId with an ad unit id from the AdMob dash.
    // https://developers.google.com/admob/android/test-ads
    // https://developers.google.com/admob/ios/test-ads
    adUnitId: 'ca-app-pub-4855672100917117/8072013013',
    size: AdSize.smartBanner,

    listener: (MobileAdEvent event) {
      print("BannerAd event is $event");
    },
  );

  @override
  void initState() {


    FirebaseAdMob.instance
        .initialize(appId: 'ca-app-pub-4855672100917117~4707483070');
    aDDS();
    Future.delayed(const Duration(seconds: 35), () {
      myInterstitial
        ..load()
        ..show(
          anchorType: AnchorType.bottom,
          anchorOffset: 0.0,
        );
    });
    super.initState();
    print(ca);
    print(rate);
    _loads();
    _loadrate();

    Future.delayed(const Duration(seconds: 25), () {
      if (rate == 0) {
        _neverSatisfied();
      }
    });

    Future.delayed(const Duration(milliseconds: 1000 * 3), () {
// Here you can write your code
      if (ca != '') {
        setState(() {
          print(ca);
          this.getData(ca);
          flag(ca);
          print(ca);
        });
      } else {
        print("in");
        this.getData('in');
        flag("in");
        print("in");
      }
    });
  }

  void aDDS() {
    myBanner
      // typically this happens well before the ad is shown
      ..load()
      ..show(
        // Positions the banner ad 60 pixels from the bottom of the screen
        anchorOffset: 0.0,

        // Banner Position
        anchorType: AnchorType.bottom,
      );
  }

  @override
  void dispose() {
    super.dispose();
  }

  /*_load() async {
   SharedPreferences prefs = await SharedPreferences.getInstance();
   setState(() {
     ca = (prefs.getString('cat') ?? "in");
   });
 }*/
  _assign(String cas) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Future.delayed(const Duration(seconds: 2), () {
      prefs.setString('cat', cas);
      ca = (prefs.getString('cat'));
      print(ca);
    });
  }

  _loads() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      ca = (prefs.getString('cat') ?? '');
    });
  }

  _loadrate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      rate = (prefs.getString('rate') ?? 0);
    });
  }

  _assignRate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Future.delayed(const Duration(seconds: 2), () {
      prefs.setInt('rate', 1);
      rate = (prefs.getInt('rate'));
      print(rate);
    });
  }

  Future<List<Article>> getData(String newsType) async {
    String link;
    link = "https://newsapi.org/v2/top-headlines?country=" +
        newsType +
        "&category=technology&apiKey=652e11c0a7bc41d49838e5c49d49be36";

    var res = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    print(res.body);
    setState(() {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        var rest = data["articles"] as List;
        print(rest);
        list = rest.map<Article>((json) => Article.fromJson(json)).toList();
      }
    });
    print("List Size: ${list.length}");
    return list;
  }

  @override
  Widget build(BuildContext context) {
    int ss = 11;
    return new RepaintBoundary(
      key: screen,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "TechnoBuzz",
            style: TextStyle(color: Colors.black54),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.star),
              onPressed: () {
                _neverSatisfied();
              },
            ),
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
          color: Colors.white,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: Image.asset(
                          imgUrl,
                          width: double.infinity,
                        ),
                      ),
                      flex: 1,
                    ),
                    Padding(padding: EdgeInsets.all(7)),
                    Expanded(
                      child: Container(
                        height: 50,
                        child: ListView(
                          padding: EdgeInsets.all(0.2),
                          scrollDirection: Axis.vertical,
                          children: <Widget>[
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    list.clear();
                                    getData('ar');
                                    flag('ar');
                                    _assign('ar');
                                  });
                                },
                                child: Image.asset("ar.png",
                                    height: MediaQuery.of(context).size.height /
                                        ss)),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    list.clear();
                                    getData('au');
                                    flag('au');
                                    _assign('au');
                                  });
                                },
                                child: Image.asset("au.png",
                                    height: MediaQuery.of(context).size.height /
                                        ss)),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    list.clear();
                                    getData('at');
                                    flag('at');
                                    _assign('at');
                                  });
                                },
                                child: Image.asset("at.png",
                                    height: MediaQuery.of(context).size.height /
                                        ss)),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  list.clear();
                                  _assign('be');
                                  getData("be");
                                  flag("be");
                                });
                              },
                              child: Image.asset("be.png",
                                  height:
                                      MediaQuery.of(context).size.height / ss),
                            ),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    list.clear();
                                    getData("bg");
                                    flag("bg");
                                    _assign('bg');
                                  });
                                },
                                child: Image.asset("bg.png",
                                    height: MediaQuery.of(context).size.height /
                                        ss)),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    list.clear();
                                    getData("br");
                                    flag("br");
                                    _assign('br');
                                  });
                                },
                                child: Image.asset("br.png",
                                    height: MediaQuery.of(context).size.height /
                                        ss)),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    list.clear();
                                    getData("ca");
                                    flag("ca");
                                    _assign('ca');
                                  });
                                },
                                child: Image.asset("ca.png",
                                    height: MediaQuery.of(context).size.height /
                                        ss)),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    list.clear();
                                    getData("cn");
                                    flag("cn");
                                    _assign('cn');
                                  });
                                },
                                child: Image.asset("cn.png",
                                    height: MediaQuery.of(context).size.height /
                                        ss)),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    list.clear();
                                    getData("co");
                                    flag("co");
                                    _assign('co');
                                  });
                                },
                                child: Image.asset("co.png",
                                    height: MediaQuery.of(context).size.height /
                                        ss)),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    list.clear();
                                    getData("cu");
                                    flag("cu");
                                    _assign('cu');
                                  });
                                },
                                child: Image.asset("cu.png",
                                    height: MediaQuery.of(context).size.height /
                                        ss)),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    list.clear();
                                    getData("cz");
                                    flag("cz");
                                    _assign('cz');
                                  });
                                },
                                child: Image.asset("cz.png",
                                    height: MediaQuery.of(context).size.height /
                                        ss)),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    list.clear();
                                    getData("de");
                                    flag("de");
                                    _assign('de');
                                  });
                                },
                                child: Image.asset("de.png",
                                    height: MediaQuery.of(context).size.height /
                                        ss)),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    list.clear();
                                    getData("eg");
                                    flag("eg");
                                    _assign('eg');
                                  });
                                },
                                child: Image.asset("eg.png",
                                    height: MediaQuery.of(context).size.height /
                                        ss)),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    list.clear();
                                    getData("fr");
                                    flag("fr");
                                    _assign('fr');
                                  });
                                },
                                child: Image.asset("fr.png",
                                    height: MediaQuery.of(context).size.height /
                                        ss)),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    list.clear();
                                    getData("gb");
                                    flag("gb");
                                    _assign('gb');
                                  });
                                },
                                child: Image.asset("gb.png",
                                    height: MediaQuery.of(context).size.height /
                                        ss)),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    list.clear();
                                    getData("hk");
                                    flag("hk");
                                    _assign('hk');
                                  });
                                },
                                child: Image.asset("hk.png",
                                    height: MediaQuery.of(context).size.height /
                                        ss)),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    list.clear();
                                    getData("hu");
                                    flag("hu");
                                    _assign('hu');
                                  });
                                },
                                child: Image.asset("hu.png",
                                    height: MediaQuery.of(context).size.height /
                                        ss)),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    list.clear();
                                    getData("in");
                                    flag("in");
                                    _assign('in');
                                  });
                                },
                                child: Image.asset("in.png",
                                    height: MediaQuery.of(context).size.height /
                                        ss)),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    list.clear();
                                    getData("id");
                                    flag("id");
                                    _assign('id');
                                  });
                                },
                                child: Image.asset("id.png",
                                    height: MediaQuery.of(context).size.height /
                                        ss)),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    list.clear();
                                    getData("ie");
                                    flag("ie");
                                    _assign('ie');
                                  });
                                },
                                child: Image.asset("ie.png",
                                    height: MediaQuery.of(context).size.height /
                                        ss)),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    list.clear();
                                    getData("us");
                                    flag("us");
                                    _assign('co');
                                  });
                                },
                                child: Image.asset("us.png",
                                    height: MediaQuery.of(context).size.height /
                                        ss)),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    list.clear();
                                    getData("il");
                                    flag("il");
                                    _assign('il');
                                  });
                                },
                                child: Image.asset("il.png",
                                    height: MediaQuery.of(context).size.height /
                                        ss)),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    list.clear();
                                    getData("it");
                                    flag("it");
                                    _assign('it');
                                  });
                                },
                                child: Image.asset("it.png",
                                    height: MediaQuery.of(context).size.height /
                                        ss)),
                          ],
                        ),
                      ),
                      flex: 9,
                    ),
                  ],
                ), /*Container(



              child: ListView(
             padding: EdgeInsets.all(0.4),

                scrollDirection: Axis.vertical,
                children: <Widget>[
                  GestureDetector(onTap: (){
                    setState(() {
                      getData("ar");
                      list.clear();
                    });

                  },
                      child: Image.asset("bs.png",height: MediaQuery.of(context).size.height/9,fit: BoxFit.fill)),
                  GestureDetector(onTap: (){
                    setState(() {
                      getData("in");
                      list.clear();
                    });


                  },
                      child: Image.asset("bs.png",height: MediaQuery.of(context).size.height/9,fit: BoxFit.fill)),
                  GestureDetector(onTap: (){},
                      child:Image.asset("bs.png",height: MediaQuery.of(context).size.height/9,fit: BoxFit.fill)),
                  GestureDetector(onTap: (){},
                      child: Image.asset("bs.png",height: MediaQuery.of(context).size.height/9,fit: BoxFit.fill)),
                  GestureDetector(onTap: (){},
                      child: Image.asset("bs.png",height: MediaQuery.of(context).size.height/9,fit: BoxFit.fill)),
                  GestureDetector(onTap: (){},
                      child:Image.asset("bs.png",height: MediaQuery.of(context).size.height/9,fit: BoxFit.fill)),
                  GestureDetector(onTap: (){},
                      child: Image.asset("bs.png",height: MediaQuery.of(context).size.height/9,fit: BoxFit.fill)),
                  GestureDetector(onTap: (){},
                      child: Image.asset("bs.png",height: MediaQuery.of(context).size.height/9,fit: BoxFit.fill)),
                  GestureDetector(onTap: (){},
                      child:Image.asset("bs.png",height: MediaQuery.of(context).size.height/9,fit: BoxFit.fill)),
                  GestureDetector(onTap: (){},
                      child: Image.asset("bs.png",height: MediaQuery.of(context).size.height/9,fit: BoxFit.fill)),
                  GestureDetector(onTap: (){},
                      child: Image.asset("bs.png",height: MediaQuery.of(context).size.height/9,fit: BoxFit.fill)),
                  GestureDetector(onTap: (){},
                      child:Image.asset("bs.png",height: MediaQuery.of(context).size.height/9,fit: BoxFit.fill)),

                ],

              ),

            ),*/
              ),
              Expanded(
                flex: 8,
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        flex: 0,
                        child: Container(
                          color: Colors.pinkAccent,
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: Container(
                          child: loader(list),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void flag(String ff) {
    print(imgUrl);
    if (ff == "") {
      setState(() {
        imgUrl = "in.png";
      });
    } else {
      setState(() {
        imgUrl = ff + ".png";
      });
    }
  }

  void screenShot() async {
    RenderRepaintBoundary boundary = screen.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    var filePath = await ImagePickerSaver.saveFile(
        fileData: byteData.buffer.asUint8List());

    print(filePath);
    final ByteData bytes = await rootBundle.load(filePath);
    _getShare(filePath, "");
    //final ByteData bytes = await rootBundle.load('assets/image.png');
// await EsysFlutterShare.shareImage('myImageTest.png', bytes, 'my image title');
  }

  void _onLoadingdw(bool t) {
    if (t) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              children: <Widget>[
                Container(
                  height: 70,
                  width: 70,
                  child: Column(
                    children: <Widget>[
                      new CircularProgressIndicator(),
                      new Text("Setting wallpaper.."),
                    ],
                  ),
                ),
              ],
            );
          });
    } else {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              children: <Widget>[
                Container(
                  height: 70,
                  width: 70,
                  child: CircularProgressIndicator(),
                ),
              ],
            );
          });

      new Future.delayed(new Duration(seconds: 1), () {
        //pop dialog

        Navigator.pop(context);
      });
    }
  }
}

class Article {
  Source source;
  String author;
  String title;
  String description;
  String url;
  String urlToImage;
  String publishedAt;
  String content;

  Article(
      {this.source,
      this.author,
      this.title,
      this.description,
      this.url,
      this.urlToImage,
      this.publishedAt,
      this.content});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
        source: Source.fromJson(json["source"]),
        author: json["author"],
        title: json["title"],
        description: json["description"],
        url: json["url"],
        urlToImage: json["urlToImage"],
        publishedAt: json["publishedAt"],
        content: json["content"]);
  }
}

class Source {
  String id;
  String name;

  Source({this.id, this.name});

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json["id"] as String,
      name: json["name"] as String,
    );
  }
}

Widget listViewWidget(List<Article> article) {
  if (article.length != 0) {
    return Container(
      child: ListView.builder(
          itemCount: article.length,
          padding: const EdgeInsets.all(2.0),
          itemBuilder: (context, position) {
            return GestureDetector(
                child: Container(
                  height: MediaQuery.of(context).size.height / 2.5,
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          article[position].title,
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Expanded(
                        flex: 8,
                        child: Container(
                          child: Card(
                            elevation: 5.0,
                            child: Stack(
                              children: <Widget>[
                                /* Center(child: CircularProgressIndicator()),
                                Image.network('${article[position].urlToImage}',fit: BoxFit.fill,width: MediaQuery.of(context).size.width,)*/
                                Center(child: CircularProgressIndicator()),
                                FadeInImage.memoryNetwork(
                                  fadeInDuration: const Duration(seconds: 2),
                                  fadeInCurve: Curves.bounceIn,
                                  placeholder: kTransparentImage,
                                  image: '${article[position].urlToImage}',
                                  fit: BoxFit.fill,
                                  width: MediaQuery.of(context).size.width,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Text(article[position].source.name),
                              // Text('${article[position].source.name}'+article[position].publishedAt.substring(0,10))
                            ],
                          ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(6.0))
                    ],
                  ),
                ),
                /*child: ListTile(
              title: Text(
                '${article[position].title}',
                style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  child: article[position].urlToImage == null
                      ? Image(
                    image: AssetImage('images/no_image_available.png'),
                  )
                      : Image.network('${article[position].urlToImage}'),
                  height: 100.0,
                  width: 100.0,
                ),
              ),
             // onTap: () => _onTapItem(context, article[position]),
            ),*/
                onTap: () {
                  /*  if(article[position].urlToImage==null||article[position].title==null||article[position].description==null
                ||article[position].content==null||article[position].source.name==null||article[position].url==null){
                  article[position].urlToImage="";
                  article[position].description="";
                  article[position].title="";
                  article[position].content="";
                  article[position].source.name="";
                  article[position].url="";

                }*/

                  if (article[position].urlToImage == null) {
                    article[position].urlToImage = "";
                  }
                  if (article[position].title == null) {
                    article[position].title = "";
                  }
                  if (article[position].description == null) {
                    article[position].description = "";
                  }
                  if (article[position].content == null) {
                    article[position].content = "";
                  }
                  if (article[position].source.name == null) {
                    article[position].source.name = "";
                  }

                  if (article[position].url == null) {
                    article[position].url = "";
                  }

                  Future.delayed(const Duration(milliseconds: 20), () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MainPage(
                                  url: article[position].url,
                                  description: article[position].description,
                                  name: article[position].source.name,
                                  urlToImage: article[position].urlToImage,
                                  title: article[position].title,
                                  content: article[position].content,
                                )));
                  });
                });
          }),
    );
  } else {
    return Center(child: CircularProgressIndicator());
  }
}

Widget loader(List article) {
  if (article == null) {
    return Center(child: CircularProgressIndicator());
  } else {
    return listViewWidget(article);
  }
}
