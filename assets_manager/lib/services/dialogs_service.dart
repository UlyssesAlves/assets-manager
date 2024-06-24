import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class DialogsService {
  DialogsService(this.context);

  final BuildContext context;

  Future<T> awaitProcessToExecute<T>(
      Future<T> Function() processToWaitFor, String loadingPopupTitle) async {
    try {
      showLoadingAnimation(loadingPopupTitle);

      var result = await processToWaitFor();

      closePopup();

      return result;
    } catch (e) {
      closePopup();

      throw Exception('Error trying to await process to execute. $e');
    }
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
            const Text('Por favor aguarde.'),
          ],
        ),
      ),
      onWillPopActive: true,
    ).show();
  }

  void closePopup() {
    Navigator.pop(context);
  }

  Future<void> showNoConnectionAvailablePopup() async {
    await Alert(
        context: context,
        type: AlertType.none,
        title: 'Dispositivo Offline',
        desc:
            'Uma conexão ativa com a internet é necessária para realizar essa operação. Por favor, verifique o status de conexão de seu dispositivo e tente novamente.',
        buttons: [
          DialogButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
              onPressed: () => Navigator.pop(context))
        ],
        style: const AlertStyle(
          isCloseButton: false,
          isOverlayTapDismiss: true,
        )).show();
  }
}
