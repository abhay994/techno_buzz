import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
  class Myweb extends StatefulWidget {
 String url;
 String name;
    Myweb({Key key, @required this.url,@required this.name}) : super(key: key);
    @override
    _MywebState createState() => new _MywebState();
  }
  
  class _MywebState extends State<Myweb> {
    @override
    Widget build(BuildContext context) {
      return new Stack(
        children: <Widget>[
      Container(

        child: const Center(

          child: CircularProgressIndicator() ,
        ),
      ),
      WebviewScaffold(url: widget.url,
          appBar: new AppBar(
            title: new Text(widget.name),

          ),
          withZoom: true,
          withLocalStorage: true,
         initialChild: Container(
           child: Center(child: CircularProgressIndicator(),),
           height:MediaQuery.of(context).size.height ,
           width: MediaQuery.of(context).size.width,
         ),


           ),



        ],
      );
    }
  }
  