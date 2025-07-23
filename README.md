# SDK для взаимодействия с порталом фича флагов 
SDK для взаимодействия с микросервисом, позволяющим работать с фича флагами разных проектов на разных окружениях.

# Подключение и использование SDK
## Инициализация SDK
Для работы с SDK необходимо проинициализировать его со следующими параметрами  
- `storageType` - тип хранилища фича флагов. Реализовано 3 типа хранилища:  
    - `.inMemory(appFlags: [any FeatureFlagsEnum])` - сохранение фича флагов в памяти сессии. 
    - `.userDefaults(appFlags: [any FeatureFlagsEnum])` - сохранение фича флагов в UserDefaults. 
    - `.custom(FeatureTogglesStorage)` - сохранение фича флагов в настраиваемом пользователем SDK хранилище, реализующем протокол `FeatureTogglesStorage`. 
По умолчанию используется `userDefaults(appFlags: [])`  
Используйте `FeatureFlagsEnum` для локального формирования фича флагов. SDK будет сохранять фича флаги, указанные в массиве appFlags. В случае пустого массива appFlags SDK будет сохранять все фича флаги приходящие с сервера.
- `headerKey` - заголовок хеша в ответах запросов, по которому определяется изменились ли значения фича флагов. По умолчанию `ff-hash`
- `baseUrl` - URL сервера. Является обязательным параметром.
- `apiFeaturePath` - путь до метода запроса получения фича флагов. По умолчанию `/api/features`
- `featuresHeaders` - словарь дополнительных заголовков для запроса фича флагов. Если вы не используете интерсептор для перехвата запросов, то можете передать необходимые заголовки в этом параметре, например, токен. По умолчанию пуст.
- `certificates` - сертификаты, используемые для ssl-pinning. По умолчанию nil.
- `publicKeyHash` - хеш публичного ключа, используемого для ssl-pinning. Используется в приоритете перед сертификатами. По умолчанию nil.
- `mockFilePath` - путь до мок файла. Если параметр задан, то вместо запроса флагов с сервера библиотека вернёт список флагов из мок файла. По умолчанию nil.
```swift
    let featureTogglesSDK = FeatureTogglesSDK(baseUrl: "your link")
```
## Взаимодействие с хранилищем
- Для получения списка флагов из хранилища воспользуйтесь функцией `getFlags`
- Для получение состояния флага из хранилища воспользуйтесь функцией `isEnabled`
- Для принудительного обновления хранилища воспользуйтесь функцией `loadRemote`
- Для сверки хеша с хешем из хранилища воспользуйте функцией `obtainHash`
- Для локального изменения состояния флага измените значение `useLocal` на `true` через функцию `changeUseLocalState`, после чего SDK будет возвращать локальное состояние заданное через функцию `changeLocalState`
- Для сброса значений фича флага до дефолтных воспользуйтесь функцией `resetToDefaultValues`
- Делегат SDK реализует реагирование на изменение состояния хранилища
```swift
    extension YourDelegateClass: FeatureTogglesSDKDelegate {
        func didFeatureTogglesStorageUpdate() {
            // Your actions
        }
    }
```
## Интерсептор
- Для автоматического отслеживания изменения фича флагов нужно запустить интерсептор при помощи функции `startInterceptor`  
Отключить интерсептор можно с помощью функции `stopInterceptor`
- Для возможности отпралять для всех запросов какой-либо заголовок, например токен можно воспользоваться следующей функцией `addInterceptorHeader`
- Для собственной реализации реакции на запросы, например, логирования, можно задать следующие переменные
```swift
  featureTogglesSDK.interceptRequest = { request in
      print("Intercept request: \(request.url)")
  }
  
  featureTogglesSDK.interceptResponse = { response in
      print("Intercept response: \(response.url)")
  }
```
## Мокирование списка флагов
В случае необходимости мокирования списка флагов, возвращаемых библиотекой (например для UI тестов), необходимо добавить JSON файл с ответом в проект и указать путь до него в параметре `mockFilePath` при инициализации библиотеки
```swift
    let featureTogglesSDK = FeatureTogglesSDK(baseUrl: "your link", mockFilePath: Bundle.main.url(forResource: "your_mock", withExtension: "json"))
```

## Установка

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.

```swift
// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "YourProject",
  dependencies: [
    .package(url: "https://github.com/True-Engineering/FeatureTogglesSDK_iOS.git", branch: "master"),
  ],
  targets: [
    .target(name: "YourProject", dependencies: ["TEFeatureToggles"])
  ]
)
```

```bash
$ swift build
```
### [CocoaPods](https://cocoapods.org)

TEFeatureToggles is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TEFeatureToggles'
```

## License

This library is licensed under the Apache 2.0 License. See the LICENSE and NOTION files for more info.

## Технологический стек
- **Swift 5.7**
- Реализация интерсептора взята с [**NetShears**](https://github.com/divar-ir/NetShears#netshears)
