import 'package:flutter/material.dart';
import '../services/loader_service.dart';

class GlobalLoaderOverlay extends StatefulWidget {
  final Widget child;

  const GlobalLoaderOverlay({super.key, required this.child});

  @override
  State<GlobalLoaderOverlay> createState() => _GlobalLoaderOverlayState();
}

class _GlobalLoaderOverlayState extends State<GlobalLoaderOverlay> {
  @override
  void initState() {
    super.initState();
    // LoaderService.instance.addListener(_handleLoaderChange);
  }

  @override
  void dispose() {
    // LoaderService.instance.removeListener(_handleLoaderChange);
    super.dispose();
  }

  void _handleLoaderChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (LoaderService.instance.isLoading)
          Container(
            color: Colors.black26,
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (LoaderService.instance.loadingMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(LoaderService.instance.loadingMessage!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
