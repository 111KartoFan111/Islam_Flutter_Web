import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../constants/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';
import '../../routes.dart';
import '../../widgets/custom_button.dart';
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
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    
    // Загружаем продукты при открытии страницы
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
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
            Tab(text: AppStrings.users),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Вкладка с товарами
          _buildProductsTab(),
          
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

  Widget _buildProductItem(Product product, ProductProvider productProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение товара
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.imageUrl.startsWith('http')
                ? Image.network(
                    product.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: AppColors.secondary,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  )
                : Image.asset(
                    product.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: AppColors.secondary,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
            ),
            
            const SizedBox(width: 16),
            
            // Информация о товаре
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.heading4,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    '${AppStrings.productCategory}: ${product.category}',
                    style: AppTextStyles.bodySmall,
                  ),
                  
                  Text(
                    '${AppStrings.price}: ${product.price} ${AppStrings.currency}',
                    style: AppTextStyles.bodyMedium,
                  ),
                  
                  Text(
                    '${AppStrings.productStock}: ${product.stock}',
                    style: AppTextStyles.bodySmall,
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
                                builder: (context) => ProductForm(product: product),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(AppStrings.edit),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _confirmDeleteProduct(context, product, productProvider);
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

  void _confirmDeleteProduct(
    BuildContext context,
    Product product,
    ProductProvider productProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteProduct),
        content: Text('${product.name} өнімін жоюды растаңыз?'),
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
              
              final success = await productProvider.deleteProduct(product.id);
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppStrings.productDeleted)),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(productProvider.error)),
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