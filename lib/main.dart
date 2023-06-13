import 'dart:developer';
import 'package:demo_google_signin_web_app/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseConfig);
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: authStateChanges(),
    );
  }

  Widget authStateChanges() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            return HomePage(
              FirebaseAuth.instance.currentUser!,
            );
          } else {
            return const LoginPage();
          }
        });
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (_auth.currentUser == null) {
        await handelGoogleSignIn(true);
      } else {}
    });
  }

  Future<void> handelGoogleSignIn(bool useSilently) async {
    try {
      GoogleSignInAccount googleSignInAccount = (useSilently)
          ? await _handleGoogleSignInSilently()
          : await _handleGoogleSignIn();
      final GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential result =
          await _auth.signInWithCredential(credential);
      final User? user = result.user;
      log("User: ${user?.displayName ?? ''},${user?.email ?? ''},${user?.photoURL ?? ''},${user?.phoneNumber ?? ''},");
    } catch (e) {
      //return User();
      debugPrint(e.toString());
    }
  }

  Future<GoogleSignInAccount> _handleGoogleSignIn() async {
    GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
    return googleSignInAccount!;
  }

  Future<GoogleSignInAccount> _handleGoogleSignInSilently() async {
    GoogleSignInAccount? googleSignInAccount =
        await _googleSignIn.signInSilently();
    return googleSignInAccount!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Sign in below to your google account'),
            const SizedBox(
              height: 40,
            ),
            ElevatedButton(
              onPressed: () async {
                await handelGoogleSignIn(false);
              },
              child: Container(
                height: 70,
                width: 180,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(
                    Radius.circular(50),
                  ),
                  // border: Border.all(color: Colors.black, width: 0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.g_mobiledata,
                    ),
                    Text("Sign in with Google")
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage(this.user, {super.key});
  final User user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  FirebaseAuth auth = FirebaseAuth.instance;
  void logout() async {
    await auth.signOut();
    await _googleSignIn.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              child: Image.network(
                widget.user.photoURL ?? '',
              ),
            ),
            const SizedBox(width: 20),
            Text(widget.user.email ?? ''),
            const SizedBox(
              width: 40,
            ),
            TextButton(
              onPressed: () {
                logout();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ));
              },
              child: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
