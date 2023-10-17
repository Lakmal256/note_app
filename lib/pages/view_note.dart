import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../locator.dart';
import '../note.dart';
import '../service/service.dart';
import 'pages.dart';

class ViewNotes extends StatefulWidget {
  const ViewNotes({super.key});

  @override
  State<ViewNotes> createState() => _ViewNotesState();
}

class _ViewNotesState extends State<ViewNotes> {
  List<QuotesDto>? quote;
  Random random = Random();
  int? randomIndex = -1;
  List<Note> filteredNotes = [];
  List<Note> notes = [];
  bool isLoading = true;
  ThemeData? selectedTheme;

  @override
  void initState() {
    isLoading = true;
    fetchAllQuotes();
    loadNotesFromLocal(); // Load notes from local storage
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Access the ThemeProvider here
    final themeProvider = Provider.of<ThemeProvider>(context);
    selectedTheme = themeProvider.selectedTheme;

    // Now that you have selectedTheme, you can call loadNotesFromLocal
    loadNotesFromLocal();
  }

  void loadNotesFromLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList('notes');

    if (notesJson != null) {
      notes = notesJson.map((noteJson) => Note.fromJson(json.decode(noteJson))).toList();
    }
    filteredNotes = notes; // Set filteredNotes to loaded notes
  }

  //fetch random quote
  fetchAllQuotes() async {
    final quotes = await locate<RestService>().fetchQuotes();
    setState(() {
      quote = quotes;
      randomIndex = random.nextInt(quote!.length);
      isLoading = false;
    });
  }

  String getRandomQuote(int randomIndex) {
    if (randomIndex == -1) {
      return 'Loading...';
    }
    return quote![randomIndex].text ?? 'Unknown';
  }

  String getRandomAuthor(int randomIndex) {
    if (randomIndex == -1) {
      return '';
    }
    return quote![randomIndex].author ?? 'Anonymous';
  }

  //save notes to local storage
  void saveNotesToLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final notesJson = notes.map((note) => json.encode(note.toJson())).toList();
    prefs.setStringList('notes', notesJson);
  }

  //search notes
  void onSearchTextChanged(String searchText) {
    setState(() {
      filteredNotes = notes
          .where((note) =>
              note.content.toLowerCase().contains(searchText.toLowerCase()) ||
              note.title.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

  //delete notes
  void deleteNote(int index) {
    setState(() {
      if (index >= 0 && index < filteredNotes.length) {
        Note note = filteredNotes[index];
        notes.remove(note);
        saveNotesToLocal();
        filteredNotes = List.from(notes);
      }
    });
  }

  final lightTheme = ThemeData(
    brightness: Brightness.light,
  );

  final darkTheme = ThemeData(
    brightness: Brightness.dark,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: selectedTheme == lightTheme ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      height: 50,
                    ),
                    Text(
                      getRandomQuote(randomIndex!),
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: selectedTheme == lightTheme ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      getRandomAuthor(randomIndex!),
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: selectedTheme == lightTheme ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 6,
                          child: Container(
                            height: 70,
                            decoration: BoxDecoration(
                              color: selectedTheme == lightTheme
                                  ? const Color(0xFFFFFFFF)
                                  : const Color(0xFFFFFFFF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(color: const Color(0xFFD4D4D4), width: 1),
                              shape: BoxShape.rectangle,
                            ),
                            child: Center(
                              child: TextField(
                                onChanged: onSearchTextChanged,
                                cursorColor:
                                    selectedTheme == lightTheme ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                                autocorrect: false,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(left: 30, right: 10),
                                      child: Icon(
                                        Icons.search,
                                        color: selectedTheme == lightTheme
                                            ? const Color(0xFF000000)
                                            : const Color(0xFFFFFFFF),
                                        size: 25,
                                      ),
                                    ),
                                    hintText: 'Search',
                                    hintStyle: TextStyle(
                                        fontSize: 20,
                                        color: selectedTheme == lightTheme
                                            ? const Color(0xFF000000)
                                            : const Color(0xFFFFFFFF))),
                                style: TextStyle(
                                    fontSize: 20,
                                    color: selectedTheme == lightTheme
                                        ? const Color(0xFF000000)
                                        : const Color(0xFFFFFFFF)),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: CircularOption(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => const SettingsView(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.settings,
                              color: selectedTheme == lightTheme ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                            ),
                            heightFactor: 0.9,
                            color: selectedTheme == lightTheme
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFFFFFFFF).withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                        child: notes.isEmpty
                            ? Center(
                                child: Text(
                                  "Create a note",
                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                      color: selectedTheme == lightTheme
                                          ? const Color(0xFF000000)
                                          : const Color(0xFFFFFFFF),
                                      fontWeight: FontWeight.w800),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredNotes.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 15),
                                    elevation: 0,
                                    color: selectedTheme == lightTheme
                                        ? const Color(0xFFFFFFFF)
                                        : const Color(0xFF000000).withOpacity(0.2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                        color: Color(0xFFD9D9D9),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                                      child: ListTile(
                                        title: RichText(
                                          text: TextSpan(
                                              text: '${filteredNotes[index].title} \n',
                                              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                                  color: selectedTheme == lightTheme
                                                      ? const Color(0xFF000000)
                                                      : const Color(0xFFFFFFFF),
                                                  fontWeight: FontWeight.w800,
                                              fontFamily: "Montserrat"),
                                              children: [
                                                TextSpan(
                                                  text: filteredNotes[index].content,
                                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                      color: selectedTheme == lightTheme
                                                          ? const Color(0xFF000000)
                                                          : const Color(0xFFFFFFFF),
                                                      fontWeight: FontWeight.w500,
                                                      fontFamily: "Montserrat"),
                                                )
                                              ]),
                                        ),
                                        trailing: CircularOption(
                                          onPressed: () async {
                                            final result = await confirmDialog(context);
                                            if (result != null && result) {
                                              deleteNote(index);
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Color(0xFFFF0000),
                                          ),
                                          heightFactor: 0.9,
                                          color: selectedTheme == lightTheme
                                              ? const Color(0xFFFFFFFF)
                                              : const Color(0xFF000000).withOpacity(0.2),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )),
                  ],
                ),
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const CreateNoteView(),
            ),
          );

          // If result is not null, add the note to the list
          if (result != null) {
            setState(() {
              notes.add(Note(id: notes.length, title: result[0], content: result[1]));
              filteredNotes = notes;
            });
          }
        },
        elevation: 0,
        backgroundColor: const Color(0xFF5FFFD8),
        child: const Icon(Icons.add, color: Color(0xFF1C1B1F)),
      ),
    );
  }
}

class CircularOption extends StatelessWidget {
  const CircularOption({
    Key? key,
    required this.icon,
    required this.color,
    required this.heightFactor,
    required this.onPressed,
  }) : super(key: key);

  final Widget icon;
  final Color color;
  final double heightFactor;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: FractionallySizedBox(
          heightFactor: heightFactor,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Container(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD4D4D4), width: 1),
              ),
              child: icon,
            ),
          ),
        ),
      ),
    );
  }
}
