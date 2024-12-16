import {PJTabComponent, PJTabBarItemInterface, PJTabBarItem, PJTabBarOptionsInterface, PJTabBarOptions, PJReferenceTabBarItemInterface, PJTabComponentController, PJCustomerBuilderInterface} from '@piaojin/pjtabbar'

/*
 * 用于在@Builder中引用传递: 按引用传递参数时，传递的参数可为状态变量，且状态变量的改变会引起@Builder方法内的UI刷新 (https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V2/arkts-builder-0000001524176981-V2)
 */
@Component
struct PJCustomerItemBuilderWrap {
  @State item: PJTabBarItemInterface = {id: '', index: 0, title: '' }
  currentItemIndex: number = -1
  @Link selectedItemIndex: number
  @Link tabBarOptions: PJTabBarOptionsInterface

  private isSelectedItem(): boolean {
    return this.selectedItemIndex === this.currentItemIndex
  }

  build() {
    Column({space: 10}) {
      if ((this.currentItemIndex / 2) === 1) {
        Text(this.item.title)
          .fontSize(this.tabBarOptions.fontSize)
          .textAlign(TextAlign.Center)
          .fontColor(this.isSelectedItem() ? this.tabBarOptions.selectedFontColor : this.tabBarOptions.fontColor)
      } else if ((this.currentItemIndex % 2) === 0) {
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

      if (this.isSelectedItem()) {
        Text('Buy It')
          .fontSize(this.tabBarOptions.fontSize)
          .textAlign(TextAlign.Center)
          .fontColor(this.tabBarOptions.selectedFontColor)
          .margin({bottom: 10})
      }
    }
  }
}

@Entry
@Component
struct CustomItemPage {
  private items: PJTabBarItemInterface[] = [new PJTabBarItem('红烧猪蹄'), new PJTabBarItem('猫山王榴莲'), new PJTabBarItem('龙眼'), new PJTabBarItem('荔枝'),
    new PJTabBarItem('牛杂面'), new PJTabBarItem('烤羊腿'), new PJTabBarItem('牛肉火锅'), new PJTabBarItem('蓝鳍金枪鱼刺身')
  ]
  private options: PJTabBarOptionsInterface = new PJTabBarOptions()
  private controller: PJTabComponentController = new PJTabComponentController()

  aboutToAppear() {
    this.options.indicatorWidth = 30
    this.options.indicatorHeight = 6
    this.options.indicatorColor= Color.Orange
    this.options.tabBarBackGround = Color.Pink
    this.options.tabBarContentMargin = {left: 10, right: 10}
  }

  @Builder titleBuilder() {
    Text('Custom Item Page')
    .padding({left: 20, top: 20})
  }

  @Builder contentBuilder($$: PJReferenceTabBarItemInterface) {
    Text($$.currentItemIndex.toString() + ' ' + $$.item.title)
      .width('100%')
      .height('100%')
      .textAlign(TextAlign.Center)
      .backgroundColor(Color.Green)
      .expandSafeArea([SafeAreaType.SYSTEM])
  }

  /*
   * 1. 当customerItemBuilder中的组件用到PJTabBarItem的title/selectedItemIndex时时，并且希望当调用controller的update操作后该组件的title/selectedItemIndex时能跟着更新，那么customerItemBuilder的内容需要封装到一个子组件中，例如PJCustomerItemBuilderWrap。并且PJCustomerItemBuilderWrap需要以
   * @State(也可采用@ObjectLink) item: PJTabBarItemInterface = {id: '', index: 0, title: '' }
   * currentItemIndex: number = 0
   * @Link selectedItemIndex: number
   * 的形式绑定数据。这么做的原因是当数据源从PJTabComponent中通过@Builder函数引用传递到调用者的customerItemBuilder时，需要通过@State/@ObjectLink/@Link等关键词才能绑定数据源，并且组件的UI才能跟着数据的变化而变化。
   * 详情可参考官方文档: https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V2/arkts-builder-0000001524176981-V2#section1522464044212 与 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V2/arkts-component-state-management-0000001524417205-V2
   *
   * 2. 当customerItemBuilder中的组件用到PJTabBarItem的title/selectedItemIndex时，并且不需要随着controller的update操作后该组件的title/selectedItemIndex能跟着更新，那么可以不需要将customerItemBuilder的内容包装在一个组件中。
   */
  @Builder customerItemBuilder($$: PJCustomerBuilderInterface) {
    PJCustomerItemBuilderWrap({currentItemIndex: $$.currentItemIndex, selectedItemIndex: $$.selectedItemIndex, item: $$.item, tabBarOptions: $$.tabBarOptions})
  }

  build() {
    Column() {
      Navigation() {
        PJTabComponent({index: 0, items: this.items, controller: this.controller, tabBarOptions: this.options,
          contentBuilder: this.contentBuilder,
          builder: {
            customerItemBuilder: ($$: PJCustomerBuilderInterface) => {
              this.customerItemBuilder($$)
            }
          }
        })
          .width('100%')
          .height('100%')
      }
      .title(this.titleBuilder())
      .mode(NavigationMode.Stack)
      .titleMode(NavigationTitleMode.Mini)
    }
  }
}