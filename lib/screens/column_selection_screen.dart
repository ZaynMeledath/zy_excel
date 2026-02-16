import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zy_excel/controllers/excel_controller.dart';

class ColumnSelectionScreen extends StatelessWidget {
  const ColumnSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final excelController = Get.find<ExcelController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Columns'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              // Subtitle
              Text(
                'Pick one column to search in and one column to modify',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withAlpha(120),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Two column containers
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 500;
                    if (isNarrow) {
                      return Column(
                        children: [
                          Expanded(
                            child: _buildColumnContainer(
                              context: context,
                              title: 'Search Column',
                              icon: Icons.search_rounded,
                              accentColor: colorScheme.primary,
                              map: excelController.searchColsMapObs,
                              selectedCol: excelController.selectedSearchColObs,
                              headers: excelController.columnHeaders,
                              onSelect:
                                  excelController.selectOrUnselectSearchCol,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _buildColumnContainer(
                              context: context,
                              title: 'Modify Column',
                              icon: Icons.edit_rounded,
                              accentColor: colorScheme.secondary,
                              map: excelController.modifyColsMapObs,
                              selectedCol: excelController.selectedModifyColObs,
                              headers: excelController.columnHeaders,
                              onSelect:
                                  excelController.selectOrUnselectModifyCol,
                            ),
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: _buildColumnContainer(
                            context: context,
                            title: 'Search Column',
                            icon: Icons.search_rounded,
                            accentColor: colorScheme.primary,
                            map: excelController.searchColsMapObs,
                            selectedCol: excelController.selectedSearchColObs,
                            headers: excelController.columnHeaders,
                            onSelect: excelController.selectOrUnselectSearchCol,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildColumnContainer(
                            context: context,
                            title: 'Modify Column',
                            icon: Icons.edit_rounded,
                            accentColor: colorScheme.secondary,
                            map: excelController.modifyColsMapObs,
                            selectedCol: excelController.selectedModifyColObs,
                            headers: excelController.columnHeaders,
                            onSelect: excelController.selectOrUnselectModifyCol,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Continue button
              Obx(() {
                final enabled = excelController.areBothColumnsSelected;
                return SizedBox(
                  width: 220,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: enabled
                        ? () => Navigator.pushNamed(context, '/modification')
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: enabled
                          ? colorScheme.primary
                          : colorScheme.primary.withAlpha(40),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Continue'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColumnContainer({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color accentColor,
    required RxMap<String, bool> map,
    required RxString selectedCol,
    required RxMap<String, String> headers,
    required void Function({required String colKey, required bool isSelected})
    onSelect,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2733),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selectedCol.value.isNotEmpty
                ? accentColor.withAlpha(100)
                : Colors.white.withAlpha(15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Icon(icon, color: accentColor, size: 20),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            if (selectedCol.value.isNotEmpty) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(
                  'Selected: ${headers[selectedCol.value] ?? selectedCol.value} (${selectedCol.value})',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withAlpha(100),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 140,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.5,
                ),
                itemCount: map.length,
                itemBuilder: (context, index) {
                  final colKey = map.keys.elementAt(index);
                  final isSelected = map[colKey] ?? false;
                  final headerName = headers[colKey] ?? colKey;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () =>
                          onSelect(colKey: colKey, isSelected: !isSelected),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? accentColor.withAlpha(30)
                              : Colors.white.withAlpha(8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? accentColor
                                : Colors.white.withAlpha(20),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              colKey,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? accentColor
                                    : colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              headerName,
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected
                                    ? accentColor.withAlpha(180)
                                    : colorScheme.onSurface.withAlpha(80),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
