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

import {PJTabBarOptionsInterface, PJTabBarOptions, PJIndicatorAnimationType} from '../models/PJTabBarOptions'
import { PJReferenceTabBarItemInterface, PJTabBarItemInterface} from '../models/PJTabBarItem'
import {PJTabBar, PJTabBarController} from './PJTabBar'
import {PJBuilder, PJNullBuilder} from '../models/PJBuilder'
import { PJTabDataSource } from '../datasources/PJTabDataSource'

@Component
export struct PJTabComponent {
  private tabsController: TabsController = new TabsController()
  private tabBarController: PJTabBarController = new PJTabBarController()
  private swiperController: SwiperController = new SwiperController()
  private hasInit: boolean = false

  @State index: number = 0
  @State items: PJTabBarItemInterface[] = []
  private dataSource: PJTabDataSource = new PJTabDataSource()
  @State private hasBindDataSource: boolean = false
  @State tabBarOptions: PJTabBarOptionsInterface = new PJTabBarOptions()
  @State private tabsIndex: number = 0
  private isOnAnimation: boolean = false
  controller?: PJTabComponentController | null

  // 点击了item
  onClickTabBarItem?: (item: PJTabBarItemInterface, index: number) => void | null
  // 切换了item
  onChangeTabBarItem?: (item: PJTabBarItemInterface, index: number) => void | null
  // 切换了page
  onChangePage?: (item: PJTabBarItemInterface, index: number) => void | null
  // Tabbar滚动到头
  onScrollEdge?: (side: Edge) => void | null

  builder: PJBuilder = new PJBuilder()

  // 自定义page内容视图
  @Require @BuilderParam contentBuilder: ($$: PJReferenceTabBarItemInterface) => void = PJNullBuilder

  aboutToAppear() {
    if (!this.hasInit) {
      this.hasInit = true
      this.index = Math.max(Math.min(this.index, this.items.length - 1), 0)
      this.tabsIndex = this.index.valueOf()
      if (this.controller) {
        this.controller.bind(this)
      }
    }
  }

  currentIndex(): number {
    return this.tabBarController.currentIndex()
  }

  changeIndex(index: number, duration: number | undefined = this.tabBarOptions.itemAnimationDuration) {
    this.tabBarController.selectItemAtIndex(index, duration)
    if (this.tabBarOptions.enableRecycling) {
      this.swiperController.changeIndex(index, true)
    } else {
      this.tabsController.changeIndex(index)
    }
  }

  private bindDataSource() {
    let dataSource = this.tabBarController.dataSource()
    if (dataSource) {
      this.dataSource = dataSource
      this.hasBindDataSource = true
    }
  }

  /// CRUD Actions

  update(index: number, item: PJTabBarItemInterface) {
    this.tabBarController.update(index, item)
  }

  push(...items: PJTabBarItemInterface[]): number {
    return this.tabBarController.push(...items)
  }

  insert(atIndex: number, item: PJTabBarItemInterface) {
    let fixedIndex = Math.min(Math.max(atIndex, 0), this.dataSource.totalCount())
    if (fixedIndex <= this.index) {
      this.tabsIndex = this.index + 1
    }
    this.tabBarController.insert(atIndex, item)
  }

  delete(atIndex: number): PJTabBarItemInterface | null {
    if (atIndex < this.dataSource.totalCount() && atIndex >= 0) {
      if (atIndex < this.index) {
        this.tabsIndex = this.index - 1
      } else if (atIndex === this.index) { // 如果删除的是当前选中的item,则默认重新选中第一个item。
        this.tabsIndex = 0
      }
    }
    return this.tabBarController.delete(atIndex)
  }

  setItems(withItems: PJTabBarItemInterface[], selectIndex: number = this.currentIndex()) {
    let defaultIndex = selectIndex < withItems.length ? Math.max(selectIndex, 0) : 0
    this.tabsIndex = defaultIndex
    this.tabBarController.setItems(withItems, selectIndex)
    this.delay(100, () => {
      if (this.tabBarOptions.enableRecycling) {
        this.swiperController.changeIndex(defaultIndex, true)
      } else {
        this.tabsController.changeIndex(defaultIndex)
      }
    })
  }

