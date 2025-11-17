import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lyno_cms/widgets/toast_widget.dart';
// import 'package:http_parser/http_parser.dart'; // (optional) if you want to set contentType on uploads

class ApiService {
  static const String baseUrl = "https://lyno-shopping.vercel.app";
  // static const String baseUrl = "http://192.168.100.189:5000";

  /// Default JSON headers (add auth here if needed)
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  /// Check internet connectivity (with toast)
  static Future<bool> hasInternet(BuildContext context) async {
    final result = await Connectivity().checkConnectivity();

    // `checkConnectivity()` now returns a list on newer plugin versions
    late final List<ConnectivityResult> list;
    list = result;

    final online = list.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet ||
          r == ConnectivityResult.vpn ||
          r == ConnectivityResult.bluetooth ||
          r == ConnectivityResult.other,
    );

    if (!online) {
      CustomToast.show(
        context: context,
        message: "No internet connection",
        color: Colors.redAccent,
      );
      return false;
    }
    return true;
  }

  /// Build a Uri from base + endpoint (endpoint WITHOUT leading slash)
  static Uri _buildUri(String endpoint, [Map<String, dynamic>? query]) {
    final uri = Uri.parse("$baseUrl/$endpoint");
    if (query == null || query.isEmpty) return uri;
    final qp = query.map((k, v) => MapEntry(k, v?.toString()));
    return uri.replace(queryParameters: qp);
  }

  // ---------------------------------------------------------------------------
  // Low-level HTTP methods (return raw http.Response?)
  // ---------------------------------------------------------------------------

  // ---------------- GET ----------------
  static Future<http.Response?> getRequest({
    required BuildContext context,
    required String endpoint,
    Map<String, dynamic>? query,
  }) async {
    if (!await hasInternet(context)) return null;

    final url = _buildUri(endpoint, query);
    try {
      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 15));
      return response;
    } on TimeoutException {
      CustomToast.show(
        context: context,
        message: "Request timed out",
        color: Colors.orange,
      );
      return null;
    } catch (e) {
      CustomToast.show(
        context: context,
        message: "Server connection failed",
        color: Colors.orange,
      );
      return null;
    }
  }

  // ---------------- POST ----------------
  static Future<http.Response?> postRequest({
    required BuildContext context,
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    if (!await hasInternet(context)) return null;

    final url = _buildUri(endpoint);
    try {
      final response = await http
          .post(url, headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      return response;
    } on TimeoutException {
      CustomToast.show(
        context: context,
        message: "Request timed out",
        color: Colors.orange,
      );
      return null;
    } catch (e) {
      CustomToast.show(
        context: context,
        message: "Server connection failed",
        color: Colors.orange,
      );
      return null;
    }
  }

  // ---------------- PATCH ----------------
  static Future<http.Response?> patchRequest({
    required BuildContext context,
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    if (!await hasInternet(context)) return null;

    final url = _buildUri(endpoint);
    try {
      final response = await http
          .patch(url, headers: _headers, body: jsonEncode(body ?? {}))
          .timeout(const Duration(seconds: 15));
      return response;
    } on TimeoutException {
      CustomToast.show(
        context: context,
        message: "Request timed out",
        color: Colors.orange,
      );
      return null;
    } catch (e) {
      CustomToast.show(
        context: context,
        message: "Server connection failed",
        color: Colors.orange,
      );
      return null;
    }
  }

  // ---------------- DELETE ----------------
  static Future<http.Response?> deleteRequest({
    required BuildContext context,
    required String endpoint,
    Map<String, dynamic>? query,
  }) async {
    if (!await hasInternet(context)) return null;

    final url = _buildUri(endpoint, query);
    try {
      final response = await http
          .delete(url, headers: _headers)
          .timeout(const Duration(seconds: 15));
      return response;
    } on TimeoutException {
      CustomToast.show(
        context: context,
        message: "Request timed out",
        color: Colors.orange,
      );
      return null;
    } catch (e) {
      CustomToast.show(
        context: context,
        message: "Server connection failed",
        color: Colors.orange,
      );
      return null;
    }
  }

  // ---------------- MULTIPART UPLOAD (Flutter web OK) ----------------
  /// Expects server to accept `fieldName` (default: "file"). Returns decoded JSON or null.
  /// Example success shape: { success: true, url: "..."} or { data: { url: "..." } }
  static Future<Map<String, dynamic>?> uploadBytes({
    required BuildContext context,
    required String endpoint, // e.g. "uploads" (without leading slash)
    required List<int> bytes,
    required String filename,
    String fieldName = 'file',
    Map<String, String>? fields,
  }) async {
    if (!await hasInternet(context)) return null;

    final uri = _buildUri(endpoint);
    try {
      final req = http.MultipartRequest('POST', uri);

      // Optional: add auth headers here (don't set content-type; MultipartRequest handles it)
      // req.headers['Authorization'] = 'Bearer ...';

      if (fields != null && fields.isNotEmpty) {
        req.fields.addAll(fields);
      }

      req.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: filename,
          // contentType: MediaType('image', 'jpeg'), // optional
        ),
      );

      final streamed = await req.send().timeout(const Duration(seconds: 30));
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return safeDecode(res.body);
      }
      showServerErrorToast(context, res);
      return null;
    } on TimeoutException {
      CustomToast.show(
        context: context,
        message: "Upload timed out",
        color: Colors.orange,
      );
      return null;
    } catch (e) {
      CustomToast.show(
        context: context,
        message: "Upload failed",
        color: Colors.orange,
      );
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // JSON helpers & error handling
  // ---------------------------------------------------------------------------

  /// Safe JSON decode -> Map<String, dynamic>
  static Map<String, dynamic> safeDecode(String body) {
    try {
      final d = jsonDecode(body);
      if (d is Map<String, dynamic>) return d;
      return {"data": d};
    } catch (_) {
      return {"data": []};
    }
  }

  /// Show generic server error toast with HTTP status
  static void showServerErrorToast(BuildContext context, http.Response res) {
    CustomToast.show(
      context: context,
      message: "Server error ${res.statusCode}",
      color: Colors.orange,
    );
  }

  /// Internal helper: if response OK -> decoded Map; else show toast and return null
  static Map<String, dynamic>? _okOrToastJson(
    BuildContext context,
    http.Response? res,
  ) {
    if (res == null) return null;
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return safeDecode(res.body);
    }
    showServerErrorToast(context, res);
    return null;
  }

  static Future<Map<String, dynamic>?> getJson({
    required BuildContext context,
    required String endpoint,
    Map<String, dynamic>? query,
  }) async {
    final res = await getRequest(
      context: context,
      endpoint: endpoint,
      query: query,
    );
    return _okOrToastJson(context, res);
  }

  static Future<Map<String, dynamic>?> postJson({
    required BuildContext context,
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    final res = await postRequest(
      context: context,
      endpoint: endpoint,
      body: body,
    );
    return _okOrToastJson(context, res);
  }

  static Future<Map<String, dynamic>?> patchJson({
    required BuildContext context,
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    final res = await patchRequest(
      context: context,
      endpoint: endpoint,
      body: body,
    );
    return _okOrToastJson(context, res);
  }

  static Future<Map<String, dynamic>?> deleteJson({
    required BuildContext context,
    required String endpoint,
    Map<String, dynamic>? query,
  }) async {
    final res = await deleteRequest(
      context: context,
      endpoint: endpoint,
      query: query,
    );
    return _okOrToastJson(context, res);
  }
}
