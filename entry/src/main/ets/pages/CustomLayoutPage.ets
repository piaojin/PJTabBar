import {PJTabComponent, PJTabBarItemInterface, PJTabBarItem, PJTabBarOptionsInterface, PJTabBarOptions} from '@piaojin/pjtabbar'
import router from '@ohos.router'

@Entry
@Component
struct CRUDItemPage {
  private items: PJTabBarItemInterface[] = [new PJTabBarItem('红烧猪蹄'), new PJTabBarItem('猫山王榴莲'), new PJTabBarItem('龙眼')]
  private options: PJTabBarOptionsInterface = new PJTabBarOptions()

  aboutToAppear() {
    this.options.indicatorWidth = 30
    this.options.indicatorHeight = 6
    this.options.indicatorColor = Color.Orange
    this.options.tabBarBackGround = Color.Pink
    this.options.selectedFontSize = 16
    this.options.selectedFontColor = Color.Orange
    this.options.tabBarContentMargin = { left: 10, right: 10 }
  }

  @Builder titleBuilder() {
    Text('CRUD Item Page')
    .padding({ left: 20, top: 20 })
  }

  @Builder contentBuilder(item: PJTabBarItemInterface, index: number) {
    Text(index.toString() + ' ' + item.title)
      .width('100%')
      .height('100%')
      .textAlign(TextAlign.Center)
      .backgroundColor(Color.Green)
  }

  build() {
    Column() {
      Navigation() {
        Column() {
          PJTabComponent({
            index: 0,
            items: this.items,
            tabBarOptions: this.options,
            contentBuilder: this.contentBuilder,
          })
            .width('100%')
            .height(150)
            .margin({ top: 30 })

          Row() {
            Button('Left')
              .onClick(() => {
                this.options.itemAlign = Alignment.Start
              })

            Button('Center')
              .onClick(() => {
                this.options.itemAlign = Alignment.Center
              })

            Button('Right')
              .onClick(() => {
                this.options.itemAlign = Alignment.End
              })
          }
          .margin({ top: 30 })
        }
      }
      .title(this.titleBuilder())
      .mode(NavigationMode.Stack)
      .titleMode(NavigationTitleMode.Mini)
    }
  }
}