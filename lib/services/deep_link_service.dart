import 'dart:async';
import 'package:app_links/app_links.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription? _sub;
  
  // Callback pour gérer les liens
  Function(Uri)? onLink;

  /// Initialise l'écoute des deep links
  Future<void> init() async {
    // Vérifier le lien initial (si l'app a été lancée via un deep link)
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null && onLink != null) {
        onLink!(initialLink);
      }
    } catch (e) {
      print('Erreur lors de la récupération du lien initial: $e');
    }

    // Écouter les liens entrants pendant que l'app est ouverte
    _sub = _appLinks.uriLinkStream.listen((Uri uri) {
      if (onLink != null) {
        onLink!(uri);
      }
    }, onError: (err) {
      print('Erreur deep link: $err');
    });
  }

  /// Arrête l'écoute des deep links
  void dispose() {
    _sub?.cancel();
  }

  /// Parse les paramètres d'un deep link de paiement
  /// Exemple: edunet://payment/success?order_id=COURSE_123&payment_token=abc
  static PaymentDeepLinkData? parsePaymentLink(Uri uri) {
    if (uri.scheme != 'edunet' || uri.host != 'payment') {
      return null;
    }

    final path = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : '';
    final isSuccess = path == 'success';
    final isCancel = path == 'cancel';

    if (!isSuccess && !isCancel) {
      return null;
    }

    return PaymentDeepLinkData(
      isSuccess: isSuccess,
      orderId: uri.queryParameters['order_id'],
      paymentToken: uri.queryParameters['payment_token'],
    );
  }
}

/// Données extraites d'un deep link de paiement
class PaymentDeepLinkData {
  final bool isSuccess;
  final String? orderId;
  final String? paymentToken;

  PaymentDeepLinkData({
    required this.isSuccess,
    this.orderId,
    this.paymentToken,
  });

  @override
  String toString() {
    return 'PaymentDeepLinkData(isSuccess: $isSuccess, orderId: $orderId, paymentToken: $paymentToken)';
  }
}
