import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_detection_demo/controller/steps-controller.dart';

class InstructionsWidget extends ConsumerWidget {
  const InstructionsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(builder: (context, ref, child) {
      final controller = ref.watch(controllerProvider);
      return IntrinsicWidth(
        child: IntrinsicHeight(
          child: Visibility(
            visible: controller.steps != GestureSteps.hasStepTwo,
            child: IntrinsicWidth(
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
                  decoration: BoxDecoration(
                      color: Colors.black54.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Text(
                      controller.steps.instruction!,
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  )),
            ),
          ),
        ),
      );
    });
  }
}
