import 'dart:async';

import 'package:flutter/material.dart';

class ReportSearchField extends StatefulWidget {
  final Function(String) onSearch;
  final String? initialValue;

  const ReportSearchField({
    super.key,
    required this.onSearch,
    this.initialValue,
  });

  @override
  State<ReportSearchField> createState() => _ReportSearchFieldState();
}

class _ReportSearchFieldState extends State<ReportSearchField> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Search in table...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon:
            _controller.text.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    widget.onSearch('');
                  },
                )
                : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onChanged: _onSearchChanged,
    );
  }
}
