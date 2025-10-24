# 🛠️ SkillMatch

## 📘 Descrição

O **SkillMatch** é um sistema voltado para a **troca de habilidades entre usuários**, permitindo que pessoas compartilhem conhecimentos e serviços de forma colaborativa.

A aplicação conta com:
- Autenticação de usuários (Firebase Auth)
- Chat em tempo real
- Sistema de avaliações
- Moderação de conteúdo
- Portfólio público
- Interface intuitiva com navegação por bottom bar

---

## 👥 Integrantes

| Nome | Matrícula |
|------|------------|
| Matheus Ferretti | 22301267 |
| Guilherme Souza | 22301119 |
| Francisco Flister | 22300910 |
| Lucca Demaria | 22300457 |
| Caio Aguilar | 22300651 |

---

## 📂 Estrutura de Diretórios

```
lib/
├── Controller/
│   ├── auth_controller.dart
│   ├── avaliacao_controller.dart
│   ├── chat_controller.dart
│   ├── mensagem_controller.dart
│   ├── usuario_controller.dart
│   └── colors.dart
│
├── Model/
│   ├── Avaliacao.dart
│   ├── Chat.dart
│   ├── Mensagem.dart
│   └── Usuario.dart
│
├── Repository/
│   ├── auth_repository.dart
│   ├── avaliacao_repository.dart
│   ├── chat_repository.dart
│   ├── mensagem_repository.dart
│   └── usuario_repository.dart
│
├── Services/
│   ├── email_services.dart
│   └── validadores.dart
│
├── View/
│   ├── tela_cadastro.dart
│   ├── tela_chat.dart
│   ├── tela_configuracoes.dart
│   ├── tela_EsqueciSenha.dart
│   ├── tela_login.dart
│   ├── tela_mensagens.dart
│   ├── tela_MinhasTrocas.dart
│   ├── tela_perfil.dart
│   ├── tela_perfilUsuario.dart
│   └── tela_ProcurarTrocas.dart
│
├── firebase_options.dart
└── main.dart
```

---

## 🚀 Como Executar o Projeto

### 1️⃣ Pré-requisitos

- **Linguagem:** Flutter (Dart)  version 3.8.0
- **Banco de dados:** Firebase  
- **Principais dependências:**  
  `firebase_auth`, `cloud_firestore`, `provider`, `image_picker`, `firebase_core`, `http`, `url_laucher`

---

### 2️⃣ Instalação

```bash
# Dowload Zip
SkillMatch

# Abra a pasta no VS Code
cd SkillMatch

# Instale as dependências
flutter pub get
```

---

### 3️⃣ Execução

```bash
# Execute o projeto
flutter run
Escolha a opção chorme e responsiva ele para app
```

---

## ✅ Checklist das Funcionalidades

| Nº | Funcionalidade | Status |
|----|----------------|:------:|
| 1 | Cadastro de usuário (validação CPF, e-mail, senha) | ✔ |
| 2 | Login com Firebase | ✔ |
| 3 | Recuperação de senha | ✔ |
| 4 | Logout | ✔ |
| 5 | Edição de perfil | ✔ |
| 6 | Exclusão de conta | ✔ |
| 7 | Listagem de conversas | ✔ |
| 8 | Chat em tempo real | ✔ |
| 9 | Criação de novas conversas | ✔ |
| 10 | Marcação de mensagens lidas | ✔ |
| 11 | Busca em conversas | ✔ |
| 12 | Avaliação de usuários (1–5 estrelas) | ✔ |
| 13 | Histórico de trocas e avaliações | ✔ |
| 14 | Cálculo de média automática | ✔ |
| 15 | Verificação de avaliação única | ✔ |
| 16 | Sistema de denúncias | ✔ |
| 17 | Validação de CPF | ✔ |
| 18 | Gerenciamento de projetos | ✔ |
| 19 | Portfólio público | ✔ |
| 20 | Links externos em projetos | ✔ |
| 21 | Busca de usuários (nome, bio, cidade) | ✔ |
| 22 | Filtro por localidade | ✔ |
| 23 | Sistema de matches | ✔ |
| 24 | Usuários recomendados | ✔ |
| 25 | Termos de uso e política | ✔ |
| 26 | Navegação por bottom bar | ✔ |
| 27 | Upload de foto de perfil | ✔ |
| 28 | Contagem de trocas finalizadas | ✔ |
| 29 | Contador de mensagens não lidas | ✔ |

**✅ Total: 29 funcionalidades implementadas.**




---

## 🧠 Design Patterns Aplicados

### 🔹 Singleton
**Uso:** Gerenciamento da conexão com o Firebase (Auth e Firestore).  
**Justificativa:** Garante uma única instância global, otimizando o uso de recursos.

### 🔹 Repository
**Uso:** Intermediação entre lógica de negócios e banco de dados.  
**Justificativa:** Facilita manutenção, testes e desacoplamento de camadas.

### 🔹 MVC (Model-View-Controller)
**Uso:** Estruturação geral do projeto Flutter.  
**Justificativa:** Separa responsabilidades, tornando o código mais limpo e modular.

### 🔹 Observer
**Uso:** Atualizações em tempo real (chat e status de mensagens).  
**Justificativa:** Permite que a interface reaja automaticamente às mudanças no banco.

<img width="4852" height="2098" alt="Untitled diagram-2025-10-24-214431" src="https://github.com/user-attachments/assets/dcb64561-fb87-48e6-9647-ee3ac46755bb" />

---

## 📈 Observações

- O sistema ultrapassou a meta de 20, totalizando **29 funcionalidades**.  
- Está totalmente funcional com Firebase integrado.

### 🔮 Futuras Melhorias
- Notificações push em tempo real.  
- Usar a localização do celular para mostrar usuarios mais pertos.  
- Modo escuro. 

