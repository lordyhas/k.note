
import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';

enum NavigationScreen{home, explorer, setting, myspace}

class NavigationController extends Cubit<NavigationScreen> {
  NavigationController() : super(NavigationScreen.home);
  final _stackState = _Stack<NavigationScreen>();

  void setState(NavigationScreen screenState) {
    _stackState.push(screenState);
    emit(_stackState.peek);
  }

  NavigationScreen get currentScreen => _stackState.peek;

  void back() => _stackState.pop();

}

class _Stack<E extends NavigationScreen> {
  final _queue = Queue<E>();

  void push(E value) => _queue.addFirst(value);
  E pop() => _queue.removeFirst();

  E get peek => _queue.first;

  bool get isEmpty => _queue.isEmpty;
  bool get isNotEmpty => _queue.isNotEmpty;

  @override
  String toString()  => _queue.toString();
}


/*
class BottomNavigationControllerCubit extends Cubit<NavigationScreenState> {
  BottomNavigationControllerCubit() : super(NavigationScreenState.home);

  void changeScreen(NavigationScreenState state) => emit(state);
}

*/