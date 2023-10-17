import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    ThemeData selectedTheme = themeProvider.selectedTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 38.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    padding: const EdgeInsets.all(0),
                    icon: Icon(
                      Icons.arrow_back,
                      color: selectedTheme == lightTheme ? Colors.black : Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Settings",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: selectedTheme == lightTheme ? Colors.black : Colors.white,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "App theme",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: selectedTheme == lightTheme ? Colors.black : Colors.white, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 20),
                  const SettingDropdown(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThemePreferences {
  static const String selectedThemeKey = 'selectedTheme';

  static Future<void> setThemePreference(String themeName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(selectedThemeKey, themeName);
  }

  static Future<String?> getThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(selectedThemeKey);
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeData _selectedTheme = lightTheme;

  ThemeProvider() {
    // Load the selected theme from preferences during initialization
    ThemePreferences.getThemePreference().then((themeName) {
      _selectedTheme = themeName == 'dark' ? darkTheme : lightTheme;
      notifyListeners();
    });
  }

  ThemeData get selectedTheme => _selectedTheme;

  void setTheme(ThemeData theme) {
    _selectedTheme = theme;

    // Save the selected theme to preferences
    String themeName = (theme == darkTheme) ? 'dark' : 'light';
    ThemePreferences.setThemePreference(themeName);

    notifyListeners();
  }
}


final lightTheme = ThemeData(
  brightness: Brightness.light,
  // Define your light theme settings here
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  // Define your dark theme settings here
);

class SettingDropdown extends StatefulWidget {
  const SettingDropdown({super.key});

  @override
  SettingDropdownState createState() => SettingDropdownState();
}

class SettingDropdownState extends State<SettingDropdown> {
  late DropdownController _dropdownController;

  ThemeData selectedTheme = lightTheme; // Initialize with a default theme

  @override
  void initState() {
    super.initState();
    _dropdownController = DropdownController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Access the ThemeProvider here, after initState has completed
    ThemeData selectedTheme = Provider.of<ThemeProvider>(context).selectedTheme;

    // Determine the initial selected value based on the current theme
    if (selectedTheme == lightTheme) {
      _dropdownController.selectedValue = 'Light';
    } else if (selectedTheme == darkTheme) {
      _dropdownController.selectedValue = 'Dark';
    }
    else {
      // Set the theme based on system settings
      _dropdownController.selectedValue = 'System';
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData selectedTheme = Provider.of<ThemeProvider>(context).selectedTheme;
    return DropdownButtonHideUnderline(
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD9D9D9), width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButton<String>(
          value: _dropdownController.selectedValue,
          onChanged: (String? newValue) {
            setState(() {
              _dropdownController.selectedValue = newValue!;
              if (newValue == 'Light') {
                Provider.of<ThemeProvider>(context, listen: false).setTheme(lightTheme);
              } else if (newValue == 'Dark') {
                Provider.of<ThemeProvider>(context, listen: false).setTheme(darkTheme);
              } else {
                // Set the theme based on system settings
                Provider.of<ThemeProvider>(context, listen: false)
                    .setTheme(MediaQuery.of(context).platformBrightness == Brightness.dark ? darkTheme : lightTheme);
              }
            });
          },
          items: <String>['Light', 'Dark', 'System'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(value,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: selectedTheme == lightTheme ? Colors.black : Colors.white,)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class DropdownController {
  late String selectedValue;
  Function(String)? onChanged;

  void setSelectedValue(String value) {
    selectedValue = value;
    onChanged?.call(value);
  }
}
