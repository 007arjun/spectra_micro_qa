import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLHelper {
  static final SQLHelper _instance = SQLHelper._internal();

  factory SQLHelper() => _instance;

  SQLHelper._internal();

  static Database? _database;

  static final String tableUsers = 'users';
  static final String tableProducts = 'products';
  static final String tableBranches = 'branches';
  static final String tableForms = 'forms';
  static final String tableFormFields = 'formFields';

  static final String columnUserId = 'id';
  static final String columnName = 'name';
  static final String columnEmail = 'email';
  static final String columnPhone = 'phone';
  static final String columnPassword = 'password';
  static final String columnProfileImage = 'profileImage';

  static final String columnProductId = 'id';
  static final String columnProductName = 'name';
  static final String columnProductDescription = 'description';
  static final String columnProductAddedDate = 'addedDate';
  static final String columnProductBatchName = 'batchName';
  static final String columnProductImagePath = 'imagePath';
  static final String columnProductUserId = 'userId';

  static final String columnBranchId = 'id';
  static final String columnBranchName = 'name';
  static final String columnBranchDate = 'date';
  static final String columnBranchQuantity = 'quantity';
  static final String columnBranchSerialNumber = 'serialNumber';
  static final String columnBranchManufacturer = 'manufacturer';

  static final String columnFormId = 'id';
  static final String columnFormTitle = 'title';
  static final String columnFormCreatedOn = 'createdOn';
  static final String columnFormFieldId = 'fieldId';
  static final String columnFormFieldTitle = 'fieldtitle';
  static final String columnFormFieldType = 'type';
  static final String columnFormFieldFormId = 'formFieldId';
  static final String columnFormFieldSelectedOption = 'selectedOption';
  static final String columnFormFieldComment = 'comment';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'your_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableUsers (
            $columnUserId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnName TEXT NOT NULL,
            $columnEmail TEXT NOT NULL,
            $columnPhone TEXT NOT NULL,
            $columnPassword TEXT NOT NULL,
            $columnProfileImage TEXT,
            UNIQUE ($columnEmail)
          )
        ''');

        await db.execute('''
          CREATE TABLE $tableProducts (
            $columnProductId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnProductName TEXT NOT NULL,
            $columnProductDescription TEXT NOT NULL,
            $columnProductAddedDate TEXT NOT NULL,
            $columnProductImagePath TEXT NOT NULL,
            $columnProductBatchName TEXT NOT NULL,
            $columnProductUserId INTEGER NOT NULL,
            FOREIGN KEY ($columnProductUserId) REFERENCES $tableUsers($columnUserId)
          )
        ''');

        await db.execute('''
          CREATE TABLE $tableBranches (
            $columnBranchId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnBranchName TEXT NOT NULL,
            $columnBranchDate TEXT NOT NULL,
            $columnBranchQuantity TEXT NOT NULL,
            $columnBranchSerialNumber TEXT NOT NULL,
            $columnBranchManufacturer TEXT NOT NULL
          )
        ''');

        Map<String, dynamic> defaultBranch = {
          columnBranchName: '2024-01',
          columnBranchDate: '2024-01-01',
          columnBranchQuantity: '50',
          columnBranchSerialNumber: 'SN001',
          columnBranchManufacturer: 'Spectrum Softtech Solution',
        };
        await db.insert(tableBranches, defaultBranch);

        await db.execute('''
          CREATE TABLE $tableForms (
            $columnFormId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnFormTitle TEXT NOT NULL,
            $columnFormCreatedOn TEXT NOT NULL
          )
        ''');

        Map<String, dynamic> defaultForm = {
          columnFormTitle: 'Form 1',
          columnFormCreatedOn: '2024-01-01',
        };
        int formId = await db.insert(tableForms, defaultForm);

        await db.execute('''
        CREATE TABLE $tableFormFields (
          $columnFormFieldId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnFormFieldTitle TEXT NOT NULL,
          $columnFormFieldType TEXT NOT NULL,
          $columnFormFieldFormId INTEGER,
          $columnFormFieldSelectedOption TEXT,
          $columnFormFieldComment TEXT, 
          FOREIGN KEY ($columnFormFieldFormId) REFERENCES $tableForms($columnFormId)
        )
      ''');
        List<Map<String, dynamic>> defaultFormFields = [
          {
            columnFormFieldId:'1',
            columnFormFieldTitle: 'Power LED',
            columnFormFieldType: 'Radio Button',
            columnFormFieldFormId: formId,
            columnFormFieldSelectedOption: 'OK',
            columnFormFieldComment: '',
          },
          {
            columnFormFieldId:'2',
            columnFormFieldTitle: 'ESP WiFi',
            columnFormFieldType: 'Radio Button',
            columnFormFieldFormId: formId,
            columnFormFieldSelectedOption: 'NOT OK',
            columnFormFieldComment: '',
          },
          {
            columnFormFieldId:'3',
            columnFormFieldTitle: 'Power On Announcement',
            columnFormFieldType: 'Radio Button',
            columnFormFieldFormId: formId,
            columnFormFieldSelectedOption: 'OK',
            columnFormFieldComment: '',
          },
          {
            columnFormFieldId:'4',
            columnFormFieldTitle: 'Installation ID Announcement',
            columnFormFieldType: 'Radio Button',
            columnFormFieldFormId: formId,
            columnFormFieldSelectedOption: 'OK',
            columnFormFieldComment: '',
          },
          {
            columnFormFieldId:'5',
            columnFormFieldTitle: 'Web Interface',
            columnFormFieldType: 'Radio Button',
            columnFormFieldFormId: formId,
            columnFormFieldSelectedOption: 'NOT OK',
            columnFormFieldComment: '',
          },
          {
            columnFormFieldId:'6',
            columnFormFieldTitle: 'Check Offset Height Announcer',
            columnFormFieldType: 'Radio Button',
            columnFormFieldFormId: formId,
            columnFormFieldSelectedOption: 'OK',
            columnFormFieldComment: '',
          },
          {
            columnFormFieldId:'7',
            columnFormFieldTitle: 'Test Audio',
            columnFormFieldType: 'Radio Button',
            columnFormFieldFormId: formId,
            columnFormFieldSelectedOption: 'NOT OK',
            columnFormFieldComment: '',
          },
          {
            columnFormFieldId:'8',
            columnFormFieldTitle: 'LiDAR',
            columnFormFieldType: 'Radio Button',
            columnFormFieldFormId: formId,
            columnFormFieldSelectedOption: 'NOT Ok',
            columnFormFieldComment: '',
          },
          {
            columnFormFieldId:'9',
            columnFormFieldTitle: 'GPS',
            columnFormFieldType: 'Radio Button',
            columnFormFieldFormId: formId,
            columnFormFieldSelectedOption: 'OK',
            columnFormFieldComment: '',
          },
          {
            columnFormFieldId:'10',
            columnFormFieldTitle: 'Temperature',
            columnFormFieldType: 'Radio Button',
            columnFormFieldFormId: formId,
            columnFormFieldSelectedOption: 'OK',
            columnFormFieldComment: '',
          },
          {
            columnFormFieldId:'11',
            columnFormFieldTitle: 'Landing Gear',
            columnFormFieldType: 'Radio Button',
            columnFormFieldFormId: formId,
            columnFormFieldSelectedOption: 'OK',
            columnFormFieldComment: '',
          },
          {
            columnFormFieldId:'12',
            columnFormFieldTitle: 'BT',
            columnFormFieldType: 'Radio Button',
            columnFormFieldFormId: formId,
            columnFormFieldSelectedOption: 'OK',
            columnFormFieldComment: '',
          },
          {
            columnFormFieldId:'13',
            columnFormFieldTitle: 'Comment',
            columnFormFieldType: 'Comment',
            columnFormFieldFormId: formId,
            columnFormFieldSelectedOption: '',
            columnFormFieldComment: 'addd',
          },

        ];

        for (Map<String, dynamic> field in defaultFormFields) {
          await db.insert(tableFormFields, field);
        }
      },
    );
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert(tableUsers, user);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      tableUsers,
      where: '$columnEmail = ?',
      whereArgs: [email],
    );

    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateUserPassword(String email, String newPassword) async {
    Database db = await database;
    return await db.update(
      tableUsers,
      {'password': newPassword},
      where: '$columnEmail = ?',
      whereArgs: [email],
    );
  }

  Future<int> updateUser(String email, String name, String updatedEmail, String phone, String profileImage) async {
    Database db = await database;
    return await db.update(
      tableUsers,
      {
        columnName: name,
        columnEmail: updatedEmail,
        columnPhone: phone,
        columnProfileImage: profileImage,
      },
      where: '$columnEmail = ?',
      whereArgs: [email],
    );
  }

  Future<int> insertProduct(Map<String, dynamic> product, int userUniqueIdentifier) async {
    Database db = await database;
    product[columnProductUserId] = userUniqueIdentifier;
    return await db.insert(tableProducts, product);
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    Database db = await database;
    return await db.query(tableProducts);
  }

  Future<int> insertProfileImage(String userEmail, String imagePath) async {
    Database db = await database;
    return await db.update(
      tableUsers,
      {columnProfileImage: imagePath},
      where: '$columnEmail = ?',
      whereArgs: [userEmail],
    );
  }

  Future<int> updateProduct(String productName, Map<String, dynamic> updatedProduct) async {
    Database db = await database;
    return await db.update(
      tableProducts,
      updatedProduct,
      where: '$columnProductName = ?',
      whereArgs: [productName],
    );
  }

  Future<int> deleteProduct(String productName) async {
    Database db = await database;
    return await db.delete(
      tableProducts,
      where: '$columnProductName = ?',
      whereArgs: [productName],
    );
  }

  Future<int> insertBranch(Map<String, dynamic> branch) async {
    Database db = await database;
    return await db.insert(tableBranches, branch);
  }

  Future<List<Map<String, dynamic>>> getAllBranches() async {
    Database db = await database;
    return await db.query(tableBranches);
  }

  Future<int> updateBatch(String oldBatchName, Map<String, dynamic> updatedBatch) async {
    Database db = await SQLHelper().database;
    return await db.update(
      tableBranches,
      updatedBatch,
      where: '$columnBranchName = ?',
      whereArgs: [oldBatchName],
    );
  }

  Future<int> deleteBatch(int batchId) async {
    Database db = await database;
    return await db.delete(
      tableBranches,
      where: '$columnBranchId = ?',
      whereArgs: [batchId],
    );
  }

  Future<List<String>> getAllBatchNames() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(tableBranches, columns: [columnBranchName]);
    return result.map((map) => map[columnBranchName] as String).toList();
  }

  Future<Map<String, dynamic>> insertForm(Map<String, dynamic> formData, List<Map<String, dynamic>> formFields) async {
    Database db = await database;
    int formId = await db.insert(tableForms, formData);

    for (Map<String, dynamic> field in formFields) {
      field[columnFormFieldFormId] = formId;
      await db.insert(tableFormFields, field);
    }

    List<Map<String, dynamic>> insertedFormData = await db.query(
      tableForms,
      where: '$columnFormId = ?',
      whereArgs: [formId],
    );

    return insertedFormData.isNotEmpty ? insertedFormData.first : {};
  }

  Future<List<Map<String, dynamic>>> fetchFormsForUser(String? userId) async {
    try {
      final db = await database;
      List<Map<String, dynamic>> forms = await db.rawQuery('yourQuery');
      return forms;
    } catch (e) {
      print('Error fetching forms: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllForms() async {
    Database db = await database;
    return await db.query(tableForms);
  }

  Future<Map<String, dynamic>> fetchFormDetails(int formId) async {
    Database db = await database;
    List<Map<String, dynamic>> formDetails = await db.query(
      tableForms,
      where: '$columnFormId = ?',
      whereArgs: [formId],
    );

    return formDetails.isNotEmpty ? formDetails.first : {};
  }

  Future<int> _generateDefaultUserId() async {
    Database db = await _instance.database;
    List<Map<String, dynamic>> result =
    await db.rawQuery('SELECT MAX($columnUserId) as maxId FROM $tableUsers');
    int maxId = result.isNotEmpty ? (result.first['maxId'] ?? 0) : 0;
    return maxId + 1;
  }

  Future<void> _generateDefaultProduct(int defaultUserId) async {
    Map<String, dynamic> defaultProduct = {
      columnProductName: 'SkyVoiceAlert 500',
      columnProductDescription:
      'LLC’s SkyVoice Alert (FAA Approved) announces the heights through the pilots headset when the LiDAR (Laser) measures a set of predefined altitudes.',
      columnProductAddedDate: '2024-01-01',
      columnProductImagePath: 'assets/product.jpeg',
      columnProductBatchName: '2024-01',
      columnProductUserId: defaultUserId,
    };

    await _instance.insertProduct(defaultProduct, defaultUserId);
  }

  Future<int> initDefaultData() async {
    int defaultUserId = await _generateDefaultUserId();

    Database db = await _instance.database;
    List<Map<String, dynamic>> existingProducts = await db.query(
      tableProducts,
      where: '$columnProductUserId = ?',
      whereArgs: [defaultUserId],
    );

    if (existingProducts.isEmpty) {
      await _generateDefaultProduct(defaultUserId);
    }

    return defaultUserId;
  }

  Future<void> updateFormAndFields(int formId, String formTitle, List<Map<String, dynamic>> updatedFormFields) async {
    Database db = await database;

    await db.update(
      tableForms,
      {columnFormTitle: formTitle},
      where: '$columnFormId = ?',
      whereArgs: [formId],
    );

    for (Map<String, dynamic> field in updatedFormFields) {
      int fieldId = field[columnFormFieldId];
      int formFieldFormId = field[columnFormFieldFormId];

      await db.update(
        tableFormFields,
        field,
        where: '$columnFormFieldId = ? AND $columnFormFieldFormId = ?',
        whereArgs: [fieldId, formFieldFormId],
      );
    }
  }

  Future<int> updateFormField(int fieldId, String title, String comment, String selectedOption) async {
    Database db = await database;
    return await db.update(
      tableFormFields,
      {
        columnFormFieldTitle: title,
        columnFormFieldComment: comment,
        columnFormFieldSelectedOption: selectedOption,
      },
      where: '$columnFormFieldId = ?',
      whereArgs: [fieldId],
    );
  }

  Future<List<Map<String, dynamic>>> getFormsByProductId(int productId) async {
    Database db = await database;
    return await db.query(
      tableForms,
      where: '$columnProductId = ?',
      whereArgs: [productId],
    );
  }

}
