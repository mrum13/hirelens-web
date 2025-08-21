import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hirelens_admin/components/buttons.dart';
import 'package:hirelens_admin/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController tokenController = TextEditingController();
  bool isLoginLoading = false;
  bool isSendCodeLoading = false;

  void handleLogin() async {
    if (isLoginLoading) return;
    setState(() {
      isLoginLoading = true;
    });
    String email = emailController.text.trim();
    String token = tokenController.text.trim();

    try {
      if (email.isEmpty || token.isEmpty) {
        throw Exception('Email and token cannot be empty');
      }

      final result = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: token,
      );

      if (result.user!.userMetadata!['role'] != null) {
        await Supabase.instance.client.auth.signOut();
        throw Exception("This user is not allowed to login to admin panel!");
      }

      GoRouter.of(context).replace('/app/home');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: ${e.toString()}')));
      setState(() {
        isLoginLoading = false;
        isSendCodeLoading = false;
      });
    }
  }

  void handleSendCode() async {
    if (isSendCodeLoading) return;
    setState(() {
      isSendCodeLoading = true;
    });
    String email = emailController.text.trim();

    try {
      if (email.isEmpty) {
        throw Exception('Email cannot be empty');
      }

      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
        shouldCreateUser: false,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Code sent to $email')));

      // setState(() {
      //   isSendCodeLoading = false;
      // });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send code: ${e.toString()}')),
      );

      setState(() {
        isSendCodeLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.45,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hirelens Admin Login',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              SizedBox(height: 32),
              TextField(
                autofocus: true,
                controller: emailController,
                decoration: InputDecoration(label: Text('Email')),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: TextField(
                      controller: tokenController,
                      decoration: InputDecoration(label: Text('Kode OTP')),
                    ),
                  ),
                  MyFilledButton(
                    isLoading: isSendCodeLoading,
                    width: 180,
                    onTap: handleSendCode,
                    variant: MyFilledButtonVariant.neutral,
                    child: Text("Kirim OTP"),
                  ),
                ],
              ),
              SizedBox(height: 32),
              MyFilledButton(
                isLoading: isLoginLoading,
                variant: MyFilledButtonVariant.primary,
                onTap: handleLogin,
                child: Text(
                  "Login",
                  style: TextStyle(
                    color: themeFromContext(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
