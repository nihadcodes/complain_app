import 'package:complain_management/features/fabric/fabric_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../complain form/complain_form.dart';
import '../card view/card_view.dart';
import '../authentication/views/login_page.dart';
import '../../utils/local_storage/database_helper.dart';

class HomePage extends StatelessWidget {
  final String username;

  const HomePage({Key? key, required this.username}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage(title: 'Login')),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          Row(
            children: [
              const Icon(Icons.person_pin, color: Colors.white), // User icon
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(username),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _logout(context), // Pass context here
              ),
            ],
          ),
        ],
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 150),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,
                children: [
                  _buildCard(
                    context,
                    title: 'Complaint Form',
                    icon: Icons.edit,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ComplainForm(username: username),
                        ),
                      );
                    },
                  ),
                  _buildCard(
                    context,
                    title: 'View Complaints',
                    icon: Icons.view_list,
                    onTap: () async {
                      List<Map<String, dynamic>> complaints = await DatabaseHelper().getComplaints();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CardViewPage(complaintList: complaints),
                        ),
                      );
                    },
                  ),
                  _buildCard(
                    context,
                    title: 'Settings',
                    icon: Icons.settings,
                    onTap: () {
                      // Handle Settings tap
                    },
                  ),
                  _buildCard(
                    context,
                    title: 'Others',
                    icon: Icons.factory,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FabricPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required IconData icon, required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.blueAccent),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
