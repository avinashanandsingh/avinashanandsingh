import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  RazorpayService._privateConstructor();
  static final RazorpayService instance = RazorpayService._privateConstructor();

  // 1. Change from 'late' to nullable
  Razorpay? _razorpay;

  Function(PaymentSuccessResponse)? _onSuccessCallback;
  Function(PaymentFailureResponse)? _onFailureCallback;

  // 2. Modified init method
  void init() {
    // Prevent duplicate initializations if called multiple times
    if (_razorpay != null) return;

    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) =>
      _onSuccessCallback?.call(response);
  void _handlePaymentError(PaymentFailureResponse response) =>
      _onFailureCallback?.call(response);
  void _handleExternalWallet(ExternalWalletResponse response) {}

  void startPayment({
    required Map<String, dynamic> options,
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
  }) {
    _onSuccessCallback = onSuccess;
    _onFailureCallback = onFailure;

    // 3. Fallback: If init() was forgotten, initialize it now dynamically
    if (_razorpay == null) {
      init();
    }

    try {
      FocusManager.instance.primaryFocus?.unfocus();
      _razorpay!.open(options); // Securely use the ! operator now
    } catch (e) {
      debugPrint("Error opening Razorpay: $e");
    }
  }

  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }
}
