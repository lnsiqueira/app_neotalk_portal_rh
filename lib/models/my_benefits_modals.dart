import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/benefit_model.dart';
import '../theme/app_theme.dart';

/// Modal para Solicitar Reembolso
class RequestReimbursementModal extends StatefulWidget {
  final User user;
  final Benefit benefit;

  const RequestReimbursementModal({
    Key? key,
    required this.user,
    required this.benefit,
  }) : super(key: key);

  @override
  State<RequestReimbursementModal> createState() =>
      _RequestReimbursementModalState();
}

class _RequestReimbursementModalState extends State<RequestReimbursementModal> {
  late TextEditingController _procedureDateController;
  late TextEditingController _descriptionController;
  late TextEditingController _valueController;
  String _documentName = '';
  String _documentPath = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _procedureDateController = TextEditingController();
    _descriptionController = TextEditingController();
    _valueController = TextEditingController();
  }

  @override
  void dispose() {
    _procedureDateController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
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
          ),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _procedureDateController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _selectDocument() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecionar Documento'),
          content: const Text('Escolha o tipo de arquivo:'),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _documentPath = '/documents/recibo_${DateTime.now().millisecondsSinceEpoch}.pdf';
                  _documentName = 'Recibo_${DateTime.now().day}-${DateTime.now().month}.pdf';
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
                  _documentPath = '/documents/nota_${DateTime.now().millisecondsSinceEpoch}.jpg';
                  _documentName = 'Nota_Fiscal_${DateTime.now().day}-${DateTime.now().month}.jpg';
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

  Future<void> _submitReimbursement() async {
    if (_procedureDateController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _valueController.text.isEmpty ||
        _documentPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos os campos são obrigatórios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitação de reembolso enviada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Solicitar Reembolso',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Benefício
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.card_giftcard, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Benefício',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            widget.benefit.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Data do Procedimento
              const Text(
                'Data do Procedimento *',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _procedureDateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'DD/MM/YYYY',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.red),
                    onPressed: _selectDate,
                  ),
                ),
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),

              // Descrição
              const Text(
                'Descrição do Procedimento *',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Ex: Consulta, Exame, Medicamento',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Valor
              const Text(
                'Valor do Reembolso (R\$) *',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _valueController,
                decoration: InputDecoration(
                  hintText: '0.00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixText: 'R\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              // Documento
              const Text(
                'Documento Comprobatório *',
                style: TextStyle(fontWeight: FontWeight.w600),
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
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Clique para selecionar um documento',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(12),
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
              const SizedBox(height: 24),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitReimbursement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Enviar'),
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

/// Modal para Status de Reembolsos
class ReimbursementStatusModal extends StatelessWidget {
  final User user;

  const ReimbursementStatusModal({Key? key, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dados simulados de reembolsos
    final reimbursements = [
      {
        'id': 'RMB001',
        'date': '15/02/2024',
        'value': 'R\$ 250,00',
        'status': 'Aprovado',
        'description': 'Consulta Médica',
      },
      {
        'id': 'RMB002',
        'date': '10/02/2024',
        'value': 'R\$ 150,00',
        'status': 'Pendente',
        'description': 'Exame de Sangue',
      },
      {
        'id': 'RMB003',
        'date': '05/02/2024',
        'value': 'R\$ 500,00',
        'status': 'Processando',
        'description': 'Medicamento',
      },
      {
        'id': 'RMB004',
        'date': '28/01/2024',
        'value': 'R\$ 300,00',
        'status': 'Aprovado',
        'description': 'Fisioterapia',
      },
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Status de Reembolsos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Lista de reembolsos
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reimbursements.length,
                itemBuilder: (context, index) {
                  final reimbursement = reimbursements[index];
                  final statusColor = _getStatusColor(reimbursement['status']!);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reimbursement['description']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'ID: ${reimbursement['id']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                reimbursement['status']!,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              reimbursement['date']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              reimbursement['value']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Aprovado':
        return Colors.green;
      case 'Pendente':
        return Colors.orange;
      case 'Processando':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

/// Modal para Histórico de Uso
class UsageHistoryModal extends StatelessWidget {
  final User user;

  const UsageHistoryModal({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dados simulados de histórico
    final usageHistory = [
      {
        'date': '20/02/2024',
        'type': 'Consulta',
        'provider': 'Clínica São José',
        'value': 'R\$ 150,00',
        'icon': Icons.medical_services,
      },
      {
        'date': '18/02/2024',
        'type': 'Exame',
        'provider': 'Laboratório Central',
        'value': 'R\$ 200,00',
        'icon': Icons.science,
      },
      {
        'date': '15/02/2024',
        'type': 'Atendimento PS',
        'provider': 'Hospital Municipal',
        'value': 'R\$ 500,00',
        'icon': Icons.local_hospital,
      },
      {
        'date': '10/02/2024',
        'type': 'Consulta',
        'provider': 'Consultório Dr. Silva',
        'value': 'R\$ 150,00',
        'icon': Icons.medical_services,
      },
      {
        'date': '05/02/2024',
        'type': 'Exame',
        'provider': 'Laboratório Central',
        'value': 'R\$ 100,00',
        'icon': Icons.science,
      },
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Histórico de Uso',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Lista de histórico
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: usageHistory.length,
                itemBuilder: (context, index) {
                  final usage = usageHistory[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            usage['icon'] as IconData,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                usage['type'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                usage['provider'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                usage['date'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          usage['value'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modal para Carteirinha Virtual
class VirtualCardModal extends StatelessWidget {
  final User user;

  const VirtualCardModal({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Carteirinha Virtual',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Cartão Virtual
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade600, Colors.red.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo Unimed
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'UNIMED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        Icon(
                          Icons.credit_card,
                          color: Colors.white,
                          size: 32,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Número do cartão
                    Text(
                      '1234 5678 9012 3456',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Nome e validade
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TITULAR',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.name.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'VALIDADE',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '12/2026',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Informações do Cartão
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Titular', user.name),
                    const SizedBox(height: 12),
                    _buildInfoRow('CPF', '123.456.789-00'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Número da Carteira', '123456789'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Plano', 'Unimed Empresarial'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Validade', '12/2026'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Carteirinha compartilhada!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Compartilhar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Carteirinha baixada!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Baixar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
