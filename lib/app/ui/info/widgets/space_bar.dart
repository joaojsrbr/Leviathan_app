import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/context_extensions.dart';
import 'package:leviathan_app/app/ui/info/widgets/scope.dart';

class SpaceBar extends StatelessWidget {
  const SpaceBar({super.key});

  @override
  Widget build(BuildContext context) {
    final book = BookInfoScope.of(context).book;
    final textTheme = context.textTheme;
    final imageURL = book.getIMG;
    final title = book.title;
    final size = context.mediaQuerySize;
    final titleLarge = textTheme.titleLarge?.copyWith(color: Colors.white);

    return FlexibleSpaceBar(
      // titlePadding: EdgeInsetsDirectional.only(start: 21, top: size.height * .31),
      expandedTitleScale: 1.0,
      // title: Text(
      //   title,
      //   maxLines: 3,
      //   style: titleLarge,
      //   overflow: TextOverflow.ellipsis,
      // ),
      background: Stack(
        fit: StackFit.expand,
        children: [
          ShaderMask(
            blendMode: BlendMode.srcOver,
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Theme.of(context).colorScheme.background],
                stops: const [0.0, 1.0],
              ).createShader(bounds);
            },
            child: CachedNetworkImage(
              imageUrl: imageURL,
              imageBuilder: (context, imageProvider) => Image(
                image: ResizeImage.resizeIfNeeded(
                  1080,
                  1200,
                  imageProvider,
                ),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Positioned(
            top: size.height * .15,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.only(left: 12, right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                title,
                maxLines: 3,
                style: titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
