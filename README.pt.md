<br>
<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
</div>
<br>

<p align="center">
  <strong>Idioma:</strong>
  <a href="README.md">English</a> | <a href="README.es.md">Español</a> | <strong>Português (BR)</strong>
</p>

<h1 align="center">Scroll Infinity</h1>

<p align="center">
  Um widget Flutter que fornece uma lista de rolagem infinita com suporte nativo para carregamento paginado de dados, gerenciamento de estados e customização flexível.
  <br>
  <a href="#sobre-o-projeto"><strong>Explore a documentação »</strong></a>
  <br><br>
  <a href="https://pub.dev/packages/scroll_infinity">Ver no pub.dev</a>
  ·
  <a href="https://github.com/dariomatias-dev/scroll_infinity/issues">Reportar Bug</a>
  ·
  <a href="https://github.com/dariomatias-dev/scroll_infinity/issues">Solicitar Funcionalidade</a>
</p>

<div align="center">
  <img src="https://img.shields.io/pub/v/scroll_infinity.svg">
  <img src="https://img.shields.io/pub/likes/scroll_infinity">
  <img src="https://img.shields.io/pub/points/scroll_infinity">
</div>

## Sumário

- [Sobre o Projeto](#sobre-o-projeto)
- [Funcionalidades](#funcionalidades)
- [Construído Com](#construído-com)
- [Começando](#começando)
  - [Requisitos](#requisitos)
  - [Instalação](#instalação)
- [Uso](#uso)
  - [Rolagem Vertical Básica](#rolagem-vertical-básica)
  - [Rolagem Horizontal Básica](#rolagem-horizontal-básica)
  - [Rolagem Vertical com Intervalo](#rolagem-vertical-com-intervalo)
  - [Controller (Refresh & Retry)](#controller-refresh--retry)
  - [Trocando a Fonte de Dados](#trocando-a-fonte-de-dados)
  - [Pull-to-Refresh](#pull-to-refresh)
  - [Carregamento Manual](#carregamento-manual)
  - [Callbacks de Erro e Analytics](#callbacks-de-erro-e-analytics)
- [Propriedades](#propriedades)
- [Contribuindo](#contribuindo)
- [Licença](#licença)
- [Autor](#autor)

## Sobre o Projeto

O ScrollInfinity simplifica a implementação de listas de rolagem infinita no Flutter. Ele gerencia o carregamento paginado, os estados (carregando, vazio, erro) e as interações do usuário, permitindo que o desenvolvedor foque na construção da UI dos itens.

Oferece customização para carregamento manual/automático, widgets de estado personalizados e layouts vertical e horizontal.

### Ambiente de Desenvolvimento

| Ferramenta  | Versão Utilizada |
| ----------- | ----------------- |
| Flutter SDK | 3.44.6            |
| Dart SDK    | 3.12.2            |

## Funcionalidades

- Rolagem infinita com paginação
- Carregamento de dados manual ou automático
- Builders customizados para "Carregar Mais" e "Tentar Novamente"
- Gerenciamento dos estados de carregamento, erro e vazio
- Scrollbars, widget de cabeçalho e separadores opcionais
- Suporte a rolagem vertical e horizontal
- Direção de rolagem invertida (ex.: listas estilo chat)
- Suporte a itens iniciais
- Inserção de valores nulos em intervalos (anúncios/divisores)
- Limite de tentativas de retry em caso de erro
- Mapeamento do índice real dos itens com intervalos
- `ScrollInfinityController` para refresh/retry externos
- `ScrollController` externo para voltar ao topo e ler o offset
- Suporte a pull-to-refresh
- Limite configurável para disparo do carregamento da próxima página
- Callbacks `onError` e `onItemsLoaded` para logs/analytics
- Callback `onEndOfList` e getter `hasReachedEnd` para a última página
- A falha que causou o estado de erro é entregue ao `tryAgainBuilder`
- Passthrough de `physics`, `shrinkWrap`, `cacheExtent`, `itemExtent`, `prototypeItem`, `addAutomaticKeepAlives`, `keyboardDismissBehavior` e `restorationId` para o `ListView` interno

## Construído Com

- **[Flutter](https://flutter.dev/)** - Um toolkit de UI do Google para criar aplicações bonitas e nativamente compiladas para mobile, web e desktop a partir de uma única base de código.
- **[Dart](https://dart.dev/)** - A linguagem de programação usada pelo Flutter, otimizada para criar aplicações rápidas em qualquer plataforma.

## Começando

### Requisitos

| Requisito   | Versão          |
| ----------- | --------------- |
| Dart SDK    | >=3.12.0 <4.0.0 |
| Flutter SDK | >=3.44.0        |

Suporta Android, iOS, web, Windows, Linux e macOS.

> **Atenção:** o SDK mínimo foi elevado para **Dart 3.12 / Flutter 3.44**. Em SDKs mais antigos (como o Flutter 3.35) o `flutter pub get` não conseguirá resolver as dependências — atualize o SDK antes ou permaneça no `scroll_infinity: 0.5.2`.

### Instalação

```bash
flutter pub add scroll_infinity
```

## Uso

A paginação solicita uma nova página quando o usuário atinge o final da lista.
Se `loadData` retornar `null`, o estado de erro é exibido.

**Nota:** Utilize um tipo anulável `T?` ao usar `interval`, pois valores nulos são inseridos.

Uma demonstração totalmente configurável, com todas as propriedades conectadas a controles de UI, está disponível no diretório [example](example).

### Rolagem Vertical Básica

```dart

import 'package:flutter/material.dart';
import 'package:scroll_infinity/scroll_infinity.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _maxItems = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ScrollInfinity<int>(
          maxItems: _maxItems,
          loadData: (page) async {
            await Future.delayed(const Duration(seconds: 2));

            return List.generate(
              _maxItems,
              (index) => page * _maxItems + index + 1,
            );
          },
          itemBuilder: (value, index) {
            return ListTile(
              title: Text('Item $value'),
              subtitle: Text('Subtitle $value'),
            );
          },
        ),
      ),
    );
  }
}
```

### Rolagem Horizontal Básica

```dart

import 'package:flutter/material.dart';
import 'package:scroll_infinity/scroll_infinity.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _maxItems = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 100.0,
          child: ScrollInfinity<int>(
            scrollDirection: Axis.horizontal,
            maxItems: _maxItems,
            loadData: (page) async {
              await Future.delayed(const Duration(seconds: 2));

              return List.generate(
                _maxItems,
                (index) => page * _maxItems + index + 1,
              );
            },
            itemBuilder: (value, index) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Item $value'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
```

### Rolagem Vertical com Intervalo

```dart

import 'package:flutter/material.dart';
import 'package:scroll_infinity/scroll_infinity.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _maxItems = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ScrollInfinity<int?>(
          maxItems: _maxItems,
          interval: 2,
          loadData: (page) async {
            await Future.delayed(const Duration(seconds: 2));

            return List.generate(
              _maxItems,
              (index) => page * _maxItems + index + 1,
            );
          },
          itemBuilder: (value, index) {
            if (value == null) return const Divider();

            return ListTile(
              title: Text('Item $value'),
            );
          },
        ),
      ),
    );
  }
}
```

### Controller (Refresh & Retry)

Use um `ScrollInfinityController` para disparar `refresh()`/`retry()` de fora do widget (ex.: um botão) e para ler `isLoading`/`hasError`. O dispose cabe a quem criou a instância e deve ser feito no `dispose()`.

`retry()` refaz a requisição da página que falhou. Não faz nada quando a última busca teve sucesso ou quando o limite de `maxRetries` foi atingido — nesses casos, use `refresh()` para reiniciar a lista.

Para controlar a posição do scroll em vez da paginação, passe um `ScrollController` comum em `scrollController`. A lista usa um interno quando o parâmetro é omitido, e nunca faz dispose do controller recebido.

```dart
final _scrollController = ScrollController();

void _scrollToTop() {
  _scrollController.animateTo(
    0,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );
}
```

```dart
final _controller = ScrollInfinityController();

@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  return ScrollInfinity<int>(
    controller: _controller,
    maxItems: _maxItems,
    loadData: _loadData,
    itemBuilder: _itemBuilder,
  );
}

// Em outro lugar, ex.: um FloatingActionButton:
onPressed: () => _controller.refresh(),
```

### Trocando a Fonte de Dados

`loadData` é uma `Function`, então passar uma closure inline (ex.: `loadData: (page) => ...`) cria uma nova instância a cada rebuild — comparar por identidade resetaria a lista a cada `setState` do widget pai, o que raramente é o comportamento desejado. Por isso, trocar apenas `loadData` **não** reseta a lista.

Para carregar um conjunto de dados diferente (ex.: mudar categoria ou termo de busca), use uma das opções:

- Chame `_controller.refresh()` explicitamente quando a fonte mudar, ou
- Dê ao `ScrollInfinity` uma nova `Key` (ex.: `ValueKey(categoria)`) para o Flutter remontá-lo do zero.

```dart
ScrollInfinity<int>(
  key: ValueKey(_categoria),
  maxItems: _maxItems,
  loadData: (page) => _loadData(_categoria, page),
  itemBuilder: _itemBuilder,
)
```

### Pull-to-Refresh

Defina `enablePullToRefresh` para envolver a lista em um `RefreshIndicator` que reinicia a paginação a partir de `initialPageIndex`.

```dart
ScrollInfinity<int>(
  enablePullToRefresh: true,
  maxItems: _maxItems,
  loadData: _loadData,
  itemBuilder: _itemBuilder,
)
```

### Carregamento Manual

Defina `automaticLoading` como `false` para exibir um botão "Carregar Mais" em vez de buscar automaticamente ao rolar. Customize-o com `loadMoreBuilder`.

```dart
ScrollInfinity<int>(
  automaticLoading: false,
  loadMoreBuilder: (action) {
    return TextButton(
      onPressed: action,
      child: const Text('Carregar mais'),
    );
  },
  maxItems: _maxItems,
  loadData: _loadData,
  itemBuilder: _itemBuilder,
)
```

### Callbacks de Erro e Analytics

Use `onError` para logar/reportar falhas — a exceção lançada por `loadData`, ou uma `Exception` sintética quando `loadData` retorna `null` em vez de lançar — e `onItemsLoaded` para observar os itens buscados com sucesso (ex.: analytics). Nenhum dos dois afeta o build.

`onEndOfList` dispara quando a última página chega, ou seja, quando `loadData` retorna menos itens que `maxItems`. Um reset inicia um novo ciclo, que pode chegar ao fim outra vez. Para ler esse mesmo estado em vez de reagir a ele, use `ScrollInfinityController.hasReachedEnd`.

```dart
ScrollInfinity<int>(
  onError: (error) => log('Falha ao carregar itens', error: error),
  onItemsLoaded: (items) => analytics.logEvent('items_loaded', {'count': items.length}),
  onEndOfList: () => log('Todas as páginas carregadas'),
  maxItems: _maxItems,
  loadData: _loadData,
  itemBuilder: _itemBuilder,
)
```

## Propriedades

**Manipulação de Dados Principal**

| Nome             | Tipo                                  | Padrão | Descrição                                        |
| ---------------- | ------------------------------------- | ------ | -------------------------------------------------- |
| loadData         | `Future<List<T>?> Function(int)`      | -      | Busca os dados de cada página                     |
| itemBuilder      | `Widget Function(T value, int index)` | -      | Constrói cada item. `index` é mapeado por `useRealItemIndex`/`interval` |
| maxItems         | `int`                                 | -      | Máximo de itens por requisição                     |
| initialItems     | `List<T>?`                            | null   | Itens antes da primeira busca. Não avança a paginação: defina `initialPageIndex` após eles para não buscar a mesma página de novo. Aplicado apenas na inicialização e no reset |
| initialPageIndex | `int`                                 | 0      | Índice da página inicial. Alterá-lo reinicia a lista |
| controller       | `ScrollInfinityController?`           | null   | Refresh/retry externos e estado de loading/erro    |
| scrollController | `ScrollController?`                   | null   | Posição de scroll externa (voltar ao topo, offset). Pertence ao chamador; usa um interno quando nulo |
| onItemsLoaded    | `void Function(List<T> items)?`       | null   | Chamado com os itens de cada busca bem-sucedida    |
| onEndOfList      | `VoidCallback?`                       | null   | Chamado quando a última página é carregada         |

**Layout e Aparência**

| Nome                | Tipo                                  | Padrão   | Descrição                                            |
| ------------------- | ------------------------------------- | -------- | ----------------------------------------------------- |
| scrollDirection     | `Axis`                                | vertical | Direção da rolagem                                     |
| reverse             | `bool`                                | false    | Inverte a direção de rolagem/crescimento (ex.: chats)  |
| padding             | `EdgeInsetsGeometry?`                 | null     | Preenchimento interno                                  |
| header              | `Widget?`                             | null     | Widget de cabeçalho                                    |
| separatorBuilder    | `Widget Function(BuildContext, int)?` | null     | Separadores. `index` é a posição de exibição crua, sem mapeamento por `useRealItemIndex`/`interval` |
| scrollbars          | `bool`                                | true     | Exibe scrollbars                                       |
| enablePullToRefresh | `bool`                                | false    | Envolve a lista em um `RefreshIndicator`               |
| physics             | `ScrollPhysics?`                      | null     | Passado para o `ListView` interno                      |
| shrinkWrap          | `bool`                                | false    | Passado para o `ListView` interno                      |
| cacheExtent         | `double?`                             | null     | Passado para o `ListView` interno                      |
| itemExtent          | `double?`                             | null     | Extensão fixa para todo filho, incluindo header e rodapé. Não permitido com `prototypeItem` nem `separatorBuilder` |
| prototypeItem       | `Widget?`                             | null     | Dimensiona todo filho conforme este widget. Mesmas restrições de `itemExtent` |
| addAutomaticKeepAlives | `bool`                             | true     | Passado para o `ListView` interno                      |
| keyboardDismissBehavior | `ScrollViewKeyboardDismissBehavior?` | null  | Fechamento do teclado ao arrastar; sem valor, decide o `ScrollBehavior` do contexto |
| restorationId       | `String?`                             | null     | Restaura a posição de scroll (não as páginas carregadas) |

**Recursos Comportamentais**

| Nome              | Tipo     | Padrão | Descrição                                          |
| ----------------- | -------- | ------ | ---------------------------------------------------- |
| interval          | `int?`   | null   | Intervalo de inserção de itens nulos                 |
| useRealItemIndex  | `bool`   | true   | Indexação independente                               |
| automaticLoading  | `bool`   | true   | Busca automática ao rolar                            |
| loadMoreThreshold | `double` | 200    | Distância do fim da lista que dispara a próxima página |

**Tratamento de Erros**

| Nome               | Tipo                          | Padrão | Descrição                          |
| ------------------ | ------------------------------ | ------ | ------------------------------------ |
| maxRetries         | `int?`                         | null   | Novas tentativas permitidas após uma falha, sem contar a tentativa inicial. `0` torna a falha definitiva; combine com `retryLimitReached: const SizedBox.shrink()` para falhar em silêncio |
| onError            | `void Function(Object error)?` | null   | Chamado em caso de falha, com a exceção lançada ou uma sintética quando `loadData` retorna `null` |

**Widgets Específicos de Estado**

| Nome              | Tipo                              | Padrão | Descrição                            |
| ----------------- | --------------------------------- | ------ | -------------------------------------- |
| loading           | `Widget?`                         | null   | Widget do estado de carregamento       |
| empty             | `Widget?`                         | null   | Widget do estado vazio                 |
| tryAgainBuilder   | `Widget Function(Object, VoidCallback)?`  | null   | Widget de "Tentar Novamente", construído com a falha que causou o estado de erro |
| loadMoreBuilder   | `Widget Function(VoidCallback)?`  | null   | Widget de "Carregar Mais"              |
| retryLimitReached | `Widget?`                         | null   | Widget de limite de tentativas atingido |

## Contribuindo

1. Faça um fork do projeto
2. Crie uma branch de funcionalidade:

   ```bash
   git checkout -b feature/AmazingFeature
   ```

3. Faça o commit das alterações:

   ```bash
   git commit -m 'Add some AmazingFeature'
   ```

4. Faça o push da branch:

   ```bash
   git push origin feature/AmazingFeature
   ```

5. Abra um Pull Request

## Licença

Distribuído sob a Licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais informações.

## Autor

Desenvolvido por **Dário Matias**:

- Portfolio: [https://dariomatias-dev.com](https://dariomatias-dev.com)
- GitHub: [https://github.com/dariomatias-dev](https://github.com/dariomatias-dev)
- Email: [matiasdario75@gmail.com](mailto:matiasdario75@gmail.com)
- Instagram: [https://instagram.com/dariomatias_dev](https://instagram.com/dariomatias_dev)
- LinkedIn: [https://linkedin.com/in/dariomatias-dev](https://linkedin.com/in/dariomatias-dev)
