import 'package:flutter/material.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/context_extensions.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:settings_ui/settings_ui.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  // RelativeRect _buttonPosition(BuildContext context) {
  //   // final RenderBox bar = context.findRenderObject() as RenderBox;
  //   final RenderBox bar = context.findAncestorRenderObjectOfType() as RenderBox;
  //   final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  //   const Offset offset = Offset.zero;
  //   // final size = _container.currentContext?.size;
  //   final RelativeRect position = RelativeRect.fromRect(
  //     Rect.fromPoints(
  //       bar.localToGlobal(bar.size.bottomLeft(offset), ancestor: overlay),
  //       bar.localToGlobal(bar.size.bottomLeft(offset), ancestor: overlay),
  //     ),
  //     const Offset(4, 0) & Size(overlay.size.width, overlay.size.height),
  //   ).inflate(-6);

  //   return position;
  // }

  @override
  Widget build(BuildContext context) {
    final size = context.mediaQuerySize;
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: size.height * .2,
            flexibleSpace: const FlexibleSpaceBar(
              expandedTitleScale: 1.2,
              title: Text('Configurações'),
            ),
          ),
          SliverToBoxAdapter(
            child: SettingsList(
              darkTheme: SettingsThemeData(settingsListBackground: context.themeData.scaffoldBackgroundColor),
              lightTheme: SettingsThemeData(settingsListBackground: context.themeData.scaffoldBackgroundColor),
              shrinkWrap: true,
              sections: [
                SettingsSection(
                  // title: Text('Common'),
                  tiles: <SettingsTile>[
                    SettingsTile.navigation(
                      onPressed: (context) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: _palettePage),
                        );
                      },
                      leading: Icon(
                        MdiIcons.palette,
                        color: context.colorScheme.primary,
                      ),
                      title: Text(
                        'Aparência',
                        style: context.textTheme.titleMedium?.copyWith(color: context.colorScheme.primary),
                      ),
                    ),
                    // SettingsTile.navigation(
                    //   onPressed: (context) {},
                    //   leading: const Icon(MdiIcons.translate),
                    //   title: const Text('Linguagem'),
                    //   value: Text(Localizations.localeOf(context).toString()),
                    // ),
                  ],
                ),
              ],
            ),
          ),
          const SliverFillRemaining(),
        ],
      ),
    );
  }

  Widget _palettePage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
