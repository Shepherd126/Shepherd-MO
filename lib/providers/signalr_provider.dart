import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:signalr_core/signalr_core.dart';

class SignalRService with ChangeNotifier {
  // Hub connection instance
  late HubConnection hubConnection;
  final List<String> notifications = [];
  final List<String> kanbanUpdates = [];

  // SignalR states
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  SignalRService() {
    String url = dotenv.env['SIGNALR_URL'] ?? '';
    // Initialize the SignalR connection
    hubConnection = HubConnectionBuilder()
        .withUrl(
          url,
          HttpConnectionOptions(
            logging: (level, message) =>
                print("SignalR Log [$level]: $message"),
          ),
        )
        .withAutomaticReconnect()
        .build();

    // Set timeouts
    hubConnection.serverTimeoutInMilliseconds = 60000; // 60 seconds
    hubConnection.keepAliveIntervalInMilliseconds = 15000; // 15 seconds

    // Configure connection lifecycle events
    configureConnectionEvents();
  }

  // Starts the SignalR connection
  Future<void> startConnection() async {
    try {
      if (hubConnection.state == HubConnectionState.connected) {
        print('SignalR is already connected.');
        return;
      }

      print('Starting SignalR connection...');
      await hubConnection.start();
      _isConnected = true;
      notifyListeners();
      print('SignalR Connected.');

      // Setup listeners after successful connection
      setupListeners();
    } catch (e, stackTrace) {
      _isConnected = false;
      print('Error connecting to SignalR: $e');
      print('StackTrace: $stackTrace');

      // Retry connection manually if automatic reconnect fails
      Future.delayed(Duration(seconds: 5), () {
        print('Retrying SignalR connection...');
        startConnection();
      });
    }
  }

  // Stops the SignalR connection
  Future<void> stopConnection() async {
    if (hubConnection.state == HubConnectionState.disconnected) {
      print('SignalR is already disconnected.');
      return;
    }

    try {
      await hubConnection.stop();
      _isConnected = false;
      notifyListeners();
      print('SignalR Disconnected.');
    } catch (e) {
      print('Error stopping SignalR connection: $e');
    }
  }

  // Setup event listeners for SignalR
  void setupListeners() {
    // Listener for notifications
    hubConnection.on('LoadNotifications', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final notification = arguments[0] as String?;
        if (notification != null) {
          notifications.add(notification);
          notifyListeners();
          print('New Notification: $notification');
        }
      }
    });

    // Listener for Kanban updates
    hubConnection.on('LoadTasks', (arguments) {
      print('Kanban Update:');

      if (arguments != null && arguments.isNotEmpty) {
        final update = arguments[0] as String?;
        if (update != null) {
          kanbanUpdates.add(update);
          notifyListeners();
          print('Kanban Update: $update');
        }
      }
    });
  }

  // Configure lifecycle events for the connection
  void configureConnectionEvents() {
    hubConnection.onclose((error) {
      _isConnected = false;
      notifyListeners();
      print('Connection closed: $error');
      // Attempt to reconnect
      Future.delayed(Duration(seconds: 5), () {
        print('Reconnecting SignalR...');
        startConnection();
      });
    });

    hubConnection.onreconnecting((error) {
      _isConnected = false;
      notifyListeners();
      print('Reconnecting to SignalR: $error');
    });

    hubConnection.onreconnected((connectionId) {
      _isConnected = true;
      notifyListeners();
      print('Reconnected to SignalR with connectionId: $connectionId');
    });
  }
}
