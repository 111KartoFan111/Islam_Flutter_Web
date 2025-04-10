import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../constants/text_styles.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_button.dart';

class ProductForm extends StatefulWidget {
  final Product? product;

  const ProductForm({
    Key? key,
    this.product,
  }) : super(key: key);

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _sizesController = TextEditingController();
  final _colorsController = TextEditingController();
  final _categoryController = TextEditingController();
  final _stockController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.product != null;
    
    if (_isEdit) {
      // Заполняем форму данными существующего товара
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _imageUrlController.text = widget.product!.imageUrl;
      _sizesController.text = widget.product!.sizes.join(',');
      _colorsController.text = widget.product!.colors.join(',');
      _categoryController.text = widget.product!.category;
      _stockController.text = widget.product!.stock.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _sizesController.dispose();
    _colorsController.dispose();
    _categoryController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEdit ? AppStrings.editProduct : AppStrings.addProduct;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Название товара
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: AppStrings.productName,
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Описание товара
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: AppStrings.productDescription,
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Цена товара
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: AppStrings.productPrice,
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: AppStrings.currency,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  if (double.tryParse(value) == null) {
                    return 'Жарамды баға енгізіңіз';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // URL изображения
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.productImage,
                      prefixIcon: Icon(Icons.image),
                      hintText: 'https://example.com/image.jpg',
                    ),
                    onChanged: (value) {
                      // Обновляем предпросмотр при изменении URL
                      setState(() {});
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.fieldRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Предпросмотр изображения
                  if (_imageUrlController.text.isNotEmpty)
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _imageUrlController.text.startsWith('http')
                          ? Image.network(
                              _imageUrlController.text,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: AppColors.error,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Сурет жүктелмеді',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Text(
                                'URL суретті енгізіңіз',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Размеры
              TextFormField(
                controller: _sizesController,
                decoration: const InputDecoration(
                  labelText: AppStrings.productSizes,
                  prefixIcon: Icon(Icons.straighten),
                  hintText: 'S,M,L,XL,XXL',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Цвета
              TextFormField(
                controller: _colorsController,
                decoration: const InputDecoration(
                  labelText: AppStrings.productColors,
                  prefixIcon: Icon(Icons.color_lens),
                  hintText: 'Қара,Ақ,Сұр',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Категория
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: AppStrings.productCategory,
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Количество в наличии
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: AppStrings.productStock,
                  prefixIcon: Icon(Icons.inventory),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  if (int.tryParse(value) == null) {
                    return 'Жарамды сан енгізіңіз';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Кнопка сохранения
              CustomButton(
                text: _isEdit ? AppStrings.save : AppStrings.addProduct,
                isLoading: _isLoading,
                onPressed: _saveProduct,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      
      final name = _nameController.text;
      final description = _descriptionController.text;
      final price = double.parse(_priceController.text);
      final imageUrl = _imageUrlController.text;
      final sizes = _sizesController.text.split(',')
        .map((size) => size.trim())
        .where((size) => size.isNotEmpty)
        .toList();
      final colors = _colorsController.text.split(',')
        .map((color) => color.trim())
        .where((color) => color.isNotEmpty)
        .toList();
      final category = _categoryController.text;
      final stock = int.parse(_stockController.text);
      
      if (_isEdit) {
        // Обновление существующего товара
        final updatedProduct = widget.product!.copyWith(
          name: name,
          description: description,
          price: price,
          imageUrl: imageUrl,
          sizes: sizes,
          colors: colors,
          category: category,
          stock: stock,
        );
        
        final success = await productProvider.updateProduct(updatedProduct);
        
        if (success && mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.productUpdated)),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(productProvider.error)),
          );
        }
      } else {
        // Добавление нового товара
        final newProduct = Product(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          description: description,
          price: price,
          imageUrl: imageUrl,
          sizes: sizes,
          colors: colors,
          category: category,
          stock: stock,
        );
        
        final success = await productProvider.addProduct(newProduct);
        
        if (success && mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.productAdded)),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(productProvider.error)),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}