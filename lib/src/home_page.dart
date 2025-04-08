import 'package:flutter/material.dart';
import 'package:a03_farming/src/services/database_helper.dart';
import 'package:a03_farming/src/detail_page.dart';
import 'package:a03_farming/src/widgets/weather.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>> _crops;

  @override
  void initState() {
    super.initState();
    _crops = _fetchCrops();
  }

  Future<List<Map<String, dynamic>>> _fetchCrops() async {
    return await DatabaseHelper.getCrops();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () async {
            await DatabaseHelper.logoutUser();
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        centerTitle: true,
        title: Text('Welcome!'),
      ),
      body: Column(
        children: [
          Weather(),
          Expanded(
            child: FutureBuilder(
              future: _crops,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: Text('Loading...'));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No crops available.'));
                }

                return Column(
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'Farming Tips',
                      style: TextStyle(fontSize: 20),
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var crop = snapshot.data![index];
                          return Column(
                            children: [
                              ListTile(
                                title: Text(crop['name']),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DetailPage(cropId: crop['id'])),
                                  );
                                },
                              ),
                              if (index < snapshot.data!.length)
                                Divider(
                                  height: 1,
                                  color: Colors.grey,
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
