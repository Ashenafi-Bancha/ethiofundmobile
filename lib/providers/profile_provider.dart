import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

final profileProvider = FutureProvider<UserModel>((ref) {
  return ref.read(userServiceProvider).getProfile();
});