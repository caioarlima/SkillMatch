import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skilmatch/Controller/colors.dart';
import 'package:skilmatch/View/tela_Login.dart';

class TelaConfiguracoes extends StatefulWidget {
  const TelaConfiguracoes({super.key});

  @override
  State<TelaConfiguracoes> createState() => _TelaConfiguracoesState();
}

class _TelaConfiguracoesState extends State<TelaConfiguracoes> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  final TextEditingController _senhaController = TextEditingController();

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TelaLogin()),
    );
  }

  Future<void> _solicitarReautenticacao() async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (user.email == null) {
      throw Exception('Usuário não tem email cadastrado');
    }

    _senhaController.clear();

    final senha = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Reautenticação Necessária',
              style: TextStyle(
                color: AppColors.roxo,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Para excluir sua conta, precisamos confirmar sua identidade. Digite sua senha atual:',
                  style: TextStyle(color: AppColors.cinza, fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _senhaController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    labelStyle: TextStyle(color: AppColors.cinza),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.roxo),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.roxo, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.cinza, fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (_senhaController.text.isNotEmpty) {
                    Navigator.pop(context, _senhaController.text);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Por favor, digite sua senha'),
                        backgroundColor: AppColors.roxo,
                      ),
                    );
                  }
                },
                child: Text(
                  'Confirmar',
                  style: TextStyle(
                    color: AppColors.roxo,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    if (senha == null || senha.isEmpty) {
      throw Exception('Senha não fornecida');
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: senha,
    );

    await user.reauthenticateWithCredential(credential);
  }

  Future<void> _excluirConta() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Excluir Conta',
          style: TextStyle(
            color: AppColors.roxo,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Text(
          'Tem certeza que deseja excluir sua conta? Esta ação não pode ser desfeita e todos os seus dados serão perdidos.',
          style: TextStyle(color: AppColors.cinza, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.cinza, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Excluir',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _solicitarReautenticacao();

        try {
          await _firestore.collection('usuarios').doc(user.uid).delete();
        } catch (e) {}

        await user.delete();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TelaLogin()),
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Conta excluída com sucesso'),
              backgroundColor: AppColors.roxo,
              duration: Duration(seconds: 3),
            ),
          );
        });
      } catch (e) {
        String mensagemErro = 'Erro ao excluir conta';
        if (e.toString().contains('requires-recent-login')) {
          mensagemErro =
              'É necessário fazer login novamente antes de excluir a conta';
        } else if (e.toString().contains('wrong-password')) {
          mensagemErro = 'Senha incorreta';
        } else if (e.toString().contains('user-not-found')) {
          mensagemErro = 'Usuário não encontrado';
        } else if (e.toString().contains('network-request-failed')) {
          mensagemErro = 'Erro de conexão. Verifique sua internet';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensagemErro),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        backgroundColor: AppColors.fundo,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Configurações',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.black,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.roxo))
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  _buildDangerCard(),
                  SizedBox(height: 30),
                  _buildBackButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildDangerCard() {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange[700],
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Ações Perigosas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Essas ações afetam permanentemente sua conta e não podem ser desfeitas.',
              style: TextStyle(fontSize: 14, color: AppColors.cinza),
            ),
            SizedBox(height: 20),
            _buildActionButton(
              icon: Icons.logout,
              title: 'Sair da Conta',
              subtitle: 'Encerrar sua sessão atual',
              color: AppColors.roxo,
              onTap: _logout,
            ),
            SizedBox(height: 16),
            Container(height: 1, color: Colors.grey[300]),
            SizedBox(height: 16),
            _buildActionButton(
              icon: Icons.delete_forever,
              title: 'Excluir Conta Permanentemente',
              subtitle: 'Remover todos os seus dados do sistema',
              color: Colors.red,
              onTap: _excluirConta,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: AppColors.cinza),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.roxo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Voltar',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
