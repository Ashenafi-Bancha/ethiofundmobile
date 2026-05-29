import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../shared/widgets/loading_widget.dart';

class PaymentWebViewScreen extends StatefulWidget {
  const PaymentWebViewScreen({super.key, required this.checkoutUrl});

  final String checkoutUrl;

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  bool _loading = true;
  bool _disposed = false;
  bool _completedMockFlow = false;

  @override
  void initState() {
    super.initState();
    if (widget.checkoutUrl.contains('checkout-success')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_disposed && !_completedMockFlow) {
          _completedMockFlow = true;
          context.go('/payment/success');
        }
      });
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> _handleUrl(Uri? uri) async {
    if (!mounted || uri == null) return;
    final url = uri.toString();
    if (url.contains('success') || url.contains('payment-success') || url.contains('checkout-success')) {
      context.go('/payment/success');
    } else if (url.contains('failed') || url.contains('payment-failed') || url.contains('checkout-failed')) {
      context.go('/payment/failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.checkoutUrl.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Missing checkout URL'),
        ),
      );
    }

    if (widget.checkoutUrl.contains('checkout-success')) {
      return const Scaffold(
        body: Center(
          child: LoadingWidget(message: 'Completing payment...'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Payment'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.checkoutUrl)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
            ),
            onWebViewCreated: (controller) {},
            onLoadStart: (controller, url) {
              if (!_disposed && mounted) {
                setState(() => _loading = true);
              }
            },
            onLoadStop: (controller, url) async {
              if (!_disposed && mounted) {
                setState(() => _loading = false);
              }
              await _handleUrl(url);
            },
            shouldOverrideUrlLoading: (controller, action) async {
              await _handleUrl(action.request.url);
              return NavigationActionPolicy.ALLOW;
            },
            onReceivedError: (controller, request, error) {
              if (!mounted) return;
              context.go('/payment/failed');
            },
          ),
          if (_loading)
            const ColoredBox(
              color: Colors.white,
              child: LoadingWidget(message: 'Opening secure checkout...'),
            ),
        ],
      ),
    );
  }
}