import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:cirrus_map_view/map_view.dart';
import 'dart:async';

class MapTab extends StatefulWidget {
  MapTab({Key key}) : super(key: key) {
    // MapView.setApiKey('AIzaSyBbNgT-eMt0CkypNRgKLmLngUUc2G1aN5s');
  }

  @override
  MapTabState createState() => new MapTabState();
}

class MapTabState extends State<MapTab> {

  Completer<GoogleMapController> _controller = Completer();
  // 初始坐标
  static final CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 4,
  );
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            height: double.infinity,
          ),
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              print('mapCreated');
            },
            myLocationEnabled: true,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(           // 搜索框边距
                margin: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Container(    // 搜索框
                  decoration: BoxDecoration(
                    color: Color.fromARGB(192, 255, 255, 255),
                    borderRadius: BorderRadius.all(Radius.circular(999))
                  ),
                  padding: EdgeInsets.all(4),
                  width: MediaQuery.of(context).size.width - 16 - 16,
                  child: GestureDetector(
                    child: Row(
                      children: <Widget>[
                        Container(child: Icon(Icons.search, color: Colors.black87), margin: EdgeInsets.fromLTRB(8, 0, 8, 0)),
                        Text('直接翻译/搜索动态/景点', style: TextStyle(fontSize: 16, color: Colors.black54)),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.center,  // 垂直居中
                    ),     
                    onTap: () async {
                      print("点击了搜索框");
                      final GoogleMapController controller = await _controller.future;
                      
                    },
                  ) 
                ),
                
              ),
            )
          )
        ],
      ),
    );
  }

}
