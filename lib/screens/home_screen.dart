import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zy_excel/controllers/excel_controller.dart';
import 'package:zy_excel/utils/screen_size.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final excelController = Get.put(ExcelController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Center(
          child: Column(
            spacing: 20,
            children: [
              _buildFilePickerContainer(),

              Obx(
                () => Expanded(
                  child: Row(
                    spacing: 20,
                    children: [
                      Expanded(
                        child: _buildSearchOrModifyColsContainer(
                          title: 'Search Column',
                          map: excelController.searchColsMapObs,
                          selectOrUnselectCol:
                              excelController.selectOrUnselectSearchCol,
                        ),
                      ),

                      Expanded(
                        child: _buildSearchOrModifyColsContainer(
                          title: 'Modify Column',
                          map: excelController.modifyColsMapObs,
                          selectOrUnselectCol:
                              excelController.selectOrUnselectModifyCol,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(onPressed: () {}, child: Text('Continue')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePickerContainer() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => excelController.loadExcel(),
      child: Container(
        width: 500,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.lightBlue.withAlpha(10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blueGrey.withAlpha(50)),
        ),
        child: Center(
          child: Icon(Icons.folder_open, size: 50, color: Colors.lightBlue),
        ),
      ),
    );
  }

  Widget _buildSearchOrModifyColsContainer({
    required String title,
    required Map<String, bool> map,
    required void Function({required String colKey, required bool isSelected})
    selectOrUnselectCol,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.lightBlue.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueGrey.withAlpha(50)),
      ),
      child: Column(
        children: [
          SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 50,
                mainAxisSpacing: 10,
                crossAxisSpacing: 20,
              ),
              itemCount: map.length,
              itemBuilder: (context, index) {
                final columnKey = map.keys.elementAt(index);
                final isSelected = map[columnKey] ?? false;
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    selectOrUnselectCol(
                      colKey: columnKey,
                      isSelected: !isSelected,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blueGrey.withAlpha(50)),
                    ),
                    child: Center(
                      child: Text(
                        columnKey,
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
