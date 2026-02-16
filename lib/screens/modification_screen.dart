import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zy_excel/controllers/excel_controller.dart';

class ModificationScreen extends StatefulWidget {
  const ModificationScreen({super.key});

  @override
  State<ModificationScreen> createState() => _ModificationScreenState();
}

class _ModificationScreenState extends State<ModificationScreen> {
  final excelController = Get.find<ExcelController>();
  final searchTextController = TextEditingController();
  final Map<int, TextEditingController> editControllers = {};

  @override
  void dispose() {
    searchTextController.dispose();
    for (final c in editControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modify Data'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Obx(() {
            final count = excelController.selectedItems.length;
            if (count == 0) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count selected',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Column info bar
            Obx(
              () => Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                color: const Color(0xFF1A2733),
                child: Row(
                  children: [
                    _buildInfoChip(
                      icon: Icons.search_rounded,
                      label:
                          'Search: ${excelController.getHeaderName(excelController.selectedSearchColObs.value)}',
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      icon: Icons.edit_rounded,
                      label:
                          'Modify: ${excelController.getHeaderName(excelController.selectedModifyColObs.value)}',
                      color: colorScheme.secondary,
                    ),
                  ],
                ),
              ),
            ),

            // Search TextField
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: TextField(
                controller: searchTextController,
                onChanged: (value) => excelController.search(value),
                decoration: InputDecoration(
                  hintText:
                      'Search in ${excelController.getHeaderName(excelController.selectedSearchColObs.value)}...',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colorScheme.primary.withAlpha(180),
                  ),
                  suffixIcon: Obx(() {
                    if (excelController.searchQuery.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: colorScheme.onSurface.withAlpha(100),
                      ),
                      onPressed: () {
                        searchTextController.clear();
                        excelController.search('');
                      },
                    );
                  }),
                ),
              ),
            ),

            // Search Results & Selected Items
            Expanded(
              child: Obx(() {
                final results = excelController.searchResults;
                final selected = excelController.selectedItems;

                if (results.isEmpty && selected.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: colorScheme.onSurface.withAlpha(40),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          excelController.searchQuery.value.isEmpty
                              ? 'Start typing to search'
                              : 'No results found',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurface.withAlpha(80),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Search Results section
                    if (results.isNotEmpty) ...[
                      _buildSectionHeader(
                        'Search Results',
                        '${results.length} matches',
                        colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      ...results.map(
                        (item) => _buildSearchResultTile(item, colorScheme),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Selected Items section
                    if (selected.isNotEmpty) ...[
                      _buildSectionHeader(
                        'Selected Items',
                        '${selected.length} items',
                        colorScheme.secondary,
                      ),
                      const SizedBox(height: 8),
                      ...selected.map(
                        (item) => _buildSelectedItemCard(item, colorScheme),
                      ),
                      const SizedBox(height: 100), // space for FAB
                    ],
                  ],
                );
              }),
            ),
          ],
        ),
      ),

      // Save FAB
      floatingActionButton: Obx(() {
        if (excelController.selectedItems.isEmpty) {
          return const SizedBox.shrink();
        }
        return FloatingActionButton.extended(
          onPressed: excelController.isSaving.value ? null : _onSave,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          icon: excelController.isSaving.value
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : const Icon(Icons.save_alt_rounded),
          label: Text(
            excelController.isSaving.value ? 'Saving...' : 'Save & Download',
          ),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: color.withAlpha(130)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultTile(
    Map<String, dynamic> item,
    ColorScheme colorScheme,
  ) {
    final isSelected = item['isSelected'] as bool? ?? false;
    final searchValue = item['searchValue'] as String? ?? '';
    final modifyValue = item['modifyValue'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => excelController.toggleSelectItem(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary.withAlpha(15)
                  : const Color(0xFF1A2733),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary.withAlpha(80)
                    : Colors.white.withAlpha(10),
              ),
            ),
            child: Row(
              children: [
                // Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : Colors.white.withAlpha(50),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: colorScheme.onPrimary,
                        )
                      : null,
                ),
                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        searchValue,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Current value: $modifyValue',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withAlpha(80),
                        ),
                      ),
                    ],
                  ),
                ),

                // Row number
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Row ${item['rowIndex']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface.withAlpha(60),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedItemCard(
    Map<String, dynamic> item,
    ColorScheme colorScheme,
  ) {
    final rowIndex = item['rowIndex'] as int;
    final searchValue = item['searchValue'] as String? ?? '';
    final oldValue = item['modifyValue'] as String? ?? '';

    // Create or reuse a TextEditingController for this row
    if (!editControllers.containsKey(rowIndex)) {
      editControllers[rowIndex] = TextEditingController(
        text: excelController.newValues[rowIndex] ?? oldValue,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2733),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.secondary.withAlpha(50)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    searchValue,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const Spacer(),
                // Remove button
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    editControllers.remove(rowIndex)?.dispose();
                    excelController.removeSelectedItem(rowIndex);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: colorScheme.error.withAlpha(180),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Old value
            Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 14,
                  color: colorScheme.onSurface.withAlpha(60),
                ),
                const SizedBox(width: 6),
                Text(
                  'Old: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withAlpha(80),
                  ),
                ),
                Expanded(
                  child: Text(
                    oldValue.isEmpty ? '(empty)' : oldValue,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withAlpha(120),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // New value input
            TextField(
              controller: editControllers[rowIndex],
              onChanged: (value) =>
                  excelController.updateNewValue(rowIndex, value),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Enter new value...',
                prefixIcon: Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: colorScheme.secondary.withAlpha(150),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    try {
      final savedPath = await excelController.saveChanges();
      if (savedPath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'File saved successfully!\n$savedPath',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Save cancelled')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving file: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
