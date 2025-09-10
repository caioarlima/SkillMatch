import 'package:flutter/services.dart';

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
      (agora.month == dataNascimento.month && agora.day < dataNascimento.day)) {
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
  
  // Remove caracteres não numéricos
  String cpfLimpo = cpf.replaceAll(RegExp(r'\D'), '');
  
  // Verifica se tem 11 dígitos
  if (cpfLimpo.length != 11) {
    return 'CPF deve ter 11 dígitos';
  }
  
  // Verifica se todos os dígitos são iguais (CPF inválido)
  if (RegExp(r'^(\d)\1*$').hasMatch(cpfLimpo)) {
    return 'CPF inválido';
  }
  
  // Validação dos dígitos verificadores
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
  
  return null; // CPF válido
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
      newText = '${newText.substring(0, 3)}.${newText.substring(3, 6)}.${newText.substring(6)}';
    } else {
      newText = '${newText.substring(0, 3)}.${newText.substring(3, 6)}.${newText.substring(6, 9)}-${newText.substring(9)}';
    }
    
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}