import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/contact_model.dart';

/// Card de exibição de um contato/fornecedor na lista.
///
/// Exibe informações resumidas do contato incluindo:
/// - Avatar com inicial ou imagem
/// - Nome e status
/// - CNPJ (se disponível)
/// - Data da última atualização
/// - Tipo de contato
class ContactCard extends StatelessWidget {
  /// Dados do contato a ser exibido
  final ContactModel contact;

  /// Cria um card de contato
  ///
  /// [contact] - Modelo com os dados do contato
  const ContactCard({super.key, required this.contact});

  /// Formata uma data para exibição
  String _formatDate(DateTime? date) {
    if (date == null) return "N/A";
    return DateFormat('dd/MM/yy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Define a cor do status baseado no estado ativo/inativo
    final isActive = contact.status.toLowerCase() == 'ativo';
    final statusColor = isActive ? colors.primary : colors.error;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar do contato
            CircleAvatar(
              radius: 28,
              backgroundColor: isActive
                  ? colors.primary.withValues(alpha: 0.1)
                  : colors.surfaceContainerHighest,
              backgroundImage:
                  (contact.imageUrl != null && contact.imageUrl!.isNotEmpty)
                  ? NetworkImage(contact.imageUrl!)
                  : null,
              child: (contact.imageUrl == null || contact.imageUrl!.isEmpty)
                  ? Text(
                      contact.name.isNotEmpty
                          ? contact.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? colors.primary
                            : colors.onSurfaceVariant,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Informações do contato
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nome do contato
                      Text(
                        contact.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: colors.onSurface,
                        ),
                      ),

                      Row(
                        children: [
                          Text(
                            "Status: ",
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            isActive ? "Ativo" : "Inativo",
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // CNPJ/CPF ou Código de Giro
                  if (contact.cnpj != null && contact.cnpj!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.business_outlined,
                            size: 14,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            contact.cnpj!,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (contact.turnoverCode != null &&
                      contact.turnoverCode!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'Cod. Giro: ${contact.turnoverCode}',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ),

                  // Tipo de contato
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        contact.type,
                        style: TextStyle(fontSize: 12, color: colors.onSurface),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Data da última atualização
                  Text(
                    "Ult. Atualização ${_formatDate(contact.lastUpdate)}",
                    style: TextStyle(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
