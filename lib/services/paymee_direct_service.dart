import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymeeService {
  // VOS CLÉS PAYMEE (à remplacer)
  static const String PAYMEE_API_KEY = '6507a1376f49be6a1b8c4460a7eed289b3315e13';
  static const String PAYMEE_VENDOR_ID = '4108'; // Not used in header but often in payload if required/optional
  static const String PAYMEE_ENV = 'sandbox'; 
  
  static const String PAYMEE_API_URL = PAYMEE_ENV == 'production'
      ? 'https://app.paymee.tn/api/v2/payments/create'
      : 'https://sandbox.paymee.tn/api/v2/payments/create';

  /// Step 1 - Initiate payment
  static Future<String?> createPayment({
    required double amount,
    required String orderId,
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    String? note,
  }) async {
    try {
      // Input strictly matching documentation
      final Map<String, dynamic> payload = {
        "amount": amount, // Float value
        "note": note ?? "Order #$orderId",
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "phone": phone,
        "return_url": "https://example.com/payment/success", // Domaine neutre
        "cancel_url": "https://example.com/payment/cancel", // Domaine neutre
        "webhook_url": "https://example.com/webhook",
        "order_id": orderId,
        "vendor": int.tryParse(PAYMEE_VENDOR_ID) ?? 4108 // Sometimes required depending on API version
      };

      print('📝 Paymee Request Step 1: $payload');

      final response = await http.post(
        Uri.parse(PAYMEE_API_URL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $PAYMEE_API_KEY',
        },
        body: jsonEncode(payload),
      );

      print('📥 Paymee Response Step 1 (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == true && data['data'] != null) {
           return data['data']['payment_url'];
        } else {
           // Si Paymee renvoie des erreurs spécifiques (ex: format invalide)
           String errorDetails = data['message'] ?? 'Erreur inconnue';
           if (data['errors'] != null) {
             errorDetails += ': ${data['errors'].toString()}';
           }
           throw Exception(errorDetails);
        }
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Paymee Exception: $e');
      rethrow;
    }
  }

  /// Step 2 - Redirect the user (WebView)
  static Future<bool?> showPaymentWebView(
    BuildContext context,
    String paymentUrl,
  ) async {
    return await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PaymeeWebView(paymentUrl: paymentUrl),
      ),
    );
  }
}

class PaymeeWebView extends StatefulWidget {
  final String paymentUrl;

  const PaymeeWebView({super.key, required this.paymentUrl});

  @override
  State<PaymeeWebView> createState() => _PaymeeWebViewState();
}

class _PaymeeWebViewState extends State<PaymeeWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print('🌐 Navigation: $url');
            if (url.contains('/payment/success')) {
              // Intercept Step 3 (Return URL)
              Navigator.pop(context, true); // Success
            } else if (url.contains('/payment/cancel')) {
              Navigator.pop(context, false); // Cancel
            }
          },
          onPageFinished: (url) => setState(() => _isLoading = false),
          onWebResourceError: (error) => print('❌ WebView Error: ${error.description}'),
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement Sécurisé'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
