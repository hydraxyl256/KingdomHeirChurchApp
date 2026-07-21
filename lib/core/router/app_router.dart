import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/notifications/notification_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/storage/local_storage_service.dart';
import 'package:kingdom_heir/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:kingdom_heir/features/admin/presentation/screens/admin_devotional_day_editor_screen.dart';
import 'package:kingdom_heir/features/admin/presentation/screens/admin_devotional_series_screen.dart';
import 'package:kingdom_heir/features/admin/presentation/screens/admin_events_screen.dart';
import 'package:kingdom_heir/features/admin/presentation/screens/admin_global_impact_dashboard_screen.dart';
import 'package:kingdom_heir/features/admin/presentation/screens/admin_leader_applications_screen.dart';
import 'package:kingdom_heir/features/admin/presentation/screens/admin_leader_recognition_dashboard_screen.dart';
import 'package:kingdom_heir/features/admin/presentation/screens/admin_media_review_screen.dart';
import 'package:kingdom_heir/features/admin/presentation/screens/admin_members_screen.dart';
import 'package:kingdom_heir/features/admin/presentation/screens/admin_moderation_screen.dart';
import 'package:kingdom_heir/features/admin/presentation/screens/admin_prayer_moderation_screen.dart';
import 'package:kingdom_heir/features/admin/presentation/screens/admin_sermons_screen.dart';
import 'package:kingdom_heir/features/admin/presentation/screens/admin_shell.dart';
import 'package:kingdom_heir/features/admin/presentation/screens/admin_tools_screen.dart';
import 'package:kingdom_heir/features/auth/presentation/providers/auth_provider.dart';
import 'package:kingdom_heir/features/auth/presentation/screens/auth_callback_screen.dart';
import 'package:kingdom_heir/features/auth/presentation/screens/check_your_email_screen.dart';
import 'package:kingdom_heir/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:kingdom_heir/features/auth/presentation/screens/login_screen.dart';
import 'package:kingdom_heir/features/auth/presentation/screens/register_screen.dart';
import 'package:kingdom_heir/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:kingdom_heir/features/auth/presentation/screens/user_role_selection_screen.dart';
import 'package:kingdom_heir/features/bible/presentation/screens/bible_bookmarks_screen.dart';
import 'package:kingdom_heir/features/bible/presentation/screens/bible_discovery_search_screen.dart';
import 'package:kingdom_heir/features/bible/presentation/screens/bible_plans_screen.dart';
import 'package:kingdom_heir/features/bible/presentation/screens/bible_reader_screen.dart';
import 'package:kingdom_heir/features/bookstore/presentation/screens/kingdom_bookstore_screen.dart';
import 'package:kingdom_heir/features/challenge/presentation/screens/challenge_hub_screen.dart';
import 'package:kingdom_heir/features/challenge/presentation/screens/group_reporting_screen.dart';
import 'package:kingdom_heir/features/challenge/presentation/screens/participant_journey_screen.dart';
import 'package:kingdom_heir/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:kingdom_heir/features/devotionals/presentation/screens/devotional_day_reader_screen.dart';
import 'package:kingdom_heir/features/devotionals/presentation/screens/devotional_prayer_screen.dart';
import 'package:kingdom_heir/features/devotionals/presentation/screens/devotional_reader_screen.dart';
import 'package:kingdom_heir/features/devotionals/presentation/screens/devotional_series_detail_screen.dart';
import 'package:kingdom_heir/features/devotionals/presentation/screens/devotional_series_list_screen.dart';
import 'package:kingdom_heir/features/devotionals/presentation/screens/devotionals_screen.dart';
import 'package:kingdom_heir/features/devotionals/presentation/screens/journal_screen.dart';
import 'package:kingdom_heir/features/devotionals/presentation/screens/journey_complete_screen.dart';
import 'package:kingdom_heir/features/devotionals/presentation/screens/reflection_screen.dart';
import 'package:kingdom_heir/features/devotionals/presentation/screens/scripture_reader_screen.dart';
import 'package:kingdom_heir/features/events/presentation/screens/event_details_screen.dart';
import 'package:kingdom_heir/features/events/presentation/screens/event_listing_screen.dart';
import 'package:kingdom_heir/features/events/presentation/screens/events_calendar_screen.dart';
import 'package:kingdom_heir/features/events/presentation/screens/tickets_attendance_screen.dart';
import 'package:kingdom_heir/features/giving/presentation/screens/giving_history_screen.dart';
import 'package:kingdom_heir/features/giving/presentation/screens/giving_stewardship_hub_screen.dart';
import 'package:kingdom_heir/features/groups/presentation/screens/community_home_screen.dart';
import 'package:kingdom_heir/features/groups/presentation/screens/group_chat_screen.dart';
import 'package:kingdom_heir/features/groups/presentation/screens/group_detail_screen.dart';
import 'package:kingdom_heir/features/groups/presentation/screens/group_discovery_screen.dart';
import 'package:kingdom_heir/features/groups/presentation/screens/group_events_screen.dart';
import 'package:kingdom_heir/features/groups/presentation/screens/group_leader_screen.dart';
import 'package:kingdom_heir/features/groups/presentation/screens/group_prayer_screen.dart';
import 'package:kingdom_heir/features/kids/presentation/screens/parent_dashboard_kids_checkin_screen.dart';
import 'package:kingdom_heir/features/leadership/presentation/screens/leader_application_screen.dart';
import 'package:kingdom_heir/features/leadership/presentation/screens/leader_covenant_signature_screen.dart';
import 'package:kingdom_heir/features/leadership/presentation/screens/leader_resources_screen.dart';
import 'package:kingdom_heir/features/live_service/presentation/screens/live_service_screen.dart';
import 'package:kingdom_heir/features/members/presentation/screens/member_directory_screen.dart';
import 'package:kingdom_heir/features/members/presentation/screens/member_profile_screen.dart';
import 'package:kingdom_heir/features/more/presentation/screens/more_screen.dart';
import 'package:kingdom_heir/features/news/domain/entities/news_models.dart';
import 'package:kingdom_heir/features/news/presentation/screens/news_announcements_screen.dart';
import 'package:kingdom_heir/features/news/presentation/screens/news_article_details_screen.dart';
import 'package:kingdom_heir/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:kingdom_heir/features/onboarding/presentation/screens/profile_setup_screen.dart';
import 'package:kingdom_heir/features/podcasts/presentation/screens/podcasts_audio_hub_screen.dart';
import 'package:kingdom_heir/features/prayer_requests/presentation/screens/my_prayers_screen.dart';
import 'package:kingdom_heir/features/prayer_requests/presentation/screens/prayer_feed_screen.dart';
import 'package:kingdom_heir/features/prayer_requests/presentation/screens/submit_prayer_screen.dart';
import 'package:kingdom_heir/features/profile/presentation/screens/my_profile_screen.dart';
import 'package:kingdom_heir/features/search/presentation/screens/global_search_screen.dart';
import 'package:kingdom_heir/features/sermons/presentation/screens/sermon_audio_player_screen.dart';
import 'package:kingdom_heir/features/sermons/presentation/screens/sermon_continue_screen.dart';
import 'package:kingdom_heir/features/sermons/presentation/screens/sermon_details_screen.dart';
import 'package:kingdom_heir/features/sermons/presentation/screens/sermon_downloads_screen.dart';
import 'package:kingdom_heir/features/sermons/presentation/screens/sermon_home_screen.dart';
import 'package:kingdom_heir/features/sermons/presentation/screens/sermon_library_screen.dart';
import 'package:kingdom_heir/features/sermons/presentation/screens/sermon_player_screen.dart';
import 'package:kingdom_heir/features/sermons/presentation/screens/sermon_series_screen.dart';
import 'package:kingdom_heir/features/settings/presentation/screens/about_screen.dart';
import 'package:kingdom_heir/features/settings/presentation/screens/change_password_screen.dart';
import 'package:kingdom_heir/features/settings/presentation/screens/settings_notification_center_screen.dart';
import 'package:kingdom_heir/features/shell/app_shell.dart';
import 'package:kingdom_heir/features/start_here/presentation/screens/founder_letter_screen.dart';
import 'package:kingdom_heir/features/start_here/presentation/screens/kingdom_heirs_story_screen.dart';
import 'package:kingdom_heir/features/start_here/presentation/screens/plan_your_visit_screen.dart';
import 'package:kingdom_heir/features/start_here/presentation/screens/start_here_hub_screen.dart';
import 'package:kingdom_heir/features/start_here/presentation/screens/statement_of_faith_screen.dart';
import 'package:kingdom_heir/features/start_here/presentation/screens/vision_mission_detail_screen.dart';
import 'package:kingdom_heir/features/testimonies/presentation/screens/submit_testimony_screen.dart';
import 'package:kingdom_heir/features/testimonies/presentation/screens/testimonies_screen.dart';
import 'package:kingdom_heir/features/volunteers/presentation/screens/ministry_assignments_screen.dart';
import 'package:kingdom_heir/features/volunteers/presentation/screens/volunteer_hub_screen.dart';

