# SDK для взаимодействия с порталом фича флагов 
SDK для взаимодействия с микросервисом, позволяющим работать с фича флагами разных проектов на разных окружениях.

# Подключение и использование SDK
## Инициализация SDK
Для работы с SDK необходимо проинициализировать его со следующими параметрами  
- `storageType` - тип хранилища фича флагов. Реализовано 3 типа хранилища:
        `.inMemory` - сохранение фича флагов в памяти сессии
        `.userDefaults` - сохранение фича флагов в UserDefaults
        `.custom(FeatureTogglesStorage)` - сохранение фича флагов в настраиваемом пользователем SDK хранилище, реализующем протокол `FeatureTogglesStorage`
        По умолчанию используется userDefaults
- `headerKey` - заголовок хеша в ответах запросов, по которому определяется изменились ли значения фича флагов. По умолчанию `FF-Hash`
- `baseUrl` - URL сервера. Является обязательным параметром.
- `apiFeaturePath` - Путь до метода запроса получения фича флагов. По умолчанию `/api/features`
- `featuresHeaders` - Словарь дополнительных заголовкоа для запроса фича флагов. По умолчанию пуст. Если вы не используете интерсептор для перехвата запросов, то можете передать необходимые заголовки в этом параметре, например, токен.
```swift
    let featureTogglesSDK = FeatureTogglesSDK(baseUrl: "your link")
```
## Взаимодействие с хранилищем
- Для получения списка флагов из хранилища воспользуйтесь функцией `getFlags`
- Для получение состояния флага из хранилища воспользуйтесь функцией `isEnabled`
- Для принудительного обновления хранилища воспользуйтесь функцией `loadRemote`
- Для сверки хеша с хешем из хранилища воспользуйте функцией `obtainHash`
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
