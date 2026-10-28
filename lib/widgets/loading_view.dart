// ===== LOADING VIEW - INDIKATOR PROSES =====

import 'package:flutter/material.dart';

/// Widget tampilan loading spinner seragam untuk ViewState.loading
class LoadingView extends StatelessWidget {
  final String message;

  const LoadingView({super.key, this.message = 'Memuat data...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
