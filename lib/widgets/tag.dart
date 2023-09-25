import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class Tag extends StatelessWidget {
  final String text;
  const Tag({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.only(right: 8, left: 8, top: 1, bottom: 1),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: HexColor((text == "Synced") ? "#B5EBCE" : "#FE8A5E"),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          textStyle: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
