import 'dart:io';
import 'package:flutter/material.dart';
import 'package:a03_farming/src/services/database_helper.dart'; // Import the DatabaseHelper class

class DetailPage extends StatefulWidget {
  final int cropId;

  const DetailPage({super.key, required this.cropId});

  @override
  DetailPageState createState() => DetailPageState();
}

class DetailPageState extends State<DetailPage> {
  late Map<String, dynamic> _crop;
  late List<Map<String, dynamic>> _images;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCropData();
  }

  Future<void> _loadCropData() async {
    final crops = await DatabaseHelper.getCrops();
    if (crops.isNotEmpty) {
      _crop = crops.firstWhere((crop) => crop['id'] == widget.cropId);

      _images = await DatabaseHelper.getImagesForCrop(widget.cropId);

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Loading...'),
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.black),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_crop['name'] ?? ''),
      ),
      body: Scrollbar(
        // thumbVisibility: true, // Set this property to true
        thickness: 5,
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _images.isNotEmpty
                  ? SizedBox(
                      height: 400,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Image.file(
                              File(_images[index]['image_path']),
                              fit: BoxFit.cover,
                              width: 300,
                            ),
                          );
                        },
                      ),
                    )
                  : Text('No images available'),
              SizedBox(height: 10),
              Text(_crop['description'] ?? ''),
            ],
          ),
        ),
      ),
    );
  }
}
