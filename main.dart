import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Market Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StockSearchPage(),
    );
  }
}

class StockSearchPage extends StatefulWidget {
  @override
  _StockSearchPageState createState() => _StockSearchPageState();
}

class _StockSearchPageState extends State<StockSearchPage> {
  TextEditingController _controller = TextEditingController();
  Map<String, dynamic> _stockInfo = {};

  Future<void> _searchStock(String symbol) async {
    String apiKey =
        '66KDWJP2EI10612E'; // Insira sua chave da Alpha Vantage aqui
    String priceUrl =
        'https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$apiKey';
    String intradayUrl =
        'https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=$symbol&interval=60min&apikey=$apiKey';

    var priceResponse = await http.get(Uri.parse(priceUrl));
    var intradayResponse = await http.get(Uri.parse(intradayUrl));

    if (priceResponse.statusCode == 200 && intradayResponse.statusCode == 200) {
      var priceData = json.decode(priceResponse.body);
      var intradayData = json.decode(intradayResponse.body);

      setState(() {
        _stockInfo = {
          'price': priceData['Global Quote'],
          'intraday': intradayData['Time Series (60min)']
        };
      });
    } else {
      setState(() {
        _stockInfo = {'error': 'Erro ao buscar informações da ação'};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesquisa de Ações'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Insira o símbolo da ação',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String symbol = _controller.text;
                _searchStock(symbol);
              },
              child: Text('Pesquisar'),
            ),
            SizedBox(height: 20),
            if (_stockInfo.containsKey('price'))
              Column(
                children: [
                  Text(
                    'Preço atual: \$${_stockInfo['price']['05. price']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  if (_stockInfo.containsKey('intraday'))
                    Text(
                      'Variação das últimas 12 horas: ${_calculateVariation(_stockInfo['intraday'])}%',
                      style: TextStyle(fontSize: 16),
                    ),
                ],
              ),
            if (_stockInfo.containsKey('error'))
              Text(
                _stockInfo['error'],
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }

  String _calculateVariation(Map<String, dynamic> intradayData) {
    // Você pode implementar a lógica para calcular a variação aqui
    // Esta é uma lógica de exemplo
    // Aqui estou considerando a variação entre o primeiro e o último preço na série intraday
    var prices = intradayData.entries.toList();
    var firstPrice = double.parse(prices.last.value['1. open']);
    var lastPrice = double.parse(prices.first.value['4. close']);

    var variation = ((lastPrice - firstPrice) / firstPrice) * 100;
    return variation.toStringAsFixed(2);
  }
}
