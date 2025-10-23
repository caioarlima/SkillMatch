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

  void _mostrarTermosUso() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '📜 Termos de Uso - SkillMatch',
          style: TextStyle(
            color: AppColors.roxo,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTermoItem('CLÁUSULA PRIMEIRA – DAS CONDIÇÕES GERAIS DE USO',
                  'O "SkillMatch" é destinado a facilitar a conexão entre usuários interessados em trocar habilidades, aprender novas competências e oferecer serviços de maneira colaborativa e segura.'),
              
              _buildTermoItem('CLÁUSULA SEGUNDA – DA COLETA E USO DE DADOS PESSOAIS',
                  'O usuário declara estar ciente da coleta e uso dos seguintes dados pelo "SkillMatch":\n• Nome completo e e-mail → para identificação e login\n• Foto de perfil → para personalizar a conta\n• Habilidades oferecidas e procuradas → para funcionamento do sistema de "match"\n• Histórico de interações e trocas → para controle de reputação e segurança\n• Dados técnicos (IP, tipo de dispositivo, navegador) → para segurança e melhoria de desempenho'),
              
              _buildTermoItem('CLÁUSULA TERCEIRA – FINALIDADE DA COLETA',
                  'A coleta dos dados tem finalidades específicas e essenciais para a operação do "SkillMatch" e a conformidade com a LGPD:\n• Criar e gerenciar o perfil do usuário\n• Viabilizar o sistema de conexão ("match") entre usuários\n• Garantir a segurança das interações e prevenir fraudes\n• Permitir a comunicação interna entre usuários (chat)\n• Melhorar continuamente a experiência e o desempenho do sistema'),
              
              _buildTermoItem('CLÁUSULA QUARTA – VEDAÇÕES DO USO',
                  'O usuário compromete-se a não utilizar o "SkillMatch" para qualquer finalidade ilícita ou que viole este Termo de Uso, incluindo:\n• Carregar conteúdo ilegal, ofensivo ou difamatório\n• Praticar qualquer forma de fraude, assédio ou discriminação\n• Acessar, alterar ou danificar contas de outros usuários\n• Violar direitos autorais ou de propriedade intelectual'),
              
              _buildTermoItem('CLÁUSULA SEXTA – DA PROTEÇÃO DOS DADOS',
                  'O "SkillMatch" compromete-se a adotar medidas técnicas e administrativas em conformidade com a LGPD e normas ISO/IEC 27001, 27701 e 29100, incluindo:\n• Criptografia de dados e comunicações\n• Banco de dados seguro com acesso restrito\n• Autenticação robusta e monitoramento de acessos\n• Plano de resposta a incidentes e cópias de segurança periódicas'),
              
              _buildTermoItem('CLÁUSULA OITAVA – DOS DIREITOS DO TITULAR DOS DADOS',
                  'Em conformidade com a LGPD, o sistema permite que o usuário exerça seus direitos, incluindo:\n• Solicitar a exclusão da conta e de todos os dados\n• Revogar o consentimento a qualquer momento\n• Solicitar informações sobre o uso e tratamento de seus dados\n\nCanal de contato: skillmatch2025@gmail.com'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fechar',
              style: TextStyle(
                color: AppColors.roxo,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarPoliticaPrivacidade() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '🔒 Política de Privacidade - SkillMatch',
          style: TextStyle(
            color: AppColors.roxo,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTermoItem('1. SOBRE O SKILLMATCH',
                  'O SkillMatch é uma plataforma que conecta pessoas para a troca de habilidades e serviços, promovendo aprendizado, colaboração e networking. Os usuários podem criar perfis, listar suas habilidades e encontrar parceiros compatíveis através de um sistema de match inteligente, com chat interno e avaliações.'),
              
              _buildTermoItem('2. DADOS COLETADOS',
                  'Dados fornecidos pelo usuário:\n• Nome completo\n• E-mail\n• Senha (armazenada de forma criptografada)\n• Foto de perfil (opcional)\n• Habilidades e áreas de interesse\n• Mensagens trocadas dentro da plataforma\n\nDados coletados automaticamente:\n• Endereço IP\n• Tipo de dispositivo e sistema operacional\n• Data e hora de acesso\n• Cookies e identificadores técnicos'),
              
              _buildTermoItem('3. FINALIDADE DO TRATAMENTO DE DADOS',
                  'Os dados são utilizados exclusivamente para:\n• Criar e gerenciar contas de usuários\n• Realizar match entre habilidades compatíveis\n• Permitir comunicação via chat interno\n• Personalizar recomendações e experiência de uso\n• Garantir segurança, auditoria e prevenção de fraudes\n• Enviar comunicações relacionadas à plataforma'),
              
              _buildTermoItem('6. COMPARTILHAMENTO DE DADOS',
                  'Os dados não são vendidos nem compartilhados com terceiros, exceto:\n• Quando houver consentimento expresso do usuário\n• Por obrigação legal ou ordem judicial\n• Para suporte técnico ou hospedagem segura, sob cláusulas contratuais de confidencialidade'),
              
              _buildTermoItem('9. DIREITOS DO TITULAR DOS DADOS',
                  'Você pode exercer seus direitos garantidos pela LGPD, incluindo:\n• Acesso aos seus dados pessoais\n• Correção de informações incorretas\n• Exclusão da conta e dos dados\n• Revogação do consentimento\n• Solicitação de portabilidade\n• Informação sobre uso e compartilhamento dos dados\n\nPara exercer seus direitos: skillmatch2025@gmail.com'),
              
              _buildTermoItem('12. CANAL DE CONTATO E ENCARREGADO DE DADOS (DPO)',
                  'Controlador: Projeto SkillMatch\nEncarregado (DPO): Caio Aguilar\nE-mail: skillmatch2025@gmail.com\nTelefone: (31) 99999-9999\nEndereço: Belo Horizonte – MG'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fechar',
              style: TextStyle(
                color: AppColors.roxo,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarTermoConsentimento() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '📋 Termo de Consentimento - SkillMatch',
          style: TextStyle(
            color: AppColors.roxo,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTermoItem('CLÁUSULA PRIMEIRA – DO OBJETO DO CONSENTIMENTO',
                  'O titular AUTORIZA o Projeto "SkillMatch" a tratar os seguintes dados pessoais:\n• Nome completo e e-mail: para identificação e autenticação\n• Foto de perfil (opcional): para personalização da conta\n• Habilidades e áreas de interesse: para funcionamento do sistema de match\n• Mensagens e interações: para manter histórico de comunicação\n• Dados técnicos (IP, dispositivo, data/hora): para segurança e prevenção de fraudes'),
              
              _buildTermoItem('CLÁUSULA SEGUNDA – DAS FINALIDADES DO TRATAMENTO',
                  'Os dados pessoais serão utilizados exclusivamente para:\n1. Gerenciar cadastros e perfis dos usuários\n2. Realizar o match entre pessoas com habilidades complementares\n3. Permitir comunicação entre usuários via chat interno\n4. Garantir segurança, auditoria e prevenção de uso indevido do sistema\n5. Melhorar a experiência do usuário e personalizar recomendações'),
              
              _buildTermoItem('CLÁUSULA TERCEIRA – DO NÃO COMPARTILHAMENTO DE DADOS',
                  'Os dados não serão compartilhados com terceiros sem consentimento expresso do titular, exceto em casos de obrigação legal ou suporte técnico restrito. Qualquer eventual compartilhamento seguirá o princípio da necessidade e adotará garantias técnicas e contratuais previstas na ISO/IEC 27001.'),
              
              _buildTermoItem('CLÁUSULA SEXTA – DOS DIREITOS DO TITULAR',
                  'O titular poderá, a qualquer momento:\n• Revogar seu consentimento\n• Solicitar exclusão de seus dados pessoais\n• Solicitar acesso, cópia, correção ou atualização de dados\n• Consultar a finalidade e forma de tratamento dos dados\n• Solicitar portabilidade, quando aplicável'),
              
              _buildTermoItem('CLÁUSULA SÉTIMA – CANAL DE COMUNICAÇÃO',
                  'Canal oficial para dúvidas, solicitações e exercício de direitos:\nE-mail: skillmatch2025@gmail.com\nTelefone: (31) 99999-9999'),
              
              _buildTermoItem('CLÁUSULA DÉCIMA – DO TRATAMENTO DE DADOS DE CRIANÇAS E ADOLESCENTES',
                  'O SkillMatch observa o art. 14 da LGPD e adota medidas específicas para proteger dados de menores:\n• Dados de crianças menores de 12 anos só serão tratados com consentimento expresso de um responsável legal\n• Dados de adolescentes (12 a 18 anos) serão tratados no melhor interesse do titular, com medidas reforçadas de segurança\n• São aplicadas criptografia, controle de acesso restrito e monitoramento constante\n• O consentimento pode ser revogado a qualquer momento pelos responsáveis'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fechar',
              style: TextStyle(
                color: AppColors.roxo,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermoItem(String titulo, String conteudo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            conteudo,
            style: TextStyle(
              color: AppColors.cinza,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
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
                  _buildDocumentosCard(),
                  SizedBox(height: 16),
                  _buildDangerCard(),
                  SizedBox(height: 30),
                  _buildBackButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildDocumentosCard() {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.roxo.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description,
                  color: AppColors.roxo,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Documentos Legais',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.roxo,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Conheça nossos termos e políticas',
              style: TextStyle(fontSize: 14, color: AppColors.cinza),
            ),
            SizedBox(height: 20),
            _buildActionButton(
              icon: Icons.assignment,
              title: 'Termos de Uso',
              subtitle: 'Condições gerais de uso do aplicativo',
              color: AppColors.roxo,
              onTap: _mostrarTermosUso,
            ),
            SizedBox(height: 16),
            Container(height: 1, color: Colors.grey[300]),
            SizedBox(height: 16),
            _buildActionButton(
              icon: Icons.assignment_ind,
              title: 'Termo de Consentimento',
              subtitle: 'Autorização para tratamento de dados',
              color: AppColors.roxo,
              onTap: _mostrarTermoConsentimento,
            ),
            SizedBox(height: 16),
            Container(height: 1, color: Colors.grey[300]),
            SizedBox(height: 16),
            _buildActionButton(
              icon: Icons.security,
              title: 'Política de Privacidade',
              subtitle: 'Proteção e uso dos seus dados',
              color: AppColors.roxo,
              onTap: _mostrarPoliticaPrivacidade,
            ),
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