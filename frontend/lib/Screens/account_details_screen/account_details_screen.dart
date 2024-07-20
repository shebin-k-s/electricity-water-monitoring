import 'package:flutter/material.dart';

class AccountDetailsScreen extends StatelessWidget {
  final String name;
  final String email;

  const AccountDetailsScreen({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Details'),
      ),
      bottomNavigationBar: const BottomAppBar(
        color: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            AccountDetailsTile(
              icon: Icons.person,
              label: 'Name',
              value: name,
            ),
            const SizedBox(height: 16.0),
            AccountDetailsTile(
              icon: Icons.email,
              label: 'Email',
              value: email,
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}

class AccountDetailsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const AccountDetailsTile({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Color.fromARGB(255, 96, 66, 66),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
