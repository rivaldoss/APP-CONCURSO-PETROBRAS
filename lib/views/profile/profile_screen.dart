import 'package:flutter/material.dart';

import '../../models/user_profile.dart';
import '../../services/firebase_bootstrap.dart';
import '../../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = UserService();
  final _nameController = TextEditingController();
  String _cargo = '';
  bool _seeded = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final okName = await _service.updateDisplayName(_nameController.text);
    final okCargo = _cargo.isEmpty ? true : await _service.updateCargoPretendido(_cargo);
    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text((okName && okCargo) ? 'Perfil atualizado.' : 'Não foi possível atualizar.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: StreamBuilder<UserProfile?>(
        stream: _service.watchMe(),
        builder: (context, snapshot) {
          final profile = snapshot.data;

          if (!FirebaseBootstrap.initialized) {
            return ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: const [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Firebase ainda não está configurado.\n'
                      'Quando configurar, seu nome/cargo e ranking ficarão online.',
                    ),
                  ),
                ),
              ],
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting && profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!_seeded && profile != null) {
            _seeded = true;
            _nameController.text = profile.displayName;
            _cargo = profile.cargoPretendido;
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.person, color: cs.onPrimaryContainer),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.displayName ?? 'Usuário',
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text('Score: ${profile?.score ?? 0}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nome no ranking', style: TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _nameController,
                        maxLength: 24,
                        decoration: const InputDecoration(
                          hintText: 'Ex: Ana Silva',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('Cargo Pretendido', style: TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _cargo.isEmpty ? null : _cargo,
                        decoration: const InputDecoration(
                          hintText: 'Selecione',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Técnico de Operação',
                            child: Text('Técnico de Operação'),
                          ),
                          DropdownMenuItem(
                            value: 'Técnico de Manutenção',
                            child: Text('Técnico de Manutenção'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _cargo = v ?? ''),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _saving ? null : _save,
                          child: Text(_saving ? 'Salvando...' : 'Salvar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
