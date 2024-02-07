import 'package:chat_ai/shared/components/Constants.dart';
import 'package:dio/dio.dart';

class DioHelper {

  static Dio? dio;

  static void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        queryParameters: {
          'key': apiKey,
        }
      ),
    );
  }


  static Future<Response?> postData({
    required String pathUrl,
    required Map<String, dynamic> data,
  }) async {

    return await dio?.post(
      pathUrl,
      data: data,
    );
  }
}