// Файл lib/screens/admin/orders_list.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Добавьте в pubspec.yaml, если еще не добавлено
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../constants/text_styles.dart';
import '../../models/order.dart'; // Создадим этот файл

class OrdersList extends StatefulWidget {
  const OrdersList({Key? key}) : super(key: key);

  @override
  State<OrdersList> createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList> {
  bool _isLoading = true;
  List<Order> _orders = [];
  String _selectedStatus = ''; // Фильтр по статусу

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    // В реальном приложении здесь будет запрос к API или базе данных
    await Future.delayed(const Duration(seconds: 1)); // Имитация загрузки
    
    // Демо-данные для тестирования
    setState(() {
      _orders = [
        Order(
          id: '1001',
          userId: 'user123',
          userName: 'Алибек Сериков',
          status: 'pending',
          totalAmount: 24990,
          orderDate: DateTime.now().subtract(const Duration(days: 2)),
          items: [
            OrderItem(
              productId: '1',
              productName: 'Qazaq Republic Classic футболка',
              quantity: 2,
              price: 7990,
              selectedSize: 'M',
              selectedColor: 'Қара',
            ),
            OrderItem(
              productId: '2',
              productName: 'Qazaq Republic Худи',
              quantity: 1,
              price: 8990,
              selectedSize: 'L',
              selectedColor: 'Сұр',
            ),
          ],
          address: 'Алматы, ул. Абая 150, кв. 25',
          phone: '+7 (777) 123-45-67',
        ),
        Order(
          id: '1002',
          userId: 'user456',
          userName: 'Айгуль Нурпеисова',
          status: 'processing',
          totalAmount: 11990,
          orderDate: DateTime.now().subtract(const Duration(days: 1)),
          items: [
            OrderItem(
              productId: '3',
              productName: 'Qazaq Republic Жейде',
              quantity: 1,
              price: 11990,
              selectedSize: 'S',
              selectedColor: 'Ақ',
            ),
          ],
          address: 'Нур-Султан, ул. Кунаева 10, кв. 45',
          phone: '+7 (707) 765-43-21',
        ),
        Order(
          id: '1003',
          userId: 'user789',
          userName: 'Марат Искаков',
          status: 'shipped',
          totalAmount: 31980,
          orderDate: DateTime.now().subtract(const Duration(days: 5)),
          items: [
            OrderItem(
              productId: '1',
              productName: 'Qazaq Republic Classic футболка',
              quantity: 4,
              price: 7990,
              selectedSize: 'XL',
              selectedColor: 'Қара',
            ),
          ],
          address: 'Шымкент, ул. Жибек Жолы, 78',
          phone: '+7 (700) 555-11-22',
        ),
        Order(
          id: '1004',
          userId: 'user101',
          userName: 'Дарья Ким',
          status: 'delivered',
          totalAmount: 14990,
          orderDate: DateTime.now().subtract(const Duration(days: 10)),
          items: [
            OrderItem(
              productId: '2',
              productName: 'Qazaq Republic Худи',
              quantity: 1,
              price: 14990,
              selectedSize: 'M',
              selectedColor: 'Көк',
            ),
          ],
          address: 'Алматы, ул. Тимирязева 42, кв. 15',
          phone: '+7 (705) 999-88-77',
        ),
        Order(
          id: '1005',
          userId: 'user202',
          userName: 'Ержан Сагинтаев',
          status: 'cancelled',
          totalAmount: 23970,
          orderDate: DateTime.now().subtract(const Duration(days: 3)),
          items: [
            OrderItem(
              productId: '1',
              productName: 'Qazaq Republic Classic футболка',
              quantity: 3,
              price: 7990,
              selectedSize: 'L',
              selectedColor: 'Ақ',
            ),
          ],
          address: 'Актау, 14-й микрорайон, д. 42, кв. 12',
          phone: '+7 (775) 123-00-99',
        ),
      ];
      _isLoading = false;
    });
  }

