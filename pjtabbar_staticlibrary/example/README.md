## 使用说明

可通过PJTabBarOptions自定义指示器视图，大小，间距，布局，样式等，也可自定义Tabbar Item视图， 左右附加视图等。并支持更新，添加，删除Tabbar Item。

````

1. 导入
import {PJTabComponent, PJTabBarItem, PJTabBarOptionsInterface, PJTabBarOptions} from '@ohos/pjtabbar'
(根据需要可导入PJTabBar，PJTabComponentController, PJTabBarOptions等)

2. PJTabComponent作为Tabs + TabContent使用，也可以单独使用不带Tab content的PJTabBar。

private options: PJTabBarOptionsInterface = new PJTabBarOptions()
this.options.indicatorWidth = 30
this.options.indicatorHeight = 6
this.options.indicatorColor= Color.Orange
this.options.tabBarBackGround = Color.Pink
this.options.selectedFontSize = 16
this.options.selectedFontColor = Color.Orange
this.options.tabBarContentMargin = {left: 10, right: 10}

PJTabComponent({
   items: this.items,
   tabBarOptions: this.options,
   // 注意contentBuilder的传值方式，这种方式下contentBuilder中的this才是正确的。
   contentBuilder: (item: PJTabBarItemInterface, index: number) => {
       this.contentBuilder(item, index)
   },
})

@Builder contentBuilder(item: PJTabBarItemInterface, index: number) {
   Text(index.toString() + ' ' + item.title)
    .width('100%')
    .height('100%')
    .textAlign(TextAlign.Center)
    .backgroundColor(Color.Green)
}
````

### 设置指示器滚动效果
目前支持联动和普通滚动
<font face="微软雅黑" size=3 color=#00ff66 >this.options.indicatorAnimationType = PJIndicatorAnimationType.Linkage</font>

<font face="微软雅黑" size=5 color=#FF0000 >注意:</font>

#### 1. ```contentBuilder```的传值方式，这种方式下```contentBuilder```中的```this```才是正确的， 通过this才能正确的访问到当前调用者的属性。```customerItemBuilder```, ```customerIndicatorBuilder```, ```leftItemBuilder```和```rightItemBuilder```等Builder类似。
````
PJTabComponent({
   items: this.items,
   tabBarOptions: this.options,
   // 注意contentBuilder的传值方式，这种方式下contentBuilder中的this才是正确的。
   contentBuilder: ($$: PJReferenceTabBarItemInterface) => {
       this.contentBuilder($$)
   },
   // 这种调用方式下this不是指向当前的调用者，没法通过this访问当前调用者的属性
   // contentBuilder: this.contentBuilder
})
````

#### 2. 当```contentBuilder```中的组件用到```PJTabBarItem的title/selectedItemIndex```等属性时，并且希望当调用```controller```的```update```操作后该组件的```title/selectedItemIndex```能跟着更新，那么```contentBuilder```的内容需要封装到一个子组件中，例如```PJContentBuilderWrap```。并且```PJContentBuilderWrap```需要以
````
@State(也可采用@ObjectLink) item: PJTabBarItemInterface = {id: '', index: 0, title: '' }
currentItemIndex: number = 0
@Link selectedItemIndex: number
````
的形式绑定数据。这么做的原因是当数据源从```PJTabComponent```中通过```@Builder```函数引用传递到调用者的```contentBuilder```时，需要通过```@State/@ObjectLink/@Link```等关键词才能绑定数据源，并且组件的UI才能跟着数据的变化而变化。```customerItemBuilder```, ```customerIndicatorBuilder```, ```leftItemBuilder```和```rightItemBuilder```等Builder类似。
详细原因可参考官方文档: [@Builder装饰器: 按引用传递参数](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V2/arkts-builder-0000001524176981-V2#section1522464044212) 与 [管理组件拥有的状态](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V2/arkts-component-state-management-0000001524417205-V2)

````
// 子组件
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

// 调用者的contentBuilder函数
@Builder contentBuilder($$: PJReferenceTabBarItemInterface, self: CRUDItemPage) {
   PJContentBuilderWrap({currentItemIndex: $$.currentItemIndex, selectedItemIndex: $$.selectedItemIndex, item: $$.item})

   // 当content中的组件用到PJTabBarItem的title时，并且不需要随着controller的update操作后该组件的title能跟着更新，那么可以不需要将contentBuilder的内容包装在一个组件中， 如下。
   // Text($$.currentItemIndex + ' ' + $$.item.title + ', ' + $$.selectedItemIndex)
   //   .width('100%')
   //   .height('100%')
   //   .textAlign(TextAlign.Center)
   //   .backgroundColor(Color.Green)
 }
````

#### 3. 当```contentBuilder```中的组件用到```PJTabBarItem的title/selectedItemIndex```时，并且不需要随着```controller```的```update```操作后该组件的```title/selectedItemIndex```能跟着更新，那么可不需要将```contentBuilde```的内容包装在一个组件中。

#### 4. 当需要更新/删除/添加`item`时需要使用`PJTabComponentController`提供的接口。
````
  /**
   * Update the item with `item` at `atIndex`.
   * @param atIndex Index of the item to be updated.
   * @param item The new item used to update the current item at `atIndex`.
   */
  update(index: number, item: PJTabBarItemInterface);

  /**
   * Appends new elements to the end of an array, and returns the new length of the array.
   * @param items New elements to add to the array.
   */
  push(...items: PJTabBarItemInterface[]): number;

  /**
   * Insert the new item at `atIndex`.
   * @param atIndex Index of the new item to be inserted.
   * @param item The new item used to insert at `atIndex`.
   */
  insert(atIndex: number, item: PJTabBarItemInterface);

  /**
   * Delete the item at `atIndex`.
   * @param atIndex Delete the item at `atIndex` and return the deleted item. And return null if the `atIndex` is out of range.
   */
  delete(atIndex: number): PJTabBarItemInterface | null;

  /**
   * Replace current items with `withItems` and select item at `selectIndex`.
   * @param withItems Used to replace current items.
   * @param selectIndex If provided, will select the item at `selectIndex`. If it is not provided, the current index is used instead.
   */
  setItems(withItems: PJTabBarItemInterface[], selectIndex: number = this.currentIndex());
  
  let controller = PJTabComponentController()
  
  PJTabComponent({
     index: 0,
     items: this.items,
     controller: this.controller,
     tabBarOptions: this.options,
     contentBuilder: ($$: PJReferenceTabBarItemInterface) => {
        this.contentBuilder($$, this)
     }
   })
   
  controller.update(0, new PJTabBarItem("更新Item"))
````