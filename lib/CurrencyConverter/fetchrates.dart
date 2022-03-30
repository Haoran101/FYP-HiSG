import 'package:http/http.dart' as http;
import 'package:hi_sg/CurrencyConverter/models/allcurrencies.dart';
import 'package:hi_sg/CurrencyConverter/models/ratesmodel.dart';
import 'package:hi_sg/DataSource/api_key.dart';

Future<RatesModel> fetchrates() async {
  var response = await http.get(Uri.parse(
      'https://openexchangerates.org/api/latest.json?base=USD&app_id=' + OpenExchange_key));
  final result = ratesModelFromJson(response.body);
  return result;
}

Future<Map> fetchcurrencies() async {
  var response = await http.get(Uri.parse(
      'https://openexchangerates.org/api/currencies.json?app_id=' + OpenExchange_key));
  final allCurrencies = allCurrenciesFromJson(response.body);
  return allCurrencies;
}




















String convertSGD(Map exchangeRates, String sgd, String currency) {
  
  String output = (double.parse(sgd) /
          exchangeRates["sgd"] *
          exchangeRates[currency])
      .toStringAsFixed(2)
      .toString();
  return output;
}

String convertany(Map exchangeRates, String amount, String currencybase,
    String currencyfinal) {
  String output = (double.parse(amount) /
          exchangeRates[currencybase] *
          exchangeRates[currencyfinal])
      .toStringAsFixed(2)
      .toString();

  return output;
}
