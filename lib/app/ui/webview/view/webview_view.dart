import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/context_extensions.dart';
import 'package:leviathan_app/app/core/utils/copy_to_clipboard.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> with SingleTickerProviderStateMixin {
  String _url = '';
  // final GlobalKey webViewKey = GlobalKey();

  String _title = '';
  double _progress = 0;

  // late WebViewArguments _webViewArguments;
  bool? _isSecure;
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _onInit());
    super.initState();
  }

  void _onInit() {
    setState(() {
      _url = ModalRoute.of(context)!.settings.arguments as String;
    });
  }

  void _goBack(bool canGoBack) {
    if (!canGoBack) return;
    _webViewController?.goBack();
  }

  void _goForward(bool canGoForward) {
    if (!canGoForward) return;
    _webViewController?.goForward();
  }

  static bool urlIsSecure(Uri url) {
    return (url.scheme == "https") || isLocalizedContent(url);
  }

  static bool isLocalizedContent(Uri url) {
    return (url.scheme == "file" || url.scheme == "chrome" || url.scheme == "data" || url.scheme == "javascript" || url.scheme == "about");
  }

  void handleClick(int item) async {
    switch (item) {
      case 0:
        await InAppBrowser.openWithSystemBrowser(url: Uri.parse(_url));
        break;
      case 1:
        await _webViewController?.clearCache();
        if (defaultTargetPlatform == TargetPlatform.android) {
          await _webViewController?.clearCache();
        }
        if (mounted) setState(() {});
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: _AppBarWrapper(
        goBack: _goBack,
        url: _url,
        webViewController: _webViewController,
        isSecure: _isSecure,
        title: _title,
        goForward: _goForward,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUserScripts: UnmodifiableListView([
              UserScript(
                injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                source: """
         
                var lastScrollTop = 0;
    
                document.addEventListener(
                  'scroll',
                  (event) => {
                    window.flutter_inappwebview.callHandler('scrollListener', window.scrollY);
                    
                    
                    var st = window.pageYOffset || document.documentElement.scrollTop;
                    if (st > lastScrollTop) {
                       window.flutter_inappwebview.callHandler('scrollDirection', 'SCROLL_UP');
                    } else if (st < lastScrollTop) {
                       window.flutter_inappwebview.callHandler('scrollDirection', 'SCROLL_DOWN');
                    } 
                    lastScrollTop = st <= 0 ? 0 : st;
                    
                  },
                  { passive: true }
              );
              """,
              )
            ]),
            onConsoleMessage: (controller, consoleMessage) => log(consoleMessage.message),
            initialUrlRequest: URLRequest(url: Uri.parse(url)),
            onWebViewCreated: (controller) {
              _webViewController = controller;

              _webViewController?.addJavaScriptHandler(
                handlerName: 'scrollListener',
                callback: (arguments) {
                  final dy = (arguments.elementAt(0) as num).toDouble();
                  if (!mounted) return;

                  log(dy.toString());
                },
              );
              _webViewController?.addJavaScriptHandler(
                handlerName: 'scrollDirection',
                callback: (arguments) {
                  if (!mounted) return;
                  log(arguments.elementAt(0).toString());
                },
              );

              // _webViewController?.
              // final background = context.themeData.colorScheme.background;

              // _webViewController?.injectCSSCode(source: 'background-color: ${background.toString()}');
            },
            onLoadStart: (controller, url) {
              if (url != null) {
                setState(() {
                  _url = url.toString();
                  _isSecure = urlIsSecure(url);
                });
              }
            },
            onLoadStop: (controller, url) async {
              if (url != null) {
                setState(() {
                  _url = url.toString();
                });
              }

              final sslCertificate = await controller.getCertificate();
              setState(() {
                _isSecure = sslCertificate != null || (url != null && urlIsSecure(url));
              });
            },
            onUpdateVisitedHistory: (controller, url, isReload) {
              if (url != null) {
                setState(() {
                  _url = url.toString();
                });
              }
            },
            onTitleChanged: (controller, title) {
              if (title != null) {
                setState(() {
                  _title = title;
                });
              }
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                _progress = progress / 100;
              });
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url;
              if (navigationAction.isForMainFrame &&
                  url != null &&
                  !['http', 'https', 'file', 'chrome', 'data', 'javascript', 'about'].contains(url.scheme)) {
                if (await canLaunchUrl(url)) {
                  launchUrl(url);
                  return NavigationActionPolicy.CANCEL;
                }
              }
              return NavigationActionPolicy.ALLOW;
            },
          ),
          Visibility(
            visible: _progress < 1.0,
            child: LinearProgressIndicator(value: _progress),
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: context.mediaQuerySize.height * .08,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            InkWell(
              onLongPress: () => copyToClipboard(
                context,
                messageCopy: _url,
                messageSnackBar: 'url copiado para a área de transferência!!!',
              ),
              child: IconButton(icon: const Icon(MdiIcons.share), onPressed: () => Share.share(_url, subject: _title)),
            ),
            IconButton(
              icon: const Icon(MdiIcons.refresh),
              onPressed: () {
                _webViewController?.reload();
              },
            ),
            PopupMenuButton<int>(
              onSelected: (item) => handleClick(item),
              itemBuilder: (context) => [
                PopupMenuItem<int>(
                  enabled: false,
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          'Outras opções',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
                PopupMenuItem<int>(
                  value: 0,
                  child: Row(
                    children: [
                      const Icon(MdiIcons.openInApp),
                      const SizedBox(width: 5),
                      Text(
                        'Abrir no navegador',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<int>(
                  value: 1,
                  child: Row(
                    children: [
                      const Icon(MdiIcons.notificationClearAll),
                      const SizedBox(width: 5),
                      Text(
                        'Limpar dados de navegação',
                        style: Theme.of(context).textTheme.titleMedium,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBarWrapper extends StatelessWidget implements PreferredSizeWidget {
  const _AppBarWrapper({
    this.webViewController,
    this.isSecure,
    required this.url,
    required this.title,
    required this.goForward,
    required this.goBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  final InAppWebViewController? webViewController;
  final bool? isSecure;

  final String title;
  final void Function(bool data) goForward;
  final String url;
  final void Function(bool data) goBack;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FutureBuilder<bool>(
            future: webViewController?.canGoBack() ?? Future.value(false),
            initialData: false,
            builder: (context, snapshot) {
              final canGoBack = snapshot.hasData ? snapshot.data! : false;
              return IconButton(
                enableFeedback: true,
                icon: const Icon(MdiIcons.chevronLeft),
                onPressed: () => goBack.call(canGoBack),
              );
            },
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.fade,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: isSecure != null,
                      child: Icon(
                        isSecure == true ? Icons.lock : Icons.lock_open,
                        color: isSecure == true ? Colors.green : Colors.red,
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(url, style: const TextStyle(fontSize: 12, color: Colors.white70), overflow: TextOverflow.fade),
                    ),
                  ],
                )
              ],
            ),
          ),
          FutureBuilder<bool>(
            future: webViewController?.canGoForward() ?? Future.value(false),
            initialData: false,
            builder: (context, snapshot) {
              final canGoForward = snapshot.hasData ? snapshot.data! : false;
              return IconButton(
                icon: const Icon(MdiIcons.chevronRight),
                enableFeedback: true,
                onPressed: () => goForward.call(canGoForward),
              );
            },
          )
        ],
      ),
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(MdiIcons.close),
      ),
    );
  }
}
