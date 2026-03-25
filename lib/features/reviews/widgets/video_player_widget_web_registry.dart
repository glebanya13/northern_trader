import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

/// Web implementation: registers an HTML element factory for a given platform view.
void registerVideoViewFactory({
  required String viewId,
  required String kind,
  required String videoUrl,
  String? youtubeEmbedUrl,
  String? vimeoEmbedUrl,
}) {
  // ignore: undefined_prefixed_name
  ui_web.platformViewRegistry.registerViewFactory(
    viewId,
    (int _) {
      if (kind == 'youtube') {
        final iframe = html.IFrameElement()
          ..src = youtubeEmbedUrl ?? ''
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.border = 'none'
          ..allow =
              'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
          ..allowFullscreen = true;
        return iframe;
      }

      if (kind == 'vimeo') {
        final iframe = html.IFrameElement()
          ..src = vimeoEmbedUrl ?? ''
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.border = 'none'
          ..allow = 'autoplay; fullscreen; picture-in-picture'
          ..allowFullscreen = true;
        return iframe;
      }

      final video = html.VideoElement()
        ..src = videoUrl
        ..controls = true
        ..autoplay = false
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'contain'
        ..style.backgroundColor = '#000';
      return video;
    },
  );
}

