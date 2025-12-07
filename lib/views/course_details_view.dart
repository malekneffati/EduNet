import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/course_model.dart';
import '../models/review_model.dart';
import '../services/course_service.dart';
import '../services/payment_service.dart';
import '../services/deep_link_service.dart';
import '../components/home/navbar.dart';
import '../components/home/footer.dart';

import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../services/paymee_direct_service.dart';
import 'quiz/components/quiz_card.dart';

// Simple provider for CourseService if not globally available
final courseServiceDetailsProvider = Provider((ref) => CourseService());

class CourseDetailsView extends ConsumerStatefulWidget {
  final String courseId;

  const CourseDetailsView({super.key, required this.courseId});

  @override
  ConsumerState<CourseDetailsView> createState() => _CourseDetailsViewState();
}

class _CourseDetailsViewState extends ConsumerState<CourseDetailsView> {
  CourseModel? _course;
  bool _isLoading = true;
  bool _hasAccess = false;
  
  // Scroll & Keys
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _chaptersKey = GlobalKey();

  // Review Form
  final _commentController = TextEditingController();
  double _userRating = 0;
  bool _isSubmittingReview = false;

  // Video Controllers
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  // Deep Link Service
  final _deepLinkService = DeepLinkService();

  @override
  void initState() {
    super.initState();
    _loadCourse();
    _setupDeepLinkListener();
  }

  void _setupDeepLinkListener() {
    _deepLinkService.onLink = (Uri uri) {
      print('Deep link recu: $uri');
      final paymentData = DeepLinkService.parsePaymentLink(uri);
      
      if (paymentData != null) {
        _handlePaymentReturn(paymentData);
      }
    };
    _deepLinkService.init();
  }

