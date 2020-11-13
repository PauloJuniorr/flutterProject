import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  //String cidade;
  String pais;
  String cep;
  var temperatura;
  var tempoDescricao;
  var tempoAgora;
  var umidadeAr;
  var vento;
  var rua;
  var complemento;
  var bairro;
  var cidade;

  Future getCEP() async {
    http.Response response =
        await http.get("https://viacep.com.br/ws/$cep/json/");
    var results = jsonDecode(response.body);

    setState(() {
      this.cidade = results['localidade'];
      this.rua = results['logradouro'];
      this.complemento = results['complemento'];
      this.bairro = results['bairro'];
    });
  }

  Future getWeather() async {
    String getCidade = cidade.toString();
    http.Response response = await http.get(
        "http://api.openweathermap.org/data/2.5/weather?q=$getCidade&Brazil&appid=8b82d8962e2f6d7bf8c6f97d81563d97");
    var results = jsonDecode(response.body);

    setState(() {
      this.temperatura = results['main']['temp'];
      this.tempoDescricao = results['weather'][0]['description'];
      this.tempoAgora = results['weather'][0]['main'];
      this.umidadeAr = results['main']['humidity'];
      this.vento = results['wind']['speed'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Previsão do tempo'),
          backgroundColor: Colors.blue[100],
        ),
        body: new SingleChildScrollView(
          child: new Container(
            margin: new EdgeInsets.all(15.0),
            child: new Form(
              key: _key,
              autovalidate: _validate,
              child: _formUI(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formUI() {
    return new Column(
      children: <Widget>[
        new TextFormField(
          decoration: new InputDecoration(hintText: 'CEP'),
          maxLength: 8,
          validator: _validaCEP,
          onSaved: (String val) {
            cep = val;
          },
        ),
        new SizedBox(height: 15.0),
        new RaisedButton(
          onPressed: _sendForm,
          child: new Text('Enviar'),
        ),
        Container(
          color: Colors.deepPurple[100],
          child: Text(
              tempoDescricao.toString() != null
                  ? 'Clima: ' + tempoDescricao.toString()
                  : "",
              style: TextStyle(
                fontSize: 30,
              )),
        ),
        Container(
          color: Colors.blue[200],
          child: Text(
              temperatura.toString().isNotEmpty != null
                  ? 'Temperatura: ' + temperatura.toString()
                  : "",
              style: TextStyle(
                fontSize: 30,
              )),
        ),
        Container(
          color: Colors.deepPurple[200],
          child: Text(
              umidadeAr.toString() != null
                  ? 'Umidade Ar: ' + umidadeAr.toString()
                  : "",
              style: TextStyle(
                fontSize: 30,
              )),
        ),
        Container(
          color: Colors.deepPurple[200],
          child: Text(rua.toString() != null ? 'Rua: ' + rua.toString() : "",
              style: TextStyle(
                fontSize: 30,
              )),
        ),
        Container(
          color: Colors.deepPurple[200],
          child: Text(
              rua.toString() != null
                  ? 'Complemento: ' + complemento.toString()
                  : "",
              style: TextStyle(
                fontSize: 30,
              )),
        ),
        Container(
          color: Colors.deepPurple[200],
          child: Text(
              bairro.toString() != null ? 'Bairro: ' + bairro.toString() : "",
              style: TextStyle(
                fontSize: 30,
              )),
        ),
      ],
    );
  }

  String _validaCEP(String value) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Informe o CEP";
    } else if (!regExp.hasMatch(value)) {
      return "O CEP deve conter apenas números";
    }
    return null;
  }

  _sendForm() {
    if (_key.currentState.validate()) {
      _key.currentState.save();
      this.getWeather();
      this.getCEP();
    } else {
      setState(() {
        _validate = true;
      });
    }
  }
}
