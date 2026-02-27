class Summary {
  final int activeBenefits;
  final double annualCoparticipation;
  final int pendingRequests;

  Summary({
    required this.activeBenefits,
    required this.annualCoparticipation,
    required this.pendingRequests,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      activeBenefits: json['activeBenefits'] as int? ?? 0,
      annualCoparticipation: ((json['annualCoparticipation'] as num?) ?? 0)
          .toDouble(),
      pendingRequests: json['pendingRequests'] as int? ?? 0,
    );
  }
}
