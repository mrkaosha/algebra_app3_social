import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'std_to_slope_int_data.dart';
import 'problem_statement.dart';
import 'grid_with_gestures.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  double x = 0.0;
  double y = 0.0;
  double canvasWidth = 500;
  double canvasHeight = 500;
  double gridSize = 25;
  double margins = 0.05; //the margin size as a percent of canvasWidth
  StdToSlopeIntData eqns = StdToSlopeIntData();
  Map<String, dynamic> currentEquation = {};
  bool drawCursor = false;
  bool tapUp = true;
  FirebaseFirestore db = FirebaseFirestore.instance;
  String uid = "";

  @override
  _MainAppState() {
    currentEquation = eqns.getNextEquation();
    _resetDataList();
    print(currentEquation);
  }

  List<List<bool>> dataList = [];

  void _resetDataList() {
    dataList = List.generate(
      (canvasHeight / gridSize as int) + 1,
      (i) => List.generate(
        (canvasWidth / gridSize as int) + 1,
        (j) => false,
        growable: false,
      ),
      growable: false,
    );
  }

  void nextEquation() {
    setState(() => currentEquation = eqns.getNextEquation());
    print(currentEquation);
  }

  bool checkAnswer() {
    bool correct = true;
    int numPoints = 0;
    double offset =
        -10.0; // ****should I put this offset in the class global variables?****
    for (int i = 0; i <= (canvasHeight / gridSize as int); i++) {
      // grab the dots for the data points
      var r = dataList[i];
      r.asMap().forEach((index, d) {
        if (d) {
          numPoints++;
          print((i + offset) * currentEquation['den']);
          print(currentEquation['num'] * (index + offset) +
              currentEquation['yint'] * currentEquation['den']);
        }
        if (d &&
            ((i + offset) * currentEquation['den'] !=
                currentEquation['num'] * (index + offset) +
                    currentEquation['yint'] * currentEquation['den'])) {
          correct = false;
        }
      });
    }
    print(correct && numPoints > 1);

    // ******* INSERT FIRESTORE CODE HERE https://firebase.google.com/docs/firestore/quickstart#dart

    db.collection('mrkaosha').add({"test": 1});

    return (correct && numPoints > 1);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return MaterialApp(
      home: Scaffold(
        body: ListView(
          children: [
            const Align(
              child: LoginButton(),
            ),
            Align(
              child: ProblemStatement(currentEquation: currentEquation),
            ),
            Align(
              child: GridWithGestureDetector(
                canvasWidth: canvasWidth,
                margins: margins,
                canvasHeight: canvasHeight,
                gridSize: gridSize,
                dataList: dataList,
              ),
            ),
            Align(
              child: ActionButtons(
                checkAnswer: checkAnswer,
                nextEquation: nextEquation,
                currentEquation: currentEquation,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => _resetDataList());
              },
              child: const Text("Clear graph"),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 240.0),
            ),
            Card(
              color: theme.colorScheme.primary,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                  child: Text(
                    "South Hills Academy",
                    style: TextStyle(
                      fontSize: 10.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginButton extends StatefulWidget {
  const LoginButton({super.key});

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  late bool loggedIn = false;
  late String userName = 'Guest User';

  _LoginButtonState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        print(user.uid);
        userName =
            user.email != null ? user.email!.split('@')[0] : 'Guest User';
        setState(() {
          loggedIn = true;
        });
      }
    });
  }

  Future<void> signInWithGoogle() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

    // Once signed in, return the UserCredential
    // return await FirebaseAuth.instance.signInWithPopup(googleProvider);

    // Or use signInWithRedirect
    //return await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
  }

  //https://firebase.google.com/docs/auth/flutter/manage-users
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: loggedIn
          ? Column(
              children: [
                Text('Welcome $userName'),
                TextButton(
                  onPressed: () => setState(() {
                    loggedIn = false;
                    FirebaseAuth.instance.signOut;
                  }),
                  child: const Text('Log Out'),
                ),
              ],
            )
          : SignInButton(
              Buttons.GoogleDark,
              onPressed: signInWithGoogle,
            ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  final dynamic checkAnswer;
  final dynamic nextEquation;
  final dynamic currentEquation;
  const ActionButtons(
      {required this.checkAnswer,
      required this.nextEquation,
      required this.currentEquation,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextButton(
          onPressed: () {
            bool correct = checkAnswer();
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                content: Text(correct
                    ? "Correct!"
                    : "Incorrect, make sure your slope is ${currentEquation['num']}/${currentEquation['den']} or ${currentEquation['num'] * -1}/${currentEquation['den'] * -1} or a reduced fraction form of either"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                ],
              ),
            );
          },
          child: const Text("Check Answer"),
        ),
        TextButton(
          onPressed: () {
            nextEquation();
          },
          child: const Text("Next Equation"),
        ),
      ],
    );
  }
}
