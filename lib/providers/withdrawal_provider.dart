import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/withdrawal_model.dart';
import '../services/withdrawal_service.dart';

final myWithdrawalsProvider = FutureProvider<List<WithdrawalModel>>((ref) {
  return ref.read(withdrawalServiceProvider).getMyWithdrawals();
});