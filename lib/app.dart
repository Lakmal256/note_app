import 'package:NoteApp/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      theme: themeProvider.selectedTheme.copyWith(
        textTheme: Theme.of(context).textTheme.copyWith(
          titleSmall: const TextStyle(fontFamily: 'Montserrat'),
          titleMedium: const TextStyle(fontFamily: 'Montserrat'),
          titleLarge: const TextStyle(fontFamily: 'Montserrat'),
        ),
      ),
      color: const Color(0xFFFAFAFA),
        debugShowCheckedModeBanner: false,
      home: const ViewNotes(),
    );

  }
}
