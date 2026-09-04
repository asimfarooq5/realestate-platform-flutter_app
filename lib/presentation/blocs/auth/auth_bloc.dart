import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:malkiyat_app/data/models/user_model.dart';
import 'package:malkiyat_app/data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<DeactivateAccountRequested>(_onDeactivateAccountRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.login(event.email, event.password);
      _authRepository.setAuthToken(response.accessToken);
      emit(Authenticated(response.user));
    } catch (e) {
      emit(AuthError(_friendlyError(e)));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Register the account, then immediately log in so the user
      // is authenticated and a session is persisted.
      await _authRepository.register(
        email: event.email,
        password: event.password,
        name: event.name,
        phone: event.phone,
        dateOfBirth: event.dateOfBirth,
        role: event.role,
      );
      final response = await _authRepository.login(event.email, event.password);
      _authRepository.setAuthToken(response.accessToken);
      // RegistrationSuccess is a one-shot signal for the register screen's
      // toast/navigation; the persisted app-wide state other screens (e.g.
      // Profile, Favorites) check is Authenticated, so emit that too.
      emit(RegistrationSuccess(response.user));
      emit(Authenticated(response.user));
    } catch (e) {
      emit(AuthError(_friendlyError(e)));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.clearAuthToken();
    emit(Unauthenticated());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.restoreSession();
    final user = await _authRepository.getStoredUser();
    final token = await _authRepository.getStoredToken();
    if (user != null && token != null) {
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _authRepository.updateProfile(name: event.name, phone: event.phone);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(_friendlyError(e)));
    }
  }

  Future<void> _onDeactivateAccountRequested(
    DeactivateAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.deactivateAccount();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(_friendlyError(e)));
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('401') || msg.contains('Incorrect email')) {
      return 'Invalid email or password';
    }
    if (msg.contains('400') || msg.contains('already registered')) {
      return 'An account with this email already exists';
    }
    if (msg.contains('429')) {
      return 'Too many attempts. Please try again later.';
    }
    if (msg.contains('SocketException') || msg.contains('Connection failed') || msg.contains('Connection refused')) {
      return 'Could not connect to the server. Check your internet connection.';
    }
    return 'Something went wrong. Please try again.';
  }
}
