import 'package:flutter/material.dart';
import '../models/benefit_management_model.dart';
import '../services/benefit_management_service.dart';
import '../theme/app_theme.dart';

class BenefitFormScreen extends StatefulWidget {
  final CorporateBenefit? benefit;

  const BenefitFormScreen({Key? key, this.benefit}) : super(key: key);

  @override
  State<BenefitFormScreen> createState() => _BenefitFormScreenState();
}

class _BenefitFormScreenState extends State<BenefitFormScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _whatIsIncludedController;
  late TextEditingController _eligibilityController;
  late TextEditingController _companyCostController;
  late TextEditingController _employeeCostController;
  late TextEditingController _dependentCostController;
  late TextEditingController _coparticipationController;

  // Novos controllers para Elegibilidade
  late TextEditingController _minCompanyTimeController;
  late TextEditingController _maxDependentAgeController;
  late TextEditingController _maxBudgetPerEmployeeController;

  String _selectedCategory = 'Saúde';
  String _selectedType = 'Fixo';
  String _selectedPeriodicity = 'Mensal';
  String _selectedStatus = 'Ativo';
  bool _allowsDependents = false;
  bool _isRequired = false;
  String? _policyPdfUrl;

  // Novos campos para Elegibilidade
  String _selectedPosition = '';
  String _selectedCostCenter = 'TI';
  String _selectedContractType = 'CLT';
  String _selectedSalaryRange = 'Até 3.000';
  String _selectedLocality = 'São Paulo';
  String _selectedEmployeeStatus = 'Ativo';
  int _limitDependents = 3;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if (widget.benefit != null) {
      _nameController = TextEditingController(text: widget.benefit!.name);
      _descriptionController = TextEditingController(
        text: widget.benefit!.description,
      );
      _whatIsIncludedController = TextEditingController(
        text: widget.benefit!.whatIsIncluded,
      );
      _eligibilityController = TextEditingController(
        text: widget.benefit!.eligibility,
      );
      _companyCostController = TextEditingController(
        text: widget.benefit!.companyCost.toStringAsFixed(2),
      );
      _employeeCostController = TextEditingController(
        text: widget.benefit!.employeeCost.toStringAsFixed(2),
      );
      _dependentCostController = TextEditingController(
        text: widget.benefit!.dependentCost.toStringAsFixed(2),
      );
      _coparticipationController = TextEditingController(
        text: widget.benefit!.coparticipationPercentage.toStringAsFixed(1),
      );

      _selectedCategory = widget.benefit!.category;
      _selectedType = widget.benefit!.type;
      _selectedPeriodicity = widget.benefit!.periodicity;
      _selectedStatus = widget.benefit!.status;
      _allowsDependents = widget.benefit!.allowsDependents;
      _isRequired = widget.benefit!.isRequired;
      _policyPdfUrl = widget.benefit!.policyPdfUrl;
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _whatIsIncludedController = TextEditingController();
      _eligibilityController = TextEditingController();
      _companyCostController = TextEditingController();
      _employeeCostController = TextEditingController();
      _dependentCostController = TextEditingController();
      _coparticipationController = TextEditingController();
    }

    // Inicializar controllers de Elegibilidade
    _minCompanyTimeController = TextEditingController(text: '0');
    _maxDependentAgeController = TextEditingController(text: '25');
    _maxBudgetPerEmployeeController = TextEditingController(text: '5000.00');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _whatIsIncludedController.dispose();
    _eligibilityController.dispose();
    _companyCostController.dispose();
    _employeeCostController.dispose();
    _dependentCostController.dispose();
    _coparticipationController.dispose();
    _minCompanyTimeController.dispose();
    _maxDependentAgeController.dispose();
    _maxBudgetPerEmployeeController.dispose();
    super.dispose();
  }

  // Converter string com vírgula ou ponto para double
  double _parseDouble(String value) {
    if (value.isEmpty) return 0.0;
    return double.parse(value.replaceAll(',', '.'));
  }

  Future<void> _saveBenefit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final benefit = CorporateBenefit(
        id: widget.benefit?.id ?? '',
        name: _nameController.text,
        category: _selectedCategory,
        type: _selectedType,
        description: _descriptionController.text,
        whatIsIncluded: _whatIsIncludedController.text,
        eligibility: _eligibilityController.text,
        allowsDependents: _allowsDependents,
        companyCost: _parseDouble(_companyCostController.text),
        employeeCost: _parseDouble(_employeeCostController.text),
        dependentCost: _parseDouble(_dependentCostController.text),
        coparticipationPercentage: _parseDouble(
          _coparticipationController.text,
        ),
        periodicity: _selectedPeriodicity,
        isRequired: _isRequired,
        policyPdfUrl: _policyPdfUrl,
        status: _selectedStatus,
        createdAt: widget.benefit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.benefit == null) {
        await BenefitManagementService.addBenefit(benefit);
      } else {
        await BenefitManagementService.updateBenefit(
          widget.benefit!.id,
          benefit,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.benefit == null
                  ? 'Benefício criado com sucesso'
                  : 'Benefício atualizado com sucesso',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Erro ao salvar benefício: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.benefit == null ? 'Novo Benefício' : 'Editar Benefício',
        ),
        backgroundColor: AppTheme.primaryRed,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informações Básicas
              Text(
                'Informações Básicas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Nome
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome do Benefício *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Categoria e Tipo
              if (isMobile)
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Categoria *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: BenefitManagementService.getCategories().map((
                        category,
                      ) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value ?? 'Saúde';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: 'Tipo *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: BenefitManagementService.getTypes().map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value ?? 'Fixo';
                        });
                      },
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Categoria *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: BenefitManagementService.getCategories().map((
                          category,
                        ) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value ?? 'Saúde';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          labelText: 'Tipo *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: BenefitManagementService.getTypes().map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value ?? 'Fixo';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // Descrição
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // O que está incluído
              TextFormField(
                controller: _whatIsIncludedController,
                decoration: InputDecoration(
                  labelText: 'O que está incluído',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Critérios de Elegibilidade (descrição geral)
              TextFormField(
                controller: _eligibilityController,
                decoration: InputDecoration(
                  labelText: 'Critérios de Elegibilidade',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Configurações
              Text(
                'Configurações',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              CheckboxListTile(
                title: const Text('Permite Dependentes'),
                value: _allowsDependents,
                onChanged: (value) {
                  setState(() {
                    _allowsDependents = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 8),

              CheckboxListTile(
                title: const Text('Benefício Obrigatório'),
                value: _isRequired,
                onChanged: (value) {
                  setState(() {
                    _isRequired = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Custos
              Text('Custos', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),

              if (isMobile)
                Column(
                  children: [
                    TextFormField(
                      controller: _companyCostController,
                      decoration: InputDecoration(
                        labelText: 'Custo Empresa (R\$) *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: '0.00',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Campo obrigatório';
                        }
                        if (double.tryParse(value!.replaceAll(',', '.')) ==
                            null) {
                          return 'Valor inválido (use . ou ,)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _employeeCostController,
                      decoration: InputDecoration(
                        labelText: 'Custo Colaborador (R\$) *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: '0.00',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Campo obrigatório';
                        }
                        if (double.tryParse(value!.replaceAll(',', '.')) ==
                            null) {
                          return 'Valor inválido (use . ou ,)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dependentCostController,
                      decoration: InputDecoration(
                        labelText: 'Custo por Dependente (R\$)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: '0.00',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (double.tryParse(value.replaceAll(',', '.')) ==
                              null) {
                            return 'Valor inválido';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _coparticipationController,
                      decoration: InputDecoration(
                        labelText: 'Coparticipação (%)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: '0.0',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (double.tryParse(value.replaceAll(',', '.')) ==
                              null) {
                            return 'Valor inválido';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _companyCostController,
                        decoration: InputDecoration(
                          labelText: 'Custo Empresa (R\$) *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: '0.00',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Campo obrigatório';
                          }
                          if (double.tryParse(value!.replaceAll(',', '.')) ==
                              null) {
                            return 'Valor inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _employeeCostController,
                        decoration: InputDecoration(
                          labelText: 'Custo Colaborador (R\$) *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: '0.00',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Campo obrigatório';
                          }
                          if (double.tryParse(value!.replaceAll(',', '.')) ==
                              null) {
                            return 'Valor inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _dependentCostController,
                        decoration: InputDecoration(
                          labelText: 'Custo Dependente (R\$)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: '0.00',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (double.tryParse(value.replaceAll(',', '.')) ==
                                null) {
                              return 'Valor inválido';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              if (!isMobile)
                TextFormField(
                  controller: _coparticipationController,
                  decoration: InputDecoration(
                    labelText: 'Coparticipação (%)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: '0.0',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value.replaceAll(',', '.')) == null) {
                        return 'Valor inválido';
                      }
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 24),

              // ✅ NOVA SEÇÃO: ELEGIBILIDADE
              Text(
                'Elegibilidade',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Tempo mínimo de empresa e Cargo
              if (isMobile)
                Column(
                  children: [
                    TextFormField(
                      controller: _minCompanyTimeController,
                      decoration: InputDecoration(
                        labelText: 'Tempo Mínimo de Empresa (meses)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today),
                        hintText: '0',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedPosition.isEmpty
                          ? 'Todos'
                          : _selectedPosition,
                      decoration: InputDecoration(
                        labelText: 'Cargo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.work),
                      ),
                      items:
                          [
                                'Todos',
                                'Gerente',
                                'Coordenador',
                                'Analista',
                                'Assistente',
                              ]
                              .map(
                                (position) => DropdownMenuItem(
                                  value: position,
                                  child: Text(position),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPosition = value ?? 'Todos';
                        });
                      },
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minCompanyTimeController,
                        decoration: InputDecoration(
                          labelText: 'Tempo Mínimo de Empresa (meses)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                          hintText: '0',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPosition.isEmpty
                            ? 'Todos'
                            : _selectedPosition,
                        decoration: InputDecoration(
                          labelText: 'Cargo',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.work),
                        ),
                        items:
                            [
                                  'Todos',
                                  'Gerente',
                                  'Coordenador',
                                  'Analista',
                                  'Assistente',
                                ]
                                .map(
                                  (position) => DropdownMenuItem(
                                    value: position,
                                    child: Text(position),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPosition = value ?? 'Todos';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // Centro de Custo e Tipo de Contrato
              if (isMobile)
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedCostCenter,
                      decoration: InputDecoration(
                        labelText: 'Centro de Custo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      items:
                          [
                                'TI',
                                'RH',
                                'Comercial',
                                'Suprimentos',
                                'Administrativo',
                              ]
                              .map(
                                (center) => DropdownMenuItem(
                                  value: center,
                                  child: Text(center),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCostCenter = value ?? 'TI';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedContractType,
                      decoration: InputDecoration(
                        labelText: 'Tipo de Contrato',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      items: ['CLT', 'PJ', 'Estágio', 'Terceirizado']
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedContractType = value ?? 'CLT';
                        });
                      },
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCostCenter,
                        decoration: InputDecoration(
                          labelText: 'Centro de Custo',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.attach_money),
                        ),
                        items:
                            [
                                  'TI',
                                  'RH',
                                  'Comercial',
                                  'Suprimentos',
                                  'Administrativo',
                                ]
                                .map(
                                  (center) => DropdownMenuItem(
                                    value: center,
                                    child: Text(center),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCostCenter = value ?? 'TI';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedContractType,
                        decoration: InputDecoration(
                          labelText: 'Tipo de Contrato',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.description),
                        ),
                        items: ['CLT', 'PJ', 'Estágio', 'Terceirizado']
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedContractType = value ?? 'CLT';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // Faixa Salarial e Localidade
              if (isMobile)
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedSalaryRange,
                      decoration: InputDecoration(
                        labelText: 'Faixa Salarial',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.monetization_on),
                      ),
                      items:
                          [
                                'Até 3.000',
                                '3.000 - 5.000',
                                '5.000 - 10.000',
                                'Acima de 10.000',
                              ]
                              .map(
                                (range) => DropdownMenuItem(
                                  value: range,
                                  child: Text(range),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSalaryRange = value ?? 'Até 3.000';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedLocality,
                      decoration: InputDecoration(
                        labelText: 'Localidade',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                      items:
                          [
                                'São Paulo',
                                'Rio de Janeiro',
                                'Belo Horizonte',
                                'Curitiba',
                                'Brasília',
                              ]
                              .map(
                                (locality) => DropdownMenuItem(
                                  value: locality,
                                  child: Text(locality),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLocality = value ?? 'São Paulo';
                        });
                      },
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSalaryRange,
                        decoration: InputDecoration(
                          labelText: 'Faixa Salarial',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.monetization_on),
                        ),
                        items:
                            [
                                  'Até 3.000',
                                  '3.000 - 5.000',
                                  '5.000 - 10.000',
                                  'Acima de 10.000',
                                ]
                                .map(
                                  (range) => DropdownMenuItem(
                                    value: range,
                                    child: Text(range),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSalaryRange = value ?? 'Até 3.000';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedLocality,
                        decoration: InputDecoration(
                          labelText: 'Localidade',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.location_on),
                        ),
                        items:
                            [
                                  'São Paulo',
                                  'Rio de Janeiro',
                                  'Belo Horizonte',
                                  'Curitiba',
                                  'Brasília',
                                ]
                                .map(
                                  (locality) => DropdownMenuItem(
                                    value: locality,
                                    child: Text(locality),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLocality = value ?? 'São Paulo';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // Status do Colaborador
              DropdownButtonFormField<String>(
                value: _selectedEmployeeStatus,
                decoration: InputDecoration(
                  labelText: 'Status do Colaborador',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.verified_user),
                ),
                items: ['Ativo', 'Afastado', 'Desligado']
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEmployeeStatus = value ?? 'Ativo';
                  });
                },
              ),
              const SizedBox(height: 16),

              // Limite de Dependentes e Idade Máxima Dependente
              if (isMobile)
                Column(
                  children: [
                    TextFormField(
                      initialValue: _limitDependents.toString(),
                      decoration: InputDecoration(
                        labelText: 'Limite de Dependentes',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.people),
                        hintText: '3',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _limitDependents = int.tryParse(value) ?? 3;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _maxDependentAgeController,
                      decoration: InputDecoration(
                        labelText: 'Idade Máxima Dependente (anos)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.cake),
                        hintText: '25',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _limitDependents.toString(),
                        decoration: InputDecoration(
                          labelText: 'Limite de Dependentes',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.people),
                          hintText: '3',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _limitDependents = int.tryParse(value) ?? 3;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _maxDependentAgeController,
                        decoration: InputDecoration(
                          labelText: 'Idade Máxima Dependente (anos)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.cake),
                          hintText: '25',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // Orçamento Máximo por Colaborador
              TextFormField(
                controller: _maxBudgetPerEmployeeController,
                decoration: InputDecoration(
                  labelText: 'Orçamento Máximo por Colaborador (R\$)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                  hintText: '5000.00',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 32),

              // Periodicity e Status
              if (isMobile)
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedPeriodicity,
                      decoration: InputDecoration(
                        labelText: 'Periodicidade *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: BenefitManagementService.getPeriodicities().map((
                        periodicity,
                      ) {
                        return DropdownMenuItem(
                          value: periodicity,
                          child: Text(periodicity),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPeriodicity = value ?? 'Mensal';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Status *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: ['Ativo', 'Inativo']
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value ?? 'Ativo';
                        });
                      },
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPeriodicity,
                        decoration: InputDecoration(
                          labelText: 'Periodicidade *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: BenefitManagementService.getPeriodicities().map((
                          periodicity,
                        ) {
                          return DropdownMenuItem(
                            value: periodicity,
                            child: Text(periodicity),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPeriodicity = value ?? 'Mensal';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Status *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: ['Ativo', 'Inativo']
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value ?? 'Ativo';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),

              // Botões de Ação
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveBenefit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                    ),
                    child: Text(
                      widget.benefit == null ? 'Criar' : 'Atualizar',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import '../models/benefit_management_model.dart';
// import '../services/benefit_management_service.dart';
// import '../theme/app_theme.dart';

// class BenefitFormScreen extends StatefulWidget {
//   final CorporateBenefit? benefit;

//   const BenefitFormScreen({Key? key, this.benefit}) : super(key: key);

//   @override
//   State<BenefitFormScreen> createState() => _BenefitFormScreenState();
// }

// class _BenefitFormScreenState extends State<BenefitFormScreen> {
//   late TextEditingController _nameController;
//   late TextEditingController _descriptionController;
//   late TextEditingController _whatIsIncludedController;
//   late TextEditingController _eligibilityController;
//   late TextEditingController _companyCostController;
//   late TextEditingController _employeeCostController;
//   late TextEditingController _dependentCostController;
//   late TextEditingController _coparticipationController;

//   String _selectedCategory = 'Saúde';
//   String _selectedType = 'Fixo';
//   String _selectedPeriodicity = 'Mensal';
//   String _selectedStatus = 'Ativo';
//   bool _allowsDependents = false;
//   bool _isRequired = false;
//   String? _policyPdfUrl;

//   final _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();

//     if (widget.benefit != null) {
//       _nameController = TextEditingController(text: widget.benefit!.name);
//       _descriptionController = TextEditingController(
//         text: widget.benefit!.description,
//       );
//       _whatIsIncludedController = TextEditingController(
//         text: widget.benefit!.whatIsIncluded,
//       );
//       _eligibilityController = TextEditingController(
//         text: widget.benefit!.eligibility,
//       );
//       _companyCostController = TextEditingController(
//         text: widget.benefit!.companyCost.toStringAsFixed(2),
//       );
//       _employeeCostController = TextEditingController(
//         text: widget.benefit!.employeeCost.toStringAsFixed(2),
//       );
//       _dependentCostController = TextEditingController(
//         text: widget.benefit!.dependentCost.toStringAsFixed(2),
//       );
//       _coparticipationController = TextEditingController(
//         text: widget.benefit!.coparticipationPercentage.toStringAsFixed(1),
//       );

//       _selectedCategory = widget.benefit!.category;
//       _selectedType = widget.benefit!.type;
//       _selectedPeriodicity = widget.benefit!.periodicity;
//       _selectedStatus = widget.benefit!.status;
//       _allowsDependents = widget.benefit!.allowsDependents;
//       _isRequired = widget.benefit!.isRequired;
//       _policyPdfUrl = widget.benefit!.policyPdfUrl;
//     } else {
//       _nameController = TextEditingController();
//       _descriptionController = TextEditingController();
//       _whatIsIncludedController = TextEditingController();
//       _eligibilityController = TextEditingController();
//       _companyCostController = TextEditingController();
//       _employeeCostController = TextEditingController();
//       _dependentCostController = TextEditingController();
//       _coparticipationController = TextEditingController();
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _descriptionController.dispose();
//     _whatIsIncludedController.dispose();
//     _eligibilityController.dispose();
//     _companyCostController.dispose();
//     _employeeCostController.dispose();
//     _dependentCostController.dispose();
//     _coparticipationController.dispose();
//     super.dispose();
//   }

//   // Converter string com vírgula ou ponto para double
//   double _parseDouble(String value) {
//     if (value.isEmpty) return 0.0;
//     return double.parse(value.replaceAll(',', '.'));
//   }

//   Future<void> _saveBenefit() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     try {
//       final benefit = CorporateBenefit(
//         id: widget.benefit?.id ?? '',
//         name: _nameController.text,
//         category: _selectedCategory,
//         type: _selectedType,
//         description: _descriptionController.text,
//         whatIsIncluded: _whatIsIncludedController.text,
//         eligibility: _eligibilityController.text,
//         allowsDependents: _allowsDependents,
//         companyCost: _parseDouble(_companyCostController.text),
//         employeeCost: _parseDouble(_employeeCostController.text),
//         dependentCost: _parseDouble(_dependentCostController.text),
//         coparticipationPercentage: _parseDouble(
//           _coparticipationController.text,
//         ),
//         periodicity: _selectedPeriodicity,
//         isRequired: _isRequired,
//         policyPdfUrl: _policyPdfUrl,
//         status: _selectedStatus,
//         createdAt: widget.benefit?.createdAt ?? DateTime.now(),
//         updatedAt: DateTime.now(),
//       );

//       if (widget.benefit == null) {
//         await BenefitManagementService.addBenefit(benefit);
//       } else {
//         await BenefitManagementService.updateBenefit(
//           widget.benefit!.id,
//           benefit,
//         );
//       }

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               widget.benefit == null
//                   ? 'Benefício criado com sucesso'
//                   : 'Benefício atualizado com sucesso',
//             ),
//             backgroundColor: Colors.green,
//           ),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       print('Erro ao salvar benefício: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Erro ao salvar: ${e.toString()}'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 5),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isMobile = MediaQuery.of(context).size.width < 768;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.benefit == null ? 'Novo Benefício' : 'Editar Benefício',
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Informações Básicas
//               Text(
//                 'Informações Básicas',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//               const SizedBox(height: 16),

//               // Nome
//               TextFormField(
//                 controller: _nameController,
//                 decoration: InputDecoration(
//                   labelText: 'Nome do Benefício *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) {
//                     return 'Nome é obrigatório';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),

//               // Categoria e Tipo
//               if (isMobile)
//                 Column(
//                   children: [
//                     DropdownButtonFormField<String>(
//                       value: _selectedCategory,
//                       decoration: InputDecoration(
//                         labelText: 'Categoria *',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       items: BenefitManagementService.getCategories().map((
//                         category,
//                       ) {
//                         return DropdownMenuItem(
//                           value: category,
//                           child: Text(category),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedCategory = value ?? 'Saúde';
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     DropdownButtonFormField<String>(
//                       value: _selectedType,
//                       decoration: InputDecoration(
//                         labelText: 'Tipo *',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       items: BenefitManagementService.getTypes().map((type) {
//                         return DropdownMenuItem(value: type, child: Text(type));
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedType = value ?? 'Fixo';
//                         });
//                       },
//                     ),
//                   ],
//                 )
//               else
//                 Row(
//                   children: [
//                     Expanded(
//                       child: DropdownButtonFormField<String>(
//                         value: _selectedCategory,
//                         decoration: InputDecoration(
//                           labelText: 'Categoria *',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         items: BenefitManagementService.getCategories().map((
//                           category,
//                         ) {
//                           return DropdownMenuItem(
//                             value: category,
//                             child: Text(category),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedCategory = value ?? 'Saúde';
//                           });
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: DropdownButtonFormField<String>(
//                         value: _selectedType,
//                         decoration: InputDecoration(
//                           labelText: 'Tipo *',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         items: BenefitManagementService.getTypes().map((type) {
//                           return DropdownMenuItem(
//                             value: type,
//                             child: Text(type),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedType = value ?? 'Fixo';
//                           });
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               const SizedBox(height: 16),

//               // Descrição
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration: InputDecoration(
//                   labelText: 'Descrição *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 maxLines: 3,
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) {
//                     return 'Descrição é obrigatória';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),

//               // O que está incluso
//               TextFormField(
//                 controller: _whatIsIncludedController,
//                 decoration: InputDecoration(
//                   labelText: 'O que está incluso *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   hintText: 'Ex: Consultas, exames, internação',
//                 ),
//                 maxLines: 2,
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) {
//                     return 'Campo obrigatório';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),

//               // Elegibilidade
//               TextFormField(
//                 controller: _eligibilityController,
//                 decoration: InputDecoration(
//                   labelText: 'Elegibilidade *',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   hintText: 'Ex: Após 90 dias, Filhos até 5 anos',
//                 ),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) {
//                     return 'Elegibilidade é obrigatória';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 24),

//               // Dependentes e Obrigatoriedade
//               Text(
//                 'Configurações',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//               const SizedBox(height: 16),

//               // Checkbox 1: Permite Dependentes
//               Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: CheckboxListTile(
//                   title: const Text('Permite dependentes'),
//                   value: _allowsDependents,
//                   activeColor: AppTheme.primaryRed,
//                   checkColor: Colors.white,
//                   onChanged: (value) {
//                     setState(() {
//                       _allowsDependents = value ?? false;
//                     });
//                   },
//                 ),
//               ),
//               const SizedBox(height: 12),

//               // Checkbox 2: Benefício Obrigatório
//               Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: CheckboxListTile(
//                   title: const Text('Benefício obrigatório'),
//                   value: _isRequired,
//                   activeColor: AppTheme.primaryRed,
//                   checkColor: Colors.white,
//                   onChanged: (value) {
//                     setState(() {
//                       _isRequired = value ?? false;
//                     });
//                   },
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Custos
//               Text('Custos', style: Theme.of(context).textTheme.titleLarge),
//               const SizedBox(height: 16),

//               if (isMobile)
//                 Column(
//                   children: [
//                     TextFormField(
//                       controller: _companyCostController,
//                       decoration: InputDecoration(
//                         labelText: 'Custo Empresa (R\$) *',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         hintText: '0.00',
//                       ),
//                       keyboardType: const TextInputType.numberWithOptions(
//                         decimal: true,
//                       ),
//                       validator: (value) {
//                         if (value?.isEmpty ?? true) {
//                           return 'Campo obrigatório';
//                         }
//                         if (double.tryParse(value!.replaceAll(',', '.')) ==
//                             null) {
//                           return 'Valor inválido (use . ou ,)';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _employeeCostController,
//                       decoration: InputDecoration(
//                         labelText: 'Custo Colaborador (R\$) *',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         hintText: '0.00',
//                       ),
//                       keyboardType: const TextInputType.numberWithOptions(
//                         decimal: true,
//                       ),
//                       validator: (value) {
//                         if (value?.isEmpty ?? true) {
//                           return 'Campo obrigatório';
//                         }
//                         if (double.tryParse(value!.replaceAll(',', '.')) ==
//                             null) {
//                           return 'Valor inválido (use . ou ,)';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _dependentCostController,
//                       decoration: InputDecoration(
//                         labelText: 'Custo por Dependente (R\$)',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         hintText: '0.00',
//                       ),
//                       keyboardType: const TextInputType.numberWithOptions(
//                         decimal: true,
//                       ),
//                       validator: (value) {
//                         if (value != null && value.isNotEmpty) {
//                           if (double.tryParse(value.replaceAll(',', '.')) ==
//                               null) {
//                             return 'Valor inválido';
//                           }
//                         }
//                         return null;
//                       },
//                     ),
//                   ],
//                 )
//               else
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         controller: _companyCostController,
//                         decoration: InputDecoration(
//                           labelText: 'Custo Empresa (R\$) *',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           hintText: '0.00',
//                         ),
//                         keyboardType: const TextInputType.numberWithOptions(
//                           decimal: true,
//                         ),
//                         validator: (value) {
//                           if (value?.isEmpty ?? true) {
//                             return 'Campo obrigatório';
//                           }
//                           if (double.tryParse(value!.replaceAll(',', '.')) ==
//                               null) {
//                             return 'Valor inválido';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: TextFormField(
//                         controller: _employeeCostController,
//                         decoration: InputDecoration(
//                           labelText: 'Custo Colaborador (R\$) *',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           hintText: '0.00',
//                         ),
//                         keyboardType: const TextInputType.numberWithOptions(
//                           decimal: true,
//                         ),
//                         validator: (value) {
//                           if (value?.isEmpty ?? true) {
//                             return 'Campo obrigatório';
//                           }
//                           if (double.tryParse(value!.replaceAll(',', '.')) ==
//                               null) {
//                             return 'Valor inválido';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: TextFormField(
//                         controller: _dependentCostController,
//                         decoration: InputDecoration(
//                           labelText: 'Custo Dependente (R\$)',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           hintText: '0.00',
//                         ),
//                         keyboardType: const TextInputType.numberWithOptions(
//                           decimal: true,
//                         ),
//                         validator: (value) {
//                           if (value != null && value.isNotEmpty) {
//                             if (double.tryParse(value.replaceAll(',', '.')) ==
//                                 null) {
//                               return 'Valor inválido';
//                             }
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               const SizedBox(height: 16),

//               // Coparticipação
//               TextFormField(
//                 controller: _coparticipationController,
//                 decoration: InputDecoration(
//                   labelText: 'Coparticipação (%)',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   hintText: '0.0',
//                 ),
//                 keyboardType: const TextInputType.numberWithOptions(
//                   decimal: true,
//                 ),
//                 validator: (value) {
//                   if (value != null && value.isNotEmpty) {
//                     if (double.tryParse(value.replaceAll(',', '.')) == null) {
//                       return 'Valor inválido';
//                     }
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 24),

//               // Periodicidade e Status
//               Text(
//                 'Finalização',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//               const SizedBox(height: 16),

//               if (isMobile)
//                 Column(
//                   children: [
//                     DropdownButtonFormField<String>(
//                       value: _selectedPeriodicity,
//                       decoration: InputDecoration(
//                         labelText: 'Periodicidade *',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       items: BenefitManagementService.getPeriodicities().map((
//                         periodicity,
//                       ) {
//                         return DropdownMenuItem(
//                           value: periodicity,
//                           child: Text(periodicity),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedPeriodicity = value ?? 'Mensal';
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     DropdownButtonFormField<String>(
//                       value: _selectedStatus,
//                       decoration: InputDecoration(
//                         labelText: 'Status *',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       items: const [
//                         DropdownMenuItem(value: 'Ativo', child: Text('Ativo')),
//                         DropdownMenuItem(
//                           value: 'Inativo',
//                           child: Text('Inativo'),
//                         ),
//                       ],
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedStatus = value ?? 'Ativo';
//                         });
//                       },
//                     ),
//                   ],
//                 )
//               else
//                 Row(
//                   children: [
//                     Expanded(
//                       child: DropdownButtonFormField<String>(
//                         value: _selectedPeriodicity,
//                         decoration: InputDecoration(
//                           labelText: 'Periodicidade *',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         items: BenefitManagementService.getPeriodicities().map((
//                           periodicity,
//                         ) {
//                           return DropdownMenuItem(
//                             value: periodicity,
//                             child: Text(periodicity),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedPeriodicity = value ?? 'Mensal';
//                           });
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: DropdownButtonFormField<String>(
//                         value: _selectedStatus,
//                         decoration: InputDecoration(
//                           labelText: 'Status *',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         items: const [
//                           DropdownMenuItem(
//                             value: 'Ativo',
//                             child: Text('Ativo'),
//                           ),
//                           DropdownMenuItem(
//                             value: 'Inativo',
//                             child: Text('Inativo'),
//                           ),
//                         ],
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedStatus = value ?? 'Ativo';
//                           });
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               const SizedBox(height: 24),

//               // Botões
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text(
//                       'Cancelar',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   ElevatedButton(
//                     onPressed: _saveBenefit,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppTheme.primaryRed,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 32,
//                         vertical: 16,
//                       ),
//                     ),
//                     child: Text(widget.benefit == null ? 'Criar' : 'Atualizar'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
