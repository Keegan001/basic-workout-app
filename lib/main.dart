import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';

// --- Data Models for the Workout Plan ---

/// Represents a single exercise with its description (reps, sets, time, etc.).
class Exercise {
  final String name;
  final String description;

  Exercise({required this.name, required this.description});
}

/// Represents a full day's workout, including warm-up, main workout, and cardio.
class WorkoutDay {
  final String title;
  final String subtitle;
  final List<Exercise> warmup;
  final List<Exercise> workout;
  final List<Exercise> cardio;

  WorkoutDay({
    required this.title,
    required this.subtitle,
    required this.warmup,
    required this.workout,
    required this.cardio,
  });
}

// --- The Workout Plan Data ---

final List<WorkoutDay> workoutSplit = [
  // Day 1
  WorkoutDay(
    title: "Day 1: Push Day",
    subtitle: "Chest, Shoulders, Triceps",
    warmup: [
      Exercise(name: "Jumping Jacks", description: "60 seconds"),
      Exercise(name: "Arm Circles", description: "30s forward, 30s backward"),
      Exercise(name: "Cat-Cow Stretch", description: "60 seconds"),
      Exercise(name: "Torso Twists", description: "60 seconds"),
      Exercise(name: "Inchworms", description: "60 seconds"),
    ],
    workout: [
      Exercise(name: "Push-ups", description: "3 sets of AMRAP"),
      Exercise(name: "Pike Push-ups", description: "3 sets of 8-12 reps"),
      Exercise(name: "Decline Push-ups", description: "3 sets of 6-10 reps"),
      Exercise(name: "Plank Up-Downs", description: "3 sets of 10-12 reps per side"),
    ],
    cardio: [
      Exercise(name: "Circuit (3 rounds)", description: "60s rest between rounds"),
      Exercise(name: "High Knees", description: "30 seconds"),
      Exercise(name: "Butt Kicks", description: "30 seconds"),
      Exercise(name: "Jumping Jacks", description: "30 seconds"),
      Exercise(name: "Mountain Climbers", description: "30 seconds"),
    ],
  ),
  // Day 2
  WorkoutDay(
    title: "Day 2: Legs & Glutes",
    subtitle: "Glute Focus",
    warmup: [
      Exercise(name: "Jumping Jacks", description: "60 seconds"),
      Exercise(name: "Hip Circles", description: "30s each direction"),
      Exercise(name: "Glute Bridges", description: "20 reps"),
      Exercise(name: "Leg Swings", description: "30s each leg (all directions)"),
    ],
    workout: [
      Exercise(name: "Glute Bridge", description: "4 sets of 20-25 reps"),
      Exercise(name: "Donkey Kicks", description: "3 sets of 20 reps per leg"),
      Exercise(name: "Fire Hydrants", description: "3 sets of 20 reps per leg"),
      Exercise(name: "Bulgarian Split Squats", description: "3 sets of 12-15 reps per leg"),
      Exercise(name: "Clamshells", description: "3 sets of 25-30 reps per side"),
    ],
    cardio: [
      Exercise(name: "Jump Squats", description: "5 rounds of 45s on, 15s rest"),
      Exercise(name: "Alternating Lunges", description: "5 minutes continuous"),
    ],
  ),
  // Day 3
  WorkoutDay(
    title: "Day 3: Pull Day",
    subtitle: "Back, Biceps, Core",
    warmup: [
      Exercise(name: "Jumping Jacks", description: "60 seconds"),
      Exercise(name: "Arm Circles", description: "30s forward, 30s backward"),
      Exercise(name: "Cat-Cow Stretch", description: "60 seconds"),
      Exercise(name: "Torso Twists", description: "60 seconds"),
      Exercise(name: "Bodyweight Good Mornings", description: "60 seconds"),
    ],
    workout: [
      Exercise(name: "Superman with Lat Pulldown", description: "3 sets of 12-15 reps"),
      Exercise(name: "Reverse Plank", description: "3 sets, hold for 30-60 seconds"),
      Exercise(name: "Bird-Dog", description: "3 sets of 12-15 reps per side"),
      Exercise(name: "Isometric Bicep Curls", description: "3 sets of 30-second holds"),
    ],
    cardio: [
      Exercise(name: "Burpees", description: "5 rounds of 30s on, 30s rest"),
      Exercise(name: "Shadow Boxing", description: "5 minutes continuous"),
    ],
  ),
  // Day 4
  WorkoutDay(
    title: "Day 4: Legs & Full Body",
    subtitle: "Fat Loss Focus",
    warmup: [
      Exercise(name: "Jumping Jacks", description: "60 seconds"),
      Exercise(name: "High Knees", description: "60 seconds"),
      Exercise(name: "Butt Kicks", description: "60 seconds"),
      Exercise(name: "Frankenstein Kicks", description: "60 seconds"),
      Exercise(name: "Bodyweight Squats", description: "60 seconds"),
    ],
    workout: [
      Exercise(name: "Squats", description: "4 sets of 15-20 reps"),
      Exercise(name: "Alternating Lunges", description: "3 sets of 15-20 reps per leg"),
      Exercise(name: "Side Lunges", description: "3 sets of 12-15 reps per side"),
      Exercise(name: "Bodyweight Good Mornings", description: "3 sets of 15-20 reps"),
      Exercise(name: "Plank with Leg Raises", description: "3 sets of 15-20 alternating raises"),
    ],
    cardio: [
       Exercise(name: "Tabata (5 rounds)", description: "20s on, 10s rest"),
       Exercise(name: "Burpees", description: ""),
       Exercise(name: "Mountain Climbers", description: ""),
       Exercise(name: "Jumping Jacks", description: ""),
       Exercise(name: "High Knees", description: ""),
    ],
  ),
];


// --- Main Application ---

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  // Needed for plugins before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone database
  tz.initializeTimeZones();

  // Setup notification plugin
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const WorkoutApp());
}

class WorkoutApp extends StatelessWidget {
  const WorkoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Tracker',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.tealAccent,
        hintColor: Colors.tealAccent,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        cardColor: const Color(0xFF2C2C2C),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C2C2C),
          elevation: 0,
        ),
      ),
      home: const WorkoutHomePage(),
    );
  }
}

class WorkoutHomePage extends StatefulWidget {
  const WorkoutHomePage({super.key});

  @override
  State<WorkoutHomePage> createState() => _WorkoutHomePageState();
}

class _WorkoutHomePageState extends State<WorkoutHomePage> {
  int _lastCompletedDayIndex = -1;
  late int _nextWorkoutDayIndex;
  static const String _prefsKey = 'lastCompletedDay';

  @override
  void initState() {
    super.initState();
    _loadLastWorkoutDay();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<void> _loadLastWorkoutDay() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastCompletedDayIndex = prefs.getInt(_prefsKey) ?? -1;
      _nextWorkoutDayIndex = (_lastCompletedDayIndex + 1) % workoutSplit.length;
    });
    _scheduleDailyNotification();
  }

  Future<void> _markWorkoutAsDone() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastCompletedDayIndex = _nextWorkoutDayIndex;
      _nextWorkoutDayIndex = (_lastCompletedDayIndex + 1) % workoutSplit.length;
      prefs.setInt(_prefsKey, _lastCompletedDayIndex);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Great job! See you tomorrow for ${workoutSplit[_nextWorkoutDayIndex].title}.'),
            backgroundColor: Colors.teal,
        ),
    );

    _scheduleDailyNotification();
  }

  Future<void> _scheduleDailyNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll(); // Cancel previous notifications

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 9); // Schedule for 9 AM
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      "Time for your workout! 💪",
      "Today's focus: ${workoutSplit[_nextWorkoutDayIndex].subtitle}",
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'workout_channel_id',
          'Workout Reminders',
          channelDescription: 'Daily reminders to complete your workout',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher'
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // This makes it repeat daily at the specified time
    );
  }

  @override
  Widget build(BuildContext context) {
    final nextWorkout = workoutSplit[_nextWorkoutDayIndex];
    final lastWorkoutText = _lastCompletedDayIndex == -1
        ? "You haven't completed any workouts yet."
        : "Last workout: ${workoutSplit[_lastCompletedDayIndex].title}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workout Plan'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      lastWorkoutText,
                      style: TextStyle(
                          fontSize: 16, color: Colors.white.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Next up:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Next Workout Card
            WorkoutDayCard(workoutDay: nextWorkout),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _markWorkoutAsDone,
        label: const Text('Mark as Done'),
        icon: const Icon(Icons.check),
        backgroundColor: Colors.tealAccent,
        foregroundColor: Colors.black,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class WorkoutDayCard extends StatelessWidget {
  final WorkoutDay workoutDay;

  const WorkoutDayCard({super.key, required this.workoutDay});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: Colors.teal,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workoutDay.title,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Text(
                  workoutDay.subtitle,
                  style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          _buildExerciseSection("Warm-up (5 mins)", workoutDay.warmup, Icons.local_fire_department),
          _buildExerciseSection("Workout (30 mins)", workoutDay.workout, Icons.fitness_center),
          _buildExerciseSection("Cardio (10 mins)", workoutDay.cardio, Icons.directions_run),
        ],
      ),
    );
  }

  Widget _buildExerciseSection(String title, List<Exercise> exercises, IconData icon) {
    return Theme(
      data: ThemeData.dark().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.tealAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        children: exercises
            .map((e) => ListTile(
                  title: Text(e.name),
                  subtitle: Text(e.description, style: TextStyle(color: Colors.white.withOpacity(0.7))),
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                ))
            .toList(),
      ),
    );
  }
}