  findIndex(predicate: (value: PJTabBarItemInterface, index: number, obj: PJTabBarItemInterface[]) => boolean, thisArg?: undefined): number {
    return this.tabBarController.findIndex(predicate, thisArg)
  }

  find(predicate: (value: PJTabBarItemInterface, index: number, obj: PJTabBarItemInterface[]) => boolean, thisArg?: undefined): PJTabBarItemInterface | undefined {
    return this.tabBarController.find(predicate, thisArg)
  }

  getItem(atIndex: number): PJTabBarItemInterface | undefined {
    return this.tabBarController.getItem(atIndex)
  }

  preloadItems(indices: Optional<Array<number>>): Promise<void> {
    if (this.tabBarOptions.enableRecycling) {
      return Promise.reject("enableRecycling is true and preloadItems doesn't work. Set enableRecycling to false if want using preloadItems.")
    } else {
      return this.tabsController.preloadItems(indices)
    }
  }

  syncTabContentWidth(width: number) {
    this.tabBarController.syncTabContentWidth(width)
  }

  private handleOnSelectItem(index: number, item: PJTabBarItemInterface) {
    if (this.tabBarOptions.enableRecycling) {
      this.swiperController.changeIndex(index, true)
    } else {
      this.tabsController.changeIndex(index)
    }

    if (this.onClickTabBarItem) {
      this.onClickTabBarItem(item, index)
    }

    if (this.onChangeTabBarItem) {
      this.onChangeTabBarItem(item, index)
    }
  }

  private handleOnAnimationStart(index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) {
    this.isOnAnimation = true
    if (index !== targetIndex) {
      this.tabBarController.selectItemAtIndex(targetIndex)
    } else if (this.tabBarOptions.indicatorAnimationType === PJIndicatorAnimationType.Linkage) {
      this.tabBarController.selectItemAtIndex(index, this.tabBarOptions.tabsAnimationDuration)
    }
  }

  private handleOnAnimationEnd(index: number, extraInfo: SwiperAnimationEvent) {
    this.isOnAnimation = false
    if (this.tabBarOptions.indicatorAnimationType === PJIndicatorAnimationType.Linkage) {
      this.tabBarController.selectItemAtIndex(index)
    }
  }

  private handleOnTouch(event: TouchEvent) {
    if (!this.isOnAnimation) {
      this.tabBarController.handleTouch(event, this.index)
    }
  }

