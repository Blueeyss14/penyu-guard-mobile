import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SensorController extends GetxController {
  static const String _esp32Url = 'http://192.168.4.1/data';
  static const int _intervalSeconds = 2;

  final turbidity = 0.0.obs;
  final ph = 0.0.obs;
  final status = ''.obs;
  final isConnected = false.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final lastUpdated = ''.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    fetchData();
    _timer = Timer.periodic(
      const Duration(seconds: _intervalSeconds),
      (_) => fetchData(),
    );
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await http
          .get(Uri.parse(_esp32Url))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        turbidity.value = (data['turbidity'] as num).toDouble();
        ph.value = (data['ph'] as num).toDouble();
        status.value = data['status'] ?? '';
        isConnected.value = true;

        final now = DateTime.now();
        lastUpdated.value =
            '${now.hour.toString().padLeft(2, '0')}:'
            '${now.minute.toString().padLeft(2, '0')}:'
            '${now.second.toString().padLeft(2, '0')}';
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } on Exception catch (e) {
      isConnected.value = false;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
