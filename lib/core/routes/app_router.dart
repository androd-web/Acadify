import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/forgot_password.dart';
import '../../features/auth/screens/recovery_success_screen.dart';
import '../../features/auth/screens/first_login_screen.dart';
import '../../features/auth/screens/select_status_screen.dart';
import '../../features/auth/screens/register_student_screen.dart';
import '../../features/auth/screens/register_teacher_screen.dart';
import '../../features/auth/screens/register_admin_screen.dart';
import '../../features/student/screens/dashboard_screen.dart';
import '../../features/student/screens/announcements_screen.dart';
import '../../features/student/screens/announcement_detail.dart';
import '../../features/student/screens/courses_screen.dart';
import '../../features/student/screens/course_documents_screen.dart';
import '../../features/student/screens/pdf_viewer_screen.dart';
import '../../features/student/screens/grades_screen.dart';
import '../../features/student/screens/grade_detail_screen.dart';
import '../../features/student/screens/schedule_screen.dart';
import '../../features/student/screens/schedule_detail_screen.dart';
import '../../features/shared/screens/settings_screen.dart';
import '../../features/shared/screens/profile_screen.dart';
import '../../features/student/screens/notifications_screen.dart';
import '../../features/student/screens/offline_screen.dart';
import '../../features/student/screens/offline_storage_screen.dart';
import '../../features/teacher/screens/dashboard_screen.dart';
import '../../features/teacher/screens/teacher_courses_screen.dart';
import '../../features/teacher/screens/grade_entry_screen.dart';
import '../../features/teacher/screens/attendance_tracking_screen.dart';
import '../../features/teacher/screens/schedule_management_screen.dart';
import '../../features/teacher/screens/upload_course_screen.dart';
import '../../features/student/screens/absences_screen.dart';
import '../../features/admin/screens/dashboard_screen.dart';
import '../../features/admin/screens/announcement_management_screen.dart';
import '../../features/admin/screens/compose_announcement_screen.dart';
import '../../features/admin/screens/users_screen.dart';
import '../../features/admin/screens/add_user_screen.dart';
import '../../core/models/user_model.dart';
import '../../core/models/course_model.dart';
import '../../shared/widgets/main_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
    GoRoute(path: '/recovery-success', builder: (context, state) => const RecoverySuccessScreen()),
    GoRoute(path: '/first-login', builder: (context, state) => const FirstLoginScreen()),
    GoRoute(path: '/select-status', builder: (context, state) => const SelectStatusScreen()),
    GoRoute(path: '/register-student', builder: (context, state) => const RegisterStudentScreen()),
    GoRoute(path: '/register-teacher', builder: (context, state) => const RegisterTeacherScreen()),
    GoRoute(path: '/register-admin', builder: (context, state) => const RegisterAdminScreen()),
    
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        // Student Routes
        GoRoute(path: '/student-dashboard', builder: (context, state) => const StudentDashboard()),
        GoRoute(path: '/announcements', builder: (context, state) => const AnnouncementsScreen()),
        GoRoute(path: '/courses', builder: (context, state) => const CoursesScreen()),
        GoRoute(path: '/grades', builder: (context, state) => const GradesScreen()),
        GoRoute(path: '/schedule', builder: (context, state) => const ScheduleScreen()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen(role: UserRole.student)),
        GoRoute(path: '/teacher-profile', builder: (context, state) => const ProfileScreen(role: UserRole.teacher)),
        GoRoute(path: '/admin-profile', builder: (context, state) => const ProfileScreen(role: UserRole.admin)),

        // Teacher Routes
        GoRoute(path: '/teacher-dashboard', builder: (context, state) => const TeacherDashboard()),
        GoRoute(path: '/teacher-courses', builder: (context, state) => const TeacherCoursesScreen()),
        GoRoute(path: '/teacher-grade-entry', builder: (context, state) => const TeacherGradeEntry()),
        GoRoute(path: '/teacher-schedule', builder: (context, state) => const TeacherScheduleManagement()),

        // Admin Routes
        GoRoute(path: '/admin-dashboard', builder: (context, state) => const AdminDashboard()),
        GoRoute(path: '/admin-announcements', builder: (context, state) => const AdminAnnouncementManagement()),
        GoRoute(path: '/admin-users', builder: (context, state) => const AdminUsersScreen()),
      ],
    ),

    // Other Routes (without Nav Bar)
    GoRoute(path: '/announcement-detail', builder: (context, state) => const AnnouncementDetail()),
    GoRoute(
      path: '/course-documents', 
      builder: (context, state) => CourseDocumentsScreen(course: state.extra as CourseModel),
    ),
    GoRoute(
      path: '/pdf-viewer', 
      builder: (context, state) => PdfViewerScreen(doc: state.extra as Map<String, dynamic>),
    ),
    GoRoute(path: '/pdf-viewer-old', builder: (context, state) => const PdfViewerScreen(doc: {})),
    GoRoute(path: '/grade-detail', builder: (context, state) => const GradeDetailScreen()),
    GoRoute(path: '/schedule-detail', builder: (context, state) => const ScheduleDetailScreen()),
    GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
    GoRoute(path: '/offline', builder: (context, state) => const OfflineScreen()),
    GoRoute(path: '/offline-storage', builder: (context, state) => const OfflineStorageScreen()),
    GoRoute(path: '/absences', builder: (context, state) => const AbsencesScreen()),
    GoRoute(path: '/teacher-attendance', builder: (context, state) => const AttendanceTrackingScreen()),
    GoRoute(path: '/teacher-upload-course', builder: (context, state) => const UploadCourseScreen()),
    GoRoute(path: '/admin-compose-announcement', builder: (context, state) => const AdminComposeAnnouncement()),
    GoRoute(path: '/admin-add-user', builder: (context, state) => const AdminAddUserScreen()),
  ],
);

