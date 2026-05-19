import 'package:app/models/short.dart';
import 'package:app/services/service.dart';
import 'package:app/utils/alert.dart';
import 'package:app/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';

/* class Reel {
  final String? id;
  final String url;
  final String title;
  final String? description;
  final int likes;
  final int dislikes;

  Reel({
    this.id,
    required this.url,
    required this.title,
    this.description,
    this.likes = 0,
    this.dislikes = 0,
  });
} */

class ReelsPlayer extends StatefulWidget {
  final List<ShortData> reels;
  final int initialIndex;

  const ReelsPlayer({super.key, required this.reels, this.initialIndex = 0});

  @override
  State<ReelsPlayer> createState() => _ReelsPlayerState();
}

class _ReelsPlayerState extends State<ReelsPlayer> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.reels.length,
        itemBuilder: (context, index) {
          return ReelItem(reel: widget.reels[index]);
        },
      ),
    );
  }
}

class ReelItem extends StatefulWidget {
  final ShortData reel;

  const ReelItem({super.key, required this.reel});

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  bool _isYoutube = false;
  bool _isVimeo = false;
  bool _isInitialized = false;
  String? _vimeoId;

  bool _isLiked = false;
  bool _isDisliked = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() async {
    final url = widget.reel.url;

    // Check if YouTube
    final ytId = YoutubePlayer.convertUrlToId(url);
    if (ytId != null) {
      _isYoutube = true;
      _youtubeController = YoutubePlayerController(
        initialVideoId: ytId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          loop: true,
        ),
      );
      if (mounted) setState(() => _isInitialized = true);
      return;
    }

    // Check if Vimeo
    if (url.contains('vimeo.com')) {
      _isVimeo = true;
      // Extract Vimeo ID using RegExp
      final RegExp regExp = RegExp(r'vimeo\.com\/(?:video\/)?([0-9]+)');
      final Match? match = regExp.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        _vimeoId = match.group(1);
      }
      if (mounted) setState(() => _isInitialized = true);
      return;
    }

    // Standard Video
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: true,
        showControls: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint("Reel Video Error: $e");
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
    return Stack(
      children: [
        // Video Background
        Positioned.fill(
          child: Container(color: Colors.black, child: _buildVideoPlayer()),
        ),

        // Gradient Overlay for Text
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 300,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withAlpha(200), Colors.transparent],
                ),
              ),
            ),
          ),
        ),

        // Bottom Left Content (Title & Description)
        Positioned(
          left: 16,
          bottom: 24,
          right: 80, // Leave space for side actions
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.reel.title,
                style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (widget.reel.description != null) ...[
                Text(
                  widget.reel.description!,
                  style: GoogleFonts.lato(
                    color: Colors.white.withAlpha(220),
                    fontSize: 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        FutureBuilder(
          future: Service.identity.isLoggedIn(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            } else if (snapshot.hasData) {
              if (snapshot.data!) {
                return Positioned(
                  right: 16,
                  bottom: 24,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildActionButton(
                        icon: _isLiked
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        label: "${widget.reel.likes + (_isLiked ? 1 : 0)}",
                        color: _isLiked ? Colors.blue : Colors.white,
                        onTap: () async {
                          Result result = await Service.reaction.like(
                            'SHORT_VIDEO',
                            widget.reel.id!,
                          );
                          if (result.succeed) {
                            setState(() {
                              _isLiked = !_isLiked;
                              if (_isLiked) _isDisliked = false;
                            });
                          } else {
                            Alert.show(result.message!, isError: true);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildActionButton(
                        icon: _isDisliked
                            ? Icons.thumb_down
                            : Icons.thumb_down_outlined,
                        label: "Dislike",
                        color: _isDisliked ? Colors.red : Colors.white,
                        onTap: () async {
                          Result result = await Service.reaction.dislike(
                            'SHORT_VIDEO',
                            widget.reel.id!,
                          );
                          if (result.succeed) {
                            setState(() {
                              _isDisliked = !_isDisliked;
                              if (_isDisliked) _isLiked = false;
                            });
                          } else {
                            Alert.show(result.message!, isError: true);
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      /* const SizedBox(height: 20),
              _buildActionButton(
                icon: Icons.share_outlined,
                label: "Share",
                color: Colors.white,
                onTap: () {
                  // Handle Share
                },
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                icon: Icons.more_vert,
                label: "",
                color: Colors.white,
                onTap: () {
                  // Handle More
                },
              ), */
                    ],
                  ),
                );
              } else {
                return Container();
              }
            } else {
              return Container();
            }
          },
        ),

        // Bottom Right Actions (Like, Dislike)
      ],
    );
  }

  Widget _buildVideoPlayer() {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_isYoutube && _youtubeController != null) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width / (16 / 9),
          child: YoutubePlayer(
            controller: _youtubeController!,
            showVideoProgressIndicator: false,
            onReady: () {
              if (mounted) {
                _youtubeController!.play();
              }
            },
          ),
        ),
      );
    }

    if (_isVimeo && _vimeoId != null) {
      return SizedBox.expand(
        child: VimeoVideoPlayer(
          videoId: _vimeoId!,
          isAutoPlay: true,
          isLooping: true,
          showControls: false,
          onInAppWebViewCreated: (controller) {},
        ),
      );
    }

    if (_chewieController != null) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _videoPlayerController!.value.size.width,
          height: _videoPlayerController!.value.size.height,
          child: Chewie(controller: _chewieController!),
        ),
      );
    }

    return const Center(
      child: Text(
        "Unable to load video",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 30),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
