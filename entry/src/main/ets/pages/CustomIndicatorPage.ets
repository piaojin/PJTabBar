import {PJTabComponent, PJIndicatorPosition, PJTabBarItemInterface, PJTabBarItem, PJTabBarOptionsInterface, PJTabBarOptions} from '@piaojin/pjtabbar'
import router from '@ohos.router'

@Entry
@Component
struct CustomIndicatorPage {
  private items: PJTabBarItemInterface[] = [new PJTabBarItem('红烧猪蹄'), new PJTabBarItem('猫山王榴莲'), new PJTabBarItem('龙眼'), new PJTabBarItem('荔枝'),
  new PJTabBarItem('牛杂面'), new PJTabBarItem('烤羊腿'), new PJTabBarItem('牛肉火锅'), new PJTabBarItem('蓝鳍金枪鱼刺身')
]
  private options1: PJTabBarOptionsInterface = new PJTabBarOptions()
  private options2: PJTabBarOptionsInterface = new PJTabBarOptions()
  private options3: PJTabBarOptionsInterface = new PJTabBarOptions()

  aboutToAppear() {
    this.options1.indicatorWidth = 30
    this.options1.indicatorHeight = 6
    this.options1.indicatorColor= Color.Orange
    this.options1.tabBarBackGround = Color.Pink
    this.options1.selectedFontSize = 16
    this.options1.selectedFontColor = Color.Orange
    this.options1.tabBarContentMargin = {left: 10, right: 10}

    this.options2.indicatorWidth = 30
    this.options2.indicatorHeight = 30

    this.options3.isSameWidthWithItem = true
    this.options3.isSameHeightWithItem = true
    this.options3.indicatorPosition = PJIndicatorPosition.Center
    this.options3.indicatorColor= Color.Yellow
    this.options3.itemMargin = {top: 6, bottom: 6, left: 10, right: 10}
    this.options3.indicatorBorderRadius = 20
  }

  @Builder titleBuilder() {
    Row() {
      Image($r('app.media.back'))
        .width(30)
        .height(30)
        .onClick(() => {
          router.back()
        })

      Text('Custom Indicator Page')
    }
    .padding({left: 20, top: 20})
  }

  @Builder contentBuilder(item: PJTabBarItemInterface, index: number) {
    Text(index.toString() + ' ' + item.title)
      .width('100%')
      .height('100%')
      .textAlign(TextAlign.Center)
      .backgroundColor(Color.Green)
  }

  @Builder contentBuilder2(item: PJTabBarItemInterface, index: number) {
    Column({space: 10}) {
      Text(index.toString() + ' ' + item.title)
        .width('100%')
        .height(100)
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.Green)

      Row() {
        Button('To Top')
          .onClick(() => {
            this.options2.indicatorPosition = PJIndicatorPosition.Top
            this.options2.indicatorMargin = {top: 0, bottom: 10, left: 0, right: 0}
          })

        Button('To Center')
          .onClick(() => {
            this.options2.indicatorPosition = PJIndicatorPosition.Center
            this.options2.indicatorMargin = {top: 0, bottom: 0, left: 0, right: 0}
          })

        Button('To Bottom')
          .onClick(() => {
            this.options2.indicatorPosition = PJIndicatorPosition.Bottom
            this.options2.indicatorMargin = {top: 10, bottom: 0, left: 0, right: 0}
          })
      }
      .align(Alignment.Center)
      .alignSelf(ItemAlign.Center)
    }
  }

  @Builder customerIndicatorBuilderImage(item: PJTabBarItemInterface, options: PJTabBarOptionsInterface, index: number) {
    Image($r('app.media.durian'))
  }

  build() {
    Column() {
      Navigation() {
        List() {
          ListItem() {
            PJTabComponent({index: 0, items: this.items, tabBarOptions: this.options1,
              contentBuilder: this.contentBuilder})
          }
          .width('100%')
          .height(100)

          ListItem() {
            PJTabComponent({index: 2, items: this.items, tabBarOptions: this.options2,
              contentBuilder: this.contentBuilder2.bind(this),
              customerIndicatorBuilder: this.customerIndicatorBuilderImage
            })
          }
          .width('100%')
          .height(210)
          .margin({top: 30})

          ListItem() {
            PJTabComponent({index: 0, items: this.items, tabBarOptions: this.options3,
              contentBuilder: this.contentBuilder,
            })
          }
          .width('100%')
          .height(300)
          .margin({top: 30})

        }
      }
        .title(this.titleBuilder())
      .mode(NavigationMode.Stack)
    }
  }
}