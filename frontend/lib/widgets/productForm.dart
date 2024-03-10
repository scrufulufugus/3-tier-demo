import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:frontend/models/product.dart';

class ProductForm extends StatefulWidget {
  const ProductForm({this.product, required this.onSubmit, super.key});
  final Product? product;
  final void Function(BuildContext context, ProductBase product) onSubmit;

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final CurrencyTextInputFormatter _currencyFormat = CurrencyTextInputFormatter(
    symbol: '\$',
  );
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  TextEditingController imageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: nameController..text = widget.product?.title ?? '',
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "Product Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product name';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: descriptionController
                  ..text = widget.product?.description ?? '',
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "Description"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product description';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: priceController
                  ..text =  _currencyFormat.format(((widget.product?.price ?? 0) * 0.01).toStringAsFixed(2)),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[_currencyFormat],
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "Price"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price';
                  }
                  if ((_currencyFormat.getUnformattedValue() * 100).toInt() < 1) {
                    return 'Please enter a price greater than ${currencyFormater.format(0.01)}';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: stockController
                  ..text = widget.product?.stock.toString() ?? '',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "Stock"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the stock';
                  }
                  if (int.parse(value) < 0) {
                    return 'Please enter a stock greater than 0';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: imageController
                  ..text = widget.product?.imageUrl ?? '',
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "Image URL"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the image URL';
                  }
                  bool isUri = Uri.tryParse(value)?.hasAbsolutePath ?? false;
                  if (!isUri) {
                    return 'Please enter a valid URI';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      widget.onSubmit(
                        context,
                        ProductBase(
                          title: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                          price: (_currencyFormat.getUnformattedValue() * 100).toInt(),
                          stock: int.parse(stockController.text.trim()),
                          imageUrl: imageController.text.trim(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill input')),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
