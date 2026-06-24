import 'package:flutter/material.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/widgets/app_button.dart';

class LeaderCovenantSignatureScreen extends StatefulWidget {
  const LeaderCovenantSignatureScreen({super.key});

  @override
  State<LeaderCovenantSignatureScreen> createState() =>
      _LeaderCovenantSignatureScreenState();
}

class _LeaderCovenantSignatureScreenState
    extends State<LeaderCovenantSignatureScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _agreedToBeliefs = false;
  bool _agreedToCommitments = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leader Covenant'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            const Text(
              'Leader Covenant & Statement of Faith',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'Please read the full Statement of Faith and Leader Commitments before signing.',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            CheckboxListTile(
              title: const Text(
                  'I affirm my agreement with the Statement of Faith.',),
              value: _agreedToBeliefs,
              onChanged: (val) =>
                  setState(() => _agreedToBeliefs = val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text(
                  'I voluntarily enter this covenant as a servant of Jesus Christ and a representative of Kingdom Heirs Foundation.',),
              value: _agreedToCommitments,
              onChanged: (val) =>
                  setState(() => _agreedToCommitments = val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppSpacing.xl),
            const Divider(),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'Digital Signature',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'By typing your full legal name below, you are signing this covenant electronically. This, combined with your IP address and timestamp, serves as your legally binding signature.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Type your Full Legal Name',
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Signature required';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xxxl),
            AppButton(
              label: 'Sign Covenant',
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  if (!_agreedToBeliefs || !_agreedToCommitments) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('You must check all affirmation boxes.'),),
                    );
                    return;
                  }
                  // Submit signature
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
