import 'package:assets_manager/constants/endpoints.dart';
import 'package:assets_manager/model/data_model/asset.dart';
import 'package:assets_manager/model/data_model/company.dart';
import 'package:assets_manager/model/data_model/location.dart';
import 'package:assets_manager/services/dialogs_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:internet_connection_checker/internet_connection_checker.dart';

class ApiService {
  Future<dynamic> getJsonFromEndpoint(
      String endpoint, BuildContext context) async {
    bool internetConnectionIsAvailable =
        await InternetConnectionChecker().hasConnection;

    if (!internetConnectionIsAvailable) {
      DialogsService dialogsService = DialogsService(context);

      await dialogsService.showNoConnectionAvailablePopup();

      throw Exception('No internet connection available.');
    }

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

  Future<List<Company>> getCompanies(BuildContext context) async {
    dynamic companiesListJson =
        await getJsonFromEndpoint(kCompaniesEndpointUrl, context);

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

  Future<Map<String, Asset>> getCompanyAssets(
      String companyId, BuildContext context) async {
    String parameterizedEndpointUrl =
        kCompanyAssetsEndpointUrl.replaceFirst(':companyId', companyId);

    dynamic companyAssetsJson =
        await getJsonFromEndpoint(parameterizedEndpointUrl, context);

    Map<String, Asset> companyAssets = {};

    for (var assetJson in companyAssetsJson) {
      String assetId = assetJson['id'];

      companyAssets[assetId] = Asset(
        assetJson['status'],
        assetId,
        assetJson['name'],
        assetJson['parentId'],
        assetJson['gatewayId'],
        sensorId: assetJson['sensorId'],
        sensorType: assetJson['sensorType'],
        locationId: assetJson['locationId'],
      );
    }

    return companyAssets;
  }

  Future<Map<String, Location>> getCompanyLocations(
      String companyId, BuildContext context) async {
    String parameterizedEndpointUrl =
        kCompanyLocationsEndpointUrl.replaceFirst(':companyId', companyId);

    dynamic companyLocationsJson =
        await getJsonFromEndpoint(parameterizedEndpointUrl, context);

    Map<String, Location> companyLocations = {};

    for (var locationJson in companyLocationsJson) {
      final locationId = locationJson['id'];

      companyLocations[locationId] = Location(
        locationId,
        locationJson['name'],
        locationJson['parentId'],
      );
    }

    return companyLocations;
  }
}
