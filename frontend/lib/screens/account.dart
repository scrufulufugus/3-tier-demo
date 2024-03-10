import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/account.dart';
import 'package:frontend/widgets/header.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountState();
}

class _AccountState extends State<AccountPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController currentPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: Consumer<AccountModel>(
        builder: (context, account, child) => FutureBuilder<AccountIn>(
          future: account.info,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Form(
                key: _formKey,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                        child: TextFormField(
                          initialValue: snapshot.data!.username,
                          readOnly: true,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(), labelText: "Username"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                        child: TextFormField(
                          controller: emailController
                            ..text = snapshot.data!.email,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(), labelText: "Email"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return null;
                            }
                            RegExp emailRegex = RegExp(r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}$");
                            if (!emailRegex.hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Password"),
                          validator: (value) {
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                        child: TextFormField(
                          controller: phoneController
                            ..text = snapshot.data!.phone,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Phone Number"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return null;
                            }
                            RegExp phoneRegex = RegExp(r"^(\+\d{2})?\d{10}$");
                            if (!phoneRegex.hasMatch(value)) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                        child: TextFormField(
                          controller: addressController
                            ..text = snapshot.data!.address,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Address"),
                          validator: (value) {
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                        child: TextFormField(
                          controller: currentPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Current Password"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your current password';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16.0),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                String? nullIfUnchanged(String? value, String? original) {
                                  if (value == null || value.isEmpty) {
                                    return null;
                                  }
                                  return value == original ? null : value;
                                }

                                // Submit to backend
                                AccountOut update = AccountOut(
                                  id: snapshot.data!.id,
                                  email: nullIfUnchanged(emailController.text.trim(), snapshot.data!.email),
                                  password: nullIfUnchanged(passwordController.text, snapshot.data!.password),
                                  phone: nullIfUnchanged(phoneController.text.trim(), snapshot.data!.phone),
                                  address: nullIfUnchanged(addressController.text.trim(), snapshot.data!.address),
                                );

                                // TODO: Make async call to update account
                                String status = await account.update(update, currentPasswordController.text);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(status)),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Please fill input')),
                                );
                              }
                            },
                            child: const Text('Submit'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
