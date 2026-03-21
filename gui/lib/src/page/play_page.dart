import 'package:fluent_ui/fluent_ui.dart' hide FluentIcons;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get/get.dart';
import 'package:reboot_launcher/src/controller/dll_controller.dart';
import 'package:reboot_launcher/src/controller/game_controller.dart';
import 'package:reboot_launcher/src/pager/page_type.dart';
import 'package:reboot_launcher/src/util/translations.dart';
import 'package:reboot_launcher/src/tile/setting_tile.dart';
import 'package:reboot_launcher/src/message/data.dart';
import 'package:reboot_launcher/src/messenger/overlay.dart';
import 'package:reboot_launcher/src/pager/abstract_page.dart';
import 'package:reboot_launcher/src/button/game_start_button.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

final GlobalKey<OverlayTargetState> gameVersionOverlayTargetKey = GlobalKey();

class PlayPage extends AbstractPage {
  const PlayPage({Key? key}) : super(key: key);

  @override
  AbstractPageState<PlayPage> createState() => _PlayPageState();

  @override
  bool hasButton(String? pageName) => pageName == null;

  @override
  String get name => translations.playName;

  @override
  String get iconAsset => "assets/images/play.png";

  @override
  PageType get type => PageType.play;
}

class _PlayPageState extends AbstractPageState<PlayPage> {
  final GameController _gameController = Get.find<GameController>();
  final DllController _dllController = Get.find<DllController>();
  double downloadProgress = 0.0;

  @override
  Widget? get button => LaunchButton(
        startLabel: translations.launchFortnite,
        stopLabel: translations.closeFortnite,
        host: false,
      );

  @override
  List<SettingTile> get settings => [
        // Fake dropdown
        SettingTile(
          icon: Icon(FluentIcons.tag_24_regular),
          title: Text("Version"),
          subtitle: Text("Fortnite 14.60"),
          content: IgnorePointer(
            child: DropdownButton<String>(
              value: "14.60",
              items: [
                DropdownMenuItem(
                  value: "14.60",
                  child: Text("14.60"),
                ),
              ],
              onChanged: (_) {},
              isExpanded: true,
            ),
          ),
        ),

        // Download button + progress
        SettingTile(
          icon: Icon(FluentIcons.download_24_regular),
          title: Text("Download Fortnite 14.60"),
          subtitle: Text("Click to download and extract manually"),
          content: Column(
            children: [
              Button(
                child: Text("Download"),
                onPressed: () async {
                  await _downloadFortnite();
                },
              ),
              SizedBox(height: 8),
              LinearProgressBar(
                value: downloadProgress,
                min: 0,
                max: 1,
              ),
            ],
          ),
        ),

        _options,
        _resetDefaults
      ];

  SettingTile get _options => SettingTile(
        icon: Icon(FluentIcons.options_24_regular),
        title: Text(translations.settingsClientOptionsName),
        subtitle: Text(translations.settingsClientOptionsDescription),
        children: [
          SettingTile(
            icon: Icon(FluentIcons.options_24_regular),
            title: Text(translations.settingsClientArgsName),
            subtitle: Text(translations.settingsClientArgsDescription),
            content: TextFormBox(
              placeholder: translations.settingsClientArgsPlaceholder,
              controller: _gameController.customLaunchArgs,
            ),
          )
        ],
      );

  SettingTile get _resetDefaults => SettingTile(
        icon: Icon(FluentIcons.arrow_reset_24_regular),
        title: Text(translations.gameResetDefaultsName),
        subtitle: Text(translations.gameResetDefaultsDescription),
        content: Button(
          onPressed: () => showResetDialog(() {
            _gameController.reset();
            _dllController.resetGame();
          }),
          child: Text(translations.gameResetDefaultsContent),
        ),
      );

  // Download .rar file
  Future<void> _downloadFortnite() async {
    final url = "https://public.simplyblk.xyz/14.60.rar";
    final savePath = path.join("C:/ProjectRush/14.60", "14.60.rar");

    final dio = Dio();
    Directory(path.dirname(savePath)).createSync(recursive: true);

    try {
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              downloadProgress = received / total;
            });
          }
        },
      );
      // Show info for manual extraction
      showDialog(
        context: context,
        builder: (_) => ContentDialog(
          title: Text("Download complete"),
          content: Text(
              "14.60 downloaded to C:/ProjectRush/14.60/14.60.rar\nPlease extract manually before launching."),
          actions: [Button(child: Text("OK"), onPressed: () => Navigator.pop(context))],
        ),
      );
    } catch (e) {
      print("Download failed: $e");
    }
  }
}
