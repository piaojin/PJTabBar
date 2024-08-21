import {PJTabComponent, PJTabComponentController, PJTabBarItemInterface, PJTabBarItem, PJTabBarOptionsInterface, PJTabBarOptions,
  PJReferenceTabBarItemInterface} from '@piaojin/pjtabbar'
import { PJIndicatorAnimationType } from '@piaojin/pjtabbar/src/main/ets/models/PJTabBarOptions'

/*
 * 用于在@Builder中引用传递: 按引用传递参数时，传递的参数可为状态变量，且状态变量的改变会引起@Builder方法内的UI刷新 (https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V2/arkts-builder-0000001524176981-V2)
 */
@Component
struct PJContentBuilderWrap {
  @State item: PJTabBarItemInterface = {id: '', index: 0, title: '' }
  currentItemIndex: number = 0
  @Link selectedItemIndex: number

  build() {
    Column() {
      Text(this.currentItemIndex + ' ' + this.item.title + ', ' + this.selectedItemIndex)
        .width('100%')
        .height('100%')
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.Green)
    }
  }
}

@Entry
@Component
struct CRUDItemPage {
  private items: PJTabBarItemInterface[] = [new PJTabBarItem('红烧猪蹄'), new PJTabBarItem('猫山王榴莲'), new PJTabBarItem('龙眼'), new PJTabBarItem('荔枝'),
    new PJTabBarItem('牛杂面'), new PJTabBarItem('烤羊腿'), new PJTabBarItem('牛肉火锅'), new PJTabBarItem('蓝鳍金枪鱼刺身')]
  private options: PJTabBarOptionsInterface = new PJTabBarOptions()
  private controller: PJTabComponentController = new PJTabComponentController()
  @State private crudIndex: number = 0

  aboutToAppear() {
    this.options.indicatorWidth = 30
    this.options.indicatorHeight = 6
    this.options.indicatorColor = Color.Orange
    this.options.tabBarBackGround = Color.Pink
    this.options.selectedFontSize = 16
    this.options.selectedFontColor = Color.Orange
    this.options.tabBarContentMargin = { left: 10, right: 10 }
    this.options.indicatorAnimationType = PJIndicatorAnimationType.Linkage
  }

  @Builder titleBuilder() {
    Text('CRUD Item Page')
    .padding({ left: 20, top: 20 })
  }

  /*
   * 1. 当contentBuilder中的组件用到PJTabBarItem的title/selectedItemIndex时，并且希望当调用controller的update操作后该组件的title/selectedItemIndex时能跟着更新，那么contentBuilder的内容需要封装到一个子组件中，例如PJContentBuilderWrap。并且PJContentBuilderWrap需要以
   * @State(也可采用@ObjectLink) item: PJTabBarItemInterface = {id: '', index: 0, title: '' }
   * currentItemIndex: number = 0
   * @Link selectedItemIndex: number
   * 的形式绑定数据。这么做的原因是当数据源从PJTabComponent中通过@Builder函数引用传递到调用者的contentBuilder时，需要通过@State/@ObjectLink/@Link等关键词才能绑定数据源，并且组件的UI才能跟着数据的变化而变化。
   * 详情可参考官方文档: https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V2/arkts-builder-0000001524176981-V2#section1522464044212 与 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V2/arkts-component-state-management-0000001524417205-V2
   *
   * 2. 当content中的组件用到PJTabBarItem的title时，并且不需要随着controller的update操作后该组件的title能跟着更新，那么可不需要将contentBuilder的内容包装在一个组件中。
   */
  @Builder contentBuilder($$: PJReferenceTabBarItemInterface, self: CRUDItemPage) {
    // 当content中的组件用到PJTabBarItem的title时，并且不需要随着controller的update操作后该组件的title能跟着更新，那么可以不需要将contentBuilder的内容包装在一个组件中。
    // Text($$.currentItemIndex + ' ' + $$.item.title + ', ' + $$.selectedItemIndex)
    //   .width('100%')
    //   .height('100%')
    //   .textAlign(TextAlign.Center)
    //   .backgroundColor(Color.Green)

    PJContentBuilderWrap({currentItemIndex: $$.currentItemIndex, selectedItemIndex: $$.selectedItemIndex, item: $$.item})
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
            contentBuilder: ($$: PJReferenceTabBarItemInterface) => {
              this.contentBuilder($$, this)
            }
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
                this.crudIndex += 1
              })

            Button('Delete')
              .onClick(() => {
                this.controller.delete(0)
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