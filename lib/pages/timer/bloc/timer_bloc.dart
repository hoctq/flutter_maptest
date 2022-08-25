import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

import '../ticker.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  TimerBloc({required Ticker ticker})
      : _ticker = ticker,
        super(const TimerInitial(_duration, _distance)) {
    on<TimerStarted>(_onStarted);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerReset>(_onReset);
    on<TimerTicked>(_onTicked);
    on<TimerLocate>(_onLocate);
  }

  final Ticker _ticker;
  static const int _duration = 0;
  static const int _distance = 0;

  StreamSubscription<int>? _tickerSubscription;
  StreamSubscription<Position>? _positionStream;
  // LocationSettings locationSettings = const LocationSettings(
  //   accuracy: LocationAccuracy.high,
  //   // timeLimit: Duration(seconds: 2)
  //   // distanceFilter: 100,
  // );
  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    _positionStream?.cancel();
    return super.close();
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    emit(TimerRunInProgress(event.duration, event.distance));
    _tickerSubscription?.cancel();
    _positionStream?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: event.duration)
        .listen((duration) => add(TimerTicked(duration: duration)));
    _positionStream =
        Geolocator.getPositionStream().listen((Position? position) {
      print(position == null
          ? 'Unknown'
          : '${position.latitude.toString()}, ${position.longitude.toString()}');
      add(TimerLocate(distance: state.distance + 2));
    });
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state is TimerRunInProgress) {
      _tickerSubscription?.pause();
      _positionStream?.pause();
      emit(TimerRunPause(state.duration, state.distance));
    }
  }

  void _onResumed(TimerResumed resume, Emitter<TimerState> emit) {
    if (state is TimerRunPause) {
      _tickerSubscription?.resume();
      _positionStream?.resume();
      emit(TimerRunInProgress(state.duration, state.distance));
    }
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    _positionStream?.cancel();
    emit(const TimerInitial(_duration, _distance));
  }

  void _onTicked(TimerTicked event, Emitter<TimerState> emit) {
    emit(TimerRunInProgress(event.duration, state.distance)
        // event.duration > 0
        //     ? TimerRunInProgress(event.duration)
        //     : const TimerRunComplete(),
        );
  }

  void _onLocate(TimerLocate event, Emitter<TimerState> emit) {
    emit(TimerRunInProgress(state.duration, event.distance));
  }
}
