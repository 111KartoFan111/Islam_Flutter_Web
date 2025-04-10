import 'package:flutter/material.dart';
import '../../models/order.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({Key? key}) : super(key: key);

  @override
  _AdminOrdersPageState createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  List<Order> orders = []; // This will store your orders
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    // TODO: Implement your order fetching logic here
    // Example:
    // final fetchedOrders = await yourOrderService.getAllOrders();
    // setState(() {
    //   orders = fetchedOrders;
    //   isLoading = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление заказами'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Все заказы',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DataTable(
                      columns: const [
                        DataColumn(label: Text('ID заказа')),
                        DataColumn(label: Text('Пользователь')),
                        DataColumn(label: Text('Дата')),
                        DataColumn(label: Text('Сумма')),
                        DataColumn(label: Text('Статус')),
                        DataColumn(label: Text('Действия')),
                      ],
                      rows: orders.map((order) {
                        return DataRow(
                          cells: [
                            DataCell(Text(order.id)),
                            DataCell(Text(order.userName)),
                            DataCell(Text(order.orderDate.toString())),
                            DataCell(Text('${order.totalAmount} ₽')),
                            DataCell(Text(order.status)),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility),
                                    onPressed: () {
                                      _showOrderDetails(order);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _editOrderStatus(order);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Заказ #${order.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Пользователь: ${order.userName}'),
              Text('Дата: ${order.orderDate}'),
              Text('Статус: ${order.status}'),
              Text('Сумма: ${order.totalAmount} ₽'),
              const Divider(),
              const Text('Товары:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                        '${item.productName} x${item.quantity} - ${item.price} ₽'),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _editOrderStatus(Order order) {
    // TODO: Implement status editing functionality
  }
}