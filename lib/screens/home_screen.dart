import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zy_excel/controllers/excel_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final excelController = Get.put(ExcelController());
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App title
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                  ).createShader(bounds),
                  child: const Text(
                    'ZY Excel',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload, Search, Modify & Export',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withAlpha(130),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 48),

                // Upload area
                Obx(() {
                  final isLoading = excelController.isLoading.value;
                  final hasFile = excelController.excelObs.value != null;

                  return GestureDetector(
                    onTap: isLoading ? null : () => _pickFile(),
                    child: AnimatedBuilder2(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          constraints: const BoxConstraints(maxWidth: 480),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 48),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A2733),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: hasFile
                                  ? colorScheme.primary.withAlpha(120)
                                  : colorScheme.primary.withAlpha(
                                      (40 * _pulseAnimation.value).toInt(),
                                    ),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withAlpha(
                                  hasFile
                                      ? 30
                                      : (15 * _pulseAnimation.value).toInt(),
                                ),
                                blurRadius: 30,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isLoading)
                                SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: CircularProgressIndicator(
                                    color: colorScheme.primary,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              else if (hasFile)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withAlpha(25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 48,
                                    color: colorScheme.primary,
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withAlpha(15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.upload_file_rounded,
                                    size: 48,
                                    color: colorScheme.primary.withAlpha(180),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              Text(
                                hasFile
                                    ? 'File Loaded Successfully'
                                    : 'Upload Excel File',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: hasFile
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (hasFile)
                                Obx(() => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color:
                                            colorScheme.primary.withAlpha(20),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        excelController.fileName.value,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: colorScheme.primary
                                              .withAlpha(200),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))
                              else
                                Text(
                                  'Tap to select .xlsx file from storage',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        colorScheme.onSurface.withAlpha(100),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }),

                const SizedBox(height: 40),

                // Continue button
                Obx(() {
                  final hasFile = excelController.excelObs.value != null;
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: hasFile ? 1.0 : 0.3,
                    child: SizedBox(
                      width: 220,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: hasFile
                            ? () => Navigator.pushNamed(
                                context, '/column-selection')
                            : null,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Continue'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      await excelController.loadExcel();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load file: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

class AnimatedBuilder2 extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder2({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}

