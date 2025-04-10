import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../constants/text_styles.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';

class CatalogScreen extends StatefulWidget {
  final String? category;

  const CatalogScreen({Key? key, this.category}) : super(key: key);

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSortOption = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      
      // Если передана категория, устанавливаем её как фильтр
      if (widget.category != null && widget.category!.isNotEmpty) {
        productProvider.setSelectedCategory(widget.category!);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.catalog),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppStrings.search,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          productProvider.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                productProvider.setSearchQuery(value);
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Фильтры и сортировка
          _buildFiltersRow(productProvider),
          
          // Список товаров
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : productProvider.products.isEmpty
                    ? const Center(child: Text(AppStrings.noProducts))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: productProvider.products.length,
                        itemBuilder: (context, index) {
                          return ProductCard(
                            product: productProvider.products[index],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersRow(ProductProvider productProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Фильтр по категориям
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: const Text(AppStrings.categories),
                value: productProvider.selectedCategory.isNotEmpty
                    ? productProvider.selectedCategory
                    : null,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: [
                  const DropdownMenuItem<String>(
                    value: '',
                    child: Text(AppStrings.all),
                  ),
                  ...productProvider.categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  productProvider.setSelectedCategory(value ?? '');
                },
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Сортировка
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: const Text(AppStrings.sort),
                value: _selectedSortOption.isNotEmpty ? _selectedSortOption : null,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: const [
                  DropdownMenuItem<String>(
                    value: 'price_asc',
                    child: Text(AppStrings.sortByPriceAsc),
                  ),
                  DropdownMenuItem<String>(
                    value: 'price_desc',
                    child: Text(AppStrings.sortByPriceDesc),
                  ),
                  DropdownMenuItem<String>(
                    value: 'name',
                    child: Text(AppStrings.sortByName),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSortOption = value ?? '';
                    productProvider.setSortBy(_selectedSortOption);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}