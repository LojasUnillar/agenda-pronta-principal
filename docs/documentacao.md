# Documentação do Projeto — Agenda Inteligente

## Visão Geral

Aplicativo Flutter de gestão de contatos e fornecedores com notificações em tempo real, controle de acesso por permissões e favoritos pessoais por usuário.

**Stack:** Flutter · Supabase · Firebase FCM · Provider · GetIt

---

## Arquitetura

O projeto segue **Clean Architecture** com separação em camadas por feature:

```
lib/
├── app/                    → Configurações globais (tema, rotas, cores)
├── core/                   → Utilitários, serviços, DI, erros, widgets compartilhados
└── features/
    ├── auth/               → Login, registro, sessão, biometria
    ├── brands/             → Gerenciamento de marcas
    ├── contacts/           → Listagem, detalhes e cadastro de contatos/fornecedores
    ├── departments/        → Departamentos (acesso rápido na Home)
    ├── favorites/          → Favoritos pessoais por usuário
    ├── home/               → Tela principal, navegação, header, acesso rápido
    ├── notifications/      → Notificações em tempo real via Supabase Realtime
    ├── products/           → Gerenciamento de produtos
    ├── profile/            → Gerenciamento de usuários e cargos
    └── settings/           → Permissões de cargos
```

Cada feature adota a estrutura:
```
feature/
├── data/           → Implementações de repositórios (Supabase)
├── domain/
│   ├── models/     → Modelos de dados
│   └── repositories/ → Interfaces (contratos)
└── presentation/
    ├── pages/      → Telas
    ├── viewmodel/  → Estado (ChangeNotifier)
    └── widgets/    → Componentes reutilizáveis da feature
```

---

## Camada APP

### `app.dart`
Widget raiz da aplicação. Configura `MaterialApp` com:
- Locale `pt_BR`
- Tema claro/escuro via `AppTheme`
- Roteamento via `AppRoutes`
- Observer `homeRouteObserver` para detectar retorno à Home

### `app_colors.dart`
Paleta de cores centralizada (`AppColors`):
- `brandBlue` — cor primária da marca
- `success` / `error` — cores semânticas

### `app_routes.dart`
Mapa de rotas nomeadas (`AppRoutes`). Centraliza navegação e injeção de ViewModels por rota.

### `app_theme.dart`
Temas claro e escuro (`AppTheme`). Define `ColorScheme`, estilos de botões, inputs, cards e menus.

---

## Camada CORE

### Config
| Arquivo | Descrição |
|---|---|
| `env.dart` | Carrega variáveis de ambiente de `.env.dev` / `.env.prod`. Ajusta URL do Supabase para emulador Android. |

### Constants
| Arquivo | Descrição |
|---|---|
| `app_permissions.dart` | Constantes de código de todas as permissões do sistema (ex: `accessFav`, `createUser`, `receiveNewContactNotif`) |
| `permission_metadata.dart` | Metadados de cada permissão para exibição na UI (label, grupo) |

### DI
| Arquivo | Descrição |
|---|---|
| `service_locator.dart` | Configura injeção de dependência via GetIt. Registra repositórios como `LazySingleton` e ViewModels como `Factory`. |

### Errors
| Arquivo | Descrição |
|---|---|
| `exceptions.dart` | Hierarquia de exceções: `AppException` → `ServerException`, `AuthException`, `CacheException` |
| `failure.dart` | Falhas de domínio: `ServerFailure`, `AuthFailure`, `ConnectionFailure` |

### Services
| Arquivo | Descrição |
|---|---|
| `biometric_service.dart` | Autenticação biométrica (TouchID / FaceID) via `local_auth` |
| `connectivity_service.dart` | Verificação de conectividade via `connectivity_plus` |
| `push_notification_service.dart` | Push Notifications via Firebase FCM + `flutter_local_notifications` para foreground |

