import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../ticker.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  TimerBloc({required Ticker ticker})
      : _ticker = ticker,
        super(const TimerInitial(_duration, _positionPoint, _distance)) {
    on<TimerStarted>(_onStarted);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerReset>(_onReset);
    on<TimerTicked>(_onTicked);
    on<TimerPositionPoint>(_onPositionPoint);
    on<TimerDistance>(_onDistance);
    // on<TimerRunComplete>(_onComplete);
  }

  final Ticker _ticker;
  static const int _duration = 0;
  static const List<LatLng> _positionPoint = [];
  static const double _distance = 0;

  StreamSubscription<int>? _tickerSubscription;
  StreamSubscription<Position>? _positionStream;
  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    // timeLimit: Duration(seconds: 2)
    distanceFilter: 5,
  );
  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    _positionStream?.cancel();
    return super.close();
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    emit(TimerRunInProgress(
        event.duration, event.positionPoint, event.distance));
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
      if (position == null) return;
      final Distance distance = new Distance();
      if (state.positionPoint.isNotEmpty) {
        final double metdadi = distance.as(
            LengthUnit.Meter,
            state.positionPoint.last,
            LatLng(
                position.latitude.toDouble(), position.longitude.toDouble()));
        add(TimerDistance(distance: state.distance + metdadi));
      }
      LatLng newpoint =
          LatLng(position.latitude.toDouble(), position.longitude.toDouble());
      print(state.positionPoint);
      add(TimerPositionPoint(
          positionPoint: [...state.positionPoint, newpoint]));
    });
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state is TimerRunInProgress) {
      _tickerSubscription?.pause();
      _positionStream?.pause();
      emit(TimerRunPause(state.duration, state.positionPoint, state.distance));
    }
  }

  void _onResumed(TimerResumed resume, Emitter<TimerState> emit) {
    if (state is TimerRunPause) {
      _tickerSubscription?.resume();
      _positionStream?.resume();
      emit(TimerRunInProgress(
          state.duration, state.positionPoint, state.distance));
    }
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    _positionStream?.cancel();
    emit(const TimerInitial(_duration, _positionPoint, _distance));
  }

  // void _onComplete(TimerReset event, Emitter<TimerState> emit) {
  //   _tickerSubscription?.cancel();
  //   _positionStream?.cancel();
  //   emit(TimerRunComplete(state.duration, state.positionPoint, state.point));
  // }

  void _onTicked(TimerTicked event, Emitter<TimerState> emit) {
    emit(TimerRunInProgress(
        event.duration, state.positionPoint, state.distance));
  }

  void _onPositionPoint(TimerPositionPoint event, Emitter<TimerState> emit) {
    emit(TimerRunInProgress(
        state.duration, event.positionPoint, state.distance));
  }

  void _onDistance(TimerDistance event, Emitter<TimerState> emit) {
    emit(TimerRunInProgress(
        state.duration, state.positionPoint, event.distance));
  }
}
