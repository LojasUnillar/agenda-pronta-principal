import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Serviço responsável por verificar se há uma nova versão do app no banco de dados
/// e exibir um dialog para o usuário atualizar.
class UpdateService {
  final SupabaseClient supabase;

  UpdateService(this.supabase);

  /// Verifica se há atualização. Retorna `true` se o app foi bloqueado por uma atualização obrigatória.
  Future<bool> checkForUpdates(BuildContext context) async {
    try {
      // 1. Pega a versão instalada atualmente
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;

      // 2. Busca a última versão no Supabase
      final response = await supabase
          .from('app_versions')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return false;

      final String latestVersion = response['version_number'] as String;
      final String downloadUrl = response['download_url'] as String;
      final String? releaseNotes = response['release_notes'] as String?;
      final bool isMandatory = response['is_mandatory'] as bool? ?? false;

      // 3. Compara as versões (lógica simples de comparação de strings 'x.y.z')
      if (_isUpdateAvailable(currentVersion, latestVersion)) {
        if (!context.mounted) return false;

        // 4. Mostra o alerta
        return await _showUpdateDialog(
          context: context,
          latestVersion: latestVersion,
          downloadUrl: downloadUrl,
          releaseNotes: releaseNotes,
          isMandatory: isMandatory,
        );
      }
      return false;
    } catch (e) {
      debugPrint("Erro ao verificar atualizações: $e");
      return false; // Se der erro na rede ou banco, deixa a pessoa usar o app normal
    }
  }

  /// Mostra a caixa de diálogo de atualização
  Future<bool> _showUpdateDialog({
    required BuildContext context,
    required String latestVersion,
    required String downloadUrl,
    String? releaseNotes,
    required bool isMandatory,
  }) async {
    bool blockApp = false;

    await showDialog(
      context: context,
      barrierDismissible:
          !isMandatory, // Não deixa fechar clicando fora se for obrigatório
      builder: (context) {
        return PopScope(
          canPop: !isMandatory,
          child: AlertDialog(
            title: const Text("Nova atualização disponível! 🎉"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Versão mais recente: $latestVersion"),
                const SizedBox(height: 8),
                if (releaseNotes != null && releaseNotes.isNotEmpty)
                  Text("Novidades:\n$releaseNotes"),
                const SizedBox(height: 16),
                const Text(
                    "Por favor, instale a nova versão para continuar com a melhor experiência."),
              ],
            ),
            actions: [
              if (!isMandatory)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Depois"),
                ),
              ElevatedButton(
                onPressed: () async {
                  final uri = Uri.parse(downloadUrl);
                  try {
                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                  } catch (e) {
                    debugPrint('Erro ao abrir a URL: $e');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Não foi possível abrir o link para download.')),
                      );
                    }
                  }
                },
                child: const Text("Baixar APK"),
              ),
            ],
          ),
        );
      },
    );

    if (isMandatory) {
      blockApp = true;
    }

    return blockApp;
  }

  /// Função auxiliar para saber se V2 > V1
  bool _isUpdateAvailable(String currentVersion, String latestVersion) {
    List<int> currentParts = currentVersion.split('.').map(int.parse).toList();
    List<int> latestParts = latestVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < currentParts.length && i < latestParts.length; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return latestParts.length > currentParts.length;
  }
}