  // Фильтрация заказов по статусу
  List<Order> _getFilteredOrders() {
    if (_selectedStatus.isEmpty) {
      return _orders;
    }
    return _orders.where((order) => order.status == _selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _getFilteredOrders();
    
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Статистика и фильтры
                _buildHeader(),
                
                // Список заказов
                Expanded(
                  child: filteredOrders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 80,
                                color: AppColors.textSecondary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Заказы не найдены',
                                style: AppTextStyles.heading3,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Попробуйте изменить параметры фильтрации',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            return _buildOrderCard(filteredOrders[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  // Шапка с статистикой и фильтрами
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок и кнопка обновления
          Row(
            children: [
              Text(
                'Управление заказами',
                style: AppTextStyles.heading2,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Обновить список',
                onPressed: _loadOrders,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Статистика заказов
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.pending_actions,
                    value: _orders.where((o) => o.status == 'pending').length.toString(),
                    label: 'Ожидает',
                    color: Colors.amber,
                  ),
                  _buildStatItem(
                    icon: Icons.loop,
                    value: _orders.where((o) => o.status == 'processing').length.toString(),
                    label: 'В обработке',
                    color: Colors.blue,
                  ),
                  _buildStatItem(
                    icon: Icons.local_shipping,
                    value: _orders.where((o) => o.status == 'shipped').length.toString(),
                    label: 'Отправлено',
                    color: Colors.purple,
                  ),
                  _buildStatItem(
                    icon: Icons.check_circle,
                    value: _orders.where((o) => o.status == 'delivered').length.toString(),
                    label: 'Доставлено',
                    color: Colors.green,
                  ),
                  _buildStatItem(
                    icon: Icons.cancel,
                    value: _orders.where((o) => o.status == 'cancelled').length.toString(),
                    label: 'Отменено',
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Фильтр по статусу
          Row(
            children: [
              const Text(
                'Фильтр по статусу:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                hint: const Text('Все заказы'),
                value: _selectedStatus.isNotEmpty ? _selectedStatus : null,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value ?? '';
                  });
                },
                items: [
                  const DropdownMenuItem<String>(
                    value: '',
                    child: Text('Все заказы'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'pending',
                    child: Text('Ожидает'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'processing',
                    child: Text('В обработке'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'shipped',
                    child: Text('Отправлено'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'delivered',
                    child: Text('Доставлено'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'cancelled',
                    child: Text('Отменено'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Карточка заказа
  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            // Индикатор статуса
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getStatusColor(order.status),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            
            // Номер заказа и дата
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Заказ №${order.id}',
                  style: AppTextStyles.heading4,
                ),
                Text(
                  DateFormat('dd.MM.yyyy HH:mm').format(order.orderDate),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Клиент
              Text(
                'Клиент: ${order.userName}',
                style: AppTextStyles.bodyMedium,
              ),
              
              // Сумма заказа
              Text(
                '${order.totalAmount} ${AppStrings.currency}',
                style: AppTextStyles.price,
              ),
            ],
          ),
        ),
        trailing: _buildStatusBadge(order.status),
        children: [
          // Развернутая информация о заказе
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Разделитель
                const Divider(),
                const SizedBox(height: 8),
                
                // Товары заказа
                Text(
                  'Товары в заказе:',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Список товаров
                ...order.items.map((item) => _buildOrderItemRow(item)),
                
                const SizedBox(height: 16),
                
                // Адрес доставки
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Адрес доставки:',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            order.address,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Телефон
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Телефон: ${order.phone}',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Кнопки действий
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Кнопка изменения статуса
                    OutlinedButton.icon(
                      icon: const Icon(Icons.edit_note),
                      label: const Text('Изменить статус'),
                      onPressed: () => _showStatusChangeDialog(order),
                    ),
                    const SizedBox(width: 8),
                    
                    // Кнопка печати заказа
                    OutlinedButton.icon(
                      icon: const Icon(Icons.print),
                      label: const Text('Печать'),
                      onPressed: () {
                        // Логика печати заказа
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Функция печати в разработке'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Строка с товаром заказа
  Widget _buildOrderItemRow(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Маркер списка
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8, right: 8),
            decoration: const BoxDecoration(
              color: AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
          
          // Информация о товаре
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: AppTextStyles.bodyMedium,
                ),
                Text(
                  '${item.quantity} шт. × ${item.price} ${AppStrings.currency} = ${item.quantity * item.price} ${AppStrings.currency}',
                  style: AppTextStyles.bodySmall,
                ),
                Text(
                  'Размер: ${item.selectedSize}, Цвет: ${item.selectedColor}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Диалог изменения статуса заказа
  void _showStatusChangeDialog(Order order) {
    String newStatus = order.status;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Изменить статус заказа №${order.id}'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Радио-кнопки статусов
                RadioListTile<String>(
                  title: const Text('Ожидает'),
                  value: 'pending',
                  groupValue: newStatus,
                  onChanged: (value) {
                    setState(() => newStatus = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('В обработке'),
                  value: 'processing',
                  groupValue: newStatus,
                  onChanged: (value) {
                    setState(() => newStatus = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Отправлено'),
                  value: 'shipped',
                  groupValue: newStatus,
                  onChanged: (value) {
                    setState(() => newStatus = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Доставлено'),
                  value: 'delivered',
                  groupValue: newStatus,
                  onChanged: (value) {
                    setState(() => newStatus = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Отменено'),
                  value: 'cancelled',
                  groupValue: newStatus,
                  onChanged: (value) {
                    setState(() => newStatus = value!);
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              // Обновление статуса заказа
              setState(() {
                final index = _orders.indexWhere((o) => o.id == order.id);
                if (index != -1) {
                  _orders[index] = Order(
                    id: order.id,
                    userId: order.userId,
                    userName: order.userName,
                    status: newStatus,
                    totalAmount: order.totalAmount,
                    orderDate: order.orderDate,
                    items: order.items,
                    address: order.address,
                    phone: order.phone,
                  );
                }
              });
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Статус заказа №${order.id} изменен'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  // Получение цвета для статуса заказа
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.amber;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Бейдж статуса заказа
  Widget _buildStatusBadge(String status) {
    String statusText;
    Color color;
    
    switch (status) {
      case 'pending':
        statusText = 'Ожидает';
        color = Colors.amber;
        break;
      case 'processing':
        statusText = 'В обработке';
        color = Colors.blue;
        break;
      case 'shipped':
        statusText = 'Отправлено';
        color = Colors.purple;
        break;
      case 'delivered':
        statusText = 'Доставлено';
        color = Colors.green;
        break;
      case 'cancelled':
        statusText = 'Отменено';
        color = Colors.red;
        break;
      default:
        statusText = 'Неизвестно';
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Элемент статистики
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.heading4,
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}