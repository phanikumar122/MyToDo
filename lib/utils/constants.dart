// Base URL of your backend API.
// Use kProdUrl when deploying to a real server.
const String kDevUrl  = 'http://10.0.2.2:3000/api'; // Android emulator → localhost
const String kProdUrl = 'https://mytodo-h0b7.onrender.com/api'; // Replace with your Render URL

const String kBaseUrl = bool.fromEnvironment('dart.vm.product') ? kProdUrl : kDevUrl;

// For physical device on the same Wi-Fi network:
// const String kBaseUrl = 'http://192.168.x.x:3000/api';

// Default categories
const List<String> kDefaultCategories = [
  'Work',
  'Study',
  'Personal',
  'Health',
];

// Priority display labels
const Map<String, String> kPriorityLabels = {
  'high':   'High',
  'medium': 'Medium',
  'low':    'Low',
};

// Pomodoro durations (minutes)
const int kPomodoroWork  = 25;
const int kPomodoroBreak = 5;
const int kPomodoroLong  = 15;
