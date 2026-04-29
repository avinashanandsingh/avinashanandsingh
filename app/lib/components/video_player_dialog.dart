import 'dart:ui';
import 'package:app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../main.dart';

void show(BuildContext context, {required String url}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return VideoPlayerDialog(url: url);
    },
  );
}

class VideoPlayerDialog extends StatefulWidget {
  final String url;

  const VideoPlayerDialog({super.key, required this.url});

  @override
  State<VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog>
    with SingleTickerProviderStateMixin {
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  late AnimationController _animController;
  bool _isYoutube = false;
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final videoId = YoutubePlayer.convertUrlToId(widget.url);
    if (videoId != null) {
      setState(() {
        _isYoutube = true;
      });
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: true,
        ),
      );
      setState(() {
        _isInitialized = true;
      });
    } else {
      setState(() {
        _isYoutube = false;
      });
      try {
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(widget.url),
        );
        await _videoPlayerController!.initialize();

        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: true,
          looping: false,
          aspectRatio: _videoPlayerController!.value.aspectRatio,
          materialProgressColors: ChewieProgressColors(
            playedColor: Theme.of(context).colorScheme.primary,
            handleColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Colors.grey.withAlpha(50),
            bufferedColor: Colors.white.withAlpha(50),
          ),
          placeholder: Container(
            color: Colors.black,
            child: const Center(child: CircularProgressIndicator()),
          ),
        );

        setState(() {
          _isInitialized = true;
        });
      } catch (e) {
        setState(() {
          _error = "Could not load video: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isDark = themeProvider.themeMode == ThemeMode.dark;

        final bgColor = isDark
            ? AppColors.cardBackgroundDark.withAlpha(240)
            : Colors.white.withAlpha(240);
        final borderColor = isDark
            ? Colors.white.withAlpha(30)
            : Colors.white.withAlpha(150);

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Subtle Animated Background
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _animController,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDark
                                    ? [
                                        AppColors.primaryDark.withAlpha(80),
                                        AppColors.gradientBottom.withAlpha(120),
                                        AppColors.primaryDark.withAlpha(80),
                                      ]
                                    : [
                                        Colors.white.withAlpha(30),
                                        AppColors.primaryLight.withAlpha(20),
                                        Colors.white.withAlpha(30),
                                      ],
                                stops: [
                                  0.0,
                                  0.4 + (_animController.value * 0.2),
                                  1.0,
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Main Content
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Header with close button
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Video Player",
                                style: GoogleFonts.cinzel(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.close,
                                  color: colorScheme.onSurface.withAlpha(150),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Video Player Area - fills remaining space
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                color: Colors.black,
                                child: Center(
                                  child: _buildPlayerContent(colorScheme),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerContent(ColorScheme colorScheme) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _error!,
            style: GoogleFonts.lato(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isYoutube && _youtubeController != null) {
      return YoutubePlayer(
        controller: _youtubeController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: colorScheme.primary,
      );
    } else if (_chewieController != null) {
      return Chewie(controller: _chewieController!);
    }

    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    _animController.dispose();
    _youtubeController?.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}
