import 'package:flutter/material.dart';

class problemStatementPage extends StatefulWidget {
  const problemStatementPage({super.key});

  @override
  State<problemStatementPage> createState() => _problemStatementPageState();
}

class _problemStatementPageState extends State<problemStatementPage> {
  int? s_index;
  bool is_confirmed = false;

  final List<Map<String, String>> problemStatements = [
    {'Problem Statement': 'Network Issue', 'Status': 'Open'},
    {'Problem Statement': 'Login Failure', 'Status': 'Closed'},
    {'Problem Statement': 'Database Error', 'Status': 'Open'},
    {'Problem Statement': 'API Timeout', 'Status': 'Closed'},
  ];

  void _onCheckboxChanged(int index, bool? value) {
    setState(() {
      s_index = value == true ? index : null;
      is_confirmed = false;
    });
  }

  void _onConfirmCheckboxChanged(bool? value) {
    setState(() {
      is_confirmed = value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Problem Statement Table", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DataTable(
                    dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) => states.contains(WidgetState.selected) ? Colors.orange : null,
                    ),
                    columns: List.generate(5, (index) => DataColumn(label: Text(_getColumnHeader(index), style: AppTextStyles.defaultTextStyle()))),
                    rows: List<DataRow>.generate(
                      problemStatements.length,
                          (index) => DataRow(
                        selected: s_index == index,
                        cells: [
                          DataCell(
                            CustomCheckbox(
                              value: s_index == index,
                              onChanged: problemStatements[index]['Status'] == 'Open'
                                  ? (value) => _onCheckboxChanged(index, value)
                                  : null,
                              isEnabled: problemStatements[index]['Status'] == 'Open',
                            ),
                          ),
                          ..._getDataCells(index),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 65,),
                      CustomCheckbox(
                        value: is_confirmed && s_index != null,
                        onChanged: s_index != null ? _onConfirmCheckboxChanged : null,
                        isEnabled: s_index != null,
                      ),
                      Text("I confirm that the Problem Statement that I have chosen will not be changed.", style: AppTextStyles.defaultTextStyle()),
                    ],
                  ),
                  ElevatedButton(
                    onPressed:
                    s_index != null && is_confirmed
                        ? () => _showConfirmationDialog(context)
                        : null,
                    style:
                    ButtonStyle(
                      backgroundColor:
                      WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) =>
                      states.contains(WidgetState.disabled) ? Colors.grey[300] : (s_index != null && is_confirmed) ? Colors.orange : Colors.white),
                      foregroundColor:
                      WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) =>
                      states.contains(WidgetState.disabled) ? Colors.black : (s_index != null && is_confirmed) ? Colors.white : Colors.black),
                    ),
                    child:
                    Text("Proceed to Confirm", style: AppTextStyles.buttonTextStyle()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getColumnHeader(int index) {
    switch (index) {
      case 0:
        return 'Select';
      case 1:
        return 'S.No';
      case 2:
        return 'PSID';
      case 3:
        return 'Problem Statement';
      case 4:
        return 'Status';
      default:
        return '';
    }
  }

  List<DataCell> _getDataCells(int index) {
    return [
      DataCell(Text((index + 1).toString(), style: AppTextStyles.defaultTextStyle())),
      DataCell(Text('CP-${index + 1}', style: AppTextStyles.defaultTextStyle())),
      DataCell(Text(problemStatements[index]['Problem Statement']!, style: AppTextStyles.defaultTextStyle())),
      DataCell(Text(problemStatements[index]['Status']!, style: AppTextStyles.defaultTextStyle())),
    ];
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.orange,
        title:
        Text("Confirmed", style: AppTextStyles.confirmationTextStyle().copyWith(color: Colors.white)),
        content:
        Text("Your selection has been confirmed.", style:
        AppTextStyles.confirmationTextStyle().copyWith(color: Colors.white)),
        actions:
        [
          TextButton(
            onPressed:
                () => Navigator.of(context).pop(),
            child:
            Text("OK", style:
            AppTextStyles.confirmationTextStyle().copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class AppTextStyles {
  static TextStyle defaultTextStyle({Color color = Colors.black}) {
    return TextStyle(color: color, fontSize: 16);
  }

  static TextStyle titleTextStyle() {
    return defaultTextStyle(color: Colors.black).copyWith(fontSize: 20, fontWeight: FontWeight.bold);
  }

  static TextStyle buttonTextStyle() {
    return defaultTextStyle(color: Colors.white).copyWith(fontSize: 16);
  }

  static TextStyle confirmationTextStyle() {
    return defaultTextStyle(color: Colors.black).copyWith(fontSize: 16);
  }
}

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final bool isEnabled;

  const CustomCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      activeColor: Colors.orangeAccent,
      onChanged: isEnabled ? onChanged : null,
      visualDensity: VisualDensity.compact,
    );
  }
}