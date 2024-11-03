// api_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shepherd_mo/models/event.dart';
import 'package:shepherd_mo/models/group.dart';

class ApiService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<List<Group>> fetchGroups({
    required String searchKey,
    required int pageNumber,
    required int pageSize,
    required String userId,
  }) async {
    final url = Uri.parse('$baseUrl/group').replace(queryParameters: {
      'SearchKey': searchKey,
      'PageNumber': pageNumber.toString(),
      'PageSize': pageSize.toString(),
      'UserId': userId,
    });

    // Retrieve token from SharedPreferences
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token', // Add Bearer token
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> results = data['result'];
      return results.map((json) => Group.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Please log in again.');
    } else if (response.statusCode == 404) {
      throw Exception('Not Found: The requested resource could not be found.');
    } else if (response.statusCode == 500) {
      throw Exception('Server Error: Please try again later.');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  Future<Map<DateTime, List<Event>>> fetchEventsCalendar(
      String chosenDate,
      String groupId,
      int calendarTypeEnum,
      String userOnly,
      String getUpcoming) async {
    final url = Uri.parse('$baseUrl/event/calendar');
    Map<DateTime, List<Event>> eventsByDate = {};

    // Set query parameters
    final queryParams = {
      'ChosenDate': chosenDate,
      'GroupId': groupId,
      'CalendarTypeEnum': calendarTypeEnum.toString(),
      'UserOnly': userOnly,
      'GetUpcoming': getUpcoming
    };

    final uriWithParams = url.replace(queryParameters: queryParams);
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    final response = await http.get(
      uriWithParams,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> results = data['data'];
      final events = results.map((json) => Event.fromJson(json)).toList();
      eventsByDate = {};
      for (Event event in events) {
        final date = DateTime(
            event.fromDate!.year, event.fromDate!.month, event.fromDate!.day);
        if (eventsByDate[date] == null) {
          eventsByDate[date] = [];
        }
        eventsByDate[date]!.add(event);
      }
      return eventsByDate;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Please log in again.');
    } else if (response.statusCode == 404) {
      throw Exception('Not Found: The requested resource could not be found.');
    } else if (response.statusCode == 500) {
      throw Exception('Server Error: Please try again later.');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  Future<Event> fetchEventDetails(String id) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    final response = await http.get(
      Uri.parse('$baseUrl/event/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final results = body['data'];
      final event = Event.fromJson(results);
      return event;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Please log in again.');
    } else if (response.statusCode == 40) {
      throw Exception('Bad Request');
    } else if (response.statusCode == 404) {
      throw Exception('Not Found: The requested resource could not be found.');
    } else if (response.statusCode == 500) {
      throw Exception('Server Error: Please try again later.');
    } else {
      throw Exception("Failed to load event details");
    }
  }
}
