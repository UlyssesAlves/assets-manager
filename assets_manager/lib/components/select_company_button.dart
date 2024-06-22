import 'package:assets_manager/model/data_model/company.dart';
import 'package:flutter/material.dart';

class SelectCompanyButton extends StatelessWidget {
  SelectCompanyButton(
    this.company,
    this.onSelectedCompany,
  );

  final Company company;
  final Future<void> Function(String) onSelectedCompany;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        await onSelectedCompany(company.id);
      },
      icon: const Icon(Icons.home),
      label: Text(company.name),
      style: const ButtonStyle(
        alignment: Alignment.centerLeft,
        padding: MaterialStatePropertyAll(EdgeInsets.fromLTRB(24, 32, 24, 32)),
        foregroundColor: MaterialStatePropertyAll(Colors.white),
        backgroundColor: MaterialStatePropertyAll(
          Color.fromARGB(255, 33, 136, 255),
        ),
      ),
    );
  }
}
