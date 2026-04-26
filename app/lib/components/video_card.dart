import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoCard extends StatefulWidget {
  final String url;
  final String? title;
  final String? subtitle;
  final double height;
  final double borderRadius;

  const VideoCard({
    super.key,
    required this.url,
    this.title,
    this.subtitle,
    this.height = 220,
    this.borderRadius = 24,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isYoutube = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _isYoutube = YoutubePlayer.convertUrlToId(widget.url) != null;
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final videoId = YoutubePlayer.convertUrlToId(widget.url);
    if (videoId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } else {
      try {
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(widget.url),
        );
        await _videoPlayerController!.initialize();

        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: false,
          looping: false,
          aspectRatio: _videoPlayerController!.value.aspectRatio,
          placeholder: Container(
            color: Colors.black,
            child: const Center(child: CircularProgressIndicator()),
          ),
        );

        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      } catch (e) {
        debugPrint("VideoCard Error: $e");
      }
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Stack(
          children: [
            _isInitialized
                ? _buildPlayer()
                : const Center(child: CircularProgressIndicator()),
            // Text Overlay (Only if not playing or using it as a caption)
            if (widget.title != null || widget.subtitle != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withAlpha(150),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.title != null)
                          Text(
                            widget.title!,
                            style: TextTheme.of(context).headlineMedium,
                          ),
                        if (widget.subtitle != null)
                          Text(
                            widget.subtitle!,
                            style: TextTheme.of(context).labelSmall,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    if (_isYoutube && _youtubeController != null) {
      return YoutubePlayer(
        controller: _youtubeController!,
        showVideoProgressIndicator: true,
      );
    } else if (_chewieController != null) {
      return Chewie(controller: _chewieController!);
    }
    return const Center(child: CircularProgressIndicator());
  }
}
