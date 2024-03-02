import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../services/global.dart';
import '../services/locator.dart';
import '../services/set_or_change_pin.dart';
import 'custom_button.dart';

class PinValidation {
  static Future<bool?> showPinDialog(BuildContext context) async {
    TextEditingController pinController = TextEditingController();
    PinService _pinService = PinService();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PinCodeTextField(
              autoDisposeControllers: false,
              appContext: context,
              length: 6,
              obscureText: true,
              obscuringCharacter: '*',
              blinkWhenObscuring: true,
              animationType: AnimationType.fade,
              keyboardType: TextInputType.number,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.underline,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 40,
                fieldWidth: 30,
                inactiveColor: Colors.black45,
                inactiveFillColor: Colors.white,
                selectedFillColor: Colors.white,
                selectedColor: Colors.black45,
                disabledColor: Colors.black,
                activeFillColor: Colors.white,
              ),
              cursorColor: Colors.black,
              controller: pinController,
              animationDuration: const Duration(milliseconds: 300),
              enableActiveFill: true,
              onChanged: (String value) {},
            ),
            SizedBox(height: 20), // Add space between PinCodeTextField and cross button
          ],
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Enter your pin'),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(ctx).pop(); // Close the dialog when the button is pressed
              },
            ),
          ],
        ),
        actions: [
          CustomButton(
            title: 'Verify',
            onTap: () async {
              bool status = await _pinService.verifyPin(int.parse(pinController.text.toString()));
              if (status) {
                Navigator.of(ctx).pop(true);
                pinController.clear();
              } else {
                Navigator.of(ctx).pop(false);
                pinController.clear();
                locator<GlobalServices>().errorSnackBar("Incorrect pin");
              }
            },
          ),
        ],
      ),
    );
  }
}

