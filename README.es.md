<br>
<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
</div>
<br>

<p align="center">
  <strong>Idioma:</strong>
  <a href="README.md">English</a> | <strong>Español</strong> | <a href="README.pt.md">Português (BR)</a>
</p>

<h1 align="center">Scroll Infinity</h1>

<p align="center">
  Un widget de Flutter que proporciona una lista de desplazamiento infinito con soporte nativo para carga paginada de datos, gestión de estados y personalización flexible.
  <br>
  <a href="#sobre-el-proyecto"><strong>Explora la documentación »</strong></a>
  <br><br>
  <a href="https://pub.dev/packages/scroll_infinity">Ver en pub.dev</a>
  ·
  <a href="https://github.com/dariomatias-dev/scroll_infinity/issues">Reportar Error</a>
  ·
  <a href="https://github.com/dariomatias-dev/scroll_infinity/issues">Solicitar Funcionalidad</a>
</p>

<div align="center">
  <img src="https://img.shields.io/pub/v/scroll_infinity.svg">
  <img src="https://img.shields.io/pub/likes/scroll_infinity">
  <img src="https://img.shields.io/pub/points/scroll_infinity">
</div>

## Índice

- [Sobre el Proyecto](#sobre-el-proyecto)
- [Funcionalidades](#funcionalidades)
- [Construido Con](#construido-con)
- [Primeros Pasos](#primeros-pasos)
  - [Requisitos](#requisitos)
  - [Instalación](#instalación)
- [Uso](#uso)
  - [Desplazamiento Vertical Básico](#desplazamiento-vertical-básico)
  - [Desplazamiento Horizontal Básico](#desplazamiento-horizontal-básico)
  - [Desplazamiento Vertical con Intervalo](#desplazamiento-vertical-con-intervalo)
  - [Controller (Refresh & Retry)](#controller-refresh--retry)
  - [Cambiando la Fuente de Datos](#cambiando-la-fuente-de-datos)
  - [Pull-to-Refresh](#pull-to-refresh)
  - [Carga Manual](#carga-manual)
  - [Callbacks de Error y Analytics](#callbacks-de-error-y-analytics)
- [Propiedades](#propiedades)
- [Contribuyendo](#contribuyendo)
- [Licencia](#licencia)
- [Autor](#autor)

## Sobre el Proyecto

ScrollInfinity simplifica la implementación de listas de desplazamiento infinito en Flutter. Se encarga de la carga paginada, la gestión de estados (cargando, vacío, error) y las interacciones del usuario, permitiendo que la persona desarrolladora se concentre en construir la interfaz de los ítems.

Ofrece personalización para carga manual/automática, widgets de estado propios y disposiciones tanto verticales como horizontales.

### Entorno de Desarrollo

| Herramienta | Versión Utilizada |
| ----------- | ----------------- |
| Flutter SDK | 3.44.6            |
| Dart SDK    | 3.12.2            |

## Funcionalidades

- Desplazamiento infinito con paginación
- Carga de datos manual o automática
- Builders personalizados para "Cargar Más" y "Reintentar"
- Gestión de los estados de carga, error y vacío
- Barras de desplazamiento, widget de encabezado y separadores opcionales
- Soporte para desplazamiento vertical y horizontal
- Dirección de desplazamiento invertida (ej.: listas estilo chat)
- Soporte para ítems iniciales
- Inserción de valores nulos en intervalos (anuncios/divisores)
- Límite de reintentos en caso de error
- Mapeo del índice real de los ítems con intervalos
- `ScrollInfinityController` para refresh/retry externos
- `ScrollController` externo para volver arriba y leer el offset
- Soporte para pull-to-refresh
- Umbral configurable para disparar la carga de la siguiente página
- Callbacks `onError` y `onItemsLoaded` para logs/analytics
- Callback `onEndOfList` y getter `hasReachedEnd` para la última página
- El fallo que causó el estado de error se entrega a `tryAgainBuilder`
- Passthrough de `physics`, `shrinkWrap`, `cacheExtent`, `itemExtent`, `prototypeItem`, `addAutomaticKeepAlives`, `keyboardDismissBehavior` y `restorationId` al `ListView` interno

## Construido Con

- **[Flutter](https://flutter.dev/)** - Un toolkit de UI de Google para construir aplicaciones bonitas y compiladas nativamente para móvil, web y escritorio desde una única base de código.  
- **[Dart](https://dart.dev/)** - El lenguaje de programación usado por Flutter, optimizado para construir aplicaciones rápidas en cualquier plataforma.

## Primeros Pasos

### Requisitos

| Requisito   | Versión         |
| ----------- | --------------- |
| Dart SDK    | >=3.12.0 <4.0.0 |
| Flutter SDK | >=3.44.0        |

Soporta Android, iOS, web, Windows, Linux y macOS.

### Instalación

```bash
flutter pub add scroll_infinity
```

## Uso

La paginación solicita una nueva página cuando la persona usuaria llega al final de la lista.
Si `loadData` devuelve `null`, se muestra el estado de error.

**Nota:** Use un tipo nulable `T?` al usar `interval`, ya que se insertan valores nulos.

Hay una demo totalmente configurable, con cada propiedad conectada a un control de interfaz, en el directorio [example](example).

### Desplazamiento Vertical Básico

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
              title: Text('Ítem $value'),
              subtitle: Text('Subtítulo $value'),
            );
          },
        ),
      ),
    );
  }
}
```

### Desplazamiento Horizontal Básico

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
                  child: Text('Ítem $value'),
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

### Desplazamiento Vertical con Intervalo

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
              title: Text('Ítem $value'),
            );
          },
        ),
      ),
    );
  }
}
```

### Controller (Refresh & Retry)

Use un `ScrollInfinityController` para disparar `refresh()`/`retry()` desde fuera del widget (ej.: un botón) y para leer `isLoading`/`hasError`. El dispose corresponde a quien creó la instancia y debe hacerse en `dispose()`.

`retry()` vuelve a solicitar la página que falló. No hace nada cuando la última búsqueda tuvo éxito o cuando se alcanzó el límite de `maxRetries` — en esos casos, use `refresh()` para reiniciar la lista.

Para controlar la posición del desplazamiento en lugar de la paginación, pase un `ScrollController` común en `scrollController`. La lista usa uno interno cuando se omite el parámetro, y nunca hace dispose del controller recibido.

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

// En otro lugar, ej.: un FloatingActionButton:
onPressed: () => _controller.refresh(),
```

### Cambiando la Fuente de Datos

`loadData` es una `Function`, así que pasar un closure en línea (ej.: `loadData: (page) => ...`) crea una nueva instancia en cada rebuild — compararlo por identidad reiniciaría la lista en cada `setState` del padre, que rara vez es lo deseado. Por eso, cambiar solo `loadData` **no** reinicia la lista.

Para cargar un conjunto de datos distinto (ej.: cambiar de categoría o de término de búsqueda), haga una de dos cosas:

- Llamar a `_controller.refresh()` explícitamente cuando la fuente cambie, o
- Dar al `ScrollInfinity` una nueva `Key` (ej.: `ValueKey(category)`) para que Flutter lo remonte desde cero.

```dart
ScrollInfinity<int>(
  key: ValueKey(_category),
  maxItems: _maxItems,
  loadData: (page) => _loadData(_category, page),
  itemBuilder: _itemBuilder,
)
```

### Pull-to-Refresh

Defina `enablePullToRefresh` para envolver la lista en un `RefreshIndicator` que reinicia la paginación desde `initialPageIndex`.

```dart
ScrollInfinity<int>(
  enablePullToRefresh: true,
  maxItems: _maxItems,
  loadData: _loadData,
  itemBuilder: _itemBuilder,
)
```

### Carga Manual

Defina `automaticLoading` como `false` para mostrar un botón "Cargar Más" en lugar de buscar automáticamente al desplazar. Personalícelo con `loadMoreBuilder`.

```dart
ScrollInfinity<int>(
  automaticLoading: false,
  loadMoreBuilder: (action) {
    return TextButton(
      onPressed: action,
      child: const Text('Cargar más'),
    );
  },
  maxItems: _maxItems,
  loadData: _loadData,
  itemBuilder: _itemBuilder,
)
```

### Callbacks de Error y Analytics

Use `onError` para registrar/reportar fallos — la excepción lanzada por `loadData`, o una `Exception` sintética cuando `loadData` devuelve `null` en lugar de lanzar — y `onItemsLoaded` para observar los ítems obtenidos con éxito (ej.: analytics). Ninguno de los dos afecta el build.

`onEndOfList` se dispara cuando llega la última página, es decir, cuando `loadData` devuelve menos ítems que `maxItems`. Un reinicio comienza un nuevo ciclo, que puede llegar al final otra vez. Para leer ese mismo estado en lugar de reaccionar a él, use `ScrollInfinityController.hasReachedEnd`.

```dart
ScrollInfinity<int>(
  onError: (error) => log('Fallo al cargar los ítems', error: error),
  onItemsLoaded: (items) => analytics.logEvent('items_loaded', {'count': items.length}),
  onEndOfList: () => log('Todas las páginas cargadas'),
  maxItems: _maxItems,
  loadData: _loadData,
  itemBuilder: _itemBuilder,
)
```

## Propiedades

**Manejo de Datos**

| Nombre           | Tipo                                  | Predet. | Descripción                                      |
| ---------------- | ------------------------------------- | ------- | ------------------------------------------------ |
| loadData         | `Future<List<T>?> Function(int)`      | -       | Busca los datos de cada página                   |
| itemBuilder      | `Widget Function(T value, int index)` | -       | Construye cada ítem. `index` es mapeado por `useRealItemIndex`/`interval` |
| maxItems         | `int`                                 | -       | Máximo de ítems por solicitud                    |
| initialItems     | `List<T>?`                            | null    | Ítems antes de la primera búsqueda. No avanza la paginación: defina `initialPageIndex` después de ellos para no buscar la misma página de nuevo. Aplicado solo en la inicialización y en el reinicio |
| initialPageIndex | `int`                                 | 0       | Índice de la página inicial. Cambiarlo reinicia la lista |
| controller       | `ScrollInfinityController?`           | null    | Refresh/retry externos y estado de carga/error   |
| scrollController | `ScrollController?`                   | null    | Posición de desplazamiento externa (volver arriba, offset). Pertenece a quien llama; se usa uno interno cuando es nulo |
| onItemsLoaded    | `void Function(List<T> items)?`       | null    | Llamado con los ítems de cada búsqueda exitosa   |
| onEndOfList      | `VoidCallback?`                       | null    | Llamado cuando se carga la última página         |

**Diseño y Apariencia**

| Nombre              | Tipo                                  | Predet.  | Descripción                                        |
| ------------------- | ------------------------------------- | -------- | -------------------------------------------------- |
| scrollDirection     | `Axis`                                | vertical | Dirección del desplazamiento                       |
| reverse             | `bool`                                | false    | Invierte la dirección de desplazamiento/crecimiento (ej.: listas de chat) |
| padding             | `EdgeInsetsGeometry?`                 | null     | Padding interno                                    |
| header              | `Widget?`                             | null     | Widget de encabezado                               |
| separatorBuilder    | `Widget Function(BuildContext, int)?` | null     | Separadores. `index` es la posición cruda de exhibición, sin efecto de `useRealItemIndex`/`interval` |
| scrollbars          | `bool`                                | true     | Muestra las barras de desplazamiento               |
| enablePullToRefresh | `bool`                                | false    | Envuelve la lista en un `RefreshIndicator`         |
| physics             | `ScrollPhysics?`                      | null     | Pasado al `ListView` interno                       |
| shrinkWrap          | `bool`                                | false    | Pasado al `ListView` interno                       |
| cacheExtent         | `double?`                             | null     | Pasado al `ListView` interno                       |
| itemExtent          | `double?`                             | null     | Extensión fija para todo hijo, incluidos encabezado y pie. No permitido con `prototypeItem` ni `separatorBuilder` |
| prototypeItem       | `Widget?`                             | null     | Dimensiona todo hijo según este widget. Mismas restricciones que `itemExtent` |
| addAutomaticKeepAlives | `bool`                             | true     | Pasado al `ListView` interno                       |
| keyboardDismissBehavior | `ScrollViewKeyboardDismissBehavior?` | null  | Cierre del teclado al arrastrar; sin valor, decide el `ScrollBehavior` del contexto |
| restorationId       | `String?`                             | null     | Restaura la posición de desplazamiento (no las páginas cargadas) |

**Comportamiento**

| Nombre            | Tipo     | Predet. | Descripción                                      |
| ----------------- | -------- | ------- | ------------------------------------------------ |
| interval          | `int?`   | null    | Intervalo de inserción de ítems nulos            |
| useRealItemIndex  | `bool`   | true    | Indexación independiente                         |
| automaticLoading  | `bool`   | true    | Búsqueda automática al desplazar                 |
| loadMoreThreshold | `double` | 200     | Distancia del final de la lista que dispara la siguiente página |

**Manejo de Errores**

| Nombre             | Tipo                           | Predet. | Descripción                          |
| ------------------ | ------------------------------ | ------- | ------------------------------------ |
| maxRetries         | `int?`                         | null    | Reintentos permitidos tras un fallo, sin contar el intento inicial. `0` hace el fallo definitivo; combínelo con `retryLimitReached: const SizedBox.shrink()` para fallar en silencio |
| onError            | `void Function(Object error)?` | null    | Llamado en caso de fallo, con la excepción lanzada o una sintética cuando `loadData` devuelve `null` |

**Widgets de Estado**

| Nombre            | Tipo                                     | Predet. | Descripción                            |
| ----------------- | ---------------------------------------- | ------- | -------------------------------------- |
| loading           | `Widget?`                                | null    | Widget del estado de carga             |
| empty             | `Widget?`                                | null    | Widget del estado vacío                |
| tryAgainBuilder   | `Widget Function(Object, VoidCallback)?` | null    | Widget de "Reintentar", construido con el fallo que causó el estado de error |
| loadMoreBuilder   | `Widget Function(VoidCallback)?`         | null    | Widget de "Cargar Más"                 |
| retryLimitReached | `Widget?`                                | null    | Widget de límite de reintentos alcanzado |

## Contribuyendo

1. Haga un fork del proyecto
2. Cree una branch de funcionalidad:

   ```bash
   git checkout -b feature/AmazingFeature
   ```

3. Haga el commit de los cambios:

   ```bash
   git commit -m 'Add some AmazingFeature'
   ```

4. Haga el push de la branch:

   ```bash
   git push origin feature/AmazingFeature
   ```

5. Abra un Pull Request

## Licencia

Distribuido bajo la Licencia MIT. Vea el archivo [LICENSE](LICENSE) para más información.

## Autor

Desarrollado por **Dário Matias**:

- Portfolio: [https://dariomatias-dev.com](https://dariomatias-dev.com)
- GitHub: [https://github.com/dariomatias-dev](https://github.com/dariomatias-dev)
- Email: [matiasdario75@gmail.com](mailto:matiasdario75@gmail.com)
- Instagram: [https://instagram.com/dariomatias_dev](https://instagram.com/dariomatias_dev)
- LinkedIn: [https://linkedin.com/in/dariomatias-dev](https://linkedin.com/in/dariomatias-dev)
