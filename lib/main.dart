import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'std_to_slope_int_data.dart';
import 'grid_painter.dart';
import 'problem_statement.dart';

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

class GridWithGestureDetector extends StatefulWidget {
  const GridWithGestureDetector({
    super.key,
    required this.canvasWidth,
    required this.margins,
    required this.canvasHeight,
    required this.gridSize,
    required this.dataList,
  });

  final double canvasWidth;
  final double margins;
  final double canvasHeight;
  final double gridSize;
  final List<List<bool>> dataList;

  @override
  State<GridWithGestureDetector> createState() =>
      _GridWithGestureDetectorState();
}

class _GridWithGestureDetectorState extends State<GridWithGestureDetector> {
  double x = 0.0;
  double y = 0.0;
  bool drawCursor = false;
  void _toggleDataPoint(TapDownDetails details) {
    x = ((details.localPosition.dx - widget.margins * widget.canvasWidth) /
                widget.gridSize)
            .round() *
        widget.gridSize;
    y = ((details.localPosition.dy - widget.margins * widget.canvasHeight) /
                widget.gridSize)
            .round() *
        widget.gridSize;
    int i = ((widget.canvasWidth - y) / widget.gridSize) as int;
    if (i < 0) {
      i = 0;
    } else if (i > widget.dataList.length - 1) {
      i = widget.dataList.length - 1;
    }
    int j = x / widget.gridSize as int;
    if (j < 0) {
      j = 0;
    } else if (j > widget.dataList[0].length - 1) {
      j = widget.dataList.length - 1;
    }
    print("$i, $j");
    setState(() {
      widget.dataList[i][j]
          ? widget.dataList[i][j] = false
          : widget.dataList[i][j] = true;
      drawCursor = false;
    });
    //print(dataList);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: SizedBox(
          width: widget.canvasWidth * (1.0 + widget.margins * 2),
          height: widget.canvasHeight * (1.0 + widget.margins * 2),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTapDown: _toggleDataPoint,
              child: CustomPaint(
                foregroundPainter: CursorPainter(x, y, drawCursor),
                painter: GridPainter(widget.canvasWidth, widget.canvasHeight,
                    widget.gridSize, widget.margins, widget.dataList),
              ),
            ),
          ),
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
        print(user.email);
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
