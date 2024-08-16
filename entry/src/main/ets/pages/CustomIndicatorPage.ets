import {PJTabComponent, PJTabBar, PJIndicatorPosition, PJTabBarItemInterface, PJTabBarItem, PJTabBarOptionsInterface, PJTabBarOptions,
  PJReferenceTabBarItemInterface} from '@piaojin/pjtabbar'
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

  @State private segmentIndex: number = 0
  @State private segmentItems: PJTabBarItem [] = [new PJTabBarItem('素材'), new PJTabBarItem('字条')]
  @State private segmentOptions: PJTabBarOptions = new PJTabBarOptions()

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

    this.segmentOptions.isSameWidthWithItem = true
    this.segmentOptions.isSameHeightWithItem = true
    this.segmentOptions.indicatorPosition = PJIndicatorPosition.Center
    this.segmentOptions.indicatorBorderRadius = 12
    this.segmentOptions.indicatorColor = Color.White
    this.segmentOptions.tabBarBackGround = '#F5F4F5'
    this.segmentOptions.selectedFontColor = '#626262'
    this.segmentOptions.itemMargin = {top: 4, bottom: 4, left: 15, right: 15}
    this.segmentOptions.itemSpace = 10
    this.segmentOptions.tabBarContentMargin = {top: 2, bottom: 2, left: 2, right: 2}
    this.segmentOptions.edgeEffect = EdgeEffect.None
    this.segmentOptions.scrollable = ScrollDirection.None
    this.segmentOptions.isTabBarWidthFillParent = false
    this.segmentOptions.tabBarBorder = {radius: 14}
  }

  @Builder titleBuilder() {
    Text('Custom Indicator Page')
    .padding({left: 20, top: 20})
  }

  @Builder contentBuilder($$: PJReferenceTabBarItemInterface) {
    Text($$.currentItemIndex.toString() + ' ' + $$.item.title)
      .width('100%')
      .height('100%')
      .textAlign(TextAlign.Center)
      .backgroundColor(Color.Green)
  }

  @Builder contentBuilder2($$: PJReferenceTabBarItemInterface) {
    Column({space: 10}) {
      Text($$.currentItemIndex.toString() + ' ' + $$.item.title)
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
              contentBuilder: ($$: PJReferenceTabBarItemInterface) => {
                this.contentBuilder($$)
              }})
          }
          .width('100%')
          .height(100)

          ListItem() {
            PJTabComponent({index: 2, items: this.items, tabBarOptions: this.options2,
              contentBuilder: ($$: PJReferenceTabBarItemInterface) => {
                  this.contentBuilder2($$)
              },
              builder: {
                customerIndicatorBuilder: this.customerIndicatorBuilderImage
              }
            })
          }
          .width('100%')
          .height(210)
          .margin({top: 30})

          ListItem() {
            PJTabComponent({index: 0, items: this.items, tabBarOptions: this.options3,
              contentBuilder: ($$: PJReferenceTabBarItemInterface) => {
                this.contentBuilder($$)
              },
            })
          }
          .width('100%')
          .height(100)
          .margin({top: 30})

          ListItem() {
            Column({space: 10}) {
              Text('单独使用PJTabBbar模拟iOS风格Segment')
              Row() {
                PJTabBar({index: $segmentIndex, items: $segmentItems, tabBarOptions: $segmentOptions})
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
            }
          }
          .width('100%')
          .height(150)
          .margin({top: 30})

        }
      }
        .title(this.titleBuilder())
      .mode(NavigationMode.Stack)
      .titleMode(NavigationTitleMode.Mini)
    }
  }
}