<img width="801" height="1051" alt="SkillMatch5 drawio" src="https://github.com/user-attachments/assets/b8932f82-4cf3-4f22-b3bf-19ba3e3ab16d" /># 🛠️ SkillMatch

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

https://viewer.diagrams.net/?tags=%7B%7D&lightbox=1&highlight=0000ff&edit=_blank&layers=1&nav=1&title=SkillMatch5.drawio&dark=auto#R%3Cmxfile%3E%3Cdiagram%20name%3D%22P%C3%A1gina-1%22%20id%3D%22ICu36kgEZiB9xSZSDgqE%22%3E7V1Zc%2BK4Fv41VE0%2F0IVtbOCRAJ3mDlkKkpmbpynFFqDbxqJlkaV%2F%2FRzZ8m6MWZxLaHelGiRrP0ff%2BXQki4Y2WL1dM7Re3lAL2w21Zb01tGFDVZW2asCHiHmXMb22jFkwYsm4KGJGfmEZ2ZKxG2JhN5GQU2pzsk5GmtRxsMkTcYgx%2BppMNqd2stY1WuBMxMxEdjb2b2LxpR%2FbVTtR%2FHdMFsugZsXo%2BU9WKEgse%2BIukUVfY1HaqKENGKXc%2F7Z6G2BbjF4wLn6%2Bb1uehg1j2OFlMths2GurHfWn89ydcvLEzP8smyKDKOYF2RvZ49mf48nkpv8w%2BC7bzd%2BDwXBfycpGDoSuXpeE49kameLRKwgf4pZ8ZUNIga%2FZxsn2vmDG8VssSjb2GtMV5uwdkoTK4%2BeQmtNUFF2O5GtMEC0Zt4wJodOTkUgKfxEWHo0PfJFDtM9wZUbrr%2FHo76JxmlOHz%2BSTFoTNJbGtCXqnG9FYlyPzRxC6WlJGfkF6FIwiPGZczglV5J4T2x5QmzKIcKhXQZRpJgqT1TDsQrb7YPyVVNQNeksknCCXBw2kto3WLnn2miwyrhBbEOeKck5XMlGhpIsV7VD55whfMXKErxQJX1Y2BaRAzgJ6GNYW5Aq1rdXOVtjJqU9LVYdsjpmDOL6iG8dyMyoXdvRwLdQyWtgUsIht9I9NQVQN1bCFPlnkBb4uxNcwgYkskDWjQRpoQCxZYc4l4vvnWmHHBYx03CDRM4ulMdBKAIfz7IoPL8MaM9DyfSrKKQSswZwsNgyZFLtHljVyf26w2Rhojf5whp0lSqc6svwbAmW6D4ya6Nim3kMh0Gl2ksJ8QTy6G8QI3VpYCvlgbnMPuBj9gVNIlQNeyCYLB4I2notsAhwI2N6%2BjOZUtMYFK0OcxcRLM2xHMVM5C0UUhbxz27OvS2JZ2BHYRjni6DnE3jUlDvemqX4FfzBxB62vekOHhg8grERh%2BBPJGR9QB%2FqCiIdtGGbOKxZIub%2F5KzQnuzFRwpJaFgQ7VVnATgZ7Bne3D9O7yWQ0re1gFXZQbRmHGcL2xRvCbq4hRBu%2BFBYAMMi2MdtinTY%2BsOUkLGXchDU8NK%2B0iauc%2FAXWEUE3CTJRXpOjbDVOV4DTndJzdl%2BcVqvC6WD9HJsbGSXAjtUXS2QImTZyXWIGWJuNjg0aE%2FMZW1JYMHLs%2Fb%2FxwJMIgHxkcPgWfzh8l6E98dKlG2bi3aQYWr%2FARQVKzMBWYt2flWRMdHqO5II4BlSJk5ekt6AAce%2BFbsfAXekk4FZJo6jfb5krvrpPF9RNLpe6qXL8ccmUcyokVoLlfaRu09H93Wz8cDd9yhLmVg6HToVrKnF6KqH1ejAvazKRr8JZ507IJhheU5dwKvpbxCaCp2D4nIT%2BGj831DPUoE8LD0Cbpq90fQFaDDluIO8rz5sZPrPFoDQtxH78wRbPfwhjCLHBxxf%2FUzxRdd0PxL98%2BeJPLll90OScDsGY%2Ba0u5hFbydBv2vWQy2WLTXC5VkjfLm%2BgavZZKftUyrvOz4d%2B6h9EP09NI7slaWRgLc6ER2q9JP1TlAN5ZFtLFdRSP5RItns5irMDMAUhbL7KQRV46FC2EowvB9Vu7oajyVY8O%2BF%2B14kom56iUDmETc3dA0srwOn2wLIry8eA%2FdSkfZcGhPpdfh8sydhzCLSSx6CV9Arw8hi7ml10CqY14wzMfkP7JvPnUbfPQsIyXsAdVOzc%2ByNlc1mdckCTB3S1tjGnu3uzc1lRZofuswzNRcobrxCxTyDoWqrn1ClzPa9lemkyJRaycC3WCxPrMznYzl68pAXtvShhL7CD2Sl4lVgbDGFB8kBW2F8dWIijW%2BSaEOGkqdvusuLrjDnl9JHZ%2BxYxIS4PxeUluGf0f4JGBpEyd2vtx7sFNdRO1mM8M63S6%2FICJ2vuQtxobV%2BIH%2BWJ0bM7VjdyO6J2xXyAK6a8LybtHLk8X4yefyg5oB%2FhPtm4dsicVX9CAQlzQT95Z05AEi6QEUILsWNhBlPvtxdvggNCF%2BADLBoI9%2FcagmdKba%2BJFrr0nh%2FIw1Pr5oCGvxB3A0z5F7LQveju55k7J9Cax891yMlfmTEM1AbqxDX4BVH1eZ1Kl5Lhsuz0S8nKNvV1I0Pf%2B9GBtXotWflaUjfK6kDRma0LWUtmXzIru6%2BfWHPKQ7m%2BIluUJdaeB64Etpa%2BX%2BGiJP%2FcFSCPOPtV5NgrbodJhffSM8yHE2HhCY0mfCU2pbY0p7c0RmnU2dfStCqzNO3M5B54x8drI1O5kdG6Rknx65dvZLInlJOwCkq5zVm515IRxAqgRICwcxxH%2BSxi1u7Q%2F3t%2FIutuc7JC0XbKp%2B7Vbrmck1803fpcf91pPBo3aJ0%2FhwcxKEjNZ8n73LEz35txHVPfN1q8%2FVsTtk9A2NqlLfi%2BhK1oi%2FE4wpa9ZSGjBWf5Ks%2BZvaLTbhtfW3ov%2BpfaTNZ6X3vxf51kBaVf4OkmSZiaPn5Q8Qs8et4LPGegLmeiBWpXT72CnbmwrPwr%2F%2BmiPlrWQXXx2wNH07%2FGg9GsXs99xF1Aap7XMO9Nz6IzSJexnjPyXwbyzur%2F42L2QszoKrgULROOL0t4CLdfFlfTniNoT4gTJ3%2BDuehaiqNYj5E9W1eNGQvvz2m2vraUXiNxiY6m7rpGxwvdY0bELieriEmVvVsnmINnYmt7KbA81NCmytFKWllQAvQeSyanZfnmaikt9gs8LWpmj%2B19G09HV%2F3ZCGKv%2BoM%2FR7fDIlu%2BAyAS1lrLVc39LwZOjlNTU3KMUjCYcbVSK9s%2BNbJO7f7jw%2FfR7cN40H8Y393WdKiEldD21QQ9yU%2FKkqHCbfQLYUP53u1JwfXAg0NuBoZh2qwxQ971uB3vf22%2FEqBJQrVr2lUB7TqJtylvBlV2wbqRPYci7NHs4W46qjG0CgwN0akG0cxg5p9D2aSuxM65DG2vu7dbmTvSS%2BWSF4rtecF59CJZjbgVIO5JDmR8KOIGcy3%2BEtloNutfj2%2Bva8SthLV2ezXiblHGfCfeLeVkDjgSscwrfasz737jLuHjBrsCVGucqwLnQtD4PDhnZLcxBavsX9e8shKUays1r9w2mNktUgFc4g4BN%2FX7Nylsk0l2ULijz3x8oqw1jB9DV7ulZ%2FW5wHjnw%2FdlYj9l8CRTFm7IvBEeywahp9iTKJMIbP8tBMmDdu7MGGW3ZoJhOpOtGS3ldWhq6QPnZTdntG66pPTZ5YMPQUAw%2BnlGP3n0K5fa6F8%3D%3C%2Fdiagram%3E%3C%2Fmxfile%3E

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

> Os diagramas UML dos padrões **Singleton**, **Repository** e **MVC** estão disponíveis em `/docs/uml/`.

---

## 📈 Observações

- O sistema ultrapassou a meta de 20, totalizando **29 funcionalidades**.  
- Está totalmente funcional com Firebase integrado.

### 🔮 Futuras Melhorias
- Notificações push em tempo real.  
- Usar a localização do celular para mostrar usuarios mais pertos.  
- Modo escuro. 

