import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static final String _dbName = 'crops.db';
  static final String _tableNameCrops = 'crops';
  static final String _tableNameImages = 'images';

  static FirebaseFirestore? _firestore;
  static Database? _database;

  // Default crop data (single source of truth)
  static const List<Map<String, dynamic>> defaultCrops = [
    {
      'name': 'Maize',
      'description': 'Maize, also known as corn in North American English, is a tall stout grass that produces cereal grain. It was domesticated by indigenous peoples in southern Mexico about 9,000 years ago from wild teosinte. Native Americans planted it alongside beans and squashes in the Three Sisters polyculture. The leafy stalk of the plant gives rise to male inflorescences or tassels which produce pollen, and female inflorescences called ears. The ears yield grain, known as kernels or seeds. In modern commercial varieties, these are usually yellow or white; other varieties can be of many colors. Maize relies on humans for its propagation. Since the Columbian exchange, it has become a staple food in many parts of the world, with the total production of maize surpassing that of wheat and rice. Much maize is used for animal feed, whether as grain or as the whole plant, which can either be baled or made into the more palatable silage. Sugar-rich varieties called sweet corn are grown for human consumption, while field corn varieties are used for animal feed, for uses such as cornmeal or masa, corn starch, corn syrup, pressing into corn oil, alcoholic beverages like bourbon whiskey, and as chemical feedstocks including ethanol and other biofuels. Maize is cultivated throughout the world; a greater weight of maize is produced each year than any other grain. In 2020, world production was 1.1 billion tonnes. It is afflicted by many pests and diseases; two major insect pests, European corn borer and corn rootworms, have each caused annual losses of a billion dollars in the US. Modern plant breeding has greatly increased output and qualities such as nutrition, drought tolerance, and tolerance of pests and diseases. Much maize is now genetically modified.',
      'images': ['maize1.jpg', 'maize2.jpg', 'maize3.jpg', 'maize4.jpg', 'maize5.jpg', 'maize6.jpg', 'maize7.jpg']
    },
    {
      'name': 'Beans',
      'description': 'A bean is the seed of any plant in the legume family (Fabaceae) used as a vegetable for human consumption or animal feed.[1] The seeds are often preserved through drying, but fresh beans are also sold. Most beans are traditionally soaked and boiled, but they can be cooked in many different ways,[2] including frying and baking, and are used in many traditional dishes throughout the world. The unripe seedpods of some varieties are also eaten whole as green beans or edamame (immature soybean), but fully ripened beans contain toxins like phytohemagglutinin and require cooking.',
      'images': ['beans1.jpg', 'beans2.jpg', 'beans3.jpg', 'beans4.jpg', 'beans5.jpg']
    },
    {
      'name': 'Peas',
      'description': 'Pea is a pulse, vegetable or fodder crop, but the word often refers to the seed or sometimes the pod of this flowering plant species. Carl Linnaeus gave the species the scientific name Pisum sativum in 1753 (meaning cultivated pea). Some sources now treat it as Lathyrus oleraceus;[1][2] however the need and justification for the change is disputed.[3] Each pod contains several seeds (peas), which can have green or yellow cotyledons when mature. Botanically, pea pods are fruit,[4] since they contain seeds and develop from the ovary of a (pea) flower. The name is also used to describe other edible seeds from the Fabaceae such as the pigeon pea (Cajanus cajan), the cowpea (Vigna unguiculata), the seeds from several species of Lathyrus and is used as a compound form for example Sturts desert pea. Peas are annual plants, with a life cycle of one year. They are a cool-season crop grown in many parts of the world; planting can take place from winter to early summer depending on location. The average pea weighs between 0.1 and 0.36 grams (0.004–0.013 oz).[5] The immature peas (and in snow peas and snap peas the tender pod as well) are used as a vegetable, fresh, frozen or canned; varieties of the species typically called field peas are grown to produce dry peas like the split pea shelled from a matured pod. These are the basis of pease porridge and pea soup, staples of medieval cuisine; in Europe, consuming fresh immature green peas was an innovation of early modern cuisine.',
      'images': ['peas1.jpg', 'peas2.jpg', 'peas3.jpg', 'peas4.jpg', 'peas5.jpg', 'peas6.jpg', 'peas7.jpg']
    },
    {
      'name': 'Wheat',
      'description': 'Wheat is a group of wild and domesticated grasses of the genus Triticum. They are cultivated for their cereal grains, which are staple foods around the world. Well-known wheat species and hybrids include the most widely grown common wheat (T. aestivum), spelt, durum, emmer, einkorn, and Khorasan or Kamut. The archaeological record suggests that wheat was first cultivated in the regions of the Fertile Crescent around 9600 BC. Wheat is grown on a larger area of land than any other food crop (220.7 million hectares or 545 million acres in 2021). World trade in wheat is greater than that of all other crops combined. In 2021, world wheat production was 771 million tonnes (850 million short tons), making it the second most-produced cereal after maize (known as corn in North America and Australia; wheat is often called corn in countries including Britain).[4] Since 1960, world production of wheat and other grain crops has tripled and is expected to grow further through the middle of the 21st century. Global demand for wheat is increasing because of the usefulness of gluten to the food industry.',
      'images': ['wheat1.jpg', 'wheat2.jpg', 'wheat3.jpg', 'wheat4.jpg', 'wheat5.jpg', 'wheat6.jpg']
    },
  ];

  DatabaseHelper._privateConstructor() {
    _firestore = FirebaseFirestore.instance;
  }

  static Future<FirebaseFirestore> get firestore async {
    _firestore ??= FirebaseFirestore.instance
      ..settings = const Settings(persistenceEnabled: true);
    return _firestore!;
  }

  static Future<Database> get database async {
    if (_database != null) return _database!;

    try {
      await Firebase.initializeApp();
      _database ??= await _initDB();
      return _database!;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Firestore: $e');
      }
      throw Exception('Failed to initialize Firestore');
    }
  }

  static Future<Database> _initDB({bool reset = true}) async {  // Change this to false for production
    if (reset) {
      await deleteDatabaseFile();
    }
    final path = join(await getDatabasesPath(), _dbName);

    // Recreate the database
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static Future<void> deleteDatabaseFile() async {
    final path = join(await getDatabasesPath(), _dbName);
    await databaseFactory.deleteDatabase(path);
    if (kDebugMode) print('Database deleted!');
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Create crops table
    await db.execute('''
      CREATE TABLE $_tableNameCrops (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');

    // Create images table
    await db.execute('''
      CREATE TABLE $_tableNameImages (
        image_id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_path TEXT NOT NULL,
        crop_id INTEGER NOT NULL,
        FOREIGN KEY (crop_id) REFERENCES $_tableNameCrops (id)
      )
    ''');

    // Create users table
    await db.execute('''
  CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT NOT NULL,
    password TEXT NOT NULL
  )
''');

    if (kDebugMode) {
      print("Tables created!");
    }

    // Initialize images and crops
    await _initImages(db);
    await _initFirestore();
  }

  static Future<void> _initImages(Database db) async {
    final dir = await getApplicationDocumentsDirectory();
    final cropsDir = Directory(join(dir.path, 'crops'));
    await cropsDir.create(recursive: true);

    // Insert crops first using the default data
    for (final crop in defaultCrops) {
      final cropId = await db.insert(_tableNameCrops, {
        'name': crop['name']!,
        'description': crop['description']!,
      });

      // Insert images if available
      final imageFiles =
          crop['images'].map((image) => image as String).toList();

      for (final imageFile in imageFiles) {
        final filePath = join(cropsDir.path, imageFile);
        if (!File(filePath).existsSync()) {
          try {
            final data =
                await rootBundle.load('assets/images/crops/$imageFile');
            await File(filePath).writeAsBytes(data.buffer.asUint8List());
          } catch (e) {
            if (kDebugMode) print('Error copying $imageFile: $e');
            continue;
          }
        }

        // Insert the image path with crop_id reference
        await db.insert(_tableNameImages, {
          'image_path': filePath,
          'crop_id': cropId, // Reference to the crop_id from crops table
        });
      }
    }
  }

  static Future<void> _initFirestore() async {
    final firestore = await DatabaseHelper.firestore;
    final cropsRef = firestore.collection('crops');
    final snapshot = await cropsRef.get();

    if (snapshot.docs.isNotEmpty) return;

    // Insert default crops into Firestore if they don't exist
    for (final crop in defaultCrops) {
      await cropsRef.add({
        'name': crop['name'],
        'description': crop['description'],
        'image_path': crop['images'].isNotEmpty
            ? crop['images'][0]
            : '', // Default to first image if available
      });
    }
  }

  static Future<int> registerUser(String email, String password) async {
    final db = await database;

    // Check if the email already exists
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      throw Exception('Email already exists');
    }

    // If email doesn't exist, insert the new user
    return await db.insert('users', {
      'email': email,
      'password': password, // In a real app, store a hashed password!
    });
  }

  static String? _currentUserEmail;

  static Future<Map<String, dynamic>?> loginUser(
      String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      _currentUserEmail = email;
    }
    return result.isNotEmpty ? result.first : null;
  }

  static Future<void> logoutUser() async {
    _currentUserEmail = null;
  }

  static Future<bool> isLoggedIn() async {
    return _currentUserEmail != null;
  }

  static Future<List<Map<String, dynamic>>> getCrops() async {
    return (await database).query(_tableNameCrops);
  }

  static Future<List<Map<String, dynamic>>> getImagesForCrop(int cropId) async {
    final db = await database;
    return db.query(
      _tableNameImages,
      where: 'crop_id = ?',
      whereArgs: [cropId],
    );
  }
}
