import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shopos/src/blocs/report/report_cubit.dart';
import 'package:shopos/src/config/colors.dart';
import 'package:shopos/src/models/input/report_input.dart';
import 'package:shopos/src/pages/report_table.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/services/pdf.dart';
import 'package:shopos/src/services/set_or_change_pin.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/custom_date_picker.dart';

import '../services/report.dart';
import '../widgets/pin_validation.dart';

enum ReportType { sale, purchase, expense, stock,estimate, saleReturn }

class ReportsPage extends StatefulWidget {
  static const String routeName = '/reports_page';
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ReportInput _reportInput = ReportInput();
  final _formKey = GlobalKey<FormState>();
  late final PdfService _pdfService;
  late final ReportCubit _reportCubit;
  bool _showLoader = false;
  final TextEditingController pinController = TextEditingController();
  PinService _pinService = PinService();

  ///
  @override
  void initState() {
    super.initState();
    _reportCubit = ReportCubit();
    _pdfService = PdfService();
  }

  ///
  @override
  void dispose() {
    _reportCubit.close();
    super.dispose();
  }

  ///
  void _toggleReportType(ReportType type) {
    setState(() {
      _reportInput.type == type
          ? _reportInput.type = null
          : _reportInput.type = type;
    });
  }

  void _handleReportsView(ReportsView state) async {
    if (state.expenses != null) {
      Navigator.pushNamed(context, ReportTable.routeName,
          arguments: tableArg(
              expenses: state.expenses, type: _reportInput.type.toString()));
    }
    if (state.orders != null) {
      Navigator.pushNamed(context, ReportTable.routeName,
          arguments: tableArg(
              orders: state.orders, type: _reportInput.type.toString()));
    }
    if (state.product != null) {
      Navigator.pushNamed(context, ReportTable.routeName,
          arguments: tableArg(
              products: state.product, type: _reportInput.type.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Reports'),
        centerTitle: true,
      ),
      body: BlocListener<ReportCubit, ReportState>(
        bloc: _reportCubit,
        listener: (context, state) async {
          if (_showLoader) {
            Navigator.pop(context);
          }
          setState(() {
            _showLoader = false;
          });

          /// View
          if (state is ReportsView) {
            _handleReportsView(state);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 500,
                      child: Column(
                        children: [
                          CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            value: _reportInput.type == ReportType.sale,
                            activeColor: ColorsConst.primaryColor,
                            checkboxShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            contentPadding: const EdgeInsets.all(0),
                            onChanged: (value) {
                              _toggleReportType(ReportType.sale);
                            },
                            title: const Text("Sale Report"),
                          ),
                          CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            value: _reportInput.type == ReportType.saleReturn,
                            activeColor: ColorsConst.primaryColor,
                            checkboxShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            contentPadding: const EdgeInsets.all(0),
                            onChanged: (value) {
                              _toggleReportType(ReportType.saleReturn);
                            },
                            title: const Text("Sale Return Report"),
                          ),
                          CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            value: _reportInput.type == ReportType.purchase,
                            activeColor: ColorsConst.primaryColor,
                            checkboxShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (value) {
                              _toggleReportType(ReportType.purchase);
                            },
                            contentPadding: const EdgeInsets.all(0),
                            title: const Text("Purchase Report"),
                          ),
                          CheckboxListTile(
                            contentPadding: const EdgeInsets.all(0),
                            activeColor: ColorsConst.primaryColor,
                            controlAffinity: ListTileControlAffinity.leading,
                            value: _reportInput.type == ReportType.expense,
                            checkboxShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (value) {
                              _toggleReportType(ReportType.expense);
                            },
                            title: const Text("Expense Report"),
                          ),
                          CheckboxListTile(
                            contentPadding: const EdgeInsets.all(0),
                            activeColor: ColorsConst.primaryColor,
                            controlAffinity: ListTileControlAffinity.leading,
                            value: _reportInput.type == ReportType.stock,
                            checkboxShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (value) {
                              _toggleReportType(ReportType.stock);
                            },
                            title: const Text("Stock Report"),
                          ),
                          CheckboxListTile(
                            contentPadding: const EdgeInsets.all(0),
                            activeColor: ColorsConst.primaryColor,
                            controlAffinity: ListTileControlAffinity.leading,
                            value: _reportInput.type == ReportType.estimate,
                            checkboxShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (value) {
                              _toggleReportType(ReportType.estimate);
                            },
                            title: const Text("Estimate Report"),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        CustomDatePicker(
                          label: 'Start date',
                          hintText: 'dd/mm/yyyy',
                          onChanged: (DateTime value) {
                            setState(() {
                              _reportInput.startDate = value;
                            });
                          },
                          onSave: (DateTime? value) {
                            setState(() {
                              _reportInput.startDate = value;
                            });
                          },
                          validator: (DateTime? value) {
                            if (value == null &&
                                _reportInput.type != ReportType.stock) {
                              return 'Please select start date';
                            }
                            return null;
                          },
                          value: _reportInput.startDate,
                        ),
                        const Divider(color: Colors.transparent),
                        CustomDatePicker(
                          hintText: 'dd/mm/yyyy',
                          label: 'End date',
                          onChanged: (DateTime value) {
                            setState(() {
                              _reportInput.endDate = value;
                            });
                          },
                          onSave: (DateTime? value) {
                            setState(() {
                              _reportInput.endDate = value;
                            });
                          },
                          validator: (DateTime? value) {
                            if (value == null &&
                                _reportInput.type != ReportType.stock) {
                              return 'Please select end date';
                            }
                            return null;
                          },
                          value: _reportInput.endDate,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      title: "View",
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          ?.copyWith(color: Colors.white, fontSize: 18),
                      onTap: () {
                        _onSubmit();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_reportInput.type == null) {
        locator<GlobalServices>().errorSnackBar("Please select a report type");
        return;
      }

      bool status = await _pinService.pinStatus();
      bool todayFlag = false;
      String current_date = await ReportService().getCurrentDate();
      //if input date is today's date
      if(current_date.substring(0,10) == _reportInput.startDate.toString().substring(0,10) &&
          current_date.substring(0,10) == _reportInput.endDate.toString().substring(0,10)){
        todayFlag = true;
      }
      if ((!status) || todayFlag) {
        _reportCubit.getReport(_reportInput);
      } else {
        bool checkPin = await PinValidation.showPinDialog(context) as bool;
        // bool? checkPin = await _showPinDialog();
        if (checkPin) {
          _reportCubit.getReport(_reportInput);
        }else{
          return;
        }
      }
    }
  }

}
