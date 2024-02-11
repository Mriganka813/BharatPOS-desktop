import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//Callback function signature
typedef BarcodeScannedCallback = void Function(String barcode);

class BarcodeKeyboardListener extends StatefulWidget {
  final Widget child;
  final BarcodeScannedCallback _onBarcodeScanned;
  final Duration _bufferDuration;
  final bool useKeyDownEvent;
  final bool caseSensitive;

  BarcodeKeyboardListener({
    Key? key,
    required this.child,
    required Function(String) onBarcodeScanned,
    this.useKeyDownEvent = true,
    Duration bufferDuration = hundredMs,
    this.caseSensitive = false,

  })  : _onBarcodeScanned = onBarcodeScanned,
        _bufferDuration = bufferDuration,
        super(key: key);

  @override
  _BarcodeKeyboardListenerState createState() => _BarcodeKeyboardListenerState(
      _onBarcodeScanned, _bufferDuration, useKeyDownEvent, caseSensitive);
}

//One Second constant
const Duration aSecond = Duration(seconds: 1);
//100 miliseconds constant
const Duration hundredMs = Duration(milliseconds: 100);
//lineFeed character constant
const String lineFeed = '\n';

class _BarcodeKeyboardListenerState extends State<BarcodeKeyboardListener> {
  List<String> _scannedChars = [];
  DateTime? _lastScannedCharCodeTime;
  late StreamSubscription<String?> _keyboardSubscription;

  final BarcodeScannedCallback _onBarcodeScannedCallback;
  final Duration _bufferDuration;

  final _controller = StreamController<String?>();

  final bool _useKeyDownEvent;

  final bool _caseSensitive;

  bool _isShiftPressed = false;

  _BarcodeKeyboardListenerState(this._onBarcodeScannedCallback,this._bufferDuration, this._useKeyDownEvent, this._caseSensitive) {
    try{
      RawKeyboard.instance.addListener(_keyBoardCallback);
      _keyboardSubscription =
          _controller.stream.where((char) => char != null).listen(onKeyEvent);
    }catch(e){

    }
  }

  void onKeyEvent(String? char) {
    try{
      //remove any pending characters older than bufferDuration value
      checkPendingCharCodesToClear();
      _lastScannedCharCodeTime = DateTime.now();
      if (char == lineFeed) {
        _onBarcodeScannedCallback.call(_scannedChars.join());
        resetScannedCharCodes();
      } else {
        //add character to list of scanned characters;
        _scannedChars.add(char!);
      }
    }catch(e){

    }
  }

  void checkPendingCharCodesToClear() {
   try{
     if (_lastScannedCharCodeTime != null) {
       if (_lastScannedCharCodeTime!
           .isBefore(DateTime.now().subtract(_bufferDuration))) {
         resetScannedCharCodes();
       }
     }
   }catch(e){

   }
  }

  void resetScannedCharCodes() {
    _lastScannedCharCodeTime = null;
    _scannedChars = [];
  }

  void addScannedCharCode(String charCode) {
    _scannedChars.add(charCode);
  }

  void _keyBoardCallback(RawKeyEvent keyEvent) {
    try{
      if (keyEvent.logicalKey.keyId > 255 &&
          keyEvent.data.logicalKey != LogicalKeyboardKey.enter &&
          keyEvent.data.logicalKey != LogicalKeyboardKey.shiftLeft) return;
      if ((!_useKeyDownEvent && keyEvent is RawKeyUpEvent) ||
          (_useKeyDownEvent && keyEvent is RawKeyDownEvent)) {
        if (keyEvent.data is RawKeyEventDataAndroid) {
          if (keyEvent.data.logicalKey == LogicalKeyboardKey.shiftLeft) {
            _isShiftPressed = true;
          } else {
            if (_isShiftPressed && _caseSensitive) {
              _isShiftPressed = false;
              _controller.sink.add(String.fromCharCode(
                  ((keyEvent.data) as RawKeyEventDataAndroid).codePoint)
                  .toUpperCase());
            } else {
              _controller.sink.add(String.fromCharCode(
                  ((keyEvent.data) as RawKeyEventDataAndroid).codePoint));
            }
          }
        } else if (keyEvent.data is RawKeyEventDataFuchsia) {
          _controller.sink.add(String.fromCharCode(
              ((keyEvent.data) as RawKeyEventDataFuchsia).codePoint));
        } else if (keyEvent.data.logicalKey == LogicalKeyboardKey.enter) {
          _controller.sink.add(lineFeed);
        } else if (keyEvent.data is RawKeyEventDataWeb) {
          _controller.sink.add(((keyEvent.data) as RawKeyEventDataWeb).keyLabel);
        } else if (keyEvent.data is RawKeyEventDataLinux) {
          _controller.sink
              .add(((keyEvent.data) as RawKeyEventDataLinux).keyLabel);
        } else if (keyEvent.data is RawKeyEventDataWindows) {
          try{
            _controller.sink.add(String.fromCharCode(
                ((keyEvent.data) as RawKeyEventDataWindows).keyCode));
          }catch(e){

          }

        } else if (keyEvent.data is RawKeyEventDataMacOs) {
          _controller.sink
              .add(((keyEvent.data) as RawKeyEventDataMacOs).characters);
        } else if (keyEvent.data is RawKeyEventDataIos) {
          _controller.sink
              .add(((keyEvent.data) as RawKeyEventDataIos).characters);
        } else {
          _controller.sink.add(keyEvent.character);
        }
      }
    }catch(e){

    }

  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    try{
      _keyboardSubscription.cancel();
      _controller.close();
      RawKeyboard.instance.removeListener(_keyBoardCallback);
      super.dispose();
    }catch(e){

    }
  }
}
