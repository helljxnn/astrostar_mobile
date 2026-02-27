import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../data/services/auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService = AuthService();

  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthUserUpdated>(_onAuthUserUpdated);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        final user = await _authService.getStoredUser();
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('🟢 AuthBloc: Recibido evento de login');
    debugPrint('🟢 Email: ${event.email}');
    
    emit(AuthLoading());
    debugPrint('🟢 AuthBloc: Emitido AuthLoading');

    try {
      debugPrint('🟢 AuthBloc: Llamando a authService.login()');
      final response = await _authService.login(event.email, event.password);
      debugPrint('🟢 AuthBloc: Respuesta recibida - success: ${response.success}');

      if (response.success && response.data != null) {
        debugPrint('✅ AuthBloc: Login exitoso, emitiendo AuthAuthenticated');
        emit(AuthAuthenticated(response.data!.user));
      } else {
        debugPrint('❌ AuthBloc: Login fallido - ${response.message}');
        emit(AuthError(response.message));
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      debugPrint('❌ AuthBloc: Excepción capturada - $e');
      emit(AuthError('Error inesperado: ${e.toString()}'));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authService.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthUserUpdated(
    AuthUserUpdated event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      // Mantener estado actual
    }
  }
}
