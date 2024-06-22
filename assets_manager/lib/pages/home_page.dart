import 'package:assets_manager/components/select_company_button.dart';
import 'package:assets_manager/constants/spacings.dart';
import 'package:assets_manager/model/data_model/company.dart';
import 'package:assets_manager/services/api_service.dart';
import 'package:assets_manager/services/tree_builder.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Company>>? _companiesFuture;
  Key? _refreshKey;
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();

    refreshCompanies();
  }

  void refreshCompanies() {
    _companiesFuture = apiService.getCompanies();
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
              gui.add(Center(
                child: Column(
                  children: [
                    LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.blueAccent,
                      size: 70,
                    ),
                    const Text('Loading companies. Please wait...'),
                  ],
                ),
              ));
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

  List<Widget> buildCompaniesList(List<Company> companies) {
    var companiesList = <Widget>[];

    for (var company in companies) {
      companiesList.addAll([
        SelectCompanyButton(company, onSelectedCompany),
        const SizedBox(height: kVerticalListSpacing),
      ]);
    }

    return companiesList;
  }

  Future<void> onSelectedCompany(String companyId) async {
    try {
      Alert(
        context: context,
        title: 'Loading Assets',
        style: const AlertStyle(
          isCloseButton: false,
          isOverlayTapDismiss: false,
          isButtonVisible: false,
        ),
        content: Center(
          child: Column(
            children: [
              LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.blueGrey,
                size: 70,
              ),
              const Text('Please wait.'),
            ],
          ),
        ),
        onWillPopActive: true,
      ).show();

      var companyAssets = await apiService.getCompanyAssets(companyId);

      var companyLocations = await apiService.getCompanyLocations(companyId);

      TreeBuilder treeBuilder = TreeBuilder(companyAssets, companyLocations);

      final tree = treeBuilder.buildTree();

      Navigator.pop(context);

      // TODO: open assets screen.
    } catch (e) {
      // TODO: show error to end user and ask him to try again.
      print('Error trying load assets page for selected company.');
      print(e);

      await Alert(
              context: context,
              type: AlertType.error,
              desc:
                  'Error trying to load the selected company. Please, try again later.')
          .show();
    }
  }
}
