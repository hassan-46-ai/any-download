import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_downloader/core/providers.dart';
import 'package:youtube_downloader/core/theme/app_theme.dart';
import 'package:youtube_downloader/core/utils/error_messages.dart';
import 'package:youtube_downloader/core/utils/url_utils.dart';
import 'package:youtube_downloader/features/download/widgets/media_panel.dart';

/// Paste a link from YouTube, Shorts, Facebook, Instagram, TikTok, X ...
class DownloadPage extends ConsumerStatefulWidget {
  const DownloadPage({super.key});

  @override
  ConsumerState<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends ConsumerState<DownloadPage> {
  static const _platforms = [
    'YouTube',
    'Shorts',
    'Facebook',
    'Instagram',
    'TikTok',
    'X (Twitter)',
  ];

  final _controller = TextEditingController();
  String? _url;
  bool _invalid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String raw) {
    final url = normalizeUrl(raw);
    setState(() {
      _url = url;
      _invalid = url == null && raw.trim().isNotEmpty;
    });
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || !mounted) return;
    _controller.text = text.trim();
    _submit(text);
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _url = null;
      _invalid = false;
    });
  }

  Future<void> _updateEngine() async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Updating the download engine…')),
    );
    try {
      final status = await ref.read(ytDlpServiceProvider).updateEngine();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            status == 'ALREADY_UP_TO_DATE'
                ? 'The engine is already up to date.'
                : 'Engine updated.',
          ),
        ),
      );
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(describeError(error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = _controller.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Download',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Update download engine',
            icon: const Icon(Icons.system_update_alt),
            onPressed: _updateEngine,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.gradient,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Paste a link',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Save videos and audio from your favorite sites.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final name in _platforms)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.go,
            onChanged: (_) => setState(() {}),
            onSubmitted: _submit,
            decoration: InputDecoration(
              hintText: 'https://…',
              prefixIcon: const Icon(Icons.link),
              errorText: _invalid ? 'This is not a valid link' : null,
              suffixIcon: hasText
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Clear',
                          icon: const Icon(Icons.clear),
                          onPressed: _clear,
                        ),
                        IconButton(
                          tooltip: 'Fetch',
                          icon: Icon(
                            Icons.arrow_forward_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: () => _submit(_controller.text),
                        ),
                      ],
                    )
                  : IconButton(
                      tooltip: 'Paste',
                      icon: const Icon(Icons.content_paste),
                      onPressed: _paste,
                    ),
            ),
          ),
          const SizedBox(height: 24),
          if (_url != null) MediaPanel(url: _url!),
        ],
      ),
    );
  }
}
