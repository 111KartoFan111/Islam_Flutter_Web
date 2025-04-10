import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../services/order_service.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../routes.dart';
import 'product_form.dart';
import 'users_list.dart';

class AdminPanel extends StatefulWidget {
  final int initialTab;

  const AdminPanel({
    Key? key,
    this.initialTab = 0,
  }) : super(key: key);

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OrderService _orderService = OrderService();
  List<Order> orders = [];
  bool isLoadingOrders = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => isLoadingOrders = true);
    try {
      orders = await _orderService.getAllOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки заказов: $e')),
      );
    }
    setState(() => isLoadingOrders = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (!authProvider.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Panel')),
        body: const Center(child: Text('Доступно только для администраторов')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Продукты'),
            Tab(text: 'Заказы'),
            Tab(text: 'Пользователи'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductsTab(),
          _buildOrdersTab(),
          _buildUsersTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.addProduct),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildProductsTab() {
    final productProvider = Provider.of<ProductProvider>(context);
    
    return productProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : productProvider.products.isEmpty
            ? const Center(child: Text('Нет продуктов'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: productProvider.products.length,
                itemBuilder: (context, index) {
                  final product = productProvider.products[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: product.imageUrl.isNotEmpty
                          ? Image.network(
                              product.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image_not_supported),
                      title: Text(product.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${product.price} ₸'),
                          Text('В наличии: ${product.stock}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.editProduct,
                                arguments: product,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () => _confirmDeleteProduct(product),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
  }

  Widget _buildOrdersTab() {
    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: isLoadingOrders
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('Нет заказов'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderItem(orders[index]);
                  },
                ),
    );
  }

  Widget _buildOrderItem(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Заказ #${order.id}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Пользователь: ${order.userName}'),
            Text('Дата: ${order.orderDate.toString()}'),
            Text('Сумма: ${order.totalAmount} ₸'),
            Text('Статус: ${order.status}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showOrderDetails(order),
                    child: const Text('Просмотр'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _editOrderStatus(order),
                    child: const Text('Изменить статус'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    return const UsersList();
  }

  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Заказ #${order.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Пользователь: ${order.userName}'),
              Text('Дата: ${order.orderDate}'),
              Text('Сумма: ${order.totalAmount} ₸'),
              Text('Статус: ${order.status}'),
              const Divider(),
              const Text('Товары:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                        '${item.productName} x${item.quantity} - ${item.price} ₸'),
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

  void _editOrderStatus(Order order) async {
    final statusController = TextEditingController(text: order.status);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить статус'),
        content: TextField(
          controller: statusController,
          decoration: const InputDecoration(labelText: 'Новый статус'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _orderService.updateOrderStatus(
                  order.id,
                  statusController.text,
                );
                await _loadOrders();
                if (mounted) Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка: $e')),
                );
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить продукт'),
        content: Text('Вы уверены, что хотите удалить ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final productProvider = Provider.of<ProductProvider>(context, listen: false);
              try {
                await productProvider.deleteProduct(product.id);
                if (mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Продукт удален')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка при удалении: $e')),
                );
              }
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}