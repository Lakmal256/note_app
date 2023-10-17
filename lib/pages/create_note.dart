import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../form.dart';
import '../note.dart';
import '../validator.dart';
import 'pages.dart';

class NoteFormValue extends FormValue {
  String? title;
  String? content;

  NoteFormValue({this.title, this.content});
}

class NoteFormController extends FormController<NoteFormValue> {
  NoteFormController() : super(initialValue: NoteFormValue(content: "", title: ""));

  @override
  Future<bool> validate() async {
    value.errors.clear();

    String? title = value.title;
    if (StringValidators.isEmpty(title)) {
      value.errors.addAll({"title": "Title can't be empty"});
    }

    String? content = value.content;
    if (StringValidators.isEmpty(content)) {
      value.errors.addAll({"content": "Content can't be empty"});
    }

    setValue(value);
    return value.errors.isEmpty;
  }
}

class NoteForm extends StatefulFormWidget<NoteFormValue> {
  const NoteForm({
    Key? key,
    required NoteFormController controller,
  }) : super(key: key, controller: controller);

  @override
  State<NoteForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<NoteForm> with FormMixin {
  TextEditingController titleTextEditingController = TextEditingController();
  TextEditingController contentTextEditingController = TextEditingController();
  ThemeData? selectedTheme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Access the ThemeProvider here
    final themeProvider = Provider.of<ThemeProvider>(context);
    selectedTheme = themeProvider.selectedTheme;
  }

  final lightTheme = ThemeData(
    brightness: Brightness.light,
  );

  final darkTheme = ThemeData(
    brightness: Brightness.dark,
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, formValue, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Title",
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: selectedTheme == lightTheme ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),
            Container(
              height: 70,
              decoration: BoxDecoration(
                color: selectedTheme == lightTheme ? const Color(0xFFFFFFFF) : const Color(0xFFFFFFFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD4D4D4), width: 1),
                shape: BoxShape.rectangle,
              ),
              child: Center(
                child: TextField(
                  controller: titleTextEditingController,
                  cursorColor: selectedTheme == lightTheme ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                  autocorrect: false,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                      fontSize: 20,
                      color: selectedTheme == lightTheme ? const Color(0xFF000000) : const Color(0xFFFFFFFF)),
                  onChanged: (value) {
                    widget.controller.setValue(
                      widget.controller.value..title = value,
                    );
                  },
                ),
              ),
            ),
            Text(
              widget.controller.value.getError("title") ?? "",
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            Text(
              "Content",
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: selectedTheme == lightTheme ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                color: selectedTheme == lightTheme ? const Color(0xFFFFFFFF) : const Color(0xFFFFFFFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 1,
                  color: const Color(0xFFD4D4D4),
                ),
              ),
              child: TextField(
                controller: contentTextEditingController,
                autocorrect: false,
                cursorColor: selectedTheme == lightTheme ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                maxLines: 15,
                textAlign: TextAlign.left,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                ),
                onChanged: (value) {
                  widget.controller.setValue(
                    widget.controller.value..content = value,
                  );
                },
                style: TextStyle(
                    fontSize: 18,
                    color: selectedTheme == lightTheme ? const Color(0xFF000000) : const Color(0xFFFFFFFF)),
              ),
            ),
            Text(
              widget.controller.value.getError("content") ?? "",
              style: const TextStyle(color: Colors.red),
            ),
          ],
        );
      },
    );
  }
}

class CreateNoteView extends StatefulWidget {
  const CreateNoteView({
    Key? key,
  }) : super(key: key);

  @override
  State<CreateNoteView> createState() => _CreateNoteViewState();
}

class _CreateNoteViewState extends State<CreateNoteView> {
  final NoteFormController controller = NoteFormController();

  List<Note> notes = [];
  ThemeData? selectedTheme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Access the ThemeProvider here
    final themeProvider = Provider.of<ThemeProvider>(context);
    selectedTheme = themeProvider.selectedTheme;
  }

  final lightTheme = ThemeData(
    brightness: Brightness.light,
  );

  final darkTheme = ThemeData(
    brightness: Brightness.dark,
  );

  @override
  void initState() {
    super.initState();
    loadNotesFromLocal(); // Load notes from local storage
  }

  void loadNotesFromLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList('notes');

    if (notesJson != null) {
      notes = notesJson.map((noteJson) => Note.fromJson(json.decode(noteJson))).toList();
    }
  }

  void saveNotesToLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final notesJson = notes.map((note) => json.encode(note.toJson())).toList();
    prefs.setStringList('notes', notesJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 38.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    padding: const EdgeInsets.all(0),
                    icon: Icon(
                      Icons.arrow_back,
                      color: selectedTheme == lightTheme ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Create Note",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: selectedTheme == lightTheme ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: NoteForm(controller: controller),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: FilledButton(
                  onPressed: () async {
                    if (await controller.validate()) {
                      final newNote = Note(
                        id: notes.length, // Assign a unique ID
                        title: controller.value.title ?? "",
                        content: controller.value.content ?? "",
                      );
                      setState(() {
                        notes.add(newNote);
                        saveNotesToLocal();
                      });
                      Navigator.pop(context, [controller.value.title, controller.value.content]);
                    }
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.standard,
                    minimumSize: MaterialStateProperty.all(const Size.fromHeight(60)),
                    backgroundColor: MaterialStateProperty.all(const Color(0xFF5FFFD8)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                  child: Text(
                    "Create",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: const Color(0xFF1E1E1E), fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
