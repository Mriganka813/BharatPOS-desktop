import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopos/src/blocs/expense/expense_cubit.dart';
import 'package:shopos/src/config/colors.dart';
import 'package:shopos/src/pages/create_expense.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/services/set_or_change_pin.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/expense_card_horizontal.dart';
import 'package:pin_code_fields/pin_code_fields.dart' as pinCode;

import '../widgets/pin_validation.dart';

class ExpensePage extends StatefulWidget {
  static const String routeName = '/expense';
  const ExpensePage({Key? key}) : super(key: key);

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  late final ExpenseCubit _expenseCubit;
  PinService _pinService = PinService();

  final TextEditingController pinController = TextEditingController();

  ///
  @override
  void initState() {
    super.initState();
    _expenseCubit = ExpenseCubit()..getExpense();
  }

  @override
  void dispose() {
    _expenseCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Expense"),
          centerTitle: true,
        ),
        floatingActionButton: Container(
          margin: const EdgeInsets.only(
            right: 10,
            bottom: 20,
          ),
          child: FloatingActionButton(
            onPressed: () async {
              await Navigator.pushNamed(context, CreateExpensePage.routeName);
              _expenseCubit.getExpense();
            },
            backgroundColor: Colors.green,
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
          child: BlocBuilder<ExpenseCubit, ExpenseState>(
            bloc: _expenseCubit,
            builder: (context, state) {
              if (state is ExpenseListRender) {
                state.expense.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
                return GridView.builder(
                  itemCount: state.expense.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, mainAxisExtent: 227,),
                  itemBuilder: (context, index) {
                    return ExpenseCardHorizontal(
                      expense: state.expense[index],
                      onDelete: () async {
                        var result = true;

                        if (await _pinService.pinStatus() == true) {
                          result = await PinValidation.showPinDialog(context) as bool;
                        }
                        if (result!) {
                          _expenseCubit.deleteExpense(state.expense[index]);
                        }
                      },
                      onEdit: () async {
                        var result = true;

                        if (await _pinService.pinStatus() == true) {
                          result = await PinValidation.showPinDialog(context) as bool;
                        }
                        if (result!) {
                          await Navigator.pushNamed(
                            context,
                            CreateExpensePage.routeName,
                            arguments: state.expense[index].id,
                          );
                          _expenseCubit.getExpense();
                        }
                      },
                    );
                  },
                );
              }
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ColorsConst.primaryColor,
                  ),
                ),
              );
            },
          ),
        ));
  }
}
