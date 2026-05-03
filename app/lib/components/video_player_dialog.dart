import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

void show(BuildContext context, {required String url}) {
  showDialog(
    context: context,
    barrierDismissible: false,
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
  bool _isYoutube = false;
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Video Background
          Positioned.fill(child: _buildPlayerContent(colorScheme)),
        ],
      ),
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
    _youtubeController?.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}