  Future<void> _handlePaymentReturn(PaymentDeepLinkData data) async {
    print('Retour de paiement: $data');
    
    if (data.isSuccess) {
      // Paiement réussi
      setState(() => _isLoading = true);
      
      // Accorder l'accès au cours
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && _course != null) {
        final paymentService = PaymentService();
        await paymentService.grantAccess(user.uid, _course!.id);
        
        // Recharger le statut d'accès
        await _checkAccess();
        
        if (mounted) {
          setState(() => _isLoading = false);
          
          // Afficher un message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Paiement reussi ! Vous avez maintenant acces au cours.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ),
          );
          
          // Scroller vers les chapitres
          if (_chaptersKey.currentContext != null) {
            Future.delayed(const Duration(milliseconds: 500), () {
              Scrollable.ensureVisible(
                _chaptersKey.currentContext!,
                duration: const Duration(seconds: 1),
              );
            });
          }
        }
      }
    } else {
      // Paiement annulé
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paiement annule. Aucun montant n\'a ete debite.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _loadCourse() async {
    final service = ref.read(courseServiceDetailsProvider);
    final course = await service.getCourseById(widget.courseId);
    
    if (mounted) {
      setState(() {
        _course = course;
        _isLoading = false;
      });
      
      if (_course != null && _course!.videoUrl != null && _course!.videoUrl!.isNotEmpty) {
        _initVideoPlayer(_course!.videoUrl!);
      }
      
      _checkAccess();
    }
  }

  Future<void> _initVideoPlayer(String url) async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoPlayerController!.initialize();

      if (mounted) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: false,
            looping: false,
            aspectRatio: _videoPlayerController!.value.aspectRatio,
            errorBuilder: (context, errorMessage) {
              return Center(child: Text('Erreur: $errorMessage', style: const TextStyle(color: Colors.white)));
            },
          );
        });
      }
    } catch (e) {
      print("Error initializing video: $e");
    }
  }

  Future<void> _checkAccess() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _course == null) return;
    
    if (_course!.isFree) {
      if (mounted) setState(() => _hasAccess = true);
      return;
    }

    final paymentService = PaymentService();
    final access = await paymentService.hasAccess(user.uid, _course!.id);
    
    if (mounted) {
      setState(() => _hasAccess = access);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_course == null) {
      return const Scaffold(body: Center(child: Text('Cours introuvable')));
    }

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            const Navbar(),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 64, 
                vertical: 32
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isMobile),
                  const SizedBox(height: 48),
                  if (_course!.chapters != null && _course!.chapters!.isNotEmpty)
                    _buildChaptersSection(),
                  const SizedBox(height: 48),
                  _buildReviewsSection(),
                ],
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildInfoSection(),
          const SizedBox(height: 24),
          _buildMediaSection(isMobile: true),
          const SizedBox(height: 24),
          _buildActionCard(isMobile: true),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               _buildInfoSection(),
               const SizedBox(height: 24),
               _buildMediaSection(isMobile: false),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            flex: 1,
            child: _buildActionCard(isMobile: false),
          ),
        ],
      );
    }
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _course!.title,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const Icon(Icons.star, color: Colors.amber, size: 20),
            Icon(Icons.star_half, color: Colors.grey[300], size: 20),
            const SizedBox(width: 8),
            Text('4.5/5', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(width: 8),
            Text('(Voir avis)', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      ],
    );
  }

  Widget _buildMediaSection({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Apercu gratuit du cours',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: isMobile ? 200 : 400,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
             ? ClipRRect(
                 borderRadius: BorderRadius.circular(12),
                 child: Chewie(controller: _chewieController!),
               )
             : _course!.videoUrl != null 
               ? const Center(child: CircularProgressIndicator(color: Colors.white))
               : const Center(child: Icon(Icons.image, size: 64, color: Colors.grey)), 
        ),
      ],
    );
  }

  Widget _buildActionCard({required bool isMobile}) {
    // Override logic for demo (HARDCODED as requested)
    bool isDevWeb = _course!.title.contains('Developpement Web');
    bool isMarketing = _course!.title.contains('Marketing Digital');
    
    double displayPrice = _course!.price;
    bool isFree = _course!.isFree;

    if (isDevWeb) {
      displayPrice = 10.0;
      isFree = false;
    } else if (isMarketing) {
      isFree = true;
    }

    if (_hasAccess) {
      return ElevatedButton(
        onPressed: () {
         if (_chaptersKey.currentContext != null) {
           Scrollable.ensureVisible(
             _chaptersKey.currentContext!,
             duration: const Duration(seconds: 1),
           );
         } else {
           // Fallback: scroll to bottom
           _scrollController.animateTo(
             _scrollController.position.maxScrollExtent,
             duration: const Duration(seconds: 1),
             curve: Curves.easeOut,
           );
         }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text('Continuer la formation', style: TextStyle(fontSize: 18)),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Categorie', _course!.category),
            const SizedBox(height: 12),
            _buildDetailRow('Duree', _course!.duration),
            const SizedBox(height: 12),
            _buildDetailRow('Instructeur', _course!.instructor),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isFree && !_hasAccess ? _handleFreeEnrollment : () => _handlePurchaseOverride(displayPrice),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFree && !_hasAccess ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isFree && !_hasAccess 
                    ? 'Commencer gratuitement' 
                    : 'Payer maintenant - ${displayPrice.toStringAsFixed(0)} TND',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildChaptersSection() {
    return Container(
      key: _chaptersKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contenu du cours',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _course!.chapters!.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final chapter = _course!.chapters![index];
              // Lock content if no access and not free
              final isLocked = !_hasAccess && !_course!.isFree;

              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey[50] : Colors.white,
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Chapitre ${index + 1} : ${chapter.title}',
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                              color: isLocked ? Colors.grey[700] : Colors.black,
                            ),
                          ),
                        ),
                        if (isLocked) 
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.lock, color: Colors.grey, size: 20),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      chapter.description,
                      style: TextStyle(color: Colors.grey[600], height: 1.5),
                    ),
                    if (chapter.videoUrl != null && chapter.videoUrl!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: isLocked 
                           ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez acheter le cours pour voir la video.')))
                           : () => context.push('/player', extra: chapter.videoUrl!),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                           children: [
                               Icon(Icons.play_circle_fill, color: isLocked ? Colors.grey : const Color(0xFF2563EB), size: 20),
                               const SizedBox(width: 8),
                               Text(
                                 'Regarder la video',
                                 style: TextStyle(
                                   color: isLocked ? Colors.grey : const Color(0xFF2563EB),
                                   fontWeight: FontWeight.w500,
                                   decoration: isLocked ? null : TextDecoration.underline,
                                 ),
                               ),
                           ],
                        ),
                      ),
                    ],
                    if (chapter.pdfUrl != null && chapter.pdfUrl!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: isLocked
                           ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez acheter le cours pour telecharger le PDF.')))
                           : () => _launchURL(chapter.pdfUrl!),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                           children: [
                               Icon(Icons.picture_as_pdf, color: isLocked ? Colors.grey : const Color(0xFFEF4444), size: 20),
                               const SizedBox(width: 8),
                               Text(
                                 'Telecharger le PDF',
                                 style: TextStyle(
                                   color: isLocked ? Colors.grey : const Color(0xFFEF4444),
                                   fontWeight: FontWeight.w500,
                                   decoration: isLocked ? null : TextDecoration.underline,
                                 ),
                               ),
                           ],
                        ),
                      ),
                    ],
                    // Quiz Section
                    if (!isLocked)
                      QuizCard(
                        courseId: _course!.id,
                        chapter: chapter,
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    final service = ref.watch(courseServiceDetailsProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Avis des etudiants',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        StreamBuilder<List<ReviewModel>>(
          stream: service.getReviews(_course!.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final reviews = snapshot.data ?? [];

            return Column(
              children: [
                if (reviews.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('Aucun avis pour le moment'),
                  )
                else
                  ...reviews.map((review) => Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ...List.generate(5, (index) => Icon(
                                index < review.rating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              )),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('dd/MM/yyyy').format(review.createdAt),
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(review.comment),
                        ],
                      ),
                    ),
                  )),
                const SizedBox(height: 24),
                _buildAddReviewForm(),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddReviewForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Laisser un avis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _userRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () => setState(() => _userRating = index + 1.0),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Votre commentaire...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSubmittingReview ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
              ),
              child: _isSubmittingReview
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Publier'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleFreeEnrollment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez vous connecter pour vous inscrire')));
      context.push('/login');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final paymentService = PaymentService();
      await paymentService.grantAccess(user.uid, _course!.id);

      if (mounted) {
        setState(() {
           _hasAccess = true;
           _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inscription reussie ! Vous pouvez maintenant acceder au cours.')));

        // Scroll to chapters
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_chaptersKey.currentContext != null) {
            Scrollable.ensureVisible(
              _chaptersKey.currentContext!,
              duration: const Duration(seconds: 1),
            );
          } else {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(seconds: 1),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _handlePurchaseOverride(double price) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez vous connecter')));
      context.push('/login');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final orderId = 'COURSE_${_course!.id}_${DateTime.now().millisecondsSinceEpoch}';

      String firstName = 'Etudiant';
      String lastName = 'EduNet';

      if (user.displayName != null && user.displayName!.isNotEmpty) {
        final parts = user.displayName!.trim().split(' ');
        if (parts.isNotEmpty && parts.first.isNotEmpty) firstName = parts.first;
        if (parts.length > 1) {
           lastName = parts.sublist(1).join(' ');
        }
        if (lastName.isEmpty || lastName.trim().isEmpty) lastName = 'EduNet';
      }

      final paymentUrl = await PaymeeService.createPayment(
        amount: price,
        orderId: orderId,
        note: 'Achat du cours : ${_course!.title}', // Note personnalisée pour Paymee
        email: user.email ?? 'user@edunet.com',
        firstName: firstName,
        lastName: lastName,
        phone: '+21611222333',
      );

      setState(() => _isLoading = false);

      if (paymentUrl != null) {
        // ... success logic ...
        final paymentSuccess = await PaymeeService.showPaymentWebView(context, paymentUrl);
        // ... (rest of the logic unchanged)
        if (paymentSuccess == true) {
             // ...
             setState(() => _isLoading = true);
             final paymentService = PaymentService();
             await paymentService.grantAccess(user.uid, _course!.id);
             await _checkAccess();
             if (mounted) {
               setState(() => _isLoading = false);
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paiement réussi !'), backgroundColor: Colors.green));
               if (_chaptersKey.currentContext != null) {
                 Future.delayed(const Duration(milliseconds: 500), () {
                   Scrollable.ensureVisible(_chaptersKey.currentContext!, duration: const Duration(seconds: 1));
                 });
               }
             }
        } else if (paymentSuccess == false) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paiement annulé'), backgroundColor: Colors.orange));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Nettoyer le message d'erreur pour l'affichage
        String errorMsg = e.toString().replaceAll('Exception: ', '');
        if (errorMsg.contains('401')) errorMsg = 'Clé API invalide (401)';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur Paymee: $errorMsg'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'Détails', onPressed: () {
              showDialog(context: context, builder: (c) => AlertDialog(title: const Text('Détails Erreur'), content: Text(e.toString())));
            }),
          ),
        );
      }
    }
  }

  Future<void> _submitReview() async {
    if (_userRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez donner une note')));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connectez-vous pour laisser un avis')));
       return;
    }

    setState(() => _isSubmittingReview = true);

    try {
      final review = ReviewModel(
        id: '',
        userId: user.uid,
        userName: user.displayName ?? user.email ?? 'Etudiant',
        rating: _userRating,
        comment: _commentController.text.trim(),
        createdAt: DateTime.now(),
      );

      final service = ref.read(courseServiceDetailsProvider);
      await service.addReview(_course!.id, review);

      setState(() {
         _userRating = 0;
         _commentController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avis publie !')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      setState(() => _isSubmittingReview = false);
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible d\'ouvrir le lien')));
    }
  }
}
