/*
 * Copyright (C) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import display from '@ohos.display'
import {PJTabBarOptionsInterface, PJIndicatorPosition, PJTabBarOptions,
  PJIndicatorAnimationType} from '../models/PJTabBarOptions'
import { PJReferenceTabBarItemInterface, PJTabBarItemInterface} from '../models/PJTabBarItem'
import {PJTabBarItemAttribute} from '../models/PJTabBarItemAttribute'
import {PJBuilder, PJCustomerBuilderInterface, PJNullBuilder} from '../models/PJBuilder'
import { PJTabDataSource } from '../models/PJTabDataSource'
import { PJTabBarItemComponent } from './PJTabBarItemComponent'

@Component
export struct PJTabBar {
  // 第一次设置的index, 用于计算indicatorOffsetX
  private defaultIndex: number = 0
  @Link index: number
  @Link items: PJTabBarItemInterface[]
  dataSource: PJTabDataSource = new PJTabDataSource()
  // tabbar配置
  @Link tabBarOptions: PJTabBarOptionsInterface
  // 指示器宽度和高度单独设置属性是因为在指示器联动模式下(this.tabBarOptions.indicatorAnimationType = PJIndicatorAnimationType.Linkage),直接使用并修改this.tabBarOptions.indicatorWidth，在快速滑动4时会导致page错乱，暂不知原因。
  @Prop indicatorWidth: number = 20
  @Prop indicatorHeight: number = 4
  controller?: PJTabBarController | null
  private scroller: Scroller = new Scroller()
  // indicator移动的距离, 即移动到选中的item的centerX下
  @State private indicatorOffsetX: number = 0
  // item坐标数据
  private attrs: Map<number, PJTabBarItemAttribute> = new Map<number, PJTabBarItemAttribute>()
  private hasInitData: boolean = false
  private hasInitTabPos: boolean = false
  @State private scrollHeight: number = 0
  onSelectItem?: (item: PJTabBarItemInterface, index: number) => void
  // tabbar滚动到头
  onScrollEdge?: (side: Edge) => void | null
  // 初始化完数据
  onInitData?: () => void | null

  builder: PJBuilder = new PJBuilder()

  // 自定义item视图
  @BuilderParam private customerItemBuilder: ($$: PJCustomerBuilderInterface) => void = PJNullBuilder
  // 自定义Indicator，不需要设置width和height
  @BuilderParam private customerIndicatorBuilder: (item: PJTabBarItemInterface, options: PJTabBarOptionsInterface, index: number) => void = PJNullBuilder
  // 左边附加视图
  @BuilderParam private leftItemBuilder: () => void = PJNullBuilder
  // 右边附加视图
  @BuilderParam private rightItemBuilder: () => void = PJNullBuilder

  // TODO: 采用onTouch手势滑动距离来处理indicator跟随page内容滚动打不到理想效果,等API11采用onGestureSwipe实现
  private moveStartX: number = 0
  private moveStartTime: number = 0
  private moveEndTime: number = 0
  private tempOffsetX: number = 0

  aboutToAppear() {
    if (!this.hasInitData) {
      this.initData()
    }
  }

  private initData() {
    // 绑定TabBar数据源
    this.dataSource.setItems(this.items)
    this.customerItemBuilder = this.builder.customerItemBuilder ?? PJNullBuilder
    this.customerIndicatorBuilder = this.builder.customerIndicatorBuilder ?? PJNullBuilder
    this.leftItemBuilder = this.builder.leftItemBuilder ?? PJNullBuilder
    this.rightItemBuilder = this.builder.rightItemBuilder ?? PJNullBuilder

    if (!this.tabBarOptions) {
      this.tabBarOptions = new PJTabBarOptions()
    }

    this.indicatorWidth = this.tabBarOptions.indicatorWidth ?? 20
    this.indicatorHeight = this.tabBarOptions.indicatorHeight ?? 20
    this.hasInitData = true
    this.defaultIndex = this.index

    if (this.controller) {
      this.controller.bind(this)
    }

    if (this.tabBarOptions.indicatorPosition === PJIndicatorPosition.Center) {
      this.tabBarOptions.indicatorMargin = {top: 0, bottom: 0, left: 0, right: 0}
    }

    if (this.onInitData) {
      this.onInitData()
    }
  }

  // item坐标大小变化
  private didAreaChange(ofIndex: number, newArea: Area) {
    // 更新保存所有item的position
    this.updateItemAttribute(ofIndex, new PJTabBarItemAttribute(newArea))
    // 第一次加载出来滚动到默认选中的item位置
    if (!this.hasInitTabPos && this.index === ofIndex) {
      this.hasInitTabPos = true
      this.scrollItemToIndex(this.index)
      if (this.tabBarOptions.isSameHeightWithItem) {
        this.indicatorHeight = newArea.height as number
      }

      if (this.tabBarOptions.isSameWidthWithItem) {
        this.indicatorWidth = newArea.width as number
      }
    }

    if (this.index === ofIndex) {
      this.scrollIndicatorToIndex(this.index)
    }
  }

  private updateItemAttribute(index: number, attr: PJTabBarItemAttribute) {
    this.attrs.set(index, attr)
  }

  /// 滚动indicator到新选中的item位置
  private scrollIndicatorToIndex(newIndex: number, duration: number | undefined = this.tabBarOptions.itemAnimationDuration) {
    if (newIndex < this.attrs.size) {
      let oldArea = this.attrs.get(this.defaultIndex)
      let newArea = this.attrs.get(newIndex)
      if (newArea && oldArea) {
        let newIndicatorOffseX: number = 0
        if (newIndex === this.defaultIndex) {
          newIndicatorOffseX = 0
        } else {
          let newItemX = (newArea.area.position.x ?? 0) as number
          let newItemCenterX = newItemX + (newArea.area.width as number) / 2
          let oldItemX = (oldArea.area.position.x ?? 0) as number
          let oldItemCenterX = oldItemX + (oldArea.area.width as number) / 2
          newIndicatorOffseX = newItemCenterX - oldItemCenterX
        }

        if (this.indicatorOffsetX !== newIndicatorOffseX) {
          this.tempOffsetX = newIndicatorOffseX
          animateTo({duration: duration, curve: Curve.Linear}, () => {
            this.indicatorOffsetX = newIndicatorOffseX
            if (this.tabBarOptions.isSameHeightWithItem && newArea && this.indicatorHeight !== (newArea.area.height as number)) {
              this.indicatorHeight = newArea.area.height as number
            }
          })
        }

        if (this.tabBarOptions.isSameWidthWithItem) {
          // 更新indicatorWidth
          let nextWidth = (newArea?.area.width ?? 0) as number
          if (nextWidth !== this.indicatorWidth) {
            // 更新indicatorWidth
            animateTo({duration: duration, curve: Curve.Linear}, () => {
              this.indicatorWidth = nextWidth
            })
          }
        }
      }
    }
  }

  /// 滚动item到指定index
  private scrollItemToIndex(index: number, duration: number | undefined = this.tabBarOptions.itemAnimationDuration) {
    if (index < this.attrs.size) {
      let attr = this.attrs.get(index)
      if (attr) {
        let optimizeOffsetX = this.tabBarOptions.optimizeOffsetX ?? 0
        // 使item尽量滚到中间位置
        this.scroller.scrollTo({xOffset: (attr.area.position.x as number) - optimizeOffsetX, yOffset: this.scroller.currentOffset().yOffset, animation: {duration: duration, curve: Curve.Linear}})
      }
    }
  }

  selectItemAtIndex(index: number, duration: number | undefined = this.tabBarOptions.itemAnimationDuration) {
    this.index = index
    this.scrollIndicatorToIndex(this.index, duration)
    // 改善指示器滚动过程中抖动问题
    this.delay(150, () => {
      this.scrollItemToIndex(index, duration)
    })
  }

  private getItemCenterX(index: number): number | null {
    if (index >= this.attrs.size) {
      return null
    }

    let targetArea = this.attrs.get(index)
    if (targetArea) {
      let newItemX = (targetArea.area.position.x ?? 0) as number
      let newItemCenterX = newItemX + (targetArea.area.width as number) / 2
      return newItemCenterX
    }
    return null
  }

  private getItemWidth(index: number): number | null {
    if (index >= this.attrs.size) {
      return null
    }

    let targetArea = this.attrs.get(index)
    if (targetArea) {
      return targetArea.area.width as number
    }
    return null
  }

  private delay(duration: number, handler: () => void) {
    new Promise<void>((resolve, _) => {
      setTimeout(() => {
        resolve()
      }, duration)
    })
      .then(() => {
        handler()
      })
  }

  handleTouch(event: TouchEvent, currentIndex: number, duration: number | undefined = this.tabBarOptions.itemAnimationDuration) {
    if (this.tabBarOptions.indicatorAnimationType !== PJIndicatorAnimationType.Linkage) {
      return
    }

    // 记录手指触摸的位置和时间，用于计算手指滑动的偏移量和滑动时间。
    let startX = this.moveStartX
    let offset = 0
    if (event.type === TouchType.Down) {
      this.moveStartX = event.touches[0].x
      this.moveStartTime = Date.now()
    }

    // 手指滑动过程中更新指示器位置和宽度
    if (event.type === TouchType.Move) {
      offset = event.touches[0].x - startX
      if ((offset >= 0 && currentIndex > 0) || (offset <= 0 && currentIndex < this.items.length - 1)) {
        let isMoveToLeft: boolean = offset > 0
        let nextIndex = isMoveToLeft ? currentIndex - 1 : currentIndex + 1
        let nextCenterX = this.getItemCenterX(nextIndex)
        let currentCenterX = this.getItemCenterX(currentIndex)
        if (nextCenterX && currentCenterX) {
          // 计算滚动百分比, 更新指示器位置
          let movePercentage = Math.abs(offset) / px2vp(display.getDefaultDisplaySync().width)
          movePercentage = Math.min(movePercentage, 1)
          let subIndicatorOffsetX = nextCenterX - currentCenterX
          this.indicatorOffsetX = this.tempOffsetX + subIndicatorOffsetX * movePercentage
          // 更新指示器宽度
          if (this.tabBarOptions.isSameWidthWithItem) {
            let targetWidth = this.getItemWidth(nextIndex)
            let currentWidth = this.getItemWidth(currentIndex)
            if (targetWidth && currentWidth) {
              let newIndicatorWidth = currentWidth + (targetWidth - currentWidth) * movePercentage
              this.indicatorWidth = newIndicatorWidth
            }
          }
        }
      }
    }

    // 手指抬起来时根据滑动的距离和手指接触的时间判断是否要滚动到下一个item。
    if (event.type === TouchType.Up) {
      this.moveEndTime = Date.now()
      let touchDuration = this.moveEndTime - this.moveStartTime
      let offset = event.touches[0].x - startX
      this.moveStartX = 0
      this.moveStartTime = 0
      this.moveEndTime = 0
      if (touchDuration <= 500) {
        // 手指滑动距离30存在误差，可能30时并没有成功切换到下一个item, 不过这种误差在UI上是指示器向反方向偏移了一点，然后滚动到正确的位置上，是可以接受的。
        if (Math.abs(offset) >= 30) {
          let nextIndex = this.index + (offset > 0 ? -1 : 1)
          if (nextIndex >= 0 && nextIndex <= this.dataSource.totalCount() - 1) {
            this.scrollIndicatorToIndex(nextIndex, duration)
          }
        }
      }
    }
  }

  /// CRUD Actions

  update(atIndex: number, item: PJTabBarItemInterface) {
    this.dataSource.update(atIndex, item)
    // 需要触发滚动指示器,以修复指示器不居中问题.
    this.delay(100, () => {
      this.selectItemAtIndex(this.index)
    })
  }

  push(...items: PJTabBarItemInterface[]): number {
    let newLength = this.dataSource.push(...items)
    // 在tabbar末尾添加完新item之后执行一次选中当前的item，以使被选中的item更新滚动位置。
    this.selectItemAtIndex(this.index)
    return newLength
  }

  insert(atIndex: number, item: PJTabBarItemInterface) {
    let fixedIndex = Math.min(Math.max(atIndex, 0), this.dataSource.totalCount())
    if (fixedIndex <= this.index) {
      this.index += 1
    }

    this.dataSource.insert(fixedIndex, item)

    if (fixedIndex <= this.index) {
      this.selectItemAtIndex(this.index)
    }

    this.delay(200, () => {
      this.scrollIndicatorToIndex(this.index)
    })
  }

  delete(atIndex: number): PJTabBarItemInterface | null {
    if (atIndex >= this.dataSource.totalCount() || atIndex < 0) {
      return null
    }

    let hasChangeIndex: boolean = atIndex <= this.index
    if (atIndex < this.index) {
      this.index -= 1
    } else if (atIndex === this.index) { // 如果删除的是当前选中的item,则默认重新选中第一个item。
      this.index = 0
    }

    let deletedItems = this.dataSource.delete(atIndex)

    this.delay(200, () => {
      this.scrollIndicatorToIndex(this.index)
      if (hasChangeIndex) {
        this.scrollItemToIndex(this.index)
        if (this.onSelectItem) {
          let selectedItem = this.getItem(this.index)
          if (selectedItem) {
            this.onSelectItem(selectedItem, this.index)
          }
        }
      }
    })
    return deletedItems.length > 0 ? deletedItems[0] : null
  }

  setItems(withItems: PJTabBarItemInterface[], selectIndex: number = this.index) {
    // 替换所有items时需要先替换TabBar的,接着在重新与dataSource绑定.
    this.items = withItems
    this.dataSource.setItems(this.items)
    let defaultIndex = selectIndex < this.dataSource.totalCount() ? Math.max(selectIndex, 0) : 0
    this.delay(200, () => {
      this.selectItemAtIndex(defaultIndex)
    })
  }

  findIndex(predicate: (value: PJTabBarItemInterface, index: number, obj: PJTabBarItemInterface[]) => boolean, thisArg?: undefined): number {
    return this.dataSource.findIndex(predicate, thisArg)
  }

  find(predicate: (value: PJTabBarItemInterface, index: number, obj: PJTabBarItemInterface[]) => boolean, thisArg?: undefined): PJTabBarItemInterface | undefined {
    return this.dataSource.find(predicate, thisArg)
  }

  getItem(atIndex: number): PJTabBarItemInterface | undefined {
    return this.dataSource.getData(atIndex)
  }

  @Styles private indicatorStyles() {
    .width(this.indicatorWidth)
    .height(this.indicatorHeight)
    .borderRadius(this.tabBarOptions.indicatorBorderRadius)
    .clip(true)
    .margin(this.tabBarOptions.indicatorMargin)
  }

  @Builder private itemBuilder(item: PJTabBarItemInterface, index: number) {
    Column() {
      if (this.tabBarOptions.indicatorPosition === PJIndicatorPosition.Center) {
        Stack() {
          this.indicatorBuilder(item, index)
          this.itemContentBuilder({currentItemIndex: index, selectedItemIndex: this.index, item: item})
        }
        .alignContent(Alignment.Center)
      } else {
        // 滚动条位置在Text上
        if (this.tabBarOptions.indicatorPosition === PJIndicatorPosition.Top) {
          this.indicatorBuilder(item, index)
        }

        this.itemContentBuilder({currentItemIndex: index, selectedItemIndex: this.index, item: item})

        // 滚动条位置在Text下
        if (this.tabBarOptions.indicatorPosition === PJIndicatorPosition.Bottom) {
          this.indicatorBuilder(item, index)
        }
      }
    }
    .onAreaChange((_, newArea) => {
      this.didAreaChange(index, newArea)
    })
    .onClick(() => {
      this.selectItemAtIndex(index)
      if (this.onSelectItem) {
        let selectedItem = this.getItem(index)
        if (selectedItem) {
          this.onSelectItem(selectedItem, index)
        }
      }
    })
    // 处理indicator挡住text问题
    .zIndex(this.defaultIndex !== index ? 1 : 0)
  }

  @Builder private indicatorBuilder(item: PJTabBarItemInterface, index: number) {
    if (!this.tabBarOptions.isHideIndicator) {
      if (this.defaultIndex === index) {
        Column() {
          Column() {
            if (this.customerIndicatorBuilder !== PJNullBuilder) {
              Column() {
                this.customerIndicatorBuilder(item, this.tabBarOptions, index)
              }
              .width(this.indicatorWidth)
              .height(this.indicatorHeight)
              .margin(this.tabBarOptions.indicatorMargin)
              .clip(true)
            } else {
              Divider()
                .indicatorStyles()
                .color(this.tabBarOptions.indicatorColor)
                .strokeWidth(this.indicatorHeight)
            }
          }
          .width(this.indicatorWidth)
        }
        /// 这里控制indicator的位置, indicatorOffsetX的值为被选中的item的centerX
        .offset({x: this.indicatorOffsetX, y: 0})
        .width(1)
        .clip(false)
        .backgroundColor(Color.Transparent)
      } else {
        Divider()
          .width(0)
          .height(this.indicatorHeight)
          .margin(this.tabBarOptions.indicatorMargin)
          .color(Color.Transparent)
      }
    }
  }

  @Builder private itemContentBuilder($$: PJReferenceTabBarItemInterface) {
    PJTabBarItemComponent({selectedItemIndex: $$.selectedItemIndex, currentItemIndex: $$.currentItemIndex, item: $$.item, tabBarOptions: this.tabBarOptions, customerItemBuilder: this.customerItemBuilder})
  }

  build() {
    Row() {
      // 左侧固定住的附加视图
      if (this.leftItemBuilder !== PJNullBuilder && this.tabBarOptions.isLeftItemFixed) {
        Column() {
          this.leftItemBuilder()
        }
        .height(this.tabBarOptions.isLeftItemSameHeightWithTabBar ? this.scrollHeight : null)
        .visibility(this.tabBarOptions.isHideLeftItem ? Visibility.None : Visibility.Visible)
        .layoutWeight(this.tabBarOptions.isTabBarWidthFillParent ? 0 : 1)
      }

      // tabbar主体
      Scroll(this.scroller) {
        Row({space: this.tabBarOptions.itemSpace}) {
          // 左侧附加视图
          if (this.leftItemBuilder !== PJNullBuilder && !this.tabBarOptions.isLeftItemFixed) {
            Column() {
              this.leftItemBuilder()
            }
            .height(this.tabBarOptions.isLeftItemSameHeightWithTabBar ? this.scrollHeight : null)
            .visibility(this.tabBarOptions.isHideLeftItem ? Visibility.None : Visibility.Visible)
          }

          ForEach(this.items, (item: PJTabBarItemInterface, index) => {
            this.itemBuilder(item, index)
          }, (item: PJTabBarItemInterface, index: number) => this.dataSource.identifier(index))

          // 右侧附加视图
          if (this.rightItemBuilder !== PJNullBuilder && !this.tabBarOptions.isRightItemFixed) {
            Column() {
              this.rightItemBuilder()
            }
            .height(this.tabBarOptions.isRightItemSameHeightWithTabBar ? this.scrollHeight : null)
            .visibility(this.tabBarOptions.isHideRightItem ? Visibility.None : Visibility.Visible)
          }
        }
      }
      .backgroundColor(this.tabBarOptions.tabBarBackGround)
      .scrollBar(BarState.Off)
      .scrollable(this.tabBarOptions.scrollable)
      .width(this.tabBarOptions.isTabBarWidthFillParent ? '100%' : null)
      .layoutWeight(this.tabBarOptions.isTabBarWidthFillParent ? 1 : 0)
      // 这里控制item的位置，比如居左居右
      .align(this.tabBarOptions.itemAlign)
      .edgeEffect(this.tabBarOptions.edgeEffect)
      .padding(this.tabBarOptions.tabBarContentMargin)
      .border(this.tabBarOptions.tabBarBorder)
      .onAreaChange((oldArea: Area, newArea: Area) => {
        this.handleScrollAreaChanged(oldArea, newArea)
      })
      .onScrollEdge((side: Edge) => {
        if (this.onScrollEdge) {
          this.onScrollEdge(side)
        }
      })

      // 右侧固定住的附加视图
      if (this.rightItemBuilder !== PJNullBuilder && this.tabBarOptions.isRightItemFixed) {
        Column() {
          this.rightItemBuilder()
        }
        .height(this.tabBarOptions.isRightItemSameHeightWithTabBar ? this.scrollHeight : null)
        .visibility(this.tabBarOptions.isHideRightItem ? Visibility.None : Visibility.Visible)
        .layoutWeight(this.tabBarOptions.isTabBarWidthFillParent ? 0 : 1)
      }
    }
    // 这里控制scroll的位置，比如居上居下居中
    .alignItems(this.tabBarOptions.tabBarVerticalAlign)
  }

  private handleScrollAreaChanged(oldArea: Area, newArea: Area) {
    if (oldArea.height !== newArea.height) {
      this.scrollHeight = newArea.height as number
    }

    if (oldArea.width !== newArea.width) {
      if (this.tabBarOptions.shouldScrollToCurrentIndexWhenTabBarWidthChanged) {
        let selectedIndexArea = this.attrs.get(this.index)
        // 如果当前选中的item已经可见则不需要滚动item的位置
        if (selectedIndexArea) {
          let x = selectedIndexArea.area.position.x
          if (x && !(x >= 0 && ((x as number) + (selectedIndexArea.area.width as number)) <= newArea.width)) {
            this.delay(500, () => {
              this.scrollItemToIndex(this.index)
            })
          }
        }
      }
    }
  }
}

class PJTabBarControllerKey {}

export class PJTabBarController {
  private weakMap = new WeakMap<object, PJTabBar>()
  private key: PJTabBarControllerKey = {}

  /**
   * Return the current selected item index.
   */
  currentIndex(): number {
    return this.weakMap.get(this.key)?.index ?? 0
  }

  /**
   * Select the item at index. And will also scroll the indicator to the selected item.
   * @param index The new selected item index.
   */
  selectItemAtIndex(index: number, duration: number | undefined = this.weakMap.get(this.key)?.tabBarOptions.itemAnimationDuration) {
    this.weakMap.get(this.key)?.selectItemAtIndex(index, duration)
  }

  /**
   * Linkage indicator and page.
   */
  handleTouch(event: TouchEvent, currentIndex: number, duration: number | undefined = this.weakMap.get(this.key)?.tabBarOptions.itemAnimationDuration) {
    this.weakMap.get(this.key)?.handleTouch(event, currentIndex, duration)
  }

  /**
   * Bind the `PJTabBar` as delegate.
   * @param tabBar Used to bind with PJTabBarController as delegate.
   */
  bind(tabBar: PJTabBar) {
    this.weakMap.set(this.key, tabBar)
  }

  dataSource(): PJTabDataSource | undefined {
    return this.weakMap.get(this.key)?.dataSource
  }

  /// CRUD Actions

  /**
   * Update the item with `item` at `atIndex`.
   * @param atIndex Index of the item to be updated.
   * @param item The new item used to update the current item at `atIndex`.
   */
  update(index: number, item: PJTabBarItemInterface) {
    this.weakMap.get(this.key)?.update(index, item)
  }

  /**
   * Appends new elements to the end of an array, and returns the new length of the array.
   * @param items New elements to add to the array.
   */
  push(...items: PJTabBarItemInterface[]): number {
    return this.weakMap.get(this.key)?.push(...items) ?? -1
  }

  /**
   * Insert the new item at `atIndex`.
   * @param atIndex Index of the new item to be inserted.
   * @param item The new item used to insert at `atIndex`.
   */
  insert(atIndex: number, item: PJTabBarItemInterface) {
    this.weakMap.get(this.key)?.insert(atIndex, item)
  }

  /**
   * Delete the item at `atIndex`.
   * @param atIndex Delete the item at `atIndex` and return the deleted item. And return null if the `atIndex` is out of range.
   */
  delete(atIndex: number): PJTabBarItemInterface | null {
    let tabBar = this.weakMap.get(this.key)
    if (tabBar) {
      return tabBar.delete(atIndex)
    }
    return null
  }

  /**
   * Replace current items with `withItems` and select item at `selectIndex`.
   * @param withItems Used to replace current items.
   * @param selectIndex If provided, will select the item at `selectIndex`. If it is not provided, the current index is used instead.
   */
  setItems(withItems: PJTabBarItemInterface[], selectIndex: number = this.currentIndex()) {
    this.weakMap.get(this.key)?.setItems(withItems, selectIndex)
  }

  /**
   * Returns the index of the first element in the array where predicate is true, and -1
   * otherwise.
   * @param predicate find calls predicate once for each element of the array, in ascending
   * order, until it finds one where predicate returns true. If such an element is found,
   * findIndex immediately returns that element index. Otherwise, findIndex returns -1.
   * @param thisArg If provided, it will be used as the this value for each invocation of
   * predicate. If it is not provided, undefined is used instead.
   */
  findIndex(predicate: (value: PJTabBarItemInterface, index: number, obj: PJTabBarItemInterface[]) => boolean, thisArg?: undefined): number {
    return this.weakMap.get(this.key)?.findIndex(predicate, thisArg) ?? -1
  }

  /**
   * Returns the value of the first element in the array where predicate is true, and undefined
   * otherwise.
   * @param predicate find calls predicate once for each element of the array, in ascending
   * order, until it finds one where predicate returns true. If such an element is found, find
   * immediately returns that element value. Otherwise, find returns undefined.
   * @param thisArg If provided, it will be used as the this value for each invocation of
   * predicate. If it is not provided, undefined is used instead.
   */
  find(predicate: (value: PJTabBarItemInterface, index: number, obj: PJTabBarItemInterface[]) => boolean, thisArg?: undefined): PJTabBarItemInterface | undefined {
    return this.weakMap.get(this.key)?.find(predicate, thisArg)
  }

  /**
   * Returns the value of the atIndex in the array where predicate is true, and undefined
   * otherwise.
   * @param atIndex Index of the element in the array.
   */
  getItem(atIndex: number): PJTabBarItemInterface | undefined {
    return this.weakMap.get(this.key)?.getItem(atIndex)
  }
}
