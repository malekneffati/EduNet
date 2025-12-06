import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/home_view.dart';
import '../views/login_view.dart';
import '../views/dashboard_view.dart';
import '../views/catalog_view.dart';
import '../views/subscription_view.dart';
import '../views/admin_dashboard_view.dart';
import '../views/admin_users_view.dart';
import '../views/admin_payments_view.dart';
import '../views/admin_promotions_view.dart';
import '../views/course_management_view.dart';
import '../views/course_form_view.dart';
import '../views/course_detail_view.dart';
import '../models/course_model.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      // Public routes
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: '/catalog',
        builder: (context, state) => const CatalogView(),
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionView(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginView(
          updateRole: (role) {
            print("🎯 [ROUTER] Role updated: $role");
          },
        ),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardView(),
      ),
      GoRoute(
        path: '/course/:id',
        builder: (context, state) {
          final course = state.extra as CourseModel;
          return CourseDetailView(course: course);
        },
      ),

      // Admin routes
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardView(),
      ),
      GoRoute(
        path: '/admin/courses',
        builder: (context, state) => const CourseManagementView(),
      ),
      GoRoute(
        path: '/admin/courses/add',
        builder: (context, state) => const CourseFormView(),
      ),
      GoRoute(
        path: '/admin/courses/edit/:id',
        builder: (context, state) {
          final courseId = state.pathParameters['id'];
          return CourseFormView(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUsersView(),
      ),
      GoRoute(
        path: '/admin/payments',
        builder: (context, state) => const AdminPaymentsView(),
      ),
      GoRoute(
        path: '/admin/promotions',
        builder: (context, state) => const AdminPromotionsView(),
      ),
    ],
    errorBuilder: (context, state) => const HomeView(),
  );
}
