import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player/video_player.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/common/providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

enum VideoType {
  youtube,
  vimeo,
  direct,
}

class VideoPlayerWidget extends ConsumerStatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
  }) : super(key: key);

  @override
  ConsumerState<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends ConsumerState<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isPlaying = false;
  VideoType? _videoType;
  String? _viewId;

  @override
  void initState() {
    super.initState();
    _determineVideoType();
    
    if (kIsWeb) {
      _registerWebView();
      _isLoading = false;
      _isInitialized = true;
    } else if (_videoType == VideoType.direct) {
      _initializeDirectVideo();
    }
  }
  
  void _registerWebView() {
    _viewId = 'video-${widget.videoUrl.hashCode}-${DateTime.now().millisecondsSinceEpoch}';
    
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId!,
      (int viewId) {
        if (_videoType == VideoType.youtube) {
          final embedUrl = _getYouTubeEmbedUrl(widget.videoUrl);
          final iframe = html.IFrameElement()
            ..src = embedUrl
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.border = 'none'
            ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
            ..allowFullscreen = true;
          return iframe;
        } else if (_videoType == VideoType.vimeo) {
          final embedUrl = _getVimeoEmbedUrl(widget.videoUrl);
          final iframe = html.IFrameElement()
            ..src = embedUrl
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.border = 'none'
            ..allow = 'autoplay; fullscreen; picture-in-picture'
            ..allowFullscreen = true;
          return iframe;
        } else {
          final video = html.VideoElement()
            ..src = widget.videoUrl
            ..controls = true
            ..autoplay = false
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.objectFit = 'contain'
            ..style.backgroundColor = '#000';
          return video;
        }
      },
    );
  }

  void _determineVideoType() {
    final url = widget.videoUrl.toLowerCase();
    if (url.contains('youtube.com/watch?v=') || url.contains('youtu.be/')) {
      _videoType = VideoType.youtube;
    } else if (url.contains('vimeo.com/')) {
      _videoType = VideoType.vimeo;
    } else {
      _videoType = VideoType.direct;
    }
  }

  Future<void> _initializeDirectVideo() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
      
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _controller!.initialize();
      _controller!.addListener(() {
        if (_controller!.value.isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = _controller!.value.isPlaying;
          });
        }
        // Проверяем на ошибки воспроизведения
        if (_controller!.value.hasError) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Ошибка воспроизведения';
            _isLoading = false;
          });
        }
      });
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Video init error: $e');
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  String _getYouTubeEmbedUrl(String url) {
    String videoId = '';
    if (url.contains('youtube.com/watch?v=')) {
      videoId = url.split('v=')[1].split('&')[0];
    } else if (url.contains('youtu.be/')) {
      videoId = url.split('youtu.be/')[1].split('?')[0];
    }
    return 'https://www.youtube.com/embed/$videoId';
  }

  String _getVimeoEmbedUrl(String url) {
    String videoId = '';
    final parts = url.split('vimeo.com/');
    if (parts.length > 1) {
      videoId = parts[1].split('?')[0];
    }
    return 'https://player.vimeo.com/video/$videoId';
  }

  Future<void> _openVideoInBrowser() async {
    final uri = Uri.parse(widget.videoUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildYouTubeWidget(AppColors colors) {
    if (kIsWeb && _viewId != null) {
      return Container(
        height: 400,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: HtmlElementView(viewType: _viewId!),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.accentColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 48,
              color: colors.accentColor,
            ),
            const SizedBox(height: 12),
            Text(
              'YouTube видео',
              style: TextStyle(
                color: colors.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _openVideoInBrowser,
              child: Text(
                'Открыть видео',
                style: TextStyle(color: colors.accentColor),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildVimeoWidget(AppColors colors) {
    if (kIsWeb && _viewId != null) {
      return Container(
        height: 400,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: HtmlElementView(viewType: _viewId!),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.accentColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 48,
              color: colors.accentColor,
            ),
            const SizedBox(height: 12),
            Text(
              'Vimeo видео',
              style: TextStyle(
                color: colors.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _openVideoInBrowser,
              child: Text(
                'Открыть видео',
                style: TextStyle(color: colors.accentColor),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDirectVideoWidget(AppColors colors) {
    // На веб используем нативный HTML5 video через HtmlElementView
    if (kIsWeb && _viewId != null) {
      return Container(
        height: 400,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: HtmlElementView(viewType: _viewId!),
        ),
      );
    }
    
    // Для мобильных используем video_player
    // Если была ошибка - показываем fallback с кнопкой открыть в браузере
    if (_hasError) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.accentColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.videocam,
              size: 48,
              color: colors.accentColor,
            ),
            const SizedBox(height: 12),
            Text(
              'Видео',
              style: TextStyle(
                color: colors.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Не удалось загрузить плеер',
              style: TextStyle(
                color: colors.greyColor,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openVideoInBrowser,
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Открыть видео'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accentColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Если загрузка в процессе
    if (_isLoading || !_isInitialized || _controller == null) {
      return Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colors.accentColor),
              const SizedBox(height: 16),
              Text(
                'Загрузка видео...',
                style: TextStyle(color: colors.textColor),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _openVideoInBrowser,
                child: Text(
                  'Открыть в браузере',
                  style: TextStyle(color: colors.accentColor),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
            if (!_isPlaying)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.play_circle_filled,
                    size: 64,
                    color: colors.accentColor.withOpacity(0.9),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPlaying = true;
                    });
                    _controller!.play();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colors = AppColors(isDark);

    if (_videoType == VideoType.youtube) {
      return _buildYouTubeWidget(colors);
    } else if (_videoType == VideoType.vimeo) {
      return _buildVimeoWidget(colors);
    } else {
      return _buildDirectVideoWidget(colors);
    }
  }
}