### Utils
| Arquivo | Descrição |
|---|---|
| `app_formatters.dart` | Máscaras de input: `CnpjInputFormatter`, `CpfInputFormatter`, `PhoneInputFormatter` |
| `app_validators.dart` | Validação de CNPJ e CPF com algoritmo de dígitos verificadores |

---

## Features

### AUTH
Responsável por login, registro, sessão persistente e biometria.

| Arquivo | Descrição |
|---|---|
| `i_auth_repository.dart` | Interface: `login`, `signUp`, `logout`, `isSessionValid`, `refreshCurrentUser`, `uploadAvatarImage`, `saveFcmToken` |
| `auth_repository_supabase.dart` | Implementação com Supabase Auth + SecureStorage para credenciais |
| `user_model.dart` | Modelo do usuário: `id`, `name`, `login`, `token`, `roles`, `permissions`, `avatarUrl`, `isActive` |
| `login_viewmodel.dart` | Login por senha ou biometria. Valida conectividade antes de cada tentativa. |
| `splash_viewmodel.dart` | Verifica sessão ativa ao abrir o app. Navega para Home ou Login. |

---

### CONTACTS

| Arquivo | Descrição |
|---|---|
| `contact_model.dart` | Modelo completo com 40+ campos: CNPJ, tipo, departamentos, telefones, avaliação, status, etc. |
| `evaluation_model.dart` | Representa avaliação (⭐) ou anotação de texto de um contato. Ambos são opcionais. |
| `department_args.dart` | Objeto de navegação com `id` e `name` do departamento para passar entre rotas |
| `i_supplier_repository.dart` | Interface CRUD de contatos + avaliações |
| `supabase_contacts_repository.dart` | Implementação Supabase para busca por departamento, CNPJ, ID, e avaliações |
| `contacts_list_viewmodel.dart` | Listagem com filtros de texto, status, tipo, marca, produto e ordenação |
| `supplier_details_page.dart` | Tela de perfil: dados, números relacionados, avaliações, anotações, favorito (⭐), edição |

**Enums:**
- `ContactSortOption` — opções de ordenação da lista (A-Z, Z-A, recente, mais frequente, etc.)
- `ContactStatusFilter` — filtro de status (todos / ativos / inativos)

---

### FAVORITES

Sistema de favoritos **pessoal por usuário** usando a tabela `tb_favoritos`.

| Arquivo | Descrição |
|---|---|
| `i_favorite_repository.dart` | Interface: `getFavorites`, `toggleFavorite`, `isFavorite` |
| `favorite_repository_supabase.dart` | Implementação Supabase com JOIN em `tb_contatos` para retornar `ContactModel` completo |
| `favorites_viewmodel.dart` | Cache local de IDs favoritados, toggle otimista, `loadFavorites`, `initCache` |
| `favorites_page.dart` | Lista os favoritos do usuário. Pull-to-refresh, estado vazio, desfavoritar por item. |

**Banco de dados:**
```sql
tb_favoritos (id UUID, user_id UUID, contact_id UUID, created_at TIMESTAMPTZ)
-- RLS: cada usuário acessa apenas seus próprios favoritos
```

---

### NOTIFICATIONS

Notificações em tempo real via Supabase Realtime.

| Arquivo | Descrição |
|---|---|
| `i_notification_repository.dart` | Interface: `notificationsStream`, `markAsRead`, `markAllAsRead`, `createNotification`, `deleteNotification` |
| `notification_repository_supabase.dart` | Realtime stream por usuário. _deletedIds para remoção otimista. Deleta leituras antes da notificação (FK). |
| `notification_viewmodel.dart` | Estado de seleção, exclusão em lote, toggle de leitura |
| `notifications_page.dart` | Lista com modo de seleção, exclusão simples e em lote, marcar todas como lidas |

**Tabelas:** `tb_notificacao`, `tb_notificacoes_leituras`

**Tipos de notificação disparados automaticamente:**
| Evento | Permissão necessária |
|---|---|
| Novo contato cadastrado | `receiveNewContactNotif` |
| Novo número relacionado adicionado | `receiveContactUpdateNotif` |
| Nova anotação adicionada | `receiveContactAnnotationNotif` |

---

### HOME

| Arquivo | Descrição |
|---|---|
| `home_viewmodel.dart` | Índice de navegação, dados do usuário, contagem de notificações, itens de acesso rápido, FCM token |
| `home_page.dart` | Scaffold com `HomeHeader`, `QuickAccessSection`, `HomeBottomNav`. RouteObserver para refresh ao retornar. |
| `home_bottom_nav.dart` | Barra inferior com Home (sempre), Favoritos, Usuários e Config (condicionais por permissão) |
| `home_header.dart` | Cabeçalho com avatar, saudação, badge de notificações |
| `quick_access_section.dart` | Grid de departamentos carregados do banco |

---

### PROFILE
Gestão de usuários e cargos.

| Arquivo | Descrição |
|---|---|
| `role_model.dart` | Cargo com `id`, `name`, `description`, `permissions` |
| `user_status_filter.dart` | Enum `UserStatusFilter` (all / active / inactive) com extensão de label e `isActiveParam` |
| `i_profile_repository.dart` | Interface: busca, criação, edição de usuários; CRUD de cargos; `getUserIdsByPermission` |
| `search_profile_viewmodel.dart` | Busca de usuários com filtros de texto e status |
| `create_profile_viewmodel.dart` | Criação de usuário com cargo |
| `edit_profile_viewmodel.dart` | Edição de perfil próprio incluindo avatar |

---

### BRANDS / PRODUCTS
CRUD simples de marcas e produtos para categorização de contatos.

| Arquivo | Descrição |
|---|---|
| `brand_model.dart` / `product_model.dart` | Modelos com `id`, `name`, `createdAt` |
| `manage_brands_viewmodel.dart` / `manage_products_viewmodel.dart` | CRUD com estados de carregamento e erro |

---

### SETTINGS
| Arquivo | Descrição |
|---|---|
| `manage_roles_viewmodel.dart` | Carrega cargos (exclui admin), cria novos cargos, atualiza permissões |
| `edit_role_permissions_page.dart` | Tela de edição de permissões de um cargo com switches por grupo |

---

## Banco de Dados (Supabase)

| Tabela | Descrição |
|---|---|
| `auth.users` | Usuários do Supabase Auth |
| `tb_usuario` | Dados extras do usuário (nome, avatar, cargo) |
| `tb_cargo` | Cargos/roles do sistema |
| `tb_permissao` | Permissões individuais |
| `tb_cargo_permissao` | Relação cargo ↔ permissão |
| `tb_contatos` | Contatos/fornecedores |
| `tb_departamento` | Departamentos |
| `tb_avaliacoes_fornecedor` | Avaliações e anotações de fornecedores |
| `tb_notificacao` | Notificações |
| `tb_notificacoes_leituras` | Status de leitura por usuário |
| `tb_favoritos` | Favoritos pessoais por usuário |
| `tb_fcm_tokens` | Tokens FCM para push notifications |
| `tb_marcas` | Marcas de produtos |
| `tb_produtos` | Produtos |

---

## Permissões disponíveis (`AppPermissions`)

| Código | Descrição |
|---|---|
| `accessFav` | Acessa a aba Favoritos |
| `accessUsersTab` | Acessa a aba Usuários |
| `accessConfig` | Acessa Configurações |
| `createContact` | Cria contatos |
| `editContact` | Edita contatos |
| `evaluateSupplier` | Avalia fornecedores (estrelas) |
| `commentSupplier` | Adiciona anotações em fornecedores |
| `sendNotification` | Envia notificações |
| `receiveNewContactNotif` | Recebe notificação de novo contato |
| `receiveContactUpdateNotif` | Recebe notificação de novo número em contato |
| `receiveContactAnnotationNotif` | Recebe notificação de nova anotação em contato |
| `createUser` | Cria usuários |
| `editUser` | Edita usuários |
