import router from '@ohos.router'

@Entry
@Component
struct Index {
  build() {
    Column() {
      Navigation() {
        Column({space: 20}) {
          Button('Custom indicator')
            .width('90%')
            .onClick(() => {
              router.pushUrl({
                url: "pages/CustomIndicatorPage"
              })
            })

          Button('Custom item')
            .width('90%')
            .onClick(() => {
              router.pushUrl({
                url: "pages/CustomItemPage"
              })
            })

          Button('Custom left and right view')
            .width('90%')
            .onClick(() => {
              router.pushUrl({
                url: "pages/CustomLeftAndRightViewPage"
              })
            })

          Button('Custom Layout')
            .width('90%')
            .onClick(() => {
              router.pushUrl({
                url: "pages/CustomLayoutPage"
              })
            })

          Button('CRUD Item')
            .width('90%')
            .onClick(() => {
              router.pushUrl({
                url: "pages/CRUDItemPage"
              })
            })
        }
      }
      .mode(NavigationMode.Stack)
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
  }
}