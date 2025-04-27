import 'package:flutter/material.dart';
import '../services/loader_service.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final Color barrierColor;
  final Color indicatorColor;
  final double opacity;

  const LoadingOverlay({
    super.key,
    required this.child,
    this.barrierColor = Colors.black,
    this.indicatorColor = Colors.white,
    this.opacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        StreamBuilder<bool>(
          stream: LoaderService.instance.loading,
          builder: (context, snapshot) {
            final isLoading = snapshot.data ?? false;
            return Visibility(
              visible: isLoading,
              child: Container(
                color: barrierColor.withOpacity(opacity),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: indicatorColor),
                      if (LoaderService.instance.loadingMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          LoaderService.instance.loadingMessage!,
                          style: TextStyle(color: indicatorColor),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
