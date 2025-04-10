import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../constants/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import '../../routes.dart';
import '../../widgets/custom_button.dart';
import 'orders_list.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    
    // Загружаем заказы при открытии страницы
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).loadOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Проверяем, является ли пользователь администратором
    if (!authProvider.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.adminPanel),
        ),
        body: const Center(
          child: Text('Тек әкімшілер үшін қол жетімді'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.adminPanel),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: AppStrings.products),
            Tab(text: AppStrings.orders),
            Tab(text: AppStrings.users),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Вкладка с товарами
          _buildProductsTab(),
          
          // Вкладка с заказами
          _buildOrdersTab(),
          
          // Вкладка с пользователями
          _buildUsersTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductForm(),
                  ),
                );
              },
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
            ? const Center(child: Text(AppStrings.noProducts))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: productProvider.products.length,
                itemBuilder: (context, index) {
                  final product = productProvider.products[index];
                  return _buildProductItem(product, productProvider);
                },
              );
  }

  Widget _buildOrdersTab() {
    final orderProvider = Provider.of<OrderProvider>(context);
    
    return orderProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : orderProvider.orders.isEmpty
            ? const Center(child: Text(AppStrings.noOrders))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orderProvider.orders.length,
                itemBuilder: (context, index) {
                  final order = orderProvider.orders[index];
                  return _buildOrderItem(order, orderProvider);
                },
              );
  }

  Widget _buildOrderItem(Order order, OrderProvider orderProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Информация о заказе
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppStrings.orderNumber}: ${order.number}',
                    style: AppTextStyles.heading4,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    '${AppStrings.orderDate}: ${DateFormat.yMd().format(order.dateTime)}',
                    style: AppTextStyles.bodySmall,
                  ),
                  
                  Text(
                    '${AppStrings.orderTotal}: ${order.total} ${AppStrings.currency}',
                    style: AppTextStyles.bodyMedium,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Кнопки действий
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderDetailsScreen(order: order),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(AppStrings.view),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _confirmDeleteOrder(context, order, orderProvider);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(AppStrings.delete),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    return const UsersList();
  }

  void _confirmDeleteOrder(
    BuildContext context,
    Order order,
    OrderProvider orderProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteOrder),
        content: Text('${order.number} өнімін жоюды растаңыз?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final success = await orderProvider.deleteOrder(order.id);
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppStrings.orderDeleted)),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(orderProvider.error)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}
