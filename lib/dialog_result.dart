import 'package:flutter/material.dart';

class DialogResult<T> {
  DialogResult({
    this.cancelled = false,
    this.value,
  });

  bool cancelled;

  T? value;
}