/// Global GoRouter provider — no code generation required.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: NotificationRouter.navigatorKey,
    initialLocation: RouteNames.dashboard,
    debugLogDiagnostics: true,
    refreshListenable: _AuthStateListenable(ref),
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.valueOrNull != null;
      final localStorage = ref.read(localStorageServiceProvider);
      final onboardingDone =
          localStorage.getBool(LocalStorageKeys.onboardingComplete) ?? false;
      final user = authState.valueOrNull;
      final roleSelected = user?.role != null ||
          localStorage.getString(LocalStorageKeys.userRole) != null;

      final location = state.uri.toString();
      final isAtAuth = location.startsWith('/auth');
      final isAtOnboarding = location.startsWith('/onboarding');
      final isAtAdmin = location.startsWith('/admin');
      final isAtStartHere = location.startsWith('/start-here');

      if (!isLoggedIn && !isAtAuth && !isAtStartHere) {
        return RouteNames.startHere;
      }

      if (isLoggedIn && !onboardingDone && !isAtOnboarding) {
        return RouteNames.onboardingProfileSetup;
      }

      if (isLoggedIn && onboardingDone && !roleSelected && !isAtAuth) {
        return RouteNames.roleSelection;
      }

      if (isLoggedIn &&
          onboardingDone &&
          roleSelected &&
          (isAtAuth || isAtStartHere)) {
        return RouteNames.dashboard;
      }

      // Admin Guard — allows admin, super_admin, and pastor roles.
      if (isAtAdmin) {
        final role = localStorage.getString(LocalStorageKeys.userRole);
        const allowedRoles = {'admin', 'super_admin', 'pastor'};
        if (role == null || !allowedRoles.contains(role)) {
          return RouteNames.dashboard;
        }
      }

      return null;
    },
    routes: [
      // ── Bible Sub-Screens (push destinations from reader) ────────
      GoRoute(
        path: RouteNames.bibleBookmarks,
        builder: (_, __) => const BibleBookmarksScreen(),
      ),
      GoRoute(
        path: RouteNames.biblePlans,
        builder: (_, __) => const BiblePlansScreen(),
      ),

      // ── Start Here ──────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.startHere,
        builder: (_, __) => const StartHereHubScreen(),
      ),
      GoRoute(
        path: RouteNames.startHereVision,
        builder: (_, __) => const VisionMissionDetailScreen(),
      ),
      GoRoute(
        path: RouteNames.startHereFounder,
        builder: (_, __) => const FounderLetterScreen(),
      ),
      GoRoute(
        path: RouteNames.startHereStatementOfFaith,
        builder: (_, __) => const StatementOfFaithScreen(),
      ),
      GoRoute(
        path: RouteNames.startHereStory,
        builder: (_, __) => const KingdomHeirsStoryScreen(),
      ),
      GoRoute(
        path: RouteNames.startHerePlanVisit,
        builder: (_, __) => const PlanYourVisitScreen(),
      ),

      // ── Onboarding ──────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.onboardingProfileSetup,
        builder: (_, __) => const ProfileSetupScreen(),
      ),

      // ── Auth ────────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.roleSelection,
        builder: (_, __) => const UserRoleSelectionScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        builder: (_, __) => const ResetPasswordScreen(),
      ),

      // ── Email Verification Landing ──────────────────────────────────────────
      // Reached when the user registers. Instructs them to check their email.
      GoRoute(
        path: RouteNames.checkYourEmail,
        builder: (context, state) {
          final storage = ref.read(localStorageServiceProvider);
          final pending = storage.getString(
            LocalStorageKeys.pendingVerificationEmail,
          );
          final fromQuery = state.uri.queryParameters['email'];
          return CheckYourEmailScreen(
            email: (fromQuery != null && fromQuery.isNotEmpty)
                ? fromQuery
                : (pending ?? ''),
          );
        },
      ),

      // ── Deep-Link Auth Callback ──────────────────────────────────────────
      // Reached when the user taps the verification link in their email but Supabase
      // returns an error (e.g. link expired, invalid).
      GoRoute(
        path: RouteNames.authCallback,
        builder: (context, state) {
          return AuthCallbackScreen(
            errorDescription: state.uri.queryParameters['error_description'],
            errorCode: state.uri.queryParameters['error_code'],
          );
        },
      ),

      // ── Shell (Bottom Nav) ─────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // Dashboard
          GoRoute(
            path: RouteNames.dashboard,
            builder: (_, __) => const DashboardScreen(),
          ),

          // Notifications Center (push from dashboard bell)
          GoRoute(
            path: RouteNames.notifications,
            builder: (_, __) => const NotificationsScreen(),
          ),

          // Global Search (push from dashboard search)
          GoRoute(
            path: RouteNames.globalSearch,
            builder: (_, __) => const GlobalSearchScreen(),
          ),

          // More Hub
          GoRoute(
            path: RouteNames.more,
            builder: (_, __) => const MoreScreen(),
          ),

          // Challenge
          GoRoute(
            path: RouteNames.challenge,
            builder: (_, __) => const ChallengeHubScreen(),
            routes: [
              GoRoute(
                path: 'participant',
                builder: (_, __) => const ParticipantJourneyScreen(),
              ),
              GoRoute(
                path: 'reporting',
                builder: (_, __) => const GroupReportingScreen(),
              ),
            ],
          ),

          // Sermons
          GoRoute(
            path: RouteNames.sermons,
            builder: (_, __) => const SermonHomeScreen(),
            routes: [
              GoRoute(
                path: 'library',
                builder: (_, __) => const SermonLibraryScreen(),
              ),
              GoRoute(
                path: 'continue',
                builder: (_, __) => const SermonContinueScreen(),
              ),
              GoRoute(
                path: 'downloads',
                builder: (_, __) => const SermonDownloadsScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, state) => SermonDetailsScreen(
                  sermonId: state.pathParameters['id']!,
                ),
                routes: [
                  GoRoute(
                    path: 'player',
                    builder: (_, state) => SermonPlayerScreen(
                      sermonId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'audio',
                    builder: (_, state) => SermonAudioPlayerScreen(
                      sermonId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'series/:seriesId',
                    builder: (_, state) => SermonSeriesScreen(
                      sermonId: state.pathParameters['id']!,
                      seriesId: state.pathParameters['seriesId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Bible
          GoRoute(
            path: RouteNames.bible,
            builder: (_, __) => const BibleReaderScreen(),
            routes: [
              GoRoute(
                path: 'search',
                builder: (_, __) => const BibleDiscoverySearchScreen(),
              ),
            ],
          ),

          // Events
          GoRoute(
            path: RouteNames.events,
            builder: (_, __) => const EventListingScreen(),
            routes: [
              GoRoute(
                path: 'calendar',
                builder: (_, __) => const EventsCalendarScreen(),
              ),
              GoRoute(
                path: 'tickets',
                builder: (_, __) => const TicketsAttendanceScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, state) => EventDetailsScreen(
                  eventId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),

          // Live
          GoRoute(
            path: RouteNames.live,
            builder: (_, __) => const LiveServiceScreen(),
          ),

          // Giving
          GoRoute(
            path: RouteNames.giving,
            builder: (_, __) => const GivingStewardshipHubScreen(),
            routes: [
              GoRoute(
                path: 'history',
                builder: (_, __) => const GivingHistoryScreen(),
              ),
              // The legacy `/home/giving/checkout` route used to open
              // an in-app checkout form. Payment is now handled by a
              // hosted page; the deep-link path is preserved but
              // redirected to the Stewardship Hub so any old links,
              // notifications, or web tests still land somewhere
              // sensible.
              GoRoute(
                path: 'checkout',
                builder: (_, __) => const GivingStewardshipHubScreen(),
              ),
            ],
          ),

          // Groups
          GoRoute(
            path: RouteNames.groups,
            builder: (_, __) => const CommunityHomeScreen(),
            routes: [
              GoRoute(
                path: 'discover',
                builder: (_, __) => const GroupDiscoveryScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, state) => GroupDetailScreen(
                  groupId: state.pathParameters['id']!,
                ),
                routes: [
                  GoRoute(
                    path: 'chat',
                    builder: (_, state) => GroupChatScreen(
                      groupId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'events',
                    builder: (_, state) => GroupEventsScreen(
                      groupId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'prayer',
                    builder: (_, state) => GroupPrayerScreen(
                      groupId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'leader',
                    builder: (_, state) => GroupLeaderScreen(
                      groupId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Devotionals — 7-Step Journey
          GoRoute(
            path: RouteNames.devotionals,
            builder: (_, __) => const DevotionalsScreen(),
            routes: [
              // Standalone journal (from AppBar shortcut)
              GoRoute(
                path: 'journal',
                builder: (_, state) => JournalScreen(
                  devotionalId: state.pathParameters['id'] ?? 'standalone',
                  standalone: true,
                ),
              ),
              // Journey steps — all keyed by :id
              GoRoute(
                path: ':id/scripture',
                builder: (_, state) => ScriptureReaderScreen(
                  devotionalId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: ':id/content',
                builder: (_, state) => DevotionalReaderScreen(
                  devotionalId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: ':id/reflection',
                builder: (_, state) => ReflectionScreen(
                  devotionalId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: ':id/prayer',
                builder: (_, state) => DevotionalPrayerScreen(
                  devotionalId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: ':id/journal',
                builder: (_, state) => JournalScreen(
                  devotionalId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: ':id/complete',
                builder: (_, state) => JourneyCompleteScreen(
                  devotionalId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),

          // Devotional Series (90-Day Journey)
          GoRoute(
            path: 'devotionals/series',
            builder: (_, __) => const DevotionalSeriesListScreen(),
            routes: [
              GoRoute(
                path: ':seriesId',
                builder: (_, state) => DevotionalSeriesDetailScreen(
                  seriesId: state.pathParameters['seriesId']!,
                ),
                routes: [
                  GoRoute(
                    path: 'day/:dayNumber',
                    builder: (_, state) => DevotionalDayReaderScreen(
                      seriesId: state.pathParameters['seriesId']!,
                      dayNumber: int.parse(
                        state.pathParameters['dayNumber'] ?? '1',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Podcasts
          GoRoute(
            path: RouteNames.podcasts,
            builder: (_, __) => const PodcastsAudioHubScreen(),
          ),

          // Kids
          GoRoute(
            path: RouteNames.kids,
            builder: (_, __) => const ParentDashboardKidsCheckinScreen(),
          ),

          // Bookstore
          GoRoute(
            path: RouteNames.bookstore,
            builder: (_, __) => const KingdomBookstoreScreen(),
          ),

          // Volunteers
          GoRoute(
            path: RouteNames.volunteers,
            builder: (_, __) => const VolunteerHubScreen(),
            routes: [
              GoRoute(
                path: 'assignments',
                builder: (_, __) => const MinistryAssignmentsScreen(),
              ),
            ],
          ),

          // Members
          GoRoute(
            path: RouteNames.members,
            builder: (_, __) => const MemberDirectoryScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => MemberProfileScreen(
                  memberId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),

          // My Profile
          GoRoute(
            path: RouteNames.myProfile,
            builder: (_, __) => const MyProfileScreen(),
          ),

          // News
          GoRoute(
            path: RouteNames.news,
            builder: (_, __) => const NewsAnnouncementsScreen(),
            routes: [
              GoRoute(
                path: 'details',
                builder: (_, state) => NewsArticleDetailsScreen(
                  article: state.extra! as NewsArticle,
                ),
              ),
            ],
          ),

          // Settings + sub-routes
          GoRoute(
            path: RouteNames.settings,
            builder: (_, __) => const SettingsNotificationCenterScreen(),
            routes: [
              GoRoute(
                path: 'change-password',
                builder: (_, __) => const ChangePasswordScreen(),
              ),
              GoRoute(
                path: 'about',
                builder: (_, __) => const AboutScreen(),
              ),
            ],
          ),

          // Prayer Requests
          GoRoute(
            path: RouteNames.prayerFeed,
            builder: (_, __) => const PrayerFeedScreen(),
            routes: [
              GoRoute(
                path: 'submit',
                builder: (_, __) => const SubmitPrayerScreen(),
              ),
              GoRoute(
                path: 'my-prayers',
                builder: (_, __) => const MyPrayersScreen(),
              ),
            ],
          ),

          // Testimonies
          GoRoute(
            path: RouteNames.testimonies,
            builder: (_, __) => const TestimoniesScreen(),
            routes: [
              GoRoute(
                path: 'submit',
                builder: (_, __) => const SubmitTestimonyScreen(),
              ),
            ],
          ),

          // Leadership
          GoRoute(
            path: RouteNames.leaderApplication,
            builder: (_, __) => const LeaderApplicationScreen(),
          ),
          GoRoute(
            path: RouteNames.leaderCovenantSignature,
            builder: (_, __) => const LeaderCovenantSignatureScreen(),
          ),
          GoRoute(
            path: RouteNames.leaderResources,
            builder: (_, __) => const LeaderResourcesScreen(),
          ),
        ],
      ),

      // ── Admin CMS ──────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            builder: (_, __) => const AdminAnalyticsDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/members',
            builder: (_, __) => const AdminMembersScreen(),
          ),
          GoRoute(
            path: '/admin/sermons',
            builder: (_, __) => const AdminSermonsScreen(),
          ),
          GoRoute(
            path: '/admin/events',
            builder: (_, __) => const AdminEventsScreen(),
          ),
          GoRoute(
            path: '/admin/moderation',
            builder: (_, __) => const AdminModerationScreen(),
          ),
          GoRoute(
            path: '/admin/prayer-moderation',
            builder: (_, __) => const AdminPrayerModerationScreen(),
          ),
          GoRoute(
            path: '/admin/leader-applications',
            builder: (_, __) => const AdminLeaderApplicationsScreen(),
          ),
          GoRoute(
            path: '/admin/global-impact',
            builder: (_, __) => const AdminGlobalImpactDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/leader-recognition',
            builder: (_, __) => const AdminLeaderRecognitionDashboardScreen(),
          ),
          // ── New admin routes ───────────────────────────────────────
          GoRoute(
            path: '/admin/media-review',
            builder: (_, __) => const AdminMediaReviewScreen(),
          ),
          GoRoute(
            path: '/admin/devotional-series',
            builder: (_, __) => const AdminDevotionalSeriesScreen(),
          ),
          GoRoute(
            path: '/admin/devotional-series/:seriesId/days/:dayNumber',
            builder: (_, state) => AdminDevotionalDayEditorScreen(
              seriesId: state.pathParameters['seriesId']!,
              dayNumber: int.parse(
                state.pathParameters['dayNumber'] ?? '1',
              ),
            ),
          ),
          // ── Admin Utility Tools (temporary, pre-CMS) ───────────────
          GoRoute(
            path: RouteNames.adminTools,
            builder: (_, __) => const AdminToolsScreen(),
          ),
        ],
      ),
    ],
  );
});

/// Bridges Riverpod's auth stream to GoRouter's [Listenable] so
/// the router refreshes automatically on sign-in / sign-out.
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}
