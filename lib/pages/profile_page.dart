import 'package:flutter/material.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/services/auth_services.dart';
import 'package:flutter_app/utils/local_storage.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  dynamic profile;

  Future<void> fetchProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // final authBloc = context.read<AuthBloc>();

    final accessToken = authProvider.accesstoken;

    // final accessToken = authBloc.state.accessToken;
    try {
      AuthServices.getProfile(accessToken).then((value) {
        setState(() {
          profile = value;
        });
      });
    } catch (e) {
      // Handle error
      // print("Failed to fetch profile: $e");
    }
  }

  Future<void> handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

     // final authBloc = context.read<AuthBloc>();

    try {
      authProvider.setLogout();
      // authBloc.add(LogoutEvent());

      deleteData("ACCESS_TOKEN");
    } catch (e) {
      // print("Failed to logout: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  // Avatar
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: NetworkImage(profile["avatar"]),
                  ),

                  const SizedBox(height: 20),

                  // Name
                  Text(
                    profile["name"],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    profile["email"],
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const SizedBox(height: 40),

                  // Profile information
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text("Full Name"),
                          subtitle: Text(profile["name"]),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: const Text("Email"),
                          subtitle: Text(profile["email"]),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: const Text("Phone"),
                          subtitle: Text(profile["phone"]),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: handleLogout,
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        "Logout",
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
