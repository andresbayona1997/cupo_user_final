import 'package:flutter/material.dart';
import 'package:promociones/pages/detail_promotion_page.dart';
import 'package:promociones/utils/options.dart';
import 'package:promociones/utils/widgets/nav_bar.dart';

class SelectProductsPage extends StatefulWidget {
  SelectProductsPage({Key key, this.products, this.promotionCode}) : super(key: key);
  final List products;
  final String promotionCode;

  @override
  _SelectProductsPageState createState() => _SelectProductsPageState();
}

class _SelectProductsPageState extends State<SelectProductsPage> {
  // bool selected = false;
  List products = [];
  List selectedProducts = [];

  @override
  initState() {
    super.initState();
    products = widget.products;
    _cleanCheckBoxes();
  }

  @override
  dispose() {
    super.dispose();
  }

  void _cleanCheckBoxes() {
    products.forEach((product) {
      if (mounted) {
        setState(() {
          product["isSelected"] = false;
        });
      }
    });
  }

  Widget _showListProducts() {
    return ListView.builder(
      padding: EdgeInsets.all(15.0),
      itemCount: products.length,
      itemBuilder: (_, index) {
        products[index].putIfAbsent('isSelected', () => false);
        return new GridTile(
          child: Card(
            child: CheckboxListTile(
              dense: true,
              value: products[index]["isSelected"],
              onChanged: (bool onChanged) {
                setState(() {
                  products[index]["isSelected"] = onChanged; 
                  addToList(products[index], products[index]["isSelected"], index);
                });
              },
              title: Text(products[index]["description"], style: TextStyle(fontSize: 12.0)),
              subtitle: Text(products[index]["presentation"], style: TextStyle(fontSize: 10.0),),
            ),
          )
        );
      },
    );
  }

  void addToList(product, bool isSelected, int index) {
    setState(() {
      if (isSelected) {
        selectedProducts.add(product);
      } else {
        selectedProducts.remove(product);
      }
    });
  }

  void _acceptPromotion() {
    if (selectedProducts.length > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailPromotionPage(promotionCode: widget.promotionCode, products: selectedProducts, listProducts: true,))
      );
    }
  }

  Widget _showBtn() {
    return Positioned(
      bottom: 0.0,
      child: Container(
        padding: EdgeInsets.all(5.0),
        height: 70.0,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.all(6.0),
          child: ButtonTheme(
            minWidth: MediaQuery.of(context).size.width,
            height: 35.0,
            child: RaisedButton(
              onPressed: selectedProducts.length > 0 ? _acceptPromotion : null,
              color: Color.fromRGBO(148, 3, 123, 1.0),
              child: Text('Obtener Promoción', style: TextStyle(color: Colors.white,)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar(title: 'Seleccione los productos',),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromRGBO(148, 3, 123, 1.0), Color.fromRGBO(191, 111, 178, 1.0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter),
        ),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: <Widget>[
            _showListProducts(),
            _showBtn()
          ],
        ),
      ),
    );
  }
}