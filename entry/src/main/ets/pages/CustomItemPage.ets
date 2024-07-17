import {PJTabComponent, PJTabBarItemInterface, PJTabBarItem, PJTabBarOptionsInterface, PJTabBarOptions} from '@piaojin/pjtabbar'
import router from '@ohos.router'

@Entry
@Component
struct CustomItemPage {
  private items: PJTabBarItemInterface[] = [new PJTabBarItem('红烧猪蹄'), new PJTabBarItem('猫山王榴莲'), new PJTabBarItem('龙眼'), new PJTabBarItem('荔枝'),
    new PJTabBarItem('牛杂面'), new PJTabBarItem('烤羊腿'), new PJTabBarItem('牛肉火锅'), new PJTabBarItem('蓝鳍金枪鱼刺身')
  ]
  private options: PJTabBarOptionsInterface = new PJTabBarOptions()

  aboutToAppear() {
    this.options.indicatorWidth = 30
    this.options.indicatorHeight = 6
    this.options.indicatorColor= Color.Orange
    this.options.tabBarBackGround = Color.Pink
    this.options.tabBarContentMargin = {left: 10, right: 10}
  }

  @Builder titleBuilder() {
    Row() {
      Image($r('app.media.back'))
        .width(30)
        .height(30)
        .onClick(() => {
          router.back()
        })

      Text('Custom Item Page')
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

  @Builder customerItemBuilder(item: PJTabBarItemInterface, options: PJTabBarOptionsInterface, index: number) {
    if ((index / 2) === 1) {
      Text(item.title)
        .textAlign(TextAlign.Center)
    } else if ((index % 2) === 0) {
      Row() {
        Text('***')
        Image($r('app.media.dragon'))
          .width(40)
          .height(40)
        Text('***')
      }
    } else {
      Image($r('app.media.durian'))
        .width(40)
        .height(40)
    }
  }

  build() {
    Column() {
      Navigation() {
        PJTabComponent({index: 0, items: this.items, tabBarOptions: this.options,
          contentBuilder: this.contentBuilder,
          builder: {
            customerItemBuilder: this.customerItemBuilder
          }
        })
          .width('100%')
          .height('100%')
      }
      .title(this.titleBuilder())
      .mode(NavigationMode.Stack)
    }
  }
}