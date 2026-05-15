import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'
    hide PlayerState, ProgressBar;
import '../theme/theme.dart';
import '../main.dart';

enum BackgroundMode { animation, video }

void show(
  BuildContext context, {
  required String url,
  String title = "Fundamentals of UX Design",
  String author = "Avinash Anand Singh",
  String? backgroundUrl,
  BackgroundMode mode = BackgroundMode.video,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AudioPlayerDialog(
        url: url,
        title: title,
        author: author,
        backgroundUrl: backgroundUrl,
        mode: mode,
      );
    },
  );
}

class AudioPlayerDialog extends StatefulWidget {
  final String url;
  final String title;
  final String author;
  final String? backgroundUrl;
  final BackgroundMode mode;

  const AudioPlayerDialog({
    super.key,
    required this.url,
    required this.title,
    required this.author,
    this.backgroundUrl,
    this.mode = BackgroundMode.video,
  });

  @override
  State<AudioPlayerDialog> createState() => _AudioPlayerDialogState();
}

class _AudioPlayerDialogState extends State<AudioPlayerDialog>
    with TickerProviderStateMixin {
  late AudioPlayer _player;
  late AnimationController _diskController;
  late AnimationController _pulseController;
  late AnimationController _bgAnimController;
  VideoPlayerController? _bgVideoController;
  YoutubePlayerController? _bgYoutubeController;

  bool _isInitialized = false;
  bool _isBgYoutube = false;
  bool disposed = false;
  late BackgroundMode _currentMode;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _currentMode = widget.mode;

    _diskController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.95,
      upperBound: 1.05,
    );

    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _init();
    _initBackgroundVideo();
  }

  Future<void> _initBackgroundVideo() async {
    if (widget.backgroundUrl != null) {
      final bgYoutubeId = YoutubePlayer.convertUrlToId(widget.backgroundUrl!);
      print(bgYoutubeId);
      if (bgYoutubeId != null) {
        setState(() {
          _isBgYoutube = true;
        });
        _bgYoutubeController = YoutubePlayerController(
          initialVideoId: bgYoutubeId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: true,
            loop: true,
            isLive: false,
            forceHD: true,
            enableCaption: false,
            disableDragSeek: true,
            hideControls: true,
          ),
        );
      } else {
        setState(() {
          _isBgYoutube = false;
        });
        _bgVideoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.backgroundUrl!),
        );
        try {
          await _bgVideoController!.initialize();
          _bgVideoController!.setVolume(0);
          _bgVideoController!.setLooping(true);
          _bgVideoController!.play();
          setState(() {});
        } catch (e) {
          print("Error initializing background video: $e");
        }
      }
    }
  }

  Future<void> _init() async {
    try {
      await _player.setUrl(widget.url);
      _player.playerStateStream.listen((state) {
        if (state.playing) {
          _diskController.repeat();
          _pulseController.repeat(reverse: true);
        } else {
          if (!disposed) {
            _diskController.stop();
            _pulseController.stop();
            _pulseController.animateTo(
              1.0,
              duration: const Duration(milliseconds: 300),
            );
          }
        }
      });
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _error = "Error loading audio: $e";
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _diskController.dispose();
    _pulseController.dispose();
    _bgAnimController.dispose();
    _bgVideoController?.dispose();
    _bgYoutubeController?.dispose();
    disposed = true;
    super.dispose();
  }

  Widget _buildBackground(bool isDark) {
    switch (_currentMode) {
      case BackgroundMode.animation:
        return _buildAnimationBackground(isDark);
      case BackgroundMode.video:
        if (widget.backgroundUrl != null) {
          return _buildVideoBackground();
        }
        // Fallback if video URL is missing
        return _buildAnimationBackground(isDark);
    }
  }

  Widget _buildAnimationBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _bgAnimController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: isDark
                  ? [
                      AppColors.primaryDark.withAlpha(60),
                      AppColors.gradientBottom.withAlpha(100),
                      AppColors.primaryDark.withAlpha(60),
                    ]
                  : [
                      Colors.white.withAlpha(20),
                      AppColors.primaryLight.withAlpha(15),
                      Colors.white.withAlpha(20),
                    ],
              stops: [0.0, 0.3 + (_bgAnimController.value * 0.4), 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoBackground() {
    if (_isBgYoutube && _bgYoutubeController != null) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: 1280,
          height: 720,
          child: YoutubePlayer(
            controller: _bgYoutubeController!,
            showVideoProgressIndicator: false,
          ),
        ),
      );
    }

    if (_bgVideoController != null && _bgVideoController!.value.isInitialized) {
      return Opacity(
        opacity: 0.3,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _bgVideoController!.value.size.width,
            height: _bgVideoController!.value.size.height,
            child: VideoPlayer(_bgVideoController!),
          ),
        ),
      );
    }

    // Default fallback
    return Container(color: Colors.black12);
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
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 40,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background Layer (Video or Animation)
                    Positioned.fill(child: _buildBackground(isDark)),
                    // Main Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Now Playing",
                                style: TextTheme.of(context).headlineSmall,
                              ),
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.primaryLight,
                                    radius: 25,
                                    child: IconButton(
                                      onPressed: () => Navigator.pop(context),
                                      icon: Icon(
                                        Icons.close,
                                        color: colorScheme.onSurface.withAlpha(
                                          150,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          if (_error != null)
                            Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                            )
                          else if (!_isInitialized)
                            const CircularProgressIndicator()
                          else ...[
                            // Disk Animation
                            /* Center(
                              child: ScaleTransition(
                                scale: _pulseController,
                                child: AnimatedBuilder(
                                  animation: _diskController,
                                  builder: (_, child) {
                                    return Transform.rotate(
                                      angle:
                                          _diskController.value * 2 * math.pi,
                                      child: child,
                                    );
                                  },
                                  child: _buildDisk(colorScheme),
                                ),
                              ),
                            ), */
                            const SizedBox(height: 32),

                            // Song Info
                            Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cinzel(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.author,
                              style: TextTheme.of(context).bodyMedium,
                            ),
                            const SizedBox(height: 32),

                            // Progress Bar
                            StreamBuilder<Duration?>(
                              stream: _player.positionStream,
                              builder: (context, snapshot) {
                                final position = snapshot.data ?? Duration.zero;
                                final total = _player.duration ?? Duration.zero;
                                return ProgressBar(
                                  progress: position,
                                  total: total,
                                  buffered: _player.bufferedPosition,
                                  onSeek: (duration) {
                                    _player.seek(duration);
                                  },
                                  progressBarColor: AppColors.accentGold,
                                  baseBarColor: colorScheme.primary.withAlpha(
                                    30,
                                  ),
                                  bufferedBarColor: colorScheme.primary
                                      .withAlpha(50),
                                  thumbColor: AppColors.accentGold,
                                  timeLabelTextStyle: GoogleFonts.lato(
                                    color: colorScheme.onSurface.withAlpha(150),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),

                            // Controls
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.skip_previous_rounded,
                                    size: 36,
                                    color: colorScheme.onSurface,
                                  ),
                                  onPressed: () => _player.seek(Duration.zero),
                                ),
                                _buildPlayButton(colorScheme),
                                IconButton(
                                  icon: Icon(
                                    Icons.skip_next_rounded,
                                    size: 36,
                                    color: colorScheme.onSurface,
                                  ),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
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

  Widget _buildDisk(ColorScheme colorScheme) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha(50),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: SweepGradient(
                  colors: [
                    Color(0xFF1E1E1E),
                    Color(0xFF333333),
                    Color(0xFF1E1E1E),
                    Color(0xFF333333),
                    Color(0xFF1E1E1E),
                  ],
                ),
              ),
            ),
            // Texture rings
            for (double size in [180, 160, 140, 110])
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10, width: 1),
                ),
                width: size,
                height: size,
              ),
            // Album Art Center (Replaced with Brand/Music Icon)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.accentGold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: AppColors.accentGold.withAlpha(200),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            // Center hole
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton(ColorScheme colorScheme) {
    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final playing = playerState?.playing ?? false;
        final processingState = playerState?.processingState;

        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return const SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(strokeWidth: 3),
          );
        }

        return GestureDetector(
          onTap: () {
            if (playing) {
              _player.pause();
            } else {
              _player.play();
            }
          },
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentGold,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGold.withAlpha(100),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        );
      },
    );
  }
}
