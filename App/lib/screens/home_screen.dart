import 'package:flutter/material.dart';
import 'package:baigan/widgets/custom_appbar.dart';
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:baigan/services/sms_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _xValue = 0.0;
  double _yValue = 0.0;
  double _zValue = 0.0;

  WebSocketChannel? _channel;
  bool _isConnected = false;
  String _lastMessage = "No messages received";

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  final SMSService _smsService = SMSService(); // ✅ Added SMS Service

  @override
  void initState() {
    super.initState();
  
    _connectToWebSocket();
    _startListeningToAccelerometer();
  }

  void _startListeningToAccelerometer() {
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _xValue = event.x;
        _yValue = event.y;
        _zValue = event.z;
      });
      _sendSensorData();
    });
  }

  void _connectToWebSocket() {
    try {
      final wsUrl = 'ws://10.0.2.2:8000/ws';
      print("Connecting to WebSocket at: $wsUrl");

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      setState(() {
        _isConnected = true;
      });

      _channel!.stream.listen(
        (message) {
          print('Received from server: $message');
          setState(() {
            _lastMessage = message.toString();
          });
        },
        onDone: () {
          print("WebSocket closed");
          setState(() {
            _isConnected = false;
          });
          _reconnectWebSocket();
        },
        onError: (error) {
          print("WebSocket error: $error");
          setState(() {
            _isConnected = false;
          });
          _reconnectWebSocket();
        },
      );
    } catch (e) {
      print("WebSocket connection failed: $e");
      setState(() {
        _isConnected = false;
      });
      _reconnectWebSocket();
    }
  }

  void _reconnectWebSocket() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isConnected) {
        print("Reconnecting WebSocket...");
        _connectToWebSocket();
      }
    });
  }

  void _sendSensorData() {
    if (!_isConnected || _channel == null) return;

    final data = {
      "timestamp": DateTime.now().toIso8601String(),
      "accelerometer": {"x": _xValue, "y": _yValue, "z": _zValue}
    };

    _channel!.sink.add(jsonEncode(data));

    // If the motion crosses a certain threshold, send a push notification
    if (_xValue.abs() > 10 || _yValue.abs() > 10 || _zValue.abs() > 10) {
      _sendPushNotification();
    }
  }

  Future<void> _sendPushNotification() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken == null) {
      print("FCM Token not available");
      return;
    }

    const String serverKey = "YOUR_FIREBASE_SERVER_KEY"; // Replace with your actual key

    final notificationData = {
      "to": fcmToken,
      "notification": {
        "title": "Motion Alert!",
        "body": "High motion detected!",
      },
    };

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "key=$serverKey",
      },
      body: jsonEncode(notificationData),
    );
   

    print("Notification Response: ${response.body}");
  }

  

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Baigan',
          showCartIcon: true,
        ),
        backgroundColor: Colors.grey.shade300,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // WebSocket Status Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'WebSocket Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _isConnected ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isConnected
                                  ? 'Connected to Server'
                                  : 'Disconnected',
                              style: TextStyle(
                                color: _isConnected ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Last Response: $_lastMessage',
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Accelerometer Data Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Real Accelerometer Data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _sensorValueBox('X', _xValue.toStringAsFixed(3)),
                            _sensorValueBox('Y', _yValue.toStringAsFixed(3)),
                            _sensorValueBox('Z', _zValue.toStringAsFixed(3)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                
                const SizedBox(height: 16),

                // ✅ Emergency SMS Button
                Center(
                  child: Center(
  child: ElevatedButton(
    onPressed: () {
      List<String> emergencyContacts = ["+919082532164", "+919322741282"]; // Dummy numbers
      String alertMessage = "🚨 Emergency Alert! Please check on me immediately.";

      SMSService.sendEmergencySMS(alertMessage, emergencyContacts);
    },
    child: const Text("Send Emergency SMS"),
  ),
),


                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sensorValueBox(String axis, String value) {
    return Column(
      children: [
        Text(axis, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }
}
