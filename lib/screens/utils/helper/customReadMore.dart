import 'package:flutter/material.dart';
import 'package:magic_cook1/l10n/app_localizations.dart';

class CustomReadMoreText extends StatefulWidget {
  final String text;
  final int trimLines;
  final TextStyle? style;
  final TextStyle? lessStyle;
  final TextStyle? moreStyle;

  const CustomReadMoreText(
      this.text, {
        Key? key,
        this.trimLines = 1,
        this.style,
        this.lessStyle,
        this.moreStyle,
      }) : super(key: key);

  @override
  _CustomReadMoreTextState createState() => _CustomReadMoreTextState();
}

class _CustomReadMoreTextState extends State<CustomReadMoreText> {
  bool _expanded = false;
  bool _hasOverflow = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = widget.style ?? theme.textTheme.bodyText2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final textSpan = TextSpan(text: widget.text, style: textStyle);
        final textPainter = TextPainter(
          text: textSpan,
          maxLines: widget.trimLines,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: constraints.maxWidth);

        _hasOverflow = textPainter.didExceedMaxLines;

        return SizedBox(
          width: constraints.maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedCrossFade(
                duration: Duration(milliseconds: 300),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: Text(
                  widget.text,
                  style: textStyle,
                  maxLines: widget.trimLines,
                  overflow: TextOverflow.ellipsis,
                ),
                secondChild: Text(
                  widget.text,
                  style: textStyle,
                ),
              ),
              if (_hasOverflow)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _expanded = !_expanded;
                        });
                      },
                      child: Text(
                        _expanded ?
                        AppLocalizations.of(context)!.read_less :
                        AppLocalizations.of(context)!.read_more,
                        style: _expanded
                            ? widget.lessStyle ?? TextStyle(color: theme.primaryColor)
                            : widget.moreStyle ?? TextStyle(color: theme.primaryColor),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
