import 'package:d_method/d_method.dart';
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
  TextEditingController passwordController = TextEditingController();
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

      // Verifikasi OTP
      await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: token,
      );

      // CEK ROLE DARI TABEL PROFILES
      final profileResponse =
          await Supabase.instance.client
              .from('profiles')
              .select('role')
              .eq('email', email)
              .single();

      DMethod.log(profileResponse.toString());

      // Jika role bukan 'admin', tolak login
      if (profileResponse['role'] != 'admin') {
        await Supabase.instance.client.auth.signOut();
        throw Exception("This user is not allowed to login to admin panel!");
      }

      setState(() {
        isSendCodeLoading = false;
      });

      // Login berhasil, redirect ke home
      GoRouter.of(context).replace('/app/home');
    } catch (e) {
      setState(() {
        isSendCodeLoading = false;
      });
      DMethod.log(e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: ${e.toString()}')));
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

      setState(() {
        isSendCodeLoading = false;
      });
    } catch (e) {
      DMethod.log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send code: ${e.toString()}')),
      );

      setState(() {
        isSendCodeLoading = false;
      });
    }
  }

  void handleLoginWithPassword() async {
    setState(() {
      isLoginLoading = true;
    });

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email or Password cannot be empty');
      }

      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // CEK ROLE DARI TABEL PROFILES
      final profileResponse =
          await Supabase.instance.client
              .from('profiles')
              .select('role')
              .eq('email', email)
              .single();

      DMethod.log(profileResponse.toString());

      // Jika role bukan 'admin', tolak login
      if (profileResponse['role'] != 'admin') {
        await Supabase.instance.client.auth.signOut();
        throw Exception("This user is not allowed to login to admin panel!");
      }

      setState(() {
        isLoginLoading = true;
      });

      // Login berhasil, redirect ke home
      GoRouter.of(context).replace('/app/home');
    } catch (e) {
      DMethod.log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed login: ${e.toString()}')),
      );

      setState(() {
        isLoginLoading = false;
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
              TextField(
                autofocus: true,
                controller: passwordController,
                decoration: InputDecoration(label: Text('Password')),
                obscureText: true,
                keyboardType: TextInputType.text,
              ),
              // Row(
              //   spacing: 16,
              //   children: [
              //     Expanded(
              //       child: TextField(
              //         controller: tokenController,
              //         decoration: InputDecoration(label: Text('Kode OTP')),
              //       ),
              //     ),
              //     MyFilledButton(
              //       isLoading: isSendCodeLoading,
              //       width: 180,
              //       onTap: handleSendCode,
              //       variant: MyFilledButtonVariant.neutral,
              //       child: Text("Kirim OTP"),
              //     ),
              //   ],
              // ),
              SizedBox(height: 32),
              MyFilledButton(
                isLoading: isLoginLoading,
                variant: MyFilledButtonVariant.primary,
                onTap: handleLoginWithPassword,
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
