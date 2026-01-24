import 'dart:io';
import 'package:factor/src/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:factor/utils/enums.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImageView extends StatelessWidget {
  ///Creates a widget displaying an image of four types namely
  ///SVG, Network, Asset, File.
  final String? url;
  final String? placeholder;
  final Color? color;
  final String? semanticsLabel;
  final double? height;
  final double? width;
  final ImageType type;
  final double? scale;
  final BoxFit? fit;
  final File? imageFile;
  final Widget? errorWidget;
  final Alignment alignment;

  const ImageView.svg(
    this.url, {
    this.color,
    this.semanticsLabel,
    this.height,
    this.scale,
    this.fit,
    this.width,
    this.alignment = Alignment.center,
    super.key,
  }) : type = ImageType.svg,
       placeholder = null,
       errorWidget = null,
       imageFile = null;

  const ImageView.network(
    this.url, {
    this.color,
    this.semanticsLabel,
    this.height,
    this.scale,
    this.fit,
    this.width,
    this.errorWidget,
    this.placeholder,
    this.alignment = Alignment.center,
    super.key,
  }) : type = ImageType.network,
       imageFile = null;

  const ImageView.asset(
    this.url, {
    this.color,
    this.semanticsLabel,
    this.height,
    this.scale,
    this.fit,
    this.width,
    this.alignment = Alignment.center,
    super.key,
  }) : type = ImageType.asset,
       placeholder = null,
       errorWidget = null,
       imageFile = null;

  const ImageView.file(
    this.imageFile, {
    this.color,
    this.semanticsLabel,
    this.height,
    this.scale = 1,
    this.fit,
    this.width,
    this.alignment = Alignment.center,
    super.key,
  }) : type = ImageType.file,
       placeholder = null,
       errorWidget = null,
       url = null;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case ImageType.svg:
        return SvgPicture.asset(
          url!,
          semanticsLabel: semanticsLabel,
          height: height,
          width: width,
          alignment: alignment,
          fit: fit ?? BoxFit.contain,
          colorFilter: color != null
              ? ColorFilter.mode(color!, BlendMode.srcIn)
              : null,
        );
      case ImageType.network:
        return FadeInImage.assetNetwork(
          placeholderScale: scale,
          fit: fit,
          height: height,
          width: width,
          alignment: alignment,
          fadeInDuration: const Duration(seconds: 1),
          fadeInCurve: Curves.easeInCirc,
          placeholder: placeholder!,
          // ?? AppAsset.profileIcon,
          image: url ?? "",
          imageErrorBuilder: (context, error, stackTrace) =>
              errorWidget ??
              Icon(FactorIcons.error, color: Colors.red, size: 30.r),
          // Image.asset(AppAsset.profileIcon, width: width),
        );
      case ImageType.asset:
        return Image.asset(
          url!,
          height: height,
          width: width,
          color: color,
          fit: fit,
          scale: scale,
          alignment: alignment,
          semanticLabel: semanticsLabel,
        );
      case ImageType.file:
        return Image.file(
          imageFile!,
          height: height,
          width: width,
          color: color,
          fit: fit,
          scale: scale!,
          alignment: alignment,
          semanticLabel: semanticsLabel,
        );
    }
  }
}
