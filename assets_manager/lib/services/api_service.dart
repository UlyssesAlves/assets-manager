import 'package:assets_manager/constants/endpoints.dart';
import 'package:assets_manager/model/data_model/asset.dart';
import 'package:assets_manager/model/data_model/company.dart';
import 'package:assets_manager/model/data_model/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  Future<dynamic> getJsonFromEndpoint(String endpoint) async {
    var response = await http.get(Uri.parse(endpoint));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // TODO: show error message to user.
      print('Error trying to get json from application endpoint $endpoint.');
      print('Status code: ${response.statusCode}');
      print(response.body);

      throw Exception('Unable to load data from the server.');
    }
  }

  Future<List<Company>> getCompanies() async {
    dynamic companiesListJson =
        await getJsonFromEndpoint(kCompaniesEndpointUrl);

    var companies = <Company>[];

    for (var companyJson in companiesListJson) {
      companies.add(
        Company(
          companyJson['id'],
          companyJson['name'],
        ),
      );
    }

    return companies;
  }

  Future<List<Asset>> getCompanyAssets(String companyId) async {
    String parameterizedEndpointUrl =
        kCompanyAssetsEndpointUrl.replaceFirst(':companyId', companyId);

    dynamic companyAssetsJson =
        await getJsonFromEndpoint(parameterizedEndpointUrl);

    List<Asset> companyAssets = [];

    for (var assetJson in companyAssetsJson) {
      companyAssets.add(
        Asset(
          assetJson['status'],
          assetJson['id'],
          assetJson['name'],
          assetJson['parentId'],
          assetJson['gatewayId'],
          sensorId: assetJson['sensorId'],
          sensorType: assetJson['sensorType'],
          locationId: assetJson['locationId'],
        ),
      );
    }

    return companyAssets;
  }

  Future<List<Location>> getCompanyLocations(String companyId) async {
    String parameterizedEndpointUrl =
        kCompanyAssetsEndpointUrl.replaceFirst(':companyId', companyId);

    dynamic companyLocationsJson =
        await getJsonFromEndpoint(parameterizedEndpointUrl);

    List<Location> companyLocations = [];

    for (var locationJson in companyLocationsJson) {
      companyLocations.add(Location(
        locationJson['id'],
        locationJson['name'],
        locationJson['parentId'],
      ));
    }

    return companyLocations;
  }
}
