import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'screens/login.dart';
import 'service/database.dart';

class EmployeeInfoScreen extends StatefulWidget {
  final String? username;
  final bool isAuthenticated;
  EmployeeInfoScreen(
      {super.key, required this.username, required this.isAuthenticated});
  final db = Database();

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<EmployeeInfoScreen> {
  late List<Map<String, dynamic>> employees = [];
  late bool isLoggedIn;

  @override
  void initState() {
    super.initState();
    isLoggedIn = widget.isAuthenticated;
    _verifyAuthentication();
  }

  void _verifyAuthentication() {
    if (!isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      _fetchEmployees();
    }
  }

  void showToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.green,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

  Future<void> _fetchEmployees() async {
    try {
      await widget.db.getConnection();
      final result = await widget.db.executeQuery('SELECT * FROM employees');
      setState(() {
        employees = result
            .map((row) => {
                  'id': row[0],
                  'fullname': row[1],
                  'dob': row[2]
                      .toString()
                      .substring(0, 10)
                      .split('-')
                      .reversed
                      .join('-'),
                  'address': row[3],
                })
            .toList();
        employees.sort((a, b) => a['id'].compareTo(b['id']));
      });
    } catch (e) {
      // ignore: avoid_print
      print('error: $e');
    } finally {
      await widget.db.connection?.close();
      // ignore: avoid_print
      print('Không lấy được dữ liệu');
    }
  }

  Future<void> addEmployeeInfo(
      String fullName, String dob, String address) async {
    try {
      await widget.db.getConnection();
      await widget.db.executeQuery(
        'SELECT addEmployeeInfo(@fullName, @dob, @address);',
        substitutionValues: {
          'fullName': fullName,
          'dob': dob,
          'address': address,
        },
      );
      setState(() {
        employees.add({
          'id': DateTime.now().millisecondsSinceEpoch,
          'fullname': fullName,
          'dob': dob,
          'address': address,
        });
      });
      showToast("Thêm nhân viên thành công!");
    } catch (e) {
      print('error: $e');
    } finally {
      await widget.db.connection?.close();
    }
  }

  void _showEmployeeForm() {
    final fullNameController = TextEditingController();
    final dateOfBirthController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Employee Information'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                TextField(
                  controller: dateOfBirthController,
                  decoration: const InputDecoration(labelText: 'Date of Birth'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      String formattedDate =
                          "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                      dateOfBirthController.text = formattedDate;
                    }
                  },
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                addEmployeeInfo(
                  fullNameController.text,
                  dateOfBirthController.text,
                  addressController.text,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> editInfoEmployee(
      int id, String fullName, String dob, String address) async {
    try {
      await widget.db.getConnection();
      await widget.db.executeQuery(
        'UPDATE employees SET full_name = @fullName, dob = @dob, address = @address WHERE id = @id;',
        substitutionValues: {
          'id': id,
          'fullName': fullName,
          'dob': dob,
          'address': address,
        },
      );
      await widget.db.connection?.close();
      showToast("Sửa thông tin thành công!");
      _fetchEmployees();
    } catch (e) {
      // ignore: avoid_print
      print('error editInfoEmployee: $e');
    } finally {
      // ignore: avoid_print
      print('Kết nối thất bại');
    }
  }

  void _showEditEmployeeDialog(Map<String, dynamic> employee) {
    final fullNameController =
        TextEditingController(text: employee['fullname']);
    final dateOfBirthController = TextEditingController(text: employee['dob']);
    final hometownController = TextEditingController(text: employee['address']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Employee Information'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                TextField(
                  controller: dateOfBirthController,
                  decoration: const InputDecoration(labelText: 'Date of Birth'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(employee['dob']),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      String formattedDate =
                          "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                      dateOfBirthController.text = formattedDate;
                    }
                  },
                ),
                TextField(
                  controller: hometownController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                editInfoEmployee(employee['id'], fullNameController.text,
                    dateOfBirthController.text, hometownController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteEmployeeInfo(int id) async {
    try {
      await widget.db.getConnection();
      await widget.db.executeQuery('DELETE FROM employees WHERE id = @id;',
          substitutionValues: {'id': id});
      await widget.db.connection?.close();
      showToast("Xóa thành công!");
      _fetchEmployees();
    } catch (e) {
      print(e);
    } finally {
      print('Kết nối không thành công');
    }
  }

  void showDeleteToast(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa nhân viên'),
          content: const Text('Bạn có chắc muốn xóa không?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                deleteEmployeeInfo(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future refreshData() async {
    await _fetchEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[200],
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Account - ${widget.username}'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: refreshData,
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _showEmployeeForm,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: employees.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Text(employee['id'].toString(),
                              style: TextStyle(color: Colors.white)),
                        ),
                        title: Text(employee['fullname'],
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date of Birth: ${employee['dob']}'),
                            Text('Address: ${employee['address']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _showEditEmployeeDialog(employee);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => showDeleteToast(employee['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
