import 'package:flutter/material.dart';
import '../services/loader_service.dart';

class LoaderOverlay extends StatelessWidget {
  final Widget child;

  const LoaderOverlay({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        StreamBuilder<bool>(
          stream: LoaderService().loading,
          initialData: false,
          builder: (context, snapshot) {
            if (snapshot.data ?? false) {
              return Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
