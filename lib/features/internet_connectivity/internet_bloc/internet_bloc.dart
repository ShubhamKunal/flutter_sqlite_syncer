import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqlite_crud_example/datebase_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'package:sqlite_crud_example/features/internet_connectivity/internet_bloc/internet_event.dart';
import 'package:sqlite_crud_example/features/internet_connectivity/internet_bloc/internet_state.dart';

class InternetBloc extends Bloc<InternetEvent, InternetState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? connectivityListener;
  final temporaryDB = TemporaryDB();
  final permanentDB = PermanentDB();

  Future<int> sendData() async {
    final dataToSend = await temporaryDB.queryAll();

    var url = "http://10.0.2.2:3000/api/people";
    // Hit API and send dataToSend and return status code
    for (var element in dataToSend) {
      var data = {
        "name": element['name'],
        "email": element['email'],
        "age": element['age'],
      };
      try {
        developer.log(data.toString());
        var response = await http.post(Uri.parse(url),
            body: json.encode(data),
            headers: {'Content-Type': 'application/json'});
        developer.log('Response status: ${response.statusCode}');
        developer.log('Response body: ${response.body}');
        if (response.statusCode == 200 || response.statusCode == 201) {
          permanentDB.insert(element);
          temporaryDB.delete(element['id']);
          developer.log('Row moved from temporary to permanent database!');
        }
      } catch (e) {
        developer.log('Error description: ${e.toString()}');
        return 503;
      }
    }

    return 0;
  }

  InternetBloc() : super(InternetInitialState()) {
    on<InternetLostEvent>((event, emit) => emit(InternetLostState()));
    on<InternetGainedEvent>((event, emit) => emit(InternetGainedState()));

    connectivityListener = _connectivity.onConnectivityChanged.listen((event) {
      switch (event) {
        case ConnectivityResult.mobile:
          add(InternetGainedEvent());
          sendData().then((value) {
            if (value == 200) {
              developer.log("All data transfered!");
            } else {
              developer.log(value.toString());
            }
          });
          developer.log("Using Mobile Internet");
          break;
        case ConnectivityResult.wifi:
          add(InternetGainedEvent());
          sendData().then((value) {
            if (value == 200) {
              developer.log("All data transfered!");
            } else {
              developer.log(value.toString());
            }
          });
          developer.log("Using Wifi Internet");
          break;
        default:
          add(InternetLostEvent());
          developer.log("No Internet");
      }
    });
  }
  @override
  Future<void> close() {
    connectivityListener?.cancel();
    return super.close();
  }
}
