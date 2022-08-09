import 'package:flutter/material.dart';
import 'package:promociones/utils/widgets/nav_bar.dart';

class TermsAndConditionsPage extends StatelessWidget {
  final List _items = [
    {
      "name": 'Atributos del dispositivo:',
      "content":
          'información como el sistema operativo, las versiones de hardware y software, el nivel de carga de la batería, la potencia de la señal, el espacio de almacenamiento disponible, el tipo de navegador, los tipos y nombres de aplicaciones y archivos, y los plugins.'
    },
    {
      "name": 'Operaciones del dispositivo:',
      "content":
          'información sobre las operaciones y los comportamientos realizados en el dispositivo, como poner una ventana en primer o segundo plano, o los movimientos del mouse (lo que permite distinguir a humanos de bots).'
    },
    {
      "name": 'Identificadores:',
      "content":
          'identificadores únicos, identificadores de dispositivos e identificadores de otro tipo, como aquellos provenientes de juegos, aplicaciones o cuentas que usas, así como identificadores de dispositivos familiares (u otros identificadores exclusivos de los Productos de las empresas de Cuponix y que se vinculan con la misma cuenta o el mismo dispositivo).'
    },
    {
      "name": 'Señales del dispositivo:',
      "content":
          'señales de Bluetooth e información sobre puntos de acceso a wifi, balizas ("beacons") y torres de telefonía celular cercanos.'
    },
    {
      "name": 'Datos de la configuración del dispositivo:',
      "content":
          'información que nos permites recibir mediante la configuración que activas en tu dispositivo, como el acceso a la ubicación de GPS, la cámara o las fotos.'
    },
    {
      "name": 'Red y conexiones:',
      "content":
          'información, como el nombre del operador de telefonía celular o proveedor de internet, el idioma, la zona horaria, el número de teléfono celular, la dirección IP, la velocidad de la conexión y, en algunos casos, información sobre otros dispositivos que se encuentran cerca o están en tu red, para que podamos hacer cosas como ayudarte, por ejemplo, a transmitir un video del teléfono al televisor.'
    },
    {
      "name": 'Datos de cookies:',
      "content":
          'datos provenientes de las cookies almacenadas en tu dispositivo, incluidos la configuración y los identificadores de cookies. Obtén más información sobre cómo usamos las cookies en la Política de cookies de Cuponix y en la Política de cookies de Cuponix'
    },
  ];

  List<Widget> _buildItems() {
    List<Widget> widgets = [];
    _items.forEach((i) {
      widgets.add(
        Padding(
          padding: EdgeInsets.all(10.0),
          child: RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              style: new TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
              children: [
                new TextSpan(
                  text: i["name"],
                ),
                new TextSpan(
                  text: i["content"],
                  style: TextStyle(
                    color: Colors.grey[900],
                    fontWeight: FontWeight.w300,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar(
        title: 'Terminos y condiciones',
      ),
      body: ListView(
        padding: EdgeInsets.all(12.0),
        children: <Widget>[
          Text(
            'Información de los dispositivos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Como se describe a continuación, recopilamos información de su dispositivo móvil Android IOS, los teléfonos, y otros dispositivos conectados a la web que usas y que se integran con nuestros Productos, y combinamos esta información entre los diferentes dispositivos que empleamos. Por ejemplo, usamos la información que recopilamos sobre cómo usas nuestros Productos en tu teléfono para personalizar mejor el contenido (incluidos los anuncios) o las funciones que ves cuando usas nuestros Productos en otro dispositivo, como tu computadora portátil o tableta, o para medir si realizaste una acción en respuesta a un anuncio que te mostramos en tu teléfono o en otro dispositivo.',
              textAlign: TextAlign.justify,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'La información que obtenemos de estos dispositivos incluye:',
            ),
          ),
          Column(
            children: _buildItems(),
          )
        ],
      ),
    );
  }
}
