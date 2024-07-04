import {PJTabComponent, PJTabComponentController, PJTabBarItemInterface, PJTabBarItem, PJTabBarOptionsInterface, PJTabBarOptions} from '@piaojin/pjtabbar'
import router from '@ohos.router'

@Entry
@Component
struct CRUDItemPage {
  private items: PJTabBarItemInterface[] = [new PJTabBarItem('红烧猪蹄'), new PJTabBarItem('猫山王榴莲'), new PJTabBarItem('龙眼'), new PJTabBarItem('荔枝'),
    new PJTabBarItem('牛杂面'), new PJTabBarItem('烤羊腿'), new PJTabBarItem('牛肉火锅'), new PJTabBarItem('蓝鳍金枪鱼刺身')
  ]
  private options: PJTabBarOptionsInterface = new PJTabBarOptions()
  private controller: PJTabComponentController = new PJTabComponentController()

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
    Row() {
      Image($r('app.media.back'))
        .width(30)
        .height(30)
        .onClick(() => {
          router.back()
        })

      Text('CRUD Item Page')
    }
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
            index: 2,
            items: this.items,
            controller: this.controller,
            tabBarOptions: this.options,
            contentBuilder: this.contentBuilder,
          })
            .width('100%')
            .height(150)
            .margin({ top: 30 })

          Row() {
            Button('Update')
              .onClick(() => {
                this.controller.update(2, new PJTabBarItem("更新龙眼"))
              })

            Button('Insert')
              .onClick(() => {
                this.controller.insert(3, new PJTabBarItem("菠萝蜜🥭"))
              })

            Button('Delete')
              .onClick(() => {
                this.controller.delete(3)
              })
          }
          .margin({ top: 30 })
        }
      }
      .title(this.titleBuilder())
      .mode(NavigationMode.Stack)
    }
  }
}