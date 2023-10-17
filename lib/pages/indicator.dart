import 'package:flutter/material.dart';

class LoadingIndicatorController extends ValueNotifier<bool> {
  LoadingIndicatorController() : super(false);

  void show() {
    value = true;
    notifyListeners();
  }

  void hide() {
    value = false;
    notifyListeners();
  }
}

class LoadingIndicatorPopup extends StatelessWidget {
  const LoadingIndicatorPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}