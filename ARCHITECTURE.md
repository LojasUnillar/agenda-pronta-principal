# Arquitetura do Projeto Agenda

Este projeto segue os princípios da **Clean Architecture** adaptada para Flutter, visando separação de responsabilidades, testabilidade e manutenibilidade.

## 1. Visão Geral

A aplicação é dividida em camadas principais:

- **Presentation (Apresentação)**: Contém UI (Widgets, Pages) e Gerenciamento de Estado (ViewModels).
- **Domain (Domínio)**: Contém as Regras de Negócio (Entities/Models, Interfaces de Repositórios/UseCases).
- **Data (Dados)**: Implementação dos Repositórios e Fontes de Dados (DataSources, APIs).
- **Core (Núcleo)**: Componentes compartilhados, injeção de dependência e utilitários.

## 2. Padrões Adotados

### MVVM (Model-View-ViewModel)

Utilizamos o padrão MVVM para gerenciamento de estado:

- **View**: Widgets Flutter que observam o ViewModel.
- **ViewModel**: `ChangeNotifier` que gerencia o estado da tela e chama a lógica de negócios.
- **Model**: Entidades de domínio.

### Injeção de Dependência

Utilizamos `get_it` para Service Locator, permitindo desacoplamento entre as camadas.

## 3. Componentes Core (UI Kit)

Para garantir consistência visual e facilidade de manutenção, criamos wrappers padrão para widgets comuns em `lib/core/widgets`:

### Componentes de Formulário

- **AppButton**: Botão padrão com suporte a estado de carregamento (`isLoading`).
- **AppTextField**: Campo de texto com estilização unificada.
- **AppSearchField**: Campo de busca para AppBars com design padronizado.

### Componentes de Feedback

- **AppEmptyState**: Widget para exibir estados de lista vazia de forma consistente.
- **AppErrorState**: Widget para exibir erros com opção de "Tentar novamente".
- **CustomLoader**: Indicador de carregamento personalizado.
- **CustomSnackbar**: Feedback visual para ações de sucesso ou erro.
- **SkeletonWidgets**: Placeholders de carregamento para listas e cartões.

### Componentes de Diálogo

- **AppConfirmDialog**: Dialog de confirmação (ex: excluir, cancelar).
  - Suporte a ações destrutivas (botão vermelho).
  - Método estático `show()` para uso simplificado.
- **AppActionDialog**: Dialog com campo de texto (ex: criar, editar).
  - Retorna o valor digitado.
  - Suporte a valor inicial.
- **AppMultiFieldDialog**: Dialog com múltiplos campos de texto.
  - Ideal para formulários simples (ex: nome + descrição).
  - Retorna lista de valores na ordem dos campos.

### Componentes de Lista

- **AppListCard**: Card padronizado para itens de lista.
  - Suporte a título, subtítulo, leading e actions.
  - Design consistente com Material Design 3.
- **AppFab**: FloatingActionButton padronizado.
  - Suporte a modo extended e mini.
  - Ícone e label configuráveis.

### Exemplo de Uso:

```dart
// Botão com loading
AppButton(
  label: "Salvar",
  isLoading: viewModel.isLoading,
  onPressed: viewModel.save,
);

// Campo de texto
AppTextField(
  controller: controller,
  label: "Nome",
  hint: "Digite o nome...",
  prefixIcon: Icons.person,
);

// Campo de busca na AppBar
AppSearchField(
  controller: searchController,
  hint: 'Buscar...',
  onChanged: viewModel.onSearchChanged,
  onClear: () => viewModel.onSearchChanged(''),
);

// Card de lista
AppListCard(
  title: brand.name,
  subtitle: brand.description,
  leading: Icon(Icons.label),
  actions: [
    IconButton(icon: Icon(Icons.edit), onPressed: () {}),
    IconButton(icon: Icon(Icons.delete), onPressed: () {}),
  ],
);

// Dialog de confirmação
final confirmed = await AppConfirmDialog.show(
  context: context,
  title: "Excluir",
  message: "Tem certeza?",
  isDanger: true,
);

// Dialog com input
final name = await AppActionDialog.show(
  context: context,
  title: "Nova Marca",
  fieldLabel: "Nome",
  actionLabel: "Criar",
);

// Dialog com múltiplos campos
final result = await AppMultiFieldDialog.show(
  context: context,
  title: "Novo Cargo",
  fields: [
    DialogFieldConfig(label: "Nome"),
    DialogFieldConfig(label: "Descrição"),
  ],
  actionLabel: "Criar",
);

// FAB padronizado
AppFab(
  label: "Novo",
  icon: Icons.add,
  onPressed: () {},
);
```