  private handleOnChange(index: number) {
    this.tabsIndex = index
    if (this.onChangePage) {
      let item = this.getItem(index)
      if (item) {
        this.onChangePage(item, index)
      }
    }
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

  build() {
    Column() {
      PJTabBar({index: $index, items: $items, tabBarOptions: $tabBarOptions, controller: this.tabBarController,
        builder: this.builder,
        onSelectItem: (item: PJTabBarItemInterface, index: number) => {
          this.handleOnSelectItem(index, item)
        },
        onScrollEdge: (side) => {
          if (this.onScrollEdge) {
            this.onScrollEdge(side)
          }
        },
        onInitData: () => {
          this.bindDataSource()
        }
      })
        .height(this.tabBarOptions.tabBarHeight)

      if (this.hasBindDataSource) {
        if (this.tabBarOptions.enableRecycling) {
          Swiper(this.swiperController) {
            LazyForEach(this.dataSource, (item: PJTabBarItemInterface, index: number) => {
              this.contentBuilder({currentItemIndex: index, selectedItemIndex: this.index, item: item})
            }, (_: PJTabBarItemInterface, index: number) => {
              return this.dataSource.identifier(index)
            })
          }
          .cachedCount(this.tabBarOptions.cachedCount)
          .index(this.tabsIndex)
          .autoPlay(false)
          .indicator(false)
          .loop(false)
          .duration(this.tabBarOptions.tabsAnimationDuration)
          .itemSpace(0)
          .curve(Curve.Linear)
          .disableSwipe(this.tabBarOptions.disableSwipe)
          .displayArrow(this.tabBarOptions.displayArrow[0], this.tabBarOptions.displayArrow[1])
          .onChange((index: number) => {
            this.handleOnChange(index)
          })
          .onAnimationStart((index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
            this.handleOnAnimationStart(index, targetIndex, extraInfo)
          })
          .onAnimationEnd((index: number, extraInfo: SwiperAnimationEvent) => {
            this.handleOnAnimationEnd(index, extraInfo)
          })
          .onTouch((event) => {
            this.handleOnTouch(event)
          })
          .onAreaChange((_, newArea: Area) => {
            this.syncTabContentWidth(newArea.width.valueOf() as number)
          })
          .expandSafeArea(this.tabBarOptions.expandSafeArea[0], this.tabBarOptions.expandSafeArea[1])
        } else {
          // 这边index如果传入this.index会形成与Tabs绑定,导致在onAnimationStart回调中调用selectItemAtIndex时过早更新this.index,造成page切换动画很快结束,过渡不自然. 需要在每次更新this.index时更新this.tabsIndex,否则CRUD操作后会出现Tabs自动选中第一个page的问题。
          Tabs({controller: this.tabsController, index: this.tabsIndex}) {
            ForEach(this.items, (item: PJTabBarItemInterface, index: number) => {
              TabContent() {
                this.contentBuilder({currentItemIndex: index, selectedItemIndex: this.index, item: item})
              }
              .align(Alignment.TopStart)
              .margin({bottom: 0})
              .expandSafeArea(this.tabBarOptions.expandSafeArea[0], this.tabBarOptions.expandSafeArea[1])
            }, (_: PJTabBarItemInterface, index: number) => {
              return this.dataSource.identifier(index)
            })
          }
          .barHeight(0)
          .scrollable(this.tabBarOptions.tabContentScrollable)
          .animationDuration(this.tabBarOptions.tabsAnimationDuration)
          .onChange((index: number) => {
            this.handleOnChange(index)
          })
          .onAnimationStart((index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
            this.handleOnAnimationStart(index, targetIndex, extraInfo)
          })
          .onAnimationEnd((index: number, extraInfo: SwiperAnimationEvent) => {
            this.handleOnAnimationEnd(index, extraInfo)
          })
          .onTouch((event) => {
            this.handleOnTouch(event)
          })
          .onAreaChange((_, newArea: Area) => {
            this.syncTabContentWidth(newArea.width.valueOf() as number)
          })
        }
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
    .expandSafeArea(this.tabBarOptions.expandSafeArea[0], this.tabBarOptions.expandSafeArea[1])
  }
}

class PJTabComponentControllerKey {}

export class PJTabComponentController {
  private weakMap = new WeakMap<object, PJTabComponent>()
  private key: PJTabComponentControllerKey = {}

  /**
   * Return the current selected item index.
   */
  currentIndex(): number {
    return this.weakMap.get(this.key)?.currentIndex() ?? 0
  }

  /**
   * Change the content page to the index. The tabbar will also select the new index.
   * @param index Index of the target page.
   */
  changeIndex(index: number, duration: number | undefined = this.weakMap.get(this.key)?.tabBarOptions.itemAnimationDuration) {
    this.weakMap.get(this.key)?.changeIndex(index, duration)
  }

  /**
   * Bind the `PJTabComponent` as delegate.
   * @param tabComponent Used to bind with PJTabComponentController as delegate.
   */
  bind(tabComponent: PJTabComponent) {
    this.weakMap.set(this.key, tabComponent)
  }

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

  /**
   * Called when need to preload specified tab content.
   *
   * @param { Optional<Array<number>> } indices - Indices of tab content to be preloaded.
   * @returns { Promise<void> } The promise returned by the function.
   * @throws { BusinessError } 401 - Parameter invalid. Possible causes:
   * <br> 1. The parameter type is not Array<number>.
   * <br> 2. The parameter is an empty array.
   * <br> 3. The parameter contains an invalid index.
   */
  preloadItems(indices: Optional<Array<number>>): Promise<void> | undefined {
    return this.weakMap.get(this.key)?.preloadItems(indices)
  }

  /**
   * Set the tab content width to tabbar. And the linkpage indicator will use it to calculate the percentage of gesture sliding.
   * The default value is the width of the device.
   * Note: If PJTabComponent does not fully fill the screen, this interface needs to be called to set the tab content width.
   * @param width used to set the tab content width.
   */
  syncTabContentWidth(width: number) {
    this.weakMap.get(this.key)?.syncTabContentWidth(width)
  }
}

