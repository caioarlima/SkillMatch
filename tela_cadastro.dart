import 'dart:io'; 
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart'; 
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:skilmatch/utils/colors.dart';
import 'package:skilmatch/telas/tela_ProcurarTrocas.dart';
import 'package:skilmatch/telas/tela_login.dart';
import 'package:firebase_database/firebase_database.dart';

enum GeneroOpcao { masculino, feminino, naoInformar }

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final TextEditingController _controladorNomeCompleto = TextEditingController();
  final TextEditingController _controladorEmailCadastro = TextEditingController();
  final TextEditingController _controladorCidade = TextEditingController();
  final TextEditingController _controladorBio = TextEditingController();
  final TextEditingController _controladorSenhaCadastro = TextEditingController();
  final TextEditingController _controladorConfirmarSenha = TextEditingController();
  final _chaveFormulario = GlobalKey<FormState>();

  File? _imagemSelecionada;
  String? _urlImagemWeb;

  GeneroOpcao? _generoSelecionado;

  final int _tamanhoMinimoSenha = 6;
  final int _tamanhoMaximoSenha = 20;
  final RegExp _regexSenha = RegExp(r"^(?=.*[0-9])(?=.*[a-zA-Z])(?=\S+$).{8,}$");

  @override
  void dispose() {
    _controladorNomeCompleto.dispose();
    _controladorEmailCadastro.dispose();
    _controladorCidade.dispose();
    _controladorBio.dispose();
    _controladorSenhaCadastro.dispose();
    _controladorConfirmarSenha.dispose();
    super.dispose();
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

  Future<void> _cadastrarUsuario() async {
    if (_chaveFormulario.currentState!.validate()) {
      final String senhaDigitada = _controladorSenhaCadastro.text.trim();
      final String confirmarSenhaDigitada = _controladorConfirmarSenha.text.trim();
      
      if (senhaDigitada != confirmarSenhaDigitada) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("As senhas não coincidem. Por favor, verifique.")),
        );
        return;
      }
      
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _controladorEmailCadastro.text.trim(),
          password: senhaDigitada,
        );
        
        String userUid = userCredential.user!.uid;

        DatabaseReference userRef = FirebaseDatabase.instance.ref('usuarios/$userUid');
        await userRef.set({
          'nomeCompleto': _controladorNomeCompleto.text,
          'cidade': _controladorCidade.text,
          'bio': _controladorBio.text,
          'genero': _generoSelecionado?.name,
          'email': _controladorEmailCadastro.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cadastro realizado com sucesso!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TelaProcurar()),
        );

      } on FirebaseAuthException catch (e) {
        String mensagemDeErro;
        if (e.code == 'weak-password') {
          mensagemDeErro = 'A senha fornecida é muito fraca.';
        } else if (e.code == 'email-already-in-use') {
          mensagemDeErro = 'Já existe uma conta com este e-mail.';
        } else if (e.code == 'invalid-email') {
          mensagemDeErro = 'O formato do e-mail é inválido.';
        } else {
          mensagemDeErro = 'Ocorreu um erro no cadastro. Tente novamente.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagemDeErro)),
        );
        print('Erro no Firebase Auth: $mensagemDeErro');
      } catch (e) {
        print('Ocorreu um erro geral ao salvar os dados: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocorreu um erro geral. Tente novamente.')),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _chaveFormulario,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 30),

                Text(
                  "Crie sua conta SkillMatch",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 20),

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
                        ? Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: AppColors.cinza,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _controladorNomeCompleto,
                  decoration: InputDecoration(
                    hintText: "Nome Completo",
                    hintStyle: TextStyle(color: AppColors.cinza),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Por favor insira seu nome completo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

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
                const SizedBox(height: 4),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: RadioListTile<GeneroOpcao>(
                        title: Text(
                          "Masculino",
                          style: TextStyle(color: AppColors.black, fontSize: 14),
                        ),
                        value: GeneroOpcao.masculino,
                        groupValue: _generoSelecionado,
                        onChanged: (GeneroOpcao? valor) {
                          setState(() {
                            _generoSelecionado = valor;
                          });
                        },
                        activeColor: AppColors.roxo,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<GeneroOpcao>(
                        title: Text(
                          "Feminino",
                          style: TextStyle(color: AppColors.black, fontSize: 14),
                        ),
                        value: GeneroOpcao.feminino,
                        groupValue: _generoSelecionado,
                        onChanged: (GeneroOpcao? valor) {
                          setState(() {
                            _generoSelecionado = valor;
                          });
                        },
                        activeColor: AppColors.roxo,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<GeneroOpcao>(
                        title: Text(
                          "Não Dizer",
                          style: TextStyle(color: AppColors.black, fontSize: 14),
                        ),
                        value: GeneroOpcao.naoInformar,
                        groupValue: _generoSelecionado,
                        onChanged: (GeneroOpcao? valor) {
                          setState(() {
                            _generoSelecionado = valor;
                          });
                        },
                        activeColor: AppColors.roxo,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _controladorEmailCadastro,
                  decoration: InputDecoration(
                    hintText: "Email",
                    hintStyle: TextStyle(color: AppColors.cinza),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Por favor insira um email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(valor)) {
                      return 'Por favor insira um email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _controladorCidade,
                  decoration: InputDecoration(
                    hintText: "Cidade",
                    hintStyle: TextStyle(color: AppColors.cinza),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Por favor insira sua cidade';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _controladorBio,
                  decoration: InputDecoration(
                    hintText: "Minhas Habilidades e Talentos",
                    hintStyle: TextStyle(color: AppColors.cinza),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Por favor descreva suas habilidades e talentos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _controladorSenhaCadastro,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Senha",
                    hintStyle: TextStyle(color: AppColors.cinza),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Por favor insira sua senha';
                    }
                    if (valor.length < _tamanhoMinimoSenha || valor.length > _tamanhoMaximoSenha) {
                      return 'A senha deve ter entre $_tamanhoMinimoSenha e $_tamanhoMaximoSenha caracteres';
                    }
                    if (!_regexSenha.hasMatch(valor)) {
                      return 'A senha deve ter no mínimo 8 caracteres, incluindo letras maiúsculas, minúsculas e números.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _controladorConfirmarSenha,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Confirme sua Senha",
                    hintStyle: TextStyle(color: AppColors.cinza),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Por favor confirme sua senha';
                    }
                    if (valor != _controladorSenhaCadastro.text) {
                      return 'As senhas não coincidem. Por favor, verifique.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _cadastrarUsuario,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.roxo,
                    minimumSize: const Size(250, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    "Cadastrar",
                    style: TextStyle(
                      fontSize: 24,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: _voltarParaLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.roxo,
                    minimumSize: const Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    "Voltar",
                    style: TextStyle(
                      fontSize: 24,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}