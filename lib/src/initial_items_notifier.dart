
import 'package:flutter/material.dart';

class InitialItemsNotifier<T> extends ValueNotifier<List<T>?> {
  InitialItemsNotifier() : super(null);

  Object? _error;

  bool _isDisposed = false;

  Object? get error => _error;

  bool get hasError => _error != null;

  bool get isDisposed => _isDisposed;

  void setLoading() {
    value = null;
    _error = null;
    notifyListeners();
  }

  void setData(List<T> items) {
    value = items;
    _error = null;
    notifyListeners();
  }

  void setError(Object error) {
    _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
