import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/remote/auth_remote_data_source.dart';
import '../../data/models/auth_user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../error/app_error.dart';
import '../../presentation/viewmodels/plan_list_viewmodel.dart';
import 'auth_service.dart';

part 'auth_state.g.dart';

// ── State ────────────────────────────────────────────────────────────────────

class AuthState {
  final bool isLoggedIn;
  final AuthUser? currentUser;
  final bool isLoading;
  final AppError? error;

  const AuthState({
    this.isLoggedIn = false,
    this.currentUser,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    AuthUser? currentUser,
    bool? isLoading,
    AppError? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ── Infrastructure providers ─────────────────────────────────────────────────

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) =>
    AuthRemoteDataSource(ref.watch(graphQLHttpClientProvider));

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
  ref.watch(authRemoteDataSourceProvider),
  ref.watch(authServiceProvider),
);

// ── Notifier ─────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class AuthStateNotifier extends _$AuthStateNotifier {
  @override
  AuthState build() {
    _restoreSession();
    return const AuthState();
  }

  Future<void> _restoreSession() async {
    final user = await ref.read(authServiceProvider).restoreSession();
    if (user != null) {
      state = state.copyWith(isLoggedIn: true, currentUser: user);
    }
  }

  Future<bool> login(String email, String password) => _doAuth(
    () => ref
        .read(authRepositoryProvider)
        .login(email: email, password: password),
  );

  Future<bool> register(String email, String password, String name) => _doAuth(
    () => ref
        .read(authRepositoryProvider)
        .register(email: email, password: password, name: name),
  );

  Future<bool> _doAuth(Future<AuthUser> Function() action) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await action();
      state = state.copyWith(
        isLoggedIn: true,
        currentUser: user,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppError ? e : UnknownError(e.toString()),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState();
  }
}
