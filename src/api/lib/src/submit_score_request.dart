final class SubmitScoreRequest {
  const SubmitScoreRequest({required this.value});

  final int value;

  Map<String, dynamic> toJson() => {'value': value};
}
