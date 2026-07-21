import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/features/challenge/domain/models/group_reporting_packet.dart';
import 'package:kingdom_heir/features/challenge/presentation/providers/challenge_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';
import 'package:reactive_forms/reactive_forms.dart';

class GroupReportingScreen extends ConsumerStatefulWidget {
  const GroupReportingScreen({super.key});

  @override
  ConsumerState<GroupReportingScreen> createState() =>
      _GroupReportingScreenState();
}

class _GroupReportingScreenState extends ConsumerState<GroupReportingScreen> {
  FormGroup buildForm() => fb.group({
        // Section 1: Group Info
        'groupName': FormControl<String>(validators: [Validators.required]),
        'leaderName': FormControl<String>(validators: [Validators.required]),
        'country': FormControl<String>(validators: [Validators.required]),
        'cityRegion': FormControl<String>(validators: [Validators.required]),
        'meetingType': FormControl<String>(validators: [Validators.required]),
        'groupStartDate': FormControl<DateTime>(),
        'reportDate': FormControl<DateTime>(value: DateTime.now()),

        // Section 2: Participant Summary
        'participantsRegistered': FormControl<int>(
          value: 0,
          validators: [Validators.required, Validators.min(0)],
        ),
        'participantsActive': FormControl<int>(value: 0),
        'participantsCompleted': FormControl<int>(value: 0),
        'participantsAttendedFourPlus': FormControl<int>(value: 0),
        'participantsQualifiedCertificate': FormControl<int>(value: 0),
        'participantsQualifiedCommissioning': FormControl<int>(value: 0),

        // Section 3: Discipleship Impact
        'spiritualGrowthCount': FormControl<int>(value: 0),
        'consistentPrayerCount': FormControl<int>(value: 0),
        'dailyBibleCount': FormControl<int>(value: 0),
        'reconciledRelationshipsCount': FormControl<int>(value: 0),
        'activeLocalChurchCount': FormControl<int>(value: 0),
        'servingOthersCount': FormControl<int>(value: 0),

        // Section 4: Evangelism Impact
        'sharedTestimonyCount': FormControl<int>(value: 0),
        'sharedGospelCount': FormControl<int>(value: 0),
        'prayedOutsideGroupCount': FormControl<int>(value: 0),
        'outreachParticipationCount': FormControl<int>(value: 0),
        'professionsOfFaithCount': FormControl<int>(value: 0),
        'baptismsCount': FormControl<int>(value: 0),

        // Section 5: Leadership Development
        'leadershipPotentialCount': FormControl<int>(value: 0),
        'potentialFutureLeaders': FormControl<String>(
          value: '',
        ), // Comma separated for simplicity in UI
        'interestLeadingFutureGroupCount': FormControl<int>(value: 0),
        'interestVesselSchoolCount': FormControl<int>(value: 0),

        // Section 6: Testimonies
        'significantTestimony': FormControl<String>(value: ''),
        'contactForFeature': FormControl<bool>(value: false),
        'photoPermission': FormControl<bool>(value: false),
        'videoPermission': FormControl<bool>(value: false),

        // Section 7: Multiplication Report
        'futureGroupsExpected': FormControl<int>(value: 0),
        'futureLeadersExpected': FormControl<int>(value: 0),
        'expectedLaunchDate': FormControl<DateTime>(),
        'projectedFutureParticipants': FormControl<int>(value: 0),

        // Section 8: Leader Self-Evaluation
        'completedReportingRequirements': FormControl<bool>(value: false),
        'faithfullyFacilitated': FormControl<bool>(value: false),
        'identifiedFutureLeaders': FormControl<bool>(value: false),
        'wouldLikeToLeadAnotherGroup': FormControl<bool>(value: false),
        'wouldLikeAdditionalCoaching': FormControl<bool>(value: false),
        'supportAreas': FormControl<String>(value: ''),

        // Final
        'finalAffirmation':
            FormControl<bool>(validators: [Validators.requiredTrue]),
      });

  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.groupReportingPacket),
      ),
      body: ReactiveFormBuilder(
        form: buildForm,
        builder: (context, form, child) {
          return Stepper(
            currentStep: _currentStep,
            onStepContinue: () async {
              if (_currentStep < 7) {
                setState(() => _currentStep += 1);
              } else {
                if (form.valid) {
                  // Build packet
                  final v = form.value;
                  final packet = GroupReportingPacket(
                    groupName: v['groupName'] as String? ?? '',
                    leaderName: v['leaderName'] as String? ?? '',
                    country: v['country'] as String? ?? '',
                    cityRegion: v['cityRegion'] as String? ?? '',
                    meetingType: v['meetingType'] as String? ?? '',
                    groupStartDate: v['groupStartDate'] as DateTime?,
                    reportDate: v['reportDate'] as DateTime?,
                    participantsRegistered:
                        v['participantsRegistered'] as int? ?? 0,
                    participantsActive: v['participantsActive'] as int? ?? 0,
                    participantsCompleted:
                        v['participantsCompleted'] as int? ?? 0,
                    participantsAttendedFourPlus:
                        v['participantsAttendedFourPlus'] as int? ?? 0,
                    participantsQualifiedCertificate:
                        v['participantsQualifiedCertificate'] as int? ?? 0,
                    participantsQualifiedCommissioning:
                        v['participantsQualifiedCommissioning'] as int? ?? 0,
                    spiritualGrowthCount:
                        v['spiritualGrowthCount'] as int? ?? 0,
                    consistentPrayerCount:
                        v['consistentPrayerCount'] as int? ?? 0,
                    dailyBibleCount: v['dailyBibleCount'] as int? ?? 0,
                    reconciledRelationshipsCount:
                        v['reconciledRelationshipsCount'] as int? ?? 0,
                    activeLocalChurchCount:
                        v['activeLocalChurchCount'] as int? ?? 0,
                    servingOthersCount: v['servingOthersCount'] as int? ?? 0,
                    sharedTestimonyCount:
                        v['sharedTestimonyCount'] as int? ?? 0,
                    sharedGospelCount: v['sharedGospelCount'] as int? ?? 0,
                    prayedOutsideGroupCount:
                        v['prayedOutsideGroupCount'] as int? ?? 0,
                    outreachParticipationCount:
                        v['outreachParticipationCount'] as int? ?? 0,
                    professionsOfFaithCount:
                        v['professionsOfFaithCount'] as int? ?? 0,
                    baptismsCount: v['baptismsCount'] as int? ?? 0,
                    leadershipPotentialCount:
                        v['leadershipPotentialCount'] as int? ?? 0,
                    potentialFutureLeaders:
                        (v['potentialFutureLeaders'] as String? ?? '')
                            .split(','),
                    interestLeadingFutureGroupCount:
                        v['interestLeadingFutureGroupCount'] as int? ?? 0,
                    interestVesselSchoolCount:
                        v['interestVesselSchoolCount'] as int? ?? 0,
                    significantTestimony:
                        v['significantTestimony'] as String? ?? '',
                    contactForFeature: v['contactForFeature'] as bool? ?? false,
                    photoPermission: v['photoPermission'] as bool? ?? false,
                    videoPermission: v['videoPermission'] as bool? ?? false,
                    futureGroupsExpected:
                        v['futureGroupsExpected'] as int? ?? 0,
                    futureLeadersExpected:
                        v['futureLeadersExpected'] as int? ?? 0,
                    expectedLaunchDate: v['expectedLaunchDate'] as DateTime?,
                    projectedFutureParticipants:
                        v['projectedFutureParticipants'] as int? ?? 0,
                    completedReportingRequirements:
                        v['completedReportingRequirements'] as bool? ?? false,
                    faithfullyFacilitated:
                        v['faithfullyFacilitated'] as bool? ?? false,
                    identifiedFutureLeaders:
                        v['identifiedFutureLeaders'] as bool? ?? false,
                    wouldLikeToLeadAnotherGroup:
                        v['wouldLikeToLeadAnotherGroup'] as bool? ?? false,
                    wouldLikeAdditionalCoaching:
                        v['wouldLikeAdditionalCoaching'] as bool? ?? false,
                    supportAreas: v['supportAreas'] as String? ?? '',
                    finalAffirmation: v['finalAffirmation'] as bool? ?? false,
                  );

                  await ref
                      .read(submitGroupReportProvider.notifier)
                      .submit(packet);

                  if (!context.mounted) return;
                  final state = ref.read(submitGroupReportProvider);
                  if (state.hasError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${state.error}')),
                    );
                  } else {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!
                            .reportSubmittedSuccessfully,),
                      ),
                    );
                  }
                } else {
                  form.markAllAsTouched();
                }
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep -= 1);
              }
            },
            steps: [
              _buildStep1(),
              _buildStep2(),
              _buildStep3(),
              _buildStep4(),
              _buildStep5(),
              _buildStep6(),
              _buildStep7(),
              _buildStep8(ref.watch(submitGroupReportProvider).isLoading),
            ],
          );
        },
      ),
    );
  }

  Step _buildStep1() => Step(
        title: Text(AppLocalizations.of(context)!.groupInformation),
        isActive: _currentStep >= 0,
        content: Column(
          children: [
            ReactiveTextField<String>(
              formControlName: 'groupName',
              decoration: const InputDecoration(labelText: 'Group Name'),
            ),
            const SizedBox(height: AppSpacing.md),
            ReactiveTextField<String>(
              formControlName: 'leaderName',
              decoration: const InputDecoration(labelText: 'Leader Name'),
            ),
            const SizedBox(height: AppSpacing.md),
            ReactiveTextField<String>(
              formControlName: 'country',
              decoration: const InputDecoration(labelText: 'Country'),
            ),
            const SizedBox(height: AppSpacing.md),
            ReactiveDropdownField<String>(
              formControlName: 'meetingType',
              decoration: const InputDecoration(labelText: 'Meeting Type'),
              items: [
                DropdownMenuItem(
                    value: 'Home',
                    child: Text(AppLocalizations.of(context)!.home),),
                DropdownMenuItem(
                    value: 'Church',
                    child: Text(AppLocalizations.of(context)!.church),),
                DropdownMenuItem(
                    value: 'Business',
                    child: Text(AppLocalizations.of(context)!.business),),
                DropdownMenuItem(
                    value: 'Workplace',
                    child: Text(AppLocalizations.of(context)!.workplace),),
                DropdownMenuItem(
                    value: 'Online',
                    child: Text(AppLocalizations.of(context)!.online),),
                DropdownMenuItem(
                    value: 'Community',
                    child: Text(AppLocalizations.of(context)!.community),),
              ],
            ),
          ],
        ),
      );

  Step _buildStep2() => Step(
        title: Text(AppLocalizations.of(context)!.participantSummary),
        isActive: _currentStep >= 1,
        content: Column(
          children: [
            _buildIntField(
              'participantsRegistered',
              'Participants originally registered?',
            ),
            _buildIntField(
              'participantsActive',
              'Participants currently active?',
            ),
            _buildIntField(
              'participantsCompleted',
              'Participants completed all 90 days?',
            ),
            _buildIntField(
              'participantsAttendedFourPlus',
              'Participants attended at least 4 gatherings?',
            ),
            _buildIntField(
              'participantsQualifiedCertificate',
              'Participants qualified for Certificate?',
            ),
          ],
        ),
      );

  Step _buildStep3() => Step(
        title: Text(AppLocalizations.of(context)!.discipleshipImpact),
        isActive: _currentStep >= 2,
        content: Column(
          children: [
            _buildIntField(
              'spiritualGrowthCount',
              'Reported spiritual growth?',
            ),
            _buildIntField(
              'consistentPrayerCount',
              'Established consistent prayer life?',
            ),
            _buildIntField(
              'dailyBibleCount',
              'Established daily Bible reading?',
            ),
            _buildIntField(
              'reconciledRelationshipsCount',
              'Reconciled broken relationships?',
            ),
            _buildIntField(
              'activeLocalChurchCount',
              'Became active in local church?',
            ),
            _buildIntField('servingOthersCount', 'Began serving others?'),
          ],
        ),
      );

  Step _buildStep4() => Step(
        title: Text(AppLocalizations.of(context)!.evangelismImpact),
        isActive: _currentStep >= 3,
        content: Column(
          children: [
            _buildIntField('sharedTestimonyCount', 'Shared their testimony?'),
            _buildIntField('sharedGospelCount', 'Shared the Gospel?'),
            _buildIntField(
              'prayedOutsideGroupCount',
              'Prayed for someone outside?',
            ),
            _buildIntField(
              'outreachParticipationCount',
              'Participated in outreach?',
            ),
            _buildIntField(
              'professionsOfFaithCount',
              'Professions of faith reported?',
            ),
            _buildIntField('baptismsCount', 'Baptisms occurred?'),
          ],
        ),
      );

  Step _buildStep5() => Step(
        title: Text(AppLocalizations.of(context)!.leadershipDevelopment),
        isActive: _currentStep >= 4,
        content: Column(
          children: [
            _buildIntField(
              'leadershipPotentialCount',
              'Demonstrated leadership potential?',
            ),
            ReactiveTextField<String>(
              formControlName: 'potentialFutureLeaders',
              decoration: const InputDecoration(
                labelText: 'List future leaders (comma separated)',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildIntField(
              'interestLeadingFutureGroupCount',
              'Interest in leading future group?',
            ),
            _buildIntField(
              'interestVesselSchoolCount',
              'Interest in Vessel School of Ministry?',
            ),
          ],
        ),
      );

  Step _buildStep6() => Step(
        title: Text(AppLocalizations.of(context)!.testimonies),
        isActive: _currentStep >= 5,
        content: Column(
          children: [
            ReactiveTextField<String>(
              formControlName: 'significantTestimony',
              decoration: const InputDecoration(
                labelText: 'Most significant testimony',
              ),
              maxLines: 5,
            ),
            ReactiveCheckboxListTile(
              formControlName: 'contactForFeature',
              title: Text(
                  AppLocalizations.of(context)!.mayWeContactThisIndividual,),
            ),
            ReactiveCheckboxListTile(
              formControlName: 'photoPermission',
              title: Text(AppLocalizations.of(context)!.photoPermissionGranted),
            ),
            ReactiveCheckboxListTile(
              formControlName: 'videoPermission',
              title: Text(AppLocalizations.of(context)!.videoPermissionGranted),
            ),
          ],
        ),
      );

  Step _buildStep7() => Step(
        title: Text(AppLocalizations.of(context)!.multiplicationReport),
        isActive: _currentStep >= 6,
        content: Column(
          children: [
            _buildIntField(
              'futureGroupsExpected',
              'Future groups expected to launch?',
            ),
            _buildIntField(
              'futureLeadersExpected',
              'Future leaders expected to lead?',
            ),
            _buildIntField(
              'projectedFutureParticipants',
              'Projected future participants?',
            ),
          ],
        ),
      );

  Step _buildStep8(bool isLoading) => Step(
        title: Text(AppLocalizations.of(context)!.leaderSelfevaluation),
        isActive: _currentStep >= 7,
        content: Column(
          children: [
            ReactiveCheckboxListTile(
              formControlName: 'completedReportingRequirements',
              title: Text(
                  AppLocalizations.of(context)!.completedReportingRequirements,),
            ),
            ReactiveCheckboxListTile(
              formControlName: 'faithfullyFacilitated',
              title: Text(
                  AppLocalizations.of(context)!.faithfullyFacilitatedYourGroup,),
            ),
            ReactiveCheckboxListTile(
              formControlName: 'identifiedFutureLeaders',
              title:
                  Text(AppLocalizations.of(context)!.identifiedFutureLeaders),
            ),
            ReactiveCheckboxListTile(
              formControlName: 'wouldLikeToLeadAnotherGroup',
              title: Text(
                  AppLocalizations.of(context)!.wouldLikeToLeadAnotherGroup,),
            ),
            ReactiveCheckboxListTile(
              formControlName: 'wouldLikeAdditionalCoaching',
              title: Text(
                  AppLocalizations.of(context)!.wouldLikeAdditionalCoaching,),
            ),
            const SizedBox(height: AppSpacing.md),
            ReactiveTextField<String>(
              formControlName: 'supportAreas',
              decoration: const InputDecoration(
                labelText: 'Areas where you need support',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.lg),
            ReactiveCheckboxListTile(
              formControlName: 'finalAffirmation',
              title: const Text(
                'I affirm that the information submitted is accurate to the best of my knowledge.',
              ),
            ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.md),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      );

  Widget _buildIntField(String name, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ReactiveTextField<int>(
        formControlName: name,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
