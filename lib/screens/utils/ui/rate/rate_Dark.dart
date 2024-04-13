import 'package:flutter/material.dart';
import 'package:magic_cook1/l10n/app_localizations.dart';
class rateDark extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<rateDark> {
  TextEditingController _textEditingController = TextEditingController();
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(_updateCharacterCount);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _updateCharacterCount() {
    setState(() {
      _characterCount = _textEditingController.text.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 80,width: 280,
          child: TextField(
            controller: _textEditingController,
            style: TextStyle(color: Colors.black,fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
              filled: true,
              fillColor: Colors.grey,
              hintText: AppLocalizations.of(context)!.hint_rec,
            ),
            maxLines: 2,
            maxLength: 50, // Limit characters to 50
          ),
        ),
        Text(
          'Characters left: ${50 - _characterCount}',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

}
