import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../models/benefit_model.dart';
import '../models/summary_model.dart';

class DataService {
  static Future<Map<String, dynamic>> loadMockData() async {
    final jsonString = await rootBundle.loadString('assets/data/mock_data.json');
    return jsonDecode(jsonString);
  }

  static Future<User> getUser() async {
    final data = await loadMockData();
    return User.fromJson(data['user']);
  }

  static Future<Summary> getSummary() async {
    final data = await loadMockData();
    return Summary.fromJson(data['summary']);
  }

  static Future<List<Benefit>> getMyBenefits() async {
    final data = await loadMockData();
    final benefitsList = data['myBenefits'] as List;
    return benefitsList.map((b) => Benefit.fromJson(b)).toList();
  }

  static Future<List<Benefit>> getAvailableBenefits() async {
    final data = await loadMockData();
    final benefitsList = data['availableBenefits'] as List;
    return benefitsList.map((b) => Benefit.fromJson(b)).toList();
  }
}
