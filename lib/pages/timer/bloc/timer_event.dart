part of 'timer_bloc.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object> get props => [];
}

class TimerStarted extends TimerEvent {
  const TimerStarted({
    required this.duration,
    required this.positionPoint,
    required this.distance,
    required this.list,
  });
  final int duration;
  final List<LatLng> positionPoint;
  final double distance;
  final List<List<LatLng>> list;
}

class TimerPaused extends TimerEvent {
  const TimerPaused();
}

class TimerResumed extends TimerEvent {
  const TimerResumed();
}

class TimerReset extends TimerEvent {
  const TimerReset();
}

class TimerComplete extends TimerEvent {
  const TimerComplete();
}

class TimerTicked extends TimerEvent {
  const TimerTicked({required this.duration});
  final int duration;

  @override
  List<Object> get props => [duration];
}

class TimerPositionPoint extends TimerEvent {
  const TimerPositionPoint({required this.positionPoint});
  final List<LatLng> positionPoint;

  @override
  List<Object> get props => [positionPoint];
}

class TimerDistance extends TimerEvent {
  const TimerDistance({required this.distance});
  final double distance;

  @override
  List<Object> get props => [distance];
}

class TimerList extends TimerEvent {
  const TimerList({required this.list});
  final List<List<LatLng>> list;

  @override
  List<Object> get props => [list];
}
