import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:skilmatch/Controller/auth_controller.dart';
import 'package:skilmatch/Controller/colors.dart';
import 'package:skilmatch/Model/usuario.dart';
import 'package:skilmatch/Repository/usuario_repository.dart';
import 'package:skilmatch/Services/validadores.dart';
import 'package:skilmatch/View/tela_login.dart';
import 'package:skilmatch/View/tela_ProcurarTrocas.dart';

enum GeneroOpcao { masculino, feminino, naoInformar }

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final TextEditingController _controladorNomeCompleto = TextEditingController();
  final TextEditingController _controladorEmailCadastro = TextEditingController();
  final TextEditingController _controladorCPF = TextEditingController();
  final TextEditingController _controladorCidade = TextEditingController();
  final TextEditingController _controladorBio = TextEditingController();
  final TextEditingController _controladorSenhaCadastro = TextEditingController();
  final TextEditingController _controladorConfirmarSenha = TextEditingController();
  final TextEditingController _controladorDataNasc = TextEditingController();
  final _chaveFormulario = GlobalKey<FormState>();
  
  File? _imagemSelecionada;
  String? _urlImagemWeb;
  DateTime? _dataNascimento;
  GeneroOpcao? _generoSelecionado;
  final int _tamanhoMinimoSenha = 6;
  bool _aceitouTermos = false;

  @override
  void dispose() {
    _controladorNomeCompleto.dispose();
    _controladorEmailCadastro.dispose();
    _controladorCPF.dispose();
    _controladorCidade.dispose();
    _controladorBio.dispose();
    _controladorSenhaCadastro.dispose();
    _controladorConfirmarSenha.dispose();
    _controladorDataNasc.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _dataNascimento ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (dataSelecionada != null && dataSelecionada != _dataNascimento) {
      setState(() {
        _dataNascimento = dataSelecionada;
        _controladorDataNasc.text = "${_dataNascimento!.day}/${_dataNascimento!.month}/${_dataNascimento!.year}";
      });
    }
  }

  Future<void> _pegarImagemDaGaleria() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (kIsWeb) {
          _urlImagemWeb = pickedFile.path;
          _imagemSelecionada = null;
        } else {
          _imagemSelecionada = File(pickedFile.path);
          _urlImagemWeb = null;
        }
      });
    }
  }

  Future<void> _mostrarTermosDeUso() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.fundo,
          title: const Text("Termos de Uso e Políticas de Privacidade"),
          content: const SingleChildScrollView(
            child: Text("📖 Termos de Uso\n\n1. Aceitação dos Termos\nAo criar uma conta e utilizar o aplicativo de troca de favores (\"Aplicativo\"), você concorda com estes Termos de Uso. Caso não concorde, não utilize o Aplicativo.\n\n2. Funcionamento do Aplicativo\nO Aplicativo permite que usuários solicitem e ofereçam ajuda em pequenas tarefas do dia a dia (ex.: trocar uma lâmpada, lavar um carro, levar algo ao mercado).\n\nOs favores são realizados de forma voluntária e sem garantia de qualidade.\n\nO Aplicativo não é intermediador de serviços profissionais pagos.\n\n3. Responsabilidades do Usuário\n\n• Fornecer informações verdadeiras no cadastro.\n• Cumprir os favores acordados com responsabilidade e respeito.\n• Não utilizar o Aplicativo para atividades ilegais, perigosas ou que envolvam menores sem supervisão adequada.\n\n4. Limitação de Responsabilidade\nO Aplicativo não se responsabiliza por danos, perdas ou prejuízos decorrentes das interações entre usuários. O uso é de inteira responsabilidade dos participantes.\n\n5. Suspensão e Encerramento\nO Aplicativo pode suspender ou excluir contas que descumprirem estes Termos ou utilizarem a plataforma de forma abusiva.\n\n6. Alterações\nOs Termos podem ser atualizados periodicamente. O uso contínuo do Aplicativo após mudanças significa concordância com a nova versão.\n\n---\n\n🔗 Política de Privacidade\n\n1. Coleta de Informações\nPodemos coletar dados pessoais fornecidos por você, como:\n\n• Nome, e-mail, telefone e foto de perfil.\n• Dados de uso do Aplicativo (ex.: favores solicitados e oferecidos).\n\n2. Uso das Informações\nAs informações são utilizadas para:\n\n• Criar e manter sua conta.\n• Conectar você a outros usuários do Aplicativo.\n• Melhorar a experiência e segurança da plataforma.\n\n3. Compartilhamento de Dados\nNão vendemos suas informações. Seus dados podem ser compartilhados apenas:\n\n• Com outros usuários (ex.: nome e contato para combinar favores).\n• Quando exigido por lei ou autoridades competentes.\n\n4. Armazenamento e Segurança\nSeus dados são armazenados em servidores seguros. Apesar dos esforços, não garantimos proteção absoluta contra acessos não autorizados.\n\n5. Direitos do Usuário\nVocê pode:\n\n• Solicitar a exclusão da sua conta.\n• Pedir a correção ou remoção de seus dados pessoais.\n\n6. Alterações\nA Política de Privacidade pode ser atualizada. O uso contínuo do Aplicativo significa concordância com as mudanças."),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(backgroundColor: AppColors.roxo, foregroundColor: AppColors.white),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _aceitouTermos = true;
                });
              },
              child: const Text("Aceito"),
            ),
          ],
        );
      },
    );
  }

Future<void> _cadastrarUsuario() async {
  if (_chaveFormulario.currentState!.validate()) {
    if (!_aceitouTermos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Você deve aceitar os Termos de Uso e Políticas de Privacidade.")),
      );
      return;
    }

    final String senhaDigitada = _controladorSenhaCadastro.text.trim();
    final String confirmarSenhaDigitada = _controladorConfirmarSenha.text.trim();
    
    if (senhaDigitada != confirmarSenhaDigitada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("As senhas não coincidem. Por favor, verifique.")),
      );
      return;
    }

    final authController = Provider.of<AuthController>(context, listen: false);
    
    final usuario = Usuario(
      nomeCompleto: _controladorNomeCompleto.text.trim(),
      email: _controladorEmailCadastro.text.trim(),
      cpf: _controladorCPF.text.trim(),
      cidade: _controladorCidade.text.trim(),
      bio: _controladorBio.text.trim(),
      genero: _generoSelecionado?.toString().split('.').last,
      dataNascimento: _dataNascimento,
    );

    try {
      await authController.cadastrar(usuario, senhaDigitada);
      
      if (authController.errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cadastro realizado com sucesso!")),
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TelaProcuraTrocas()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authController.errorMessage!)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    }
  }
}

  void _voltarParaLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TelaLogin()),
    );
  }

  Widget _campoTexto(TextEditingController controller, String hint, TextInputType type, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: _decoracao(hint),
      keyboardType: type,
      maxLines: maxLines,
      validator: (valor) => Validators.validarCampoObrigatorio(valor, hint),
    );
  }

  Widget _campoSenha(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      decoration: _decoracao(hint),
      obscureText: true,
      validator: (valor) => Validators.validarSenha(valor, _tamanhoMinimoSenha),
    );
  }

  InputDecoration _decoracao(String hint, {IconData? icone}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.cinza),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      suffixIcon: icone != null ? Icon(icone, color: AppColors.roxo) : null,
    );
  }

  Widget _radioGenero(String titulo, GeneroOpcao valor) {
    return Expanded(
      child: RadioListTile<GeneroOpcao>(
        title: Text(titulo, style: TextStyle(color: AppColors.black, fontSize: 14)),
        value: valor,
        groupValue: _generoSelecionado,
        onChanged: (GeneroOpcao? novoValor) => setState(() => _generoSelecionado = novoValor),
        activeColor: AppColors.roxo,
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Form(
                key: _chaveFormulario,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "Crie sua conta SkillMatch",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 28, color: AppColors.black),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _pegarImagemDaGaleria,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _imagemSelecionada != null
                            ? FileImage(_imagemSelecionada!)
                            : _urlImagemWeb != null
                                ? NetworkImage(_urlImagemWeb!) as ImageProvider
                                : null,
                        child: _imagemSelecionada == null && _urlImagemWeb == null
                            ? Icon(Icons.camera_alt, size: 40, color: AppColors.cinza)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _campoTexto(_controladorNomeCompleto, "Nome Completo", TextInputType.text),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text("Gênero", style: TextStyle(fontSize: 14, color: AppColors.black)),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _radioGenero("Masculino", GeneroOpcao.masculino),
                        _radioGenero("Feminino", GeneroOpcao.feminino),
                        _radioGenero("Prefiro Não Dizer", GeneroOpcao.naoInformar),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _controladorDataNasc,
                      decoration: _decoracao("Data de Nascimento", icone: Icons.calendar_today),
                      readOnly: true,
                      onTap: () => _selecionarData(context),
                      validator: (valor) => Validators.validarDataNascimento(_dataNascimento),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _controladorCPF,
                      decoration: _decoracao("CPF"),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(14),
                        CPFInputFormatter(),
                      ],
                      validator: (valor) => Validators.validarCPF(valor),
                    ),
                    const SizedBox(height: 8),
                    _campoTexto(_controladorCidade, "Cidade", TextInputType.text),
                    const SizedBox(height: 8),
                    _campoTexto(_controladorBio, "Bio", TextInputType.text, maxLines: 2),
                    const SizedBox(height: 8),
                    _campoTexto(_controladorEmailCadastro, "E-mail", TextInputType.emailAddress),
                    const SizedBox(height: 8),
                    _campoSenha(_controladorSenhaCadastro, "Senha"),
                    const SizedBox(height: 8),
                    _campoSenha(_controladorConfirmarSenha, "Confirmar Senha"),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: _aceitouTermos,
                          activeColor: AppColors.roxo,
                          onChanged: (bool? valor) {
                            if (valor == true) {
                              _mostrarTermosDeUso();
                            } else {
                              setState(() => _aceitouTermos = false);
                            }
                          },
                        ),
                        const Expanded(
                          child: Text(
                            "Aceito os Termos de Uso e as Políticas de Privacidade",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _cadastrarUsuario,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.roxo,
                        minimumSize: const Size(250, 50),
                      ),
                      child: const Text("Cadastrar", style: TextStyle(fontSize: 24, color: Colors.white)),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _voltarParaLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.roxo,
                        minimumSize: const Size(150, 50),
                      ),
                      child: const Text("Voltar", style: TextStyle(fontSize: 24, color: Colors.white)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}