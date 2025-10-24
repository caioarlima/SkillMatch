import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:skilmatch/Controller/auth_controller.dart';
import 'package:skilmatch/Controller/colors.dart';
import 'package:skilmatch/Model/Usuario.dart';
import 'package:skilmatch/Services/validadores.dart';
import 'package:skilmatch/View/tela_login.dart';
import 'package:skilmatch/View/tela_ProcurarTrocas.dart';
import 'package:flutter/foundation.dart';

enum GeneroOpcao { masculino, feminino, naoInformar }

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final TextEditingController _controladorNomeCompleto =
      TextEditingController();
  final TextEditingController _controladorEmailCadastro =
      TextEditingController();
  final TextEditingController _controladorCPF = TextEditingController();
  final TextEditingController _controladorCidade = TextEditingController();
  final TextEditingController _controladorBio = TextEditingController();
  final TextEditingController _controladorSenhaCadastro =
      TextEditingController();
  final TextEditingController _controladorConfirmarSenha =
      TextEditingController();
  final TextEditingController _controladorDataNasc = TextEditingController();
  final _chaveFormulario = GlobalKey<FormState>();

  File? _imagemSelecionada;
  String? _urlImagemWeb;
  String? _fotoBase64;
  DateTime? _dataNascimento;
  GeneroOpcao? _generoSelecionado;
  final int _tamanhoMinimoSenha = 6;
  bool _aceitouTermos = false;
  String? _erroCPF;
  bool _validandoCPF = false;
  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;

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

  void _alternarVisibilidadeSenha() {
    setState(() {
      _senhaVisivel = !_senhaVisivel;
    });
  }

  void _alternarVisibilidadeConfirmarSenha() {
    setState(() {
      _confirmarSenhaVisivel = !_confirmarSenhaVisivel;
    });
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _dataNascimento ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.roxo,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.black,
            ),
            dialogBackgroundColor: AppColors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.roxo),
            ),
          ),
          child: child!,
        );
      },
    );
    if (dataSelecionada != null && dataSelecionada != _dataNascimento) {
      setState(() {
        _dataNascimento = dataSelecionada;
        _controladorDataNasc.text =
            "${_dataNascimento!.day.toString().padLeft(2, '0')}/${_dataNascimento!.month.toString().padLeft(2, '0')}/${_dataNascimento!.year}";
      });
    }
  }

  void _aplicarMascaraData(String valor) {
    final textoLimpo = valor.replaceAll(RegExp(r'[^\d]'), '');
    
    String textoFormatado = '';
    
    if (textoLimpo.length >= 1) {
      textoFormatado = textoLimpo.substring(0, 1);
    }
    if (textoLimpo.length >= 2) {
      textoFormatado = textoLimpo.substring(0, 2);
    }
    if (textoLimpo.length >= 3) {
      textoFormatado = '${textoLimpo.substring(0, 2)}/${textoLimpo.substring(2, 3)}';
    }
    if (textoLimpo.length >= 4) {
      textoFormatado = '${textoLimpo.substring(0, 2)}/${textoLimpo.substring(2, 4)}';
    }
    if (textoLimpo.length >= 5) {
      textoFormatado = '${textoLimpo.substring(0, 2)}/${textoLimpo.substring(2, 4)}/${textoLimpo.substring(4, 5)}';
    }
    if (textoLimpo.length >= 6) {
      textoFormatado = '${textoLimpo.substring(0, 2)}/${textoLimpo.substring(2, 4)}/${textoLimpo.substring(4, 6)}';
    }
    if (textoLimpo.length >= 7) {
      textoFormatado = '${textoLimpo.substring(0, 2)}/${textoLimpo.substring(2, 4)}/${textoLimpo.substring(4, 7)}';
    }
    if (textoLimpo.length >= 8) {
      textoFormatado = '${textoLimpo.substring(0, 2)}/${textoLimpo.substring(2, 4)}/${textoLimpo.substring(4, 8)}';
    }

    if (_controladorDataNasc.text != textoFormatado) {
      _controladorDataNasc.value = TextEditingValue(
        text: textoFormatado,
        selection: TextSelection.collapsed(offset: textoFormatado.length),
      );
    }
  }

  Future<void> _pegarImagemDaGaleria() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      try {
        Uint8List bytes = await pickedFile.readAsBytes();
        String base64Image = base64Encode(bytes);

        setState(() {
          if (kIsWeb) {
            _urlImagemWeb = pickedFile.path;
            _imagemSelecionada = null;
          } else {
            _imagemSelecionada = File(pickedFile.path);
            _urlImagemWeb = null;
          }
          _fotoBase64 = base64Image;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao processar a imagem"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _mostrarTermosDeUso() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.fundo,
          title: Text(
            "Termos de Uso e Política de Privacidade - SkillMatch",
            style: TextStyle(
              color: AppColors.roxo,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "📋 TERMO DE USO DO SISTEMA SKILLMATCH",
                  style: TextStyle(
                    color: AppColors.roxo,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Este Termo de Uso é um acordo legal entre você e os desenvolvedores do Projeto SkillMatch, "
                  "um sistema criado para conectar pessoas que desejam trocar habilidades e serviços de forma colaborativa, "
                  "sem envolvimento financeiro direto, promovendo aprendizado e networking.\n\n"
                  "Ao utilizar o SkillMatch, você concorda com:\n\n"
                  "• Coleta de dados: nome, e-mail, habilidades, histórico de interações e dados técnicos\n"
                  "• Finalidade: criação de perfil, sistema de match, comunicação via chat, segurança\n"
                  "• Vedações: conteúdo ilegal, fraude, assédio, violação de direitos autorais\n"
                  "• Proteção: criptografia, controle de acesso, monitoramento de segurança\n"
                  "• Direitos: exclusão de conta, revogação de consentimento, acesso aos dados\n\n",
                  style: TextStyle(color: AppColors.cinza, fontSize: 14),
                ),
                
                Text(
                  "🔒 TERMO DE CONSENTIMENTO PARA TRATAMENTO DE DADOS",
                  style: TextStyle(
                    color: AppColors.roxo,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Você autoriza expressamente o tratamento de seus dados pessoais pelo SkillMatch, "
                  "em conformidade com a LGPD (Lei nº 13.709/2018) e normas internacionais de segurança.\n\n"
                  "Dados autorizados:\n"
                  "• Nome completo e e-mail para identificação\n"
                  "• Foto de perfil (opcional) para personalização\n"
                  "• Habilidades e áreas de interesse para match\n"
                  "• Mensagens e interações para histórico\n"
                  "• Dados técnicos (IP, dispositivo) para segurança\n\n"
                  "Finalidades:\n"
                  "• Gerenciar cadastros e perfis\n"
                  "• Realizar match entre habilidades complementares\n"
                  "• Permitir comunicação entre usuários\n"
                  "• Garantir segurança e prevenção de fraudes\n"
                  "• Melhorar experiência do usuário\n\n",
                  style: TextStyle(color: AppColors.cinza, fontSize: 14),
                ),
                
                Text(
                  "🛡️ POLÍTICA DE PRIVACIDADE",
                  style: TextStyle(
                    color: AppColors.roxo,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "O SkillMatch valoriza sua privacidade e protege seus dados com:\n\n"
                  "Medidas de segurança:\n"
                  "• Criptografia de dados e comunicações\n"
                  "• Autenticação segura e controle de acesso\n"
                  "• Monitoramento contínuo e backups\n"
                  "• Conformidade com normas ISO 27001, 27701 e 29100\n\n"
                  "Seus direitos:\n"
                  "• Acessar, corrigir e excluir seus dados\n"
                  "• Revogar consentimento a qualquer momento\n"
                  "• Solicitar portabilidade de dados\n"
                  "• Ser informado sobre uso dos dados\n\n"
                  "Dados de crianças e adolescentes:\n"
                  "• Crianças menores de 12 anos: consentimento dos responsáveis\n"
                  "• Adolescentes (12-18 anos): tratamento no melhor interesse\n"
                  "• Medidas reforçadas de segurança aplicadas\n\n"
                  "Canais de contato:\n"
                  "• E-mail: skillmatch2025@gmail.com\n"
                  "• Telefone: (31) 99999-9999\n"
                  "• DPO: Caio Aguilar - caioaguilar.skillmatch@gmail.com\n\n"
                  "Foro: Comarca de Belo Horizonte/MG",
                  style: TextStyle(color: AppColors.cinza, fontSize: 14),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Não Aceito",
                style: TextStyle(color: AppColors.cinza, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _aceitouTermos = true;
                });
              },
              child: Text(
                "Aceito os Termos",
                style: TextStyle(
                  color: AppColors.roxo,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _validarCPFUnico(String cpf) async {
    final cpfLimpo = cpf.replaceAll(RegExp(r'\D'), '');

    if (cpfLimpo.length == 11) {
      setState(() {
        _validandoCPF = true;
      });

      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );
      final erro = await Validators.validarCPFCadastrado(
        cpfLimpo,
        authController,
      );

      setState(() {
        _erroCPF = erro;
        _validandoCPF = false;
      });
    }
  }

  String? _validarCPF(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Por favor, insira o seu CPF';
    }

    final cpfLimpo = valor.replaceAll(RegExp(r'\D'), '');
    if (cpfLimpo.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }

    return _erroCPF;
  }

  Future<void> _cadastrarUsuario() async {
    if (_chaveFormulario.currentState!.validate()) {
      if (!_aceitouTermos) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Você deve aceitar os Termos de Uso e Políticas de Privacidade.",
            ),
            backgroundColor: AppColors.roxo,
          ),
        );
        return;
      }

      final String senhaDigitada = _controladorSenhaCadastro.text.trim();
      final String confirmarSenhaDigitada = _controladorConfirmarSenha.text.trim();

      if (senhaDigitada != confirmarSenhaDigitada) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("As senhas não coincidem. Por favor, verifique."),
            backgroundColor: AppColors.roxo,
          ),
        );
        return;
      }

      if (_erroCPF != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_erroCPF!), backgroundColor: Colors.red),
        );
        return;
      }

      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );

      final cpfLimpo = _controladorCPF.text.replaceAll(RegExp(r'\D'), '');
      final cpfExiste = await authController.verificarCPFExistente(cpfLimpo);

      if (cpfExiste) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CPF já cadastrado no sistema'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final usuario = Usuario(
        nomeCompleto: _controladorNomeCompleto.text.trim(),
        email: _controladorEmailCadastro.text.trim(),
        cpf: _controladorCPF.text.trim(),
        cidade: _controladorCidade.text.trim(),
        bio: _controladorBio.text.trim(),
        genero: _generoSelecionado?.toString().split('.').last,
        dataNascimento: _dataNascimento,
        fotoUrl: _fotoBase64,
      );

      try {
        await authController.cadastrar(usuario, senhaDigitada);

        if (authController.errorMessage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Cadastro realizado com sucesso!"),
              backgroundColor: AppColors.roxo,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TelaProcuraTrocas()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authController.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Form(
                key: _chaveFormulario,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "Crie sua conta SkillMatch",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                      ),
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
                        child:
                            _imagemSelecionada == null && _urlImagemWeb == null
                            ? Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: AppColors.cinza,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _controladorNomeCompleto,
                      decoration: _decoracao("Nome Completo"),
                      validator: (valor) => Validators.validarCampoObrigatorio(
                        valor,
                        "nome completo",
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          "Gênero",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _radioGenero("Masculino", GeneroOpcao.masculino),
                        _radioGenero("Feminino", GeneroOpcao.feminino),
                        _radioGenero(
                          "Prefiro Não Dizer",
                          GeneroOpcao.naoInformar,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _controladorDataNasc,
                      decoration: _decoracao(
                        "Data de Nascimento (DD/MM/AAAA)",
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today, color: AppColors.roxo),
                          onPressed: () => _selecionarData(context),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      onChanged: _aplicarMascaraData,
                      validator: (valor) => Validators.validarDataNascimentoFormatada(valor),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _controladorCPF,
                      decoration: _decoracao("CPF").copyWith(
                        suffixIcon: _validandoCPF
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.roxo,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [CPFInputFormatter()],
                      onChanged: _validarCPFUnico,
                      validator: _validarCPF,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _controladorCidade,
                      decoration: _decoracao("Cidade"),
                      validator: (valor) =>
                          Validators.validarCampoObrigatorio(valor, "cidade"),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _controladorBio,
                      decoration: _decoracao("Bio"),
                      maxLines: 2,
                      validator: (valor) =>
                          Validators.validarCampoObrigatorio(valor, "bio"),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _controladorEmailCadastro,
                      decoration: _decoracao("E-mail"),
                      keyboardType: TextInputType.emailAddress,
                      validator: (valor) => Validators.validarEmail(valor),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _controladorSenhaCadastro,
                      decoration: _decoracao("Senha").copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _senhaVisivel ? Icons.visibility : Icons.visibility_off,
                            color: AppColors.roxo,
                          ),
                          onPressed: _alternarVisibilidadeSenha,
                        ),
                      ),
                      obscureText: !_senhaVisivel,
                      validator: (valor) =>
                          Validators.validarSenha(valor, _tamanhoMinimoSenha),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _controladorConfirmarSenha,
                      decoration: _decoracao("Confirmar Senha").copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _confirmarSenhaVisivel ? Icons.visibility : Icons.visibility_off,
                            color: AppColors.roxo,
                          ),
                          onPressed: _alternarVisibilidadeConfirmarSenha,
                        ),
                      ),
                      obscureText: !_confirmarSenhaVisivel,
                      validator: (valor) =>
                          Validators.validarSenha(valor, _tamanhoMinimoSenha),
                    ),
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
                        Expanded(
                          child: Text(
                            "Aceito os Termos de Uso e as Políticas de Privacidade",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.black,
                            ),
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
                      child: Text(
                        "Cadastrar",
                        style: TextStyle(fontSize: 24, color: AppColors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _voltarParaLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.roxo,
                        minimumSize: const Size(150, 50),
                      ),
                      child: Text(
                        "Voltar",
                        style: TextStyle(fontSize: 24, color: AppColors.white),
                      ),
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

  InputDecoration _decoracao(String hint, {IconData? icone}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.cinza),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: AppColors.roxo),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: AppColors.roxo, width: 2),
      ),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      suffixIcon: icone != null ? Icon(icone, color: AppColors.roxo) : null,
    );
  }

  Widget _radioGenero(String titulo, GeneroOpcao valor) {
    return Expanded(
      child: RadioListTile<GeneroOpcao>(
        title: Text(
          titulo,
          style: TextStyle(color: AppColors.black, fontSize: 14),
        ),
        value: valor,
        groupValue: _generoSelecionado,
        onChanged: (GeneroOpcao? novoValor) =>
            setState(() => _generoSelecionado = novoValor),
        activeColor: AppColors.roxo,
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }
}