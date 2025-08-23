import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int trimLength;
  final TextStyle? style;

  const ExpandableText({
    super.key,
    required this.text,
    this.trimLength = 100,
    this.style,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  late String firstHalf;
  late String secondHalf;

  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.text.length > widget.trimLength) {
      firstHalf = widget.text.substring(0, widget.trimLength);
      secondHalf = widget.text.substring(widget.trimLength, widget.text.length);
    } else {
      firstHalf = widget.text;
      secondHalf = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return secondHalf.isEmpty
        ? Text(widget.text, style: widget.style)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isExpanded ? (firstHalf + secondHalf) : ("$firstHalf..."),
                style: widget.style,
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    isExpanded ? "Read less" : "Read more",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          );
  }
}
