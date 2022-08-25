part of 'timer_bloc.dart';

abstract class TimerState extends Equatable {
  const TimerState(this.duration, this.positionPoint, this.distance);
  final int duration;
  final List<LatLng> positionPoint;
  final double distance;

  @override
  List<Object> get props => [duration, positionPoint, distance];
}

class TimerInitial extends TimerState {
  const TimerInitial(super.duration, super.positionPoint, super.distance);

  @override
  String toString() => 'TimerInitial { duration: $duration }';
}

class TimerRunPause extends TimerState {
  const TimerRunPause(super.duration, super.positionPoint, super.distance);

  @override
  String toString() => 'TimerRunPause { duration: $duration }';
}

class TimerRunInProgress extends TimerState {
  const TimerRunInProgress(super.duration, super.positionPoint, super.distance);

  @override
  String toString() => 'TimerRunInProgress { duration: $duration }';
}

class TimerRunComplete extends TimerState {
  // const TimerRunComplete() : super(0);
  const TimerRunComplete(super.duration, super.positionPoint, super.distance);
  @override
  String toString() => 'TimerRunComplete { duration: $duration }';
}
