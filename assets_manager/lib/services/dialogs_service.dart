import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class DialogsService {
  DialogsService(this.context);

  final BuildContext context;

  Future<T> awaitProcessToExecute<T>(
      Future<T> Function() processToWaitFor, String loadingPopupTitle) async {
    showLoadingAnimation(loadingPopupTitle);

    var result = await processToWaitFor();

    closePopup();

    return result;
  }

  void showLoadingAnimation(String title) {
    Alert(
      context: context,
      title: title,
      style: const AlertStyle(
        isCloseButton: false,
        isOverlayTapDismiss: false,
        isButtonVisible: false,
      ),
      content: Center(
        child: Column(
          children: [
            LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.blueGrey,
              size: 70,
            ),
            const Text('Please wait.'),
          ],
        ),
      ),
      onWillPopActive: true,
    ).show();
  }

  void closePopup() {
    Navigator.pop(context);
  }
}
