import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://test.securitytroops.in/stapi/v1';

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '' ;  
    }

    // GET API
    // Future<dynamic> getAPI(String endpoint , {Map<String, String>? headers}) async {
    //   String? token = await getToken();
    //   final response = await http.get(
    //     Uri.parse('$baseUrl/$endpoint'),
    //     headers: headers ?? 
    //     {
    //       'Authorization' : 'Token $token'
    //     },
    //   );
    //   return response;
    // }
    Future<http.Response> getAPI(String endpoint) async {
        final token = await getToken();
        final response = await http.get(
          Uri.parse('$baseUrl/$endpoint'),
          headers: {
            'Authorization': 'Token $token',
            'Content-Type': 'application/json',
          },
        );
        return response;
      }
    
    // POST API
    Future<dynamic> postAPI(String endpoint ,Map<String,dynamic> body, {Map<String,String>? headers}) async {
      String? token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        body : json.encode(body),
        headers: headers ?? 
        {
          'Content-Type' : 'application/json',
          'Authorization' : 'Token $token'
        },
      );
      return response;
    }

    // PATCH API
    Future<dynamic> patchAPI(String endpoint ,Map<String,dynamic> body, {Map<String, String>? headers}) async {
      String? token = await getToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/$endpoint'),
        body : json.encode(body),
        headers: headers ?? 
        {
          'Content-Type' : 'application/json',
          'Authorization' : 'Token $token'
        },
      );
      return response;
    }

}