import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../shared/models/profile.dart';
import '../supabase/supabase_client.dart';

part 'auth_providers.g.dart';

@riverpod
Stream<User?> authState(AuthStateRef ref) {
  return supabase.auth.onAuthStateChange.map((event) => event.session?.user);
}

@riverpod
Future<Profile?> currentUser(CurrentUserRef ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;
  final repo = ref.read(authRepositoryProvider);
  return repo.getProfile(user.id);
}
