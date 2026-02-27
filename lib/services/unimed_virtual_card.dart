import 'package:flutter/material.dart';
import '../models/user_model.dart';

/// Widget da Carteirinha Virtual Unimed
class UnimedVirtualCard extends StatelessWidget {
  final User user;
  final String? cardNumber;
  final String? cardValidity;
  final String? planName;

  const UnimedVirtualCard({
    Key? key,
    required this.user,
    this.cardNumber = '0 123 123456789012 1',
    this.cardValidity = '11/12/2027',
    this.planName = 'EMPRESARIAL',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Fundo com padrão diagonal
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1B7D3D), // Verde escuro
                    const Color(0xFF2FA84F), // Verde médio
                  ],
                ),
              ),
            ),
            // Padrão diagonal
            CustomPaint(painter: DiagonalPatternPainter(), size: Size.infinite),
            // Conteúdo
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Logo Unimed e Bandeira
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'UNIMED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            planName ?? 'EMPRESARIAL',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      // Bandeira (representada por retângulo)
                      Container(
                        width: 50,
                        height: 32,

                        child: const Center(
                          child: Text(
                            '',
                            style: TextStyle(
                              color: Color(0xFF1B7D3D),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 32),

                  // Número do Cartão
                  Text(
                    cardNumber ?? '0 123 123456789012 1',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Courier',
                    ),
                  ),
                  //const SizedBox(height: 24),

                  // Linha divisória
                  Container(height: 1, color: Colors.white30),
                  const SizedBox(height: 16),

                  // Informações em duas linhas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Coluna esquerda
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCardInfo(
                              'VALIDADE',
                              cardValidity ?? '11/12/2027',
                            ),
                            const SizedBox(height: 12),
                            _buildCardInfo(
                              'TITULAR',
                              user.name.toUpperCase(),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Coluna direita
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // _buildCardInfo('TIPO', '3-EMPRESARIAL'),
                            const SizedBox(height: 12),
                            // _buildCardInfo('PLANO', 'INDIVIDUAL'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  //  const SizedBox(height: 16),

                  // Segunda linha de informações
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildCardInfo('OPERADORA', 'APT-085-000'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: _buildCardInfo('REGISTRO', 'NACIONAL')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildCardInfo('SEQUÊNCIA', '01')),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Terceira linha
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildCardInfo('INÍCIO', '01/01/2024')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildCardInfo('VALIDADE', '31/12/2024')),
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

  Widget _buildCardInfo(String label, String value, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

/// Painter para o padrão diagonal
class DiagonalPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1;

    // Desenha linhas diagonais
    for (double i = -size.height; i < size.width; i += 20) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DiagonalPatternPainter oldDelegate) => false;
}

/// Modal para Carteirinha Virtual Unimed - CORRIGIDO
class UnimedVirtualCardModal extends StatelessWidget {
  final User user;
  final String? cardNumber;
  final String? cardValidity;
  final String? planName;

  const UnimedVirtualCardModal({
    Key? key,
    required this.user,
    this.cardNumber,
    this.cardValidity,
    this.planName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: EdgeInsets.all(isMobile ? 16 : 32),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: isMobile ? double.infinity : 600,
        ),
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

                // Cartão - CORRIGIDO COM ALTURA DEFINIDA
                Container(
                  constraints: const BoxConstraints(
                    minHeight: 220,
                    maxHeight: 280,
                  ),
                  child: UnimedVirtualCard(
                    user: user,
                    cardNumber: cardNumber,
                    cardValidity: cardValidity,
                    planName: planName,
                  ),
                ),
                const SizedBox(height: 24),

                // Informações adicionais
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Informações do Cartão',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Titular', user.name),
                      const SizedBox(height: 8),
                      _buildInfoRow('CPF', '123.456.789-00'),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Número da Carteira',
                        '0 123 123456789012 1',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('Plano', planName ?? 'EMPRESARIAL'),
                      const SizedBox(height: 8),
                      _buildInfoRow('Validade', cardValidity ?? '11/12/2027'),
                      const SizedBox(height: 8),
                      _buildInfoRow('Status', 'Ativo'),
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
                          backgroundColor: const Color(0xFF1B7D3D),
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
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
