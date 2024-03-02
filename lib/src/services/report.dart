import 'package:dio/dio.dart';
import 'package:shopos/src/models/input/report_input.dart';
import 'package:shopos/src/services/api_v1.dart';

class ReportService {
  const ReportService();

  Future<String> getCurrentDate() async {
    final response = await ApiV1Service.getRequest('/current-date');
    return response.data['date'];
  }
  ///
  Future<Response> getAllReport(ReportInput input) async {
    final response = await ApiV1Service.getRequest(
      '/report',
      queryParameters: input.toMap(),
    );
    print("line 14 in report.dart: /report");
    print(response.data);
    return response;
  }

  ///
  Future<Response> getStockReport() async {
    final response = await ApiV1Service.getRequest(
      '/report?type=report',
    );
    return response;
  }
}
