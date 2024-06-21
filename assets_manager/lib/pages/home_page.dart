import 'dart:convert';

import 'package:assets_manager/components/select_company_button.dart';
import 'package:assets_manager/constants/endpoints.dart';
import 'package:assets_manager/constants/spacings.dart';
import 'package:assets_manager/model/data_model/company.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Company>>? _companiesFuture;
  Key? _refreshKey;

  @override
  void initState() {
    super.initState();

    refreshCompanies();
  }

  void refreshCompanies() {
    _companiesFuture = getCompanies();
    _refreshKey = UniqueKey();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset('images/tractian-logo.png'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: FutureBuilder<List<Company>>(
          key: _refreshKey,
          future: _companiesFuture,
          builder:
              (BuildContext context, AsyncSnapshot<List<Company>> snapshot) {
            List<Widget> gui = [];

            if (snapshot.hasData) {
              gui = buildCompaniesList(snapshot.requireData);
            } else if (snapshot.hasError) {
              // TODO: improve GUI for error state.
              gui.addAll([
                const Text('Error while trying to load companies.'),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      refreshCompanies();
                    });
                  },
                  icon: const Icon(Icons.error),
                  label: const Text('Try again'),
                )
              ]);
            } else {
              // TODO: show progress indicator.
              gui.add(const Text('Loading companies... Please wait.'));
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: gui,
            );
          },
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<List<Company>> getCompanies() async {
    var companies = <Company>[];

    var response = await http.get(Uri.parse(kCompaniesEndpointUrl));

    if (response.statusCode == 200) {
      companies.clear();

      var companiesListJson = jsonDecode(response.body);

      for (var companyJson in companiesListJson) {
        companies.add(
          Company(
            companyJson['id'],
            companyJson['name'],
          ),
        );
      }

      return companies;
    } else {
      // TODO: show error message to user.
      // TODO: display a button that the user can press to try to load the companies list again.
      print('Error trying to get companies from the application endpoint.');
      print('Status code: ${response.statusCode}');
      print(response.body);
      throw Exception('Unable to load companies.');
    }
  }

  List<Widget> buildCompaniesList(List<Company> companies) {
    var companiesList = <Widget>[];

    for (var company in companies) {
      companiesList.addAll([
        SelectCompanyButton(company),
        const SizedBox(height: kVerticalListSpacing),
      ]);
    }

    return companiesList;
  }
}