## 4. Backend (Supabase)

O projeto utiliza **Supabase** como Backend-as-a-Service:

- **Database**: PostgreSQL.
- **Auth**: Supabase Auth.
- **Storage**: Armazenamento de avatares e anexos.
- **Edge Functions**: Lógica de backend serverless (ex: Push Notifications).

## 5. Estrutura de Pastas

```
lib/
├── app/                  # Configurações globais (Theme, Routes)
├── core/                 # Código compartilhado
│   ├── constants/        # Constantes (Permissions, Assets)
│   ├── di/               # Injeção de Dependência
│   ├── error/            # Tratamento de erros
│   ├── presentation/     # Páginas compartilhadas
│   ├── services/         # Serviços core (Biometria, Conectividade)
│   ├── utils/            # Utilitários (Formatters, Validators)
│   └── widgets/          # Componentes Reutilizáveis (UI Kit)
├── features/             # Funcionalidades (Modularização)
│   ├── auth/             # Autenticação
│   ├── brands/           # Gestão de Marcas
│   ├── contacts/         # Gestão de Contatos
│   ├── departments/      # Gestão de Departamentos
│   ├── home/             # Tela Inicial
│   ├── notifications/    # Notificações
│   ├── products/         # Gestão de Produtos
│   ├── profile/          # Perfil de Usuário
│   └── settings/         # Configurações
└── main.dart             # Ponto de entrada
```

## 6. Fluxo de Desenvolvimento

1. **Criar UI**: Utilizar componentes do Core (`AppButton`, `AppTextField`, etc).
2. **Criar ViewModel**: Estender `ChangeNotifier`, injetar repositórios necessários.
3. **Definir Rotas**: Adicionar novas páginas em `AppRoutes`.
4. **Implementar Repositório**: Se houver chamadas ao banco, criar interface no Domain e implementação no Data.

## 7. Boas Práticas

- **Tradução**: Manter comentários e logs em Português (consistência). O código (variáveis) preferencialmente em Inglês.
- **Null Safety**: Garantir tratamento de nulos em toda a aplicação.
- **Lints**: Seguir as regras do linter configuradas no `analysis_options.yaml`.
- **UI Kit**: Sempre usar componentes do Core ao invés de widgets nativos diretamente.
- **Imports**: Preferir imports de pacote (`package:agenda/...`) ao invés de imports relativos (`../../...`).
- **DRY**: Não repetir código - usar componentes reutilizáveis sempre que possível.

## 8. Documentação

A documentação do código é essencial para a manutenção e escalabilidade do projeto. Utilizamos o **Dart Doc** (`///`) para documentar classes, métodos e propriedades públicas.

### Diretrizes

- **Idioma**: Toda a documentação deve ser escrita em **Português (Brasil)**.
- **Classes**: Devem ter uma descrição clara de sua responsabilidade, principais funcionalidades e exemplos de uso quando pertinente.
- **Métodos**: Devem descrever o que o método faz, seus parâmetros e o que retorna.
- **Widgets**: Devem explicar o propósito visual e os dados que consomem.
- **Formatação**: Utilize listas (bullet points) para enumerar funcionalidades ou requisitos.

### Exemplo de Documentação

```dart
/// ViewModel responsável pela gestão de marcas.
///
/// Gerencia o estado da tela de listagem de marcas, incluindo:
/// - Carregamento da lista de marcas
/// - Criação de novas marcas
/// - Edição de marcas existentes
/// - Exclusão de marcas
///
/// Comunica-se com [IBrandRepository] para persistência dos dados.
class ManageBrandsViewModel extends ChangeNotifier {
  /// Repositório de marcas injetado via construtor
  final IBrandRepository _repository;

  /// Cria uma nova instância do ViewModel
  ///
  /// [repository] - Repositório obrigatório para operações de dados
  ManageBrandsViewModel(this._repository);

  /// Carrega todas as marcas do repositório
  ///
  /// Atualiza [_brands] com os dados do backend e notifica listeners.
  /// Em caso de erro, armazena a mensagem em [_errorMessage].
  /// Define [_isLoading] como true durante a operação.
  Future<void> loadBrands() async {
    // ...
  }
}
```
