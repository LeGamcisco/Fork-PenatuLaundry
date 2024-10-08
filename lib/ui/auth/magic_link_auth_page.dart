import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penatu/app/bloc/auth/auth_bloc.dart';
import 'package:penatu/app/bloc/auth/auth_state.dart';
import 'package:penatu/app/bloc/auth/auth_event.dart';
import 'package:penatu/ui/dashboard/dashboard_page.dart';
import 'package:penatu/ui/styles/button.dart';
import 'package:penatu/ui/styles/dialog.dart';

class MagicLinkAuthPage extends StatefulWidget {
  static const String routeName = '/magic-auth';

  const MagicLinkAuthPage({Key? key}) : super(key: key);

  @override
  _MagicLinkAuthPageState createState() => _MagicLinkAuthPageState();
}

class _MagicLinkAuthPageState extends State<MagicLinkAuthPage> {
  late ThemeData _theme;
  final TextEditingController _emailController = TextEditingController();
  final bool isDialogShow = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is EmailSentLoginAuthState) {
            dialog(context, 'Email Konfirmasi Terkirim',
                'Konfirmasi email anda ', true, () {});
            state.emailClient.onAuthStateChange.listen((data) {
              final session = data.session;
              if (session != null && mounted) {
                dialog(context, 'Success', 'Login Successful', false, () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    DashboardPage.routeName,
                    (route) => false,
                  );
                });
              }
            });
          } else if (state is FailedMagicLinkLoginAuthState) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is LoadingAuthState) {
            return Center(child: CircularProgressIndicator());
          }
          return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildImageLogo(),
                  SizedBox(height: 18),
                  Text(
                    'Sign In',
                    style: _theme.textTheme.displayMedium,
                  ),
                  SizedBox(height: 18),
                  _buildInputEmail(),
                  SizedBox(height: 16),
                  _buildFormButton(),
                ],
              ));
        },
      ),
    );
  }

  // Widget
  Widget _buildImageLogo() {
    return Center(
      child: Image.asset(
        'assets/icons/ic_launcher.png',
        height: 120,
      ),
    );
  }

  Widget _buildInputEmail() {
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildFormButton() {
    return PrimaryButton(
      label: 'Sign In',
      isFullWidth: true,
      onPressed: () {
        final email = _emailController.text;
        if (email.isNotEmpty) {
          context.read<AuthBloc>().add(SignInMagicLink(email: email));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Masukan email')));
        }
      },
    );
  }
}
