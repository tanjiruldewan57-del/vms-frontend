import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_layout.dart';
import 'auth_provider.dart';

/// Clean, responsive desktop-first Login screen tailored to Stark Group visual style.
/// Connected to Spring Boot authentication endpoint `POST /api/v1/auth/login`.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemoCredentials() {
    ref.read(authProvider.notifier).clearError();
    _emailController.text = AppConstants.demoEmail;
    _passwordController.text = AppConstants.demoPassword;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);
    authNotifier.clearError();

    final success = await authNotifier.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      context.go(AppConstants.routeVehicles);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final auth = ref.watch(authProvider);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 920.0 : 460.0,
            ),
            child: AppCard(
              padding: EdgeInsets.zero,
              child: isDesktop
                  ? IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left Hero Banner (Desktop)
                          Expanded(
                            flex: 5,
                            child: _HeroBanner(isDark: isDark),
                          ),
                          // Right Form Area
                          Expanded(
                            flex: 6,
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: _buildForm(context, theme, isDark, auth),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: _buildForm(context, theme, isDark, auth),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AuthNotifier auth,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.starkOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: AppColors.starkOrangeLight,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Fleet Admin Portal',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Sign in to manage and audit Stark Group logistics assets.',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),

          // User-friendly Error Alert Banner on Invalid Credentials or Network Failure
          if (auth.errorMessage != null)
            _buildErrorBanner(auth.errorMessage!, isDark),

          // Email Input
          Text(
            'Stark Group Enterprise Email',
            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'e.g. fleet.admin@starkgroup.com',
              prefixIcon: Icon(Icons.email_outlined, size: 20),
            ),
            onChanged: (String _) => ref.read(authProvider.notifier).clearError(),
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your corporate email.';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Please enter a valid email address.';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // Password Input
          Text(
            'Account Password',
            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Enter account password',
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            onChanged: (String _) => ref.read(authProvider.notifier).clearError(),
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your password.';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters.';
              }
              return null;
            },
            onFieldSubmitted: (String _) => _handleLogin(),
          ),
          const SizedBox(height: 20),

          // Demo Credentials Quick Fill Button
          OutlinedButton.icon(
            icon: const Icon(Icons.bolt_rounded, size: 18, color: AppColors.starkOrange),
            label: const Text('Fill Demo Stark Admin Credentials'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(42),
            ),
            onPressed: auth.isLoading ? null : _fillDemoCredentials,
          ),
          const SizedBox(height: 16),

          // Submit Button
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: auth.isLoading ? null : _handleLogin,
            child: auth.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Access Fleet Operations'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: AppColors.statusOutOfService.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: AppColors.statusOutOfService.withOpacity(0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.statusOutOfService,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isDark ? const Color(0xFFFCA5A5) : AppColors.statusOutOfService,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final bool isDark;

  const _HeroBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D31) : const Color(0xFFF1F5F9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.starkOrange, AppColors.starkOrangeHover],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.starkOrange.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'STARK GROUP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Vehicle Management System',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.starkOrangeLight,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Northern Europe\'s leading distributor of heavy building materials, construction logistics, and fleet operations.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              _FeatureBullet(
                icon: Icons.check_circle_outline_rounded,
                text: 'Multi-company division oversight (DK, UK, DE, Suomi)',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _FeatureBullet(
                icon: Icons.check_circle_outline_rounded,
                text: 'Heavy tractors, crane flatbeds & electric transporters',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _FeatureBullet(
                icon: Icons.check_circle_outline_rounded,
                text: 'Responsive Material 3 desktop admin architecture',
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            AppConstants.appVersion,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _FeatureBullet({
    required this.icon,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.starkOrange),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
