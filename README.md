# SkillMatch - Sistema de Match de Habilidades - 3A2

## Integrantes
- Caio Aguilar - 22300651  
- Francisco Flister - 22300910  
- Guilherme Souza - 22301119  
- Lucca Demaria - 22300457  
- Matheus Ferretti - 22301267  

---

## Checklist de Funcionalidades 

### Autenticação e Perfil
- [x] Cadastro de usuários (e-mail, telefone, redes sociais)
- [x] Login com autenticação (e-mail/senha, Google, Facebook)
- [x] Edição de perfil (foto, bio, habilidades, localização)
- [ ] Verificação de identidade (documento ou selfie)
- [ ] Sistema de reputação (avaliações por favores realizados)

### Match e Conexões
- [ ] Swipe de habilidades (like/dislike em perfis)
- [ ] Match recíproco (ambos curtiram as habilidades um do outro)
- [ ] Chat entre usuários após match
- [x] Filtros de busca (localização, tipo de habilidade, disponibilidade)
- [ ] Sugestões inteligentes (baseado em histórico de trocas)

### Sistema de Favores
- [x] Cadastro de habilidades (ex: "Aulas de violão", "Conserto de móveis")
- [ ] Solicitação de favor (descrição, prazo, valor em créditos)
- [ ] Aceite/rejeição de favor
- [ ] Confirmação de conclusão do favor

### Segurança e Moderação
- [ ] Denúncia de usuários/comportamento inadequado
- [ ] Bloqueio de contatos indesejados
- [ ] Moderação manual de anúncios de habilidades
- [ ] Privacidade (opção de perfil anônimo ou restrito)

### Notificações e Engajamento
- [ ] Notificação de match
- [ ] Lembrete de favor pendente
- [ ] Push notifications para novas mensagens
- [ ] Sistema de feedback (estrelas/comentários)

### Extras e Monetização
- [ ] Assinatura premium (mais visibilidade, filtros avançados)
- [ ] Anúncios de serviços profissionais (opcional)
- [ ] Integração com pagamentos (caso envolva valores monetários)
- [ ] Gamificação (badges por trocas bem-sucedidas)

#### Arquitetura
- **Model**: Classes de dados (models/)
- **View**: Widgets de interface (views/)
- **Controller**: Gerenciamento de estado (controllers/)
- **Repository**: Gerenciamento de persistência (repositories/)


##### Como Executar o Projet
Clone o repositório:
```bash
git clone https://github.com/caioarlima/SkillMatch
cd skillmatch
flutter pub get
flutter run
