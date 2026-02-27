import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/dependent_model.dart';
import '../services/dependent_service.dart';

class DependentFormScreen extends StatefulWidget {
  final User user;
  final Dependent? dependent;

  const DependentFormScreen({Key? key, required this.user, this.dependent})
    : super(key: key);

  @override
  State<DependentFormScreen> createState() => _DependentFormScreenState();
}

class _DependentFormScreenState extends State<DependentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DependentService _service = DependentService();
  late TextEditingController _nameController;
  late TextEditingController _birthDateController;
  late TextEditingController _cpfController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String _selectedRelationship = 'filho';
  String _selectedDocumentType = 'Certidão de Nascimento';
  String _documentPath = '';
  String _documentName = '';
  bool _isLoading = false;

  final List<String> _relationships = [
    'filho',
    'filha',
    'conjuge',
    'pai',
    'mae',
    'irmao',
    'irma',
  ];

  final List<String> _documentTypes = [
    'Certidão de Nascimento',
    'RG',
    'CPF',
    'Passaporte',
    'Outro',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.dependent?.name ?? '');
    _birthDateController = TextEditingController(
      text: widget.dependent?.birthDate ?? '',
    );
    _cpfController = TextEditingController(text: widget.dependent?.cpf ?? '');
    _emailController = TextEditingController(text: '');
    _phoneController = TextEditingController(text: '');
    _selectedRelationship = widget.dependent?.relationship ?? 'filho';
    _selectedDocumentType =
        widget.dependent?.documentType ?? 'Certidão de Nascimento';
    _documentPath = widget.dependent?.documentPath ?? '';
    _documentName = widget.dependent?.documentName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDateController.text.isNotEmpty
          ? DateTime.parse(_birthDateController.text)
          : DateTime.now().subtract(const Duration(days: 365 * 10)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.red,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthDateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _selectDocument() async {
    // Simular seleção de arquivo
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecionar Documento'),
          content: const Text('Selecione o tipo de arquivo:'),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _documentPath =
                      '/documents/certidao_${DateTime.now().millisecondsSinceEpoch}.pdf';
                  _documentName =
                      'Certidão_Nascimento_${_nameController.text}.pdf';
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('PDF'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _documentPath =
                      '/documents/documento_${DateTime.now().millisecondsSinceEpoch}.jpg';
                  _documentName = 'Documento_${_nameController.text}.jpg';
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Imagem'),
            ),
          ],
        );
      },
    );
  }

  String _formatCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'\D'), '');
    if (cpf.length == 11) {
      return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
    }
    return cpf;
  }

  Future<void> _saveDependentForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_documentPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um documento'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.dependent != null) {
        // Atualizar
        final updated = widget.dependent!.copyWith(
          name: _nameController.text,
          relationship: _selectedRelationship,
          birthDate: _birthDateController.text,
          cpf: _formatCPF(_cpfController.text),
          documentType: _selectedDocumentType,
          documentPath: _documentPath,
          documentName: _documentName,
          updatedAt: DateTime.now(),
        );

        final success = await _service.updateDependent(
          widget.user.name,
          widget.dependent!.id,
          updated,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dependente atualizado com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // Criar novo
        final newDependent = Dependent(
          id: _service.generateId(),
          name: _nameController.text,
          relationship: _selectedRelationship,
          birthDate: _birthDateController.text,
          cpf: _formatCPF(_cpfController.text),
          documentType: _selectedDocumentType,
          documentPath: _documentPath,
          documentName: _documentName,
          status: 'Ativo',
        );

        final success = await _service.addDependent(
          widget.user.name,
          newDependent,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dependente adicionado com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.dependent != null ? 'Editar Dependente' : 'Novo Dependente',
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome
              const Text(
                'Nome Completo',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Ex: João Silva Santos',
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

              // Relacionamento
              const Text(
                'Relacionamento',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRelationship,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: _relationships.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(_getRelationshipLabel(value)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedRelationship = newValue);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Data de Nascimento
              const Text(
                'Data de Nascimento',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _birthDateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'YYYY-MM-DD',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    color: Colors.red,
                    onPressed: _selectDate,
                  ),
                ),
                onTap: _selectDate,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Data de nascimento é obrigatória';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // CPF
              const Text(
                'CPF',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cpfController,
                decoration: InputDecoration(
                  hintText: 'XXX.XXX.XXX-XX',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'CPF é obrigatório';
                  }
                  if (value!.replaceAll(RegExp(r'\D'), '').length != 11) {
                    return 'CPF inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const Text(
                'Email',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'email@dominio.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Email é obrigatório';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const Text(
                'Fone',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: '(00) 00000-0000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Telefone é obrigatório';
                  }
                  if (!RegExp(r'^\(\d{2}\) \d{5}-\d{4}$').hasMatch(value!)) {
                    return 'Telefone inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tipo de Documento
              const Text(
                'Tipo de Documento',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedDocumentType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: _documentTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedDocumentType = newValue);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Upload de Documento
              const Text(
                'Documento (Anexo)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    if (_documentName.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Clique para selecionar um documento',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.description, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _documentName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _documentPath,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _documentPath = '';
                                  _documentName = '';
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Material(
                        color: Colors.red.shade50,
                        child: InkWell(
                          onTap: _selectDocument,
                          splashColor: Colors.red.shade100,
                          highlightColor: Colors.red.shade100,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              _documentName.isEmpty
                                  ? 'Selecionar Arquivo'
                                  : 'Alterar Arquivo',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveDependentForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              widget.dependent != null ? 'Atualizar' : 'Criar',
                            ),
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

  String _getRelationshipLabel(String relationship) {
    switch (relationship) {
      case 'filho':
        return 'Filho';
      case 'filha':
        return 'Filha';
      case 'conjuge':
        return 'Cônjuge';
      case 'pai':
        return 'Pai';
      case 'mae':
        return 'Mãe';
      case 'irmao':
        return 'Irmão';
      case 'irma':
        return 'Irmã';
      default:
        return relationship;
    }
  }
}
