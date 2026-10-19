import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Practice 7 - Sign Up',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SignUpScreen(),
    );
  }
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthController = TextEditingController();

  final _emailFocus = FocusNode();

  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _birthController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  Future<void> _selectBirthDate() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final selected = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (selected == null) return;
    if (!mounted) return;

    setState(() {
      _birth = selected;
      _birthController.text = _formatDate(selected);
    });
  }

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Account created')));

      setState(() {
        _done = true;
      });
    }
  }

  void _startOver() {
    setState(() {
      _name.clear();
      _email.clear();
      _password.clear();
      _confirm.clear();
      _birthController.clear();

      _group = null;
      _birth = null;
      _agreed = false;
      _done = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_done ? 'Registration summary' : 'Sign up')),
      body: _done ? _buildSummary() : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create your account',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

            // Name
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _emailFocus.requestFocus(),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              validator: (v) {
                if ((v ?? '').trim().length < 2) {
                  return 'Name must have at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _email,
              focusNode: _emailFocus,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'name@kbtu.kz',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textCapitalization: TextCapitalization.none,
              textInputAction: TextInputAction.next,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              validator: (v) {
                final value = (v ?? '').trim();
                final at = value.indexOf('@');

                if (at <= 0 ||
                    !value.substring(at + 1).contains('.') ||
                    value.endsWith('.')) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password
            TextFormField(
              controller: _password,
              decoration: const InputDecoration(
                labelText: 'Password',
                helperText: 'At least 8 characters',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                setState(() {});
              },
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              validator: (v) {
                if ((v ?? '').length < 8) {
                  return 'Password must have at least 8 characters';
                }
                return null;
              },
            ),

            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: Text('${_password.text.length} of 8'),
            ),

            // Confirm password
            TextFormField(
              controller: _confirm,
              decoration: const InputDecoration(
                labelText: 'Confirm password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (_agreed) _signUp();
              },
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              validator: (v) {
                if ((v ?? '') != _password.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Group
            DropdownButtonFormField<String>(
              initialValue: _group,
              decoration: const InputDecoration(
                labelText: 'Group',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final group in groups)
                  DropdownMenuItem(value: group, child: Text(group)),
              ],
              onChanged: (value) {
                setState(() {
                  _group = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Choose a group';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Date of birth
            TextFormField(
              controller: _birthController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Date of birth',
                suffixIcon: Icon(Icons.calendar_month),
                border: OutlineInputBorder(),
              ),
              onTap: _selectBirthDate,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              validator: (_) {
                if (_birth == null) {
                  return 'Choose a date of birth';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Checkbox
            CheckboxListTile(
              title: const Text('I agree to the rules'),
              value: _agreed,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  _agreed = value ?? false;
                });
              },
            ),
            const SizedBox(height: 24),

            // Sign up
            FilledButton(
              onPressed: _agreed ? _signUp : null,
              child: const Text('Sign up'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.check_circle_outline, size: 64, color: Colors.teal),
          const SizedBox(height: 12),

          Text(
            'Account created successfully!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          SummaryCard(
            name: _name.text.trim(),
            email: _email.text.trim(),
            group: _group ?? '',
            birthDate: _birthController.text,
          ),
          const SizedBox(height: 16),

          TextButton(onPressed: _startOver, child: const Text('Start over')),
        ],
      ),
    );
  }
}
