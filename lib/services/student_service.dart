import 'api_service.dart';
import '../services/api_session_storage.dart';

class Student {
  final int id;
  final int userId;
  final DateTime? graduationDate;
  final int? semestersFromGrad;
  final int pointsAwarded;
  final int pointsUsed;

  Student({
    required this.id,
    required this.userId,
    this.graduationDate,
    this.semestersFromGrad,
    required this.pointsAwarded,
    required this.pointsUsed,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as int,
      userId: json['userId'] as int,
      graduationDate: json['graduationDate'] != null
          ? DateTime.parse(json['graduationDate'])
          : null,
      semestersFromGrad: json['semestersFromGrad'] as int?,
      pointsAwarded: json['pointsAwarded'] as int? ?? 0,
      pointsUsed: json['pointsUsed'] as int? ?? 0,
    );
  }
}

class StudentService extends ApiService {
  StudentService({required super.baseUrl});

  Future<Student?> getStudentForUserId() async {
    try {
      final userId = (await ApiSessionStorage.getSession()).userId;
      final response = await get('/students/user/$userId');
      
      if (response == null || response['data'] == null) {
        return null;
      }

      return Student.fromJson(response['data']);
    } catch (e) {
      print('Error fetching student: $e');
      return null;
    }
  }
} 