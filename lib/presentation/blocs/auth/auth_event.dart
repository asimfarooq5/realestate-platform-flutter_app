part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String? name;
  final String? phone;
  final String? dateOfBirth;
  final String role;

  const RegisterRequested({
    required this.email,
    required this.password,
    this.name,
    this.phone,
    this.dateOfBirth,
    this.role = 'BUYER',
  });

  @override
  List<Object?> get props => [email, password, name, phone, dateOfBirth, role];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class UpdateProfileRequested extends AuthEvent {
  final String? name;
  final String? phone;

  const UpdateProfileRequested({this.name, this.phone});

  @override
  List<Object?> get props => [name, phone];
}

class DeactivateAccountRequested extends AuthEvent {}
