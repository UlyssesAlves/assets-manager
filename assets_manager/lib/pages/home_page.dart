import 'package:assets_manager/components/simple_button_with_icon.dart';
import 'package:assets_manager/constants/spacings.dart';
import 'package:assets_manager/model/data_model/asset.dart';
import 'package:assets_manager/model/data_model/company.dart';
import 'package:assets_manager/model/data_model/location.dart';
import 'package:assets_manager/model/data_model/tree_node.dart';
import 'package:assets_manager/model/search_tree_blue_print.dart';
import 'package:assets_manager/pages/asset_page.dart';
import 'package:assets_manager/services/api_service.dart';
import 'package:assets_manager/services/dialogs_service.dart';
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
    _companiesFuture = apiService.getCompanies(context);
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
                const Center(
                  child: Text(
                    'Erro tentando carregar os assets da empresa selecionada. Por favor, tente novamente.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.red,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      refreshCompanies();
                    });
                  },
                  icon: const Icon(Icons.error),
                  label: const Text('Tentar novamente'),
                )
              ]);
            } else {
              gui.add(Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.blueAccent,
                      size: 70,
                    ),
                    const Text('Carregando empresas. Por favor, aguarde...'),
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
        SimpleButtonWithIcon(
          company.name,
          Image.asset('images/company.png'),
          () async {
            await onSelectedCompany(company);
          },
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        ),
        const SizedBox(height: kVerticalListSpacing),
      ]);
    }

    return companiesList;
  }

  Future<void> onSelectedCompany(Company company) async {
    try {
      DialogsService dialogsService = DialogsService(context);

      Map<String, Asset> companyAssetsMap = {};
      Map<String, Location> companyLocationsMap = {};
      Map<String, TreeNode> leafNodes = {};
      TreeNode? assetTree;

      await dialogsService.awaitProcessToExecute(() async {
        companyAssetsMap =
            await apiService.getCompanyAssets(company.id, context);

        companyLocationsMap =
            await apiService.getCompanyLocations(company.id, context);

        TreeBuilder assetsTreeBuilder = TreeBuilder(
          SearchTreeBluePrint(companyAssetsMap, companyLocationsMap),
        );

        assetTree = assetsTreeBuilder.buildTree();

        leafNodes = assetsTreeBuilder.leafNodes;
      }, 'Carregando Assets da Empresa');

      print('Finished loading assets.');

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AssetPage(assetTree!, company.name,
              companyAssetsMap, companyLocationsMap, leafNodes),
        ),
      );
    } catch (e) {
      // TODO: show error to end user and ask him to try again.
      print('Error trying load assets page for selected company.');
      print(e);

      await Alert(
              context: context,
              type: AlertType.error,
              desc:
                  'Erro tentando carregar os assets da empresa selecionada. Por favor, tente novamente.')
          .show();
    }
  }
}
