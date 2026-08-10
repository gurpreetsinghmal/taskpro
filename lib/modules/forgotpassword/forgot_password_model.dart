enum ForgotPasswordModel { email, otp, newPassword }

class ForgotPasswordState {
  final ForgotPasswordModel step;
  final bool isLoading;
  final String? errorMessage;
  final String email;
  final String otp;
  final String newPassword;
  final String confirmPassword;

  const ForgotPasswordState({
    this.step = ForgotPasswordModel.email,
    this.isLoading = false,
    this.errorMessage,
    this.email = '',
    this.otp = '',
    this.newPassword = '',
    this.confirmPassword = '',
  });

  ForgotPasswordState copyWith({
    ForgotPasswordModel? step,
    bool? isLoading,
    String? errorMessage,
    String? email,
    String? otp,
    String? newPassword,
    String? confirmPassword,
  }) {
    return ForgotPasswordState(
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      email: email ?? this.email,
      otp: otp ?? this.otp,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }
}