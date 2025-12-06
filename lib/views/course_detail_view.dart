import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../models/course_model.dart';
import '../components/home/navbar.dart';
import '../components/home/footer.dart';

class CourseDetailView extends ConsumerStatefulWidget {
  final CourseModel course;

  const CourseDetailView({super.key, required this.course});

  @override
  ConsumerState<CourseDetailView> createState() => _CourseDetailViewState();
}

class _CourseDetailViewState extends ConsumerState<CourseDetailView> {
  VideoPlayerController? _videoController;
  bool _isPlayerInitialized = false;
  bool _hasAccess = true; // Simulé pour l'instant, à connecter avec Firestore

  @override
  void initState() {
    super.initState();
    if (widget.course.videoUrl != null && widget.course.videoUrl!.isNotEmpty) {
      _initializePlayer(widget.course.videoUrl!);
    }
  }

  Future<void> _initializePlayer(String url) async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await _videoController!.initialize();
      setState(() {
        _isPlayerInitialized = true;
      });
    } catch (e) {
      print("Erreur initialisation vidéo: $e");
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir le lien : $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Navbar(),
            _buildContent(isMobile),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isMobile) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 48,
        vertical: 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fil d'ariane
          Row(
            children: [
              TextButton(
                onPressed: () => context.go('/catalog'),
                child: const Text('Catalogue'),
              ),
              const Text(' / '),
              Text(widget.course.category),
              const Text(' / '),
              Expanded(
                child: Text(
                  widget.course.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (isMobile)
            Column(
              children: [
                _buildVideoSection(),
                const SizedBox(height: 24),
                _buildInfoSection(),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildVideoSection()),
                const SizedBox(width: 32),
                Expanded(flex: 1, child: _buildInfoSection()),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _hasAccess
                ? (_isPlayerInitialized
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(_videoController!),
                          _ControlsOverlay(controller: _videoController!),
                          VideoProgressIndicator(_videoController!,
                              allowScrubbing: true),
                        ],
                      )
                    : const Center(
                        child: CircularProgressIndicator(color: Colors.white)))
                : _buildLockedContent(),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          widget.course.title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.course.description,
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  Widget _buildLockedContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock, size: 64, color: Colors.white54),
          const SizedBox(height: 16),
          const Text(
            'Contenu verrouillé',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Achetez ce cours pour accéder à la vidéo',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Rediriger vers paiement
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Accéder au cours complet'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'À propos de ce cours',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoRow(Icons.person, 'Instructeur', widget.course.instructor),
            const Divider(height: 32),
            _buildInfoRow(Icons.category, 'Catégorie', widget.course.category),
            const Divider(height: 32),
            _buildInfoRow(
                Icons.attach_money,
                'Prix',
                widget.course.isFree
                    ? 'Gratuit'
                    : '${widget.course.price.toStringAsFixed(0)} TND'),
            const SizedBox(height: 32),
            if (widget.course.pdfUrl != null && widget.course.pdfUrl!.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _hasAccess
                      ? () => _launchURL(widget.course.pdfUrl!)
                      : null,
                  icon: const Icon(Icons.description),
                  label: const Text('Ressources PDF'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (!_hasAccess)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Acheter
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Acheter maintenant'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ],
        ),
      ],
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
