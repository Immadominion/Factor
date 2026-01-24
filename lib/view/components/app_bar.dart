import 'package:factor/src/components.dart';
import 'package:factor/src/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FactorsAppBars {
  ///Creates an appbar for both `Select Currency and Coin screen`.
  static Widget selectAppBar(
    BuildContext context, {
    required String title,
    required VoidCallback onSearchOnTap,
  }) {
    return AppBar(
      backgroundColor: FactorColorsDark.kMidnight,
      leadingWidth: 200,
      leading: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                FactorIcons.arrowLeft,
                color: FactorColorsDark.kSoftWhite.withAlpha(200),
                size: 26.r,
              ),
            ),
            Gap(20),
            TextView(text: title, fontWeight: FontWeight.bold, fontSize: 18),
          ],
        ),
      ),
      actions: [
        GestureDetector(
          onTap: onSearchOnTap,
          child: Padding(
            padding: EdgeInsetsGeometry.only(right: 15),
            child: Icon(
              FactorIcons.search,
              color: FactorColorsDark.kSoftWhite.withAlpha(200),
              size: 28.r,
            ),
          ),
        ),
      ],
    );
  }

  ///Creates a widget displaying a an app bar with a textfield and cancel text
  ///widget.
  static Widget searchAppBar(
    BuildContext context, {
    required TextEditingController controller,
    required VoidCallback onCancelTap,
    required Function(String)? onTextFieldChange,
    required VoidCallback onCloseIconTap,
    required FocusNode focusNode,
  }) {
    return AppBar(
      backgroundColor: FactorColorsDark.kMidnight,
      leadingWidth: MediaQuery.sizeOf(context).width * 0.7,
      leading: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          autofocus: true,
          cursorColor: FactorColorsDark.kSunsetOrange,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: FactorStrings.hintSearch,
            hintStyle: TextStyle(
              fontFamily: FactorStrings.inter,
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: FactorColorsDark.kCarbonGray,
            ),
            suffix: Visibility(
              visible: controller.text.isNotEmpty,
              child: GestureDetector(
                onTap: onCloseIconTap,
                child: Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: FactorColorsDark.kCharcoal,
                  ),
                  child: Icon(
                    FactorIcons.close,
                    size: 15.r,
                    color: FactorColorsDark.kSoftWhite.withAlpha(200),
                  ),
                ),
              ),
            ),
          ),
          onChanged: onTextFieldChange,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: FactorStrings.inter,
            color: FactorColorsDark.kSoftWhite,
          ),
        ),
      ),
      actions: [
        SizedBox(
          height: 15,
          width: 10,
          child: VerticalDivider(color: FactorColorsDark.kCharcoal),
        ),
        Gap(30),
        TextView(
          text: FactorStrings.btnCancel,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          onTap: onCancelTap,
        ),
      ],
    );
  }
}
