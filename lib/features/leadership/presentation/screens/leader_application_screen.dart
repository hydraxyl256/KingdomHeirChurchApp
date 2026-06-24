import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/widgets/app_button.dart';
import 'package:kingdom_heir/features/leadership/domain/entities/leader_application.dart';
import 'package:kingdom_heir/features/leadership/presentation/providers/leadership_provider.dart';

class LeaderApplicationScreen extends ConsumerStatefulWidget {
  const LeaderApplicationScreen({super.key});

  @override
  ConsumerState<LeaderApplicationScreen> createState() =>
      _LeaderApplicationScreenState();
}

class _LeaderApplicationScreenState
    extends ConsumerState<LeaderApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Group Leader Application'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _buildSectionHeader('SECTION 1 - PERSONAL INFORMATION'),
            _buildCard(
              children: [
                _buildTextField('Full Name', keyName: 'fullName'),
                _buildTextField('Email', keyName: 'email'),
                _buildTextField('Phone', keyName: 'phone'),
                _buildTextField('Country', keyName: 'country'),
                _buildTextField('City / State', keyName: 'cityState'),
                _buildTextField('Church / Ministry Affiliation',
                    required: false, keyName: 'churchAffiliation',),
                _buildTextField('Pastor or Spiritual Leader Name',
                    required: false, keyName: 'pastorName',),
                _buildTextField('Pastor / Leader Contact Information',
                    required: false, keyName: 'pastorContact',),
              ],
            ),
            _buildSectionHeader('SECTION 2 - TESTIMONY'),
            _buildCard(
              children: [
                _buildTextField('How did you come to faith in Jesus Christ?',
                    maxLines: 3, keyName: 'conversionStory',),
                _buildTextField('How long have you been following Christ?',
                    keyName: 'yearsFollowingChrist',),
                _buildTextField('Describe your current walk with Christ.',
                    maxLines: 3, keyName: 'currentWalk',),
                _buildTextField(
                    'What is God currently working on in your life?',
                    maxLines: 3,
                    keyName: 'areasOfGrowth',),
              ],
            ),
            _buildSectionHeader('SECTION 3 - SPIRITUAL PRACTICES'),
            _buildCard(
              children: [
                _buildDropdown(
                    'How often do you read Scripture?',
                    [
                      'Daily',
                      'Several times per week',
                      'Weekly',
                      'Occasionally',
                    ],
                    keyName: 'bibleReadingFrequency',),
                _buildDropdown(
                    'How often do you pray?',
                    [
                      'Daily',
                      'Several times per week',
                      'Weekly',
                      'Occasionally',
                    ],
                    keyName: 'prayerFrequency',),
                _buildDropdown(
                    'Are you active in church or Christian fellowship?',
                    ['Yes', 'No'],
                    keyName: 'churchAttendanceFrequency',),
                _buildDropdown(
                    'Do you currently serve in ministry?', ['Yes', 'No'],
                    keyName: 'currentlyServing',),
                _buildTextField('If yes, describe',
                    required: false,
                    maxLines: 2,
                    keyName: 'servingDescription',),
              ],
            ),
            _buildSectionHeader('SECTION 4 - CHARACTER & REPUTATION'),
            _buildCard(
              children: [
                _buildDropdown(
                    'Do you strive to live a life honoring Jesus Christ?',
                    ['Yes', 'No'],
                    keyName: 'honoringChrist',),
                _buildDropdown(
                    'Are you willing to submit to biblical accountability?',
                    ['Yes', 'No'],
                    keyName: 'willingToSubmit',),
                _buildDropdown(
                    'Do you have unresolved conflicts that may affect your leadership?',
                    ['Yes', 'No'],
                    keyName: 'hasUnresolvedConflict',),
                _buildDropdown(
                    'Are you currently involved in any lifestyle that would bring reproach?',
                    ['Yes', 'No'],
                    keyName: 'involvedInReproach',),
                _buildDropdown(
                    'Have you been convicted of a serious criminal offense within the past 10 years?',
                    ['Yes', 'No'],
                    keyName: 'hasCriminalConviction',),
                _buildTextField('If yes, explain',
                    required: false,
                    maxLines: 2,
                    keyName: 'convictionExplanation',),
              ],
            ),
            _buildSectionHeader('SECTION 5 - LEADERSHIP EXPERIENCE'),
            _buildCard(
              children: [
                const Text(
                    'Have you led any of the following? (Select all that apply)',),
                // Placeholder for checkboxes
                const SizedBox(height: AppSpacing.sm),
                _buildTextField('Describe your leadership experience',
                    maxLines: 3, keyName: 'previousLeadershipDescription',),
                _buildTextField(
                    'Why do you want to become a Kingdom Heirs Group Leader?',
                    maxLines: 3,
                    keyName: 'whyBecomeLeader',),
                _buildTextField(
                    'Where do you plan to start a group? (e.g. Home, Church, Online)',
                    keyName: 'previousLeadershipAreas',),
              ],
            ),
            _buildSectionHeader('SECTION 6 - LEADER COMMITMENTS'),
            _buildCard(
              children: [
                const Text(
                    'By submitting this application, I commit to follow Jesus Christ faithfully, lead with humility and integrity, and protect unity among believers.',),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Submit Application',
              isLoading: ref.watch(submitLeaderApplicationProvider).isLoading,
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState!.save();

                  final app = LeaderApplication(
                    id: '', // Generated by Supabase
                    userId: '', // Populated by repository
                    status: ApplicationStatus.pending,
                    submittedAt: DateTime.now(),
                    fullName: (_formData['fullName'] as String?) ?? '',
                    email: (_formData['email'] as String?) ?? '',
                    phone: (_formData['phone'] as String?) ?? '',
                    country: (_formData['country'] as String?) ?? '',
                    cityState: (_formData['cityState'] as String?) ?? '',
                    churchAffiliation:
                        _formData['churchAffiliation'] as String?,
                    pastorName: _formData['pastorName'] as String?,
                    pastorContact: _formData['pastorContact'] as String?,
                    conversionStory:
                        (_formData['conversionStory'] as String?) ?? '',
                    yearsFollowingChrist:
                        (_formData['yearsFollowingChrist'] as String?) ?? '',
                    currentWalk: (_formData['currentWalk'] as String?) ?? '',
                    areasOfGrowth:
                        (_formData['areasOfGrowth'] as String?) ?? '',
                    bibleReadingFrequency:
                        (_formData['bibleReadingFrequency'] as String?) ?? '',
                    prayerFrequency:
                        (_formData['prayerFrequency'] as String?) ?? '',
                    churchAttendanceFrequency:
                        (_formData['churchAttendanceFrequency'] as String?) ??
                            '',
                    currentlyServing:
                        (_formData['currentlyServing'] as String?) == 'Yes',
                    servingDescription:
                        _formData['servingDescription'] as String?,
                    honoringChrist:
                        (_formData['honoringChrist'] as String?) == 'Yes',
                    willingToSubmit:
                        (_formData['willingToSubmit'] as String?) == 'Yes',
                    hasUnresolvedConflict:
                        (_formData['hasUnresolvedConflict'] as String?) ==
                            'Yes',
                    involvedInReproach:
                        (_formData['involvedInReproach'] as String?) == 'Yes',
                    hasCriminalConviction:
                        (_formData['hasCriminalConviction'] as String?) ==
                            'Yes',
                    convictionExplanation:
                        _formData['convictionExplanation'] as String?,
                    whyBecomeLeader:
                        (_formData['whyBecomeLeader'] as String?) ?? '',
                    previousLeadershipAreas: [
                      (_formData['previousLeadershipAreas'] as String?) ?? '',
                    ],
                    previousLeadershipDescription:
                        _formData['previousLeadershipDescription'] as String?,
                    agreedToCommitments: true,
                  );

                  await ref
                      .read(submitLeaderApplicationProvider.notifier)
                      .submit(app);

                  if (!context.mounted) return;
                  final state = ref.read(submitLeaderApplicationProvider);
                  if (state.hasError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${state.error}')),
                    );
                  } else {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Application submitted successfully!'),
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md, horizontal: AppSpacing.xs,),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900, // Black
          color: AppColors.primaryDark,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }

  Widget _buildTextField(String label,
      {required String keyName, bool required = true, int maxLines = 1,}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: required
            ? (val) => val == null || val.isEmpty ? 'Required' : null
            : null,
        onSaved: (val) => _formData[keyName] = val,
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options,
      {required String keyName,}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: options
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: (val) {},
        validator: (val) => val == null ? 'Required' : null,
        onSaved: (val) => _formData[keyName] = val,
      ),
    );
  }
}
