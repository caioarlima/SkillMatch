import 'package:flutter/services.dart';
import 'package:skilmatch/Controller/auth_controller.dart';

class Validators {
  static String? validarEmail(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Por favor insira seu email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(valor)) {
      return 'Por favor insira um email válido';
    }
    return null;
  }

  static String? validarSenha(String? valor, int tamanhoMinimo) {
    if (valor == null || valor.isEmpty) {
      return 'Por favor insira sua senha';
    }
    if (valor.length < tamanhoMinimo) {
      return 'Senha deve ter ao menos $tamanhoMinimo caracteres';
    }
    return null;
  }

  static int calcularIdade(DateTime dataNascimento) {
    final agora = DateTime.now();
    int idade = agora.year - dataNascimento.year;
    if (agora.month < dataNascimento.month ||
        (agora.month == dataNascimento.month &&
            agora.day < dataNascimento.day)) {
      idade--;
    }
    return idade;
  }

  static String? validarDataNascimento(DateTime? dataNascimento) {
    if (dataNascimento == null) {
      return 'Por favor, selecione sua data de nascimento.';
    }
    final idade = calcularIdade(dataNascimento);
    if (idade < 18) {
      return 'Você deve ter pelo menos 18 anos para se cadastrar.';
    }
    return null;
  }

  static String? validarDataNascimentoFormatada(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Por favor, insira sua data de nascimento.';
    }

    final partes = valor.split('/');
    if (partes.length != 3) {
      return 'Formato inválido. Use DD/MM/AAAA';
    }

    try {
      final dia = int.parse(partes[0]);
      final mes = int.parse(partes[1]);
      final ano = int.parse(partes[2]);

      final agora = DateTime.now();
      final anoAtual = agora.year;

      if (ano > anoAtual) {
        return 'O ano não pode ser maior que $anoAtual';
      }

      if (mes < 1 || mes > 12) {
        return 'Mês deve estar entre 01 e 12';
      }

      if (dia < 1 || dia > 31) {
        return 'Dia deve estar entre 01 e 31';
      }

      if (mes == 2) {
        final isBissexto = (ano % 4 == 0 && ano % 100 != 0) || (ano % 400 == 0);
        if (dia > (isBissexto ? 29 : 28)) {
          return 'Fevereiro tem no máximo ${isBissexto ? 29 : 28} dias';
        }
      } else if ([4, 6, 9, 11].contains(mes) && dia > 30) {
        return 'Este mês tem apenas 30 dias';
      }

      final dataNasc = DateTime(ano, mes, dia);
      if (dataNasc.isAfter(agora)) {
        return 'Data de nascimento não pode ser futura';
      }

      final idade = agora.difference(dataNasc).inDays ~/ 365;
      if (idade < 18) {
        return 'Você deve ter pelo menos 18 anos para se cadastrar';
      }

      return null;
    } catch (e) {
      return 'Data inválida. Use o formato DD/MM/AAAA';
    }
  }

  static String? validarCampoObrigatorio(String? valor, String nomeCampo) {
    if (valor == null || valor.isEmpty) {
      return 'Por favor, insira $nomeCampo';
    }
    return null;
  }

  static String? validarCPF(String? cpf) {
    if (cpf == null || cpf.isEmpty) {
      return 'Por favor, insira o seu CPF';
    }

    String cpfLimpo = cpf.replaceAll(RegExp(r'\D'), '');

    if (cpfLimpo.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }

    if (RegExp(r'^(\d)\1*$').hasMatch(cpfLimpo)) {
      return 'CPF inválido';
    }

    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(cpfLimpo[i]) * (10 - i);
    }

    int resto = soma % 11;
    int digito1 = resto < 2 ? 0 : 11 - resto;

    if (digito1 != int.parse(cpfLimpo[9])) {
      return 'CPF inválido';
    }

    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(cpfLimpo[i]) * (11 - i);
    }

    resto = soma % 11;
    int digito2 = resto < 2 ? 0 : 11 - resto;

    if (digito2 != int.parse(cpfLimpo[10])) {
      return 'CPF inválido';
    }

    return null;
  }

  static Future<String?> validarCPFCadastrado(
    String? cpf,
    AuthController authController,
  ) async {
    final cpfLimpo = cpf?.replaceAll(RegExp(r'\D'), '') ?? '';

    final validacaoBasica = validarCPF(cpfLimpo);
    if (validacaoBasica != null) {
      return validacaoBasica;
    }

    try {
      final cpfExiste = await authController.verificarCPFExistente(cpfLimpo);

      if (cpfExiste) {
        return 'CPF já cadastrado';
      }
    } catch (e) {
      return 'Erro ao verificar CPF';
    }

    return null;
  }

  static String formatarCPF(String cpf) {
    String cpfLimpo = cpf.replaceAll(RegExp(r'\D'), '');
    if (cpfLimpo.length > 11) {
      cpfLimpo = cpfLimpo.substring(0, 11);
    }
    if (cpfLimpo.length <= 3) {
      return cpfLimpo;
    } else if (cpfLimpo.length <= 6) {
      return '${cpfLimpo.substring(0, 3)}.${cpfLimpo.substring(3)}';
    } else if (cpfLimpo.length <= 9) {
      return '${cpfLimpo.substring(0, 3)}.${cpfLimpo.substring(3, 6)}.${cpfLimpo.substring(6)}';
    } else {
      return '${cpfLimpo.substring(0, 3)}.${cpfLimpo.substring(3, 6)}.${cpfLimpo.substring(6, 9)}-${cpfLimpo.substring(9)}';
    }
  }
}

class CPFInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (newText.length > 11) {
      newText = newText.substring(0, 11);
    }
    if (newText.length <= 3) {
      newText = newText;
    } else if (newText.length <= 6) {
      newText = '${newText.substring(0, 3)}.${newText.substring(3)}';
    } else if (newText.length <= 9) {
      newText =
          '${newText.substring(0, 3)}.${newText.substring(3, 6)}.${newText.substring(6)}';
    } else {
      newText =
          '${newText.substring(0, 3)}.${newText.substring(3, 6)}.${newText.substring(6, 9)}-${newText.substring(9)}';
    }
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}