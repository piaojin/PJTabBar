import {PJTabComponent, PJTabBarItemInterface, PJTabBarItem, PJTabBarOptionsInterface, PJTabBarOptions,
  PJReferenceTabBarItemInterface} from '@piaojin/pjtabbar'
import router from '@ohos.router'

@Entry
@Component
struct CustomLeftAndRightViewPage {
  private items: PJTabBarItemInterface[] = [new PJTabBarItem('红烧猪蹄'), new PJTabBarItem('猫山王榴莲'), new PJTabBarItem('龙眼'), new PJTabBarItem('荔枝'),
    new PJTabBarItem('牛杂面'), new PJTabBarItem('烤羊腿'), new PJTabBarItem('牛肉火锅'), new PJTabBarItem('蓝鳍金枪鱼刺身')
  ]
  private options1: PJTabBarOptionsInterface = new PJTabBarOptions()
  private options2: PJTabBarOptionsInterface = new PJTabBarOptions()

  aboutToAppear() {
    this.options1.indicatorWidth = 30
    this.options1.indicatorHeight = 6
    this.options1.indicatorColor = Color.Orange
    this.options1.tabBarBackGround = Color.Pink
    this.options1.selectedFontSize = 16
    this.options1.selectedFontColor = Color.Orange
    this.options1.tabBarContentMargin = { left: 10, right: 10 }

    this.options2.indicatorWidth = 30
    this.options2.indicatorHeight = 6
    this.options2.indicatorColor = Color.Orange
    this.options2.tabBarBackGround = Color.Pink
    this.options2.selectedFontSize = 16
    this.options2.selectedFontColor = Color.Orange
    this.options2.tabBarContentMargin = { left: 10, right: 10 }
    this.options2.isLeftItemFixed = false
    this.options2.isRightItemFixed = false
  }

  @Builder titleBuilder() {
    Text('Custom Left And Right View Page')
    .padding({ left: 20, top: 20 })
  }

  @Builder contentBuilder($$: PJReferenceTabBarItemInterface) {
    Text($$.currentItemIndex.toString() + ' ' + $$.item.title)
      .width('100%')
      .height('100%')
      .textAlign(TextAlign.Center)
      .backgroundColor(Color.Green)
  }

  @Builder leftItemBuilder() {
    Text('固定Left')
  }

  @Builder rightItemBuilder() {
    Row() {
      Image($r('app.media.durian'))
        .width(40)
        .height(40)
      Image($r('app.media.dragon'))
        .width(40)
        .height(40)
    }
  }

  @Builder leftItemBuilder2() {
    Text('Left>>>')
      .backgroundColor(Color.Yellow)
  }

  @Builder rightItemBuilder2() {
    Row() {
      Image($r('app.media.durian'))
        .width(40)
        .height(40)
      Image($r('app.media.dragon'))
        .width(40)
        .height(40)
    }
  }

  build() {
    Column() {
      Navigation() {
        List() {
          ListItem() {
            PJTabComponent({
              index: 2,
              items: this.items,
              tabBarOptions: this.options1,
              contentBuilder: this.contentBuilder,
              builder: {
                leftItemBuilder: this.leftItemBuilder,
                rightItemBuilder: this.rightItemBuilder
              }
            })
          }
          .width('100%')
          .height(200)
          .margin({ top: 30 })

          ListItem() {
            Row() {
              Button('Hide Left')
                .onClick(() => {
                  this.options1.isHideLeftItem = true
                })
              Button('Hide Right')
                .onClick(() => {
                  this.options1.isHideRightItem = true
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
          }

          ListItem() {
            PJTabComponent({
              index: 0,
              items: this.items,
              tabBarOptions: this.options2,
              contentBuilder: this.contentBuilder,
              builder: {
                leftItemBuilder: this.leftItemBuilder2,
                rightItemBuilder: this.rightItemBuilder2
              }
            })
          }
          .width('100%')
          .height(210)
          .margin({ top: 30 })

          ListItem() {
            Row() {
              Button('Hide Left')
                .onClick(() => {
                  this.options2.isHideLeftItem = true
                })
              Button('Hide Right')
                .onClick(() => {
                  this.options2.isHideRightItem = true
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
          }

        }
        .width('100%')
        .height('100%')
      }
      .title(this.titleBuilder())
      .mode(NavigationMode.Stack)
      .titleMode(NavigationTitleMode.Mini)
    }
  }
}