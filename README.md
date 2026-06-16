# Agenda App (Legacy Refactor)

Aplicativo Flutter para gestão de agendas, fornecedores e usuários.
Este projeto está passando por um processo de refatoração para modernização da arquitetura, padronização de tratamento de erros e melhorias de segurança.

## 🏗 Arquitetura

O projeto segue uma arquitetura modular baseada em **Feature-First** e **Clean Architecture**:

```
lib/
├── app/                  # Configurações globais (AppWidget, Rotas, Temas)
├── core/                 # Códigos compartilhados (Erros, DI, Widgets básicos)
│   ├── errors/           # Failure e Exception classes
│   ├── di/               # Injeção de Dependências (GetIt)
│   └── ...
├── features/             # Módulos funcionais
│   ├── auth/             # Autenticação (Login, Biometria)
│   ├── home/             # Tela principal e navegação
│   ├── profile/          # Gestão de perfil e usuários
│   ├── suppliers/        # Lista de fornecedores
│   └── ...
└── main.dart             # Ponto de entrada
```

### Tecnologias Principais

- **Gerenciamento de Estado**: `Provider` / `ChangeNotifier`
- **Injeção de Dependência**: `get_it`
- **Backend / Auth**: `Supabase`
- **Armazenamento Seguro**: `flutter_secure_storage`
- **Biometria**: `local_auth`

## 🛡 Padrões Adotados (Recentes)

### 1. Tratamento de Erros
Utilizamos classes tipadas para erros, evitando o uso de Strings ou Exceptions genéricas.

- **Data Layer**: Lança `AppException` (ex: `AuthException`, `ServerException`).
- **Domain Layer**: (Futuro) Retornará `Failure` (ex: `AuthFailure`).
- **Presentation Layer**: Captura `AppException` específica e exibe mensagem amigável.

### 2. Navegação
A lógica de navegação foi desacoplada das ViewModels.
- **ViewModel**: Retorna `bool` ou `void` indicando sucesso/falha da operação.
- **View (Page)**: Observa o resultado e executa `Navigator.push...`.

### 3. Autenticação
O armazenamento de senha em texto plano foi removido (ou despriorizado) em favor de Tokens JWT.
A validação de sessão checa primeiro a validade do Token antes de tentar re-login com credenciais.

## 🚀 Como Rodar

4. **Configuração**:
   - O projeto utiliza variáveis de ambiente para configuração (Supabase).
   - Navegue até `assets/env/` e crie cópias de `.env.example`:
     - Crie `.env.dev` para desenvolvimento.
     - Crie `.env.prod` para produção (se necessário).
   - Preencha as chaves `SUPABASE_URL` e `SUPABASE_KEY` nos arquivos criados.

2. **Dependências**:
   ```bash
   flutter pub get
   ```

3. **Execução**:
   ```bash
   flutter run
   ```

## 📝 TODOs & Melhorias Futuras
- [ ] Implementar Testes Unitários (foco em ViewModels).
- [ ] Migrar totalmente para `dart-define` ou `envied` para variáveis de ambiente.
- [ ] Refatorar módulo de Notifications.
