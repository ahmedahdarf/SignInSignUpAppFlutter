import 'package:flutter/material.dart';
import 'package:pfa_project_cloudhpc/discovery_screen.dart';

import 'package:pfa_project_cloudhpc/services/auth_service.dart';
import 'package:pfa_project_cloudhpc/views/map_view.dart';
import 'package:pfa_project_cloudhpc/views/profile_view.dart';
import 'package:pfa_project_cloudhpc/views/sign_up_view.dart';
import 'package:pfa_project_cloudhpc/weather_screen.dart';
import 'package:pfa_project_cloudhpc/widgets/provider_widget.dart';
import 'package:pfa_project_cloudhpc/views/first_view.dart';
import 'package:pfa_project_cloudhpc/views/home_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      auth: AuthService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Test",
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/home',
        routes: <String, WidgetBuilder>{
          '/home': (context) => HomeController(),
          '/signUp': (context) => SignUpView(
                authFormType: AuthFormType.signUp,
              ),
          '/signIn': (context) => SignUpView(
                authFormType: AuthFormType.signIn,
              ),
          '/anonymousSignIn': (context) => SignUpView(
                authFormType: AuthFormType.anonymous,
              ),
          '/convertUser': (context) => SignUpView(
                authFormType: AuthFormType.convert,
              ),
          '/profile': (context) => ProfilView(),
          '/gps': (context) => MapView(),
          '/discovery': (context) => DiscoveryPage(),
          '/weather': (context) => WeatherScreen(),
        },
      ),
    );
  }
}

class HomeController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of(context).auth;
    return StreamBuilder(
      stream: auth.onAuthStateChanged,
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final bool signedIn = snapshot.hasData;
          return signedIn ? Home() : FirstView();
        }
        return CircularProgressIndicator();
      },
    );
  }
}
