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

import {PJTabBarOptionsInterface, PJTabBarOptions} from '../models/PJTabBarOptions'
import {PJTabBarItemInterface} from '../models/PJTabBarItem'
import {PJTabBar, PJTabBarController} from './PJTabBar'
import {PJBuilder} from '../models/PJBuilder'

@Component
export struct PJTabComponent {
  private tabsController: TabsController = new TabsController()
  private tabBarController: PJTabBarController = new PJTabBarController()
  private hasInit: boolean = false

  @State index: number = 0
  @State items: PJTabBarItemInterface[] = []
  @State tabBarOptions: PJTabBarOptionsInterface = new PJTabBarOptions()
  // 默认选中的index
  private _defaultIndex: number = 0
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
  @Require @BuilderParam contentBuilder: (item: PJTabBarItemInterface, index: number) => void = this.nullBuilder

  @Builder private nullBuilder() {}

  aboutToAppear() {
    if (!this.hasInit) {
      this.hasInit = true
      this._defaultIndex = this.index
      if (this.controller) {
        this.controller.bind(this)
      }
    }
  }

  currentIndex(): number {
    return this.tabBarController.currentIndex()
  }

  changeIndex(index: number) {
    this.tabBarController.selectItemAtIndex(index)
    this.tabsController.changeIndex(index)
  }

  /// CRUD Actions

  update(index: number, item: PJTabBarItemInterface) {
    this.tabBarController.update(index, item)
  }

  insert(atIndex: number, item: PJTabBarItemInterface) {
    this.tabBarController.insert(atIndex, item)
  }

  delete(atIndex: number): PJTabBarItemInterface | null {
    return this.tabBarController.delete(atIndex)
  }

  replace(withItems: PJTabBarItemInterface[], selectIndex: number = this.currentIndex()) {
    this.tabBarController.replace(withItems, selectIndex)
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

  build() {
    Column() {
      PJTabBar({index: $index, items: $items, tabBarOptions: $tabBarOptions, controller: this.tabBarController,
        builder: this.builder,
        onSelectItem: (item: PJTabBarItemInterface, index: number) => {
          this.tabsController.changeIndex(index)
          if (this.onClickTabBarItem) {
            this.onClickTabBarItem(item, index)
          }

          if (this.onChangeTabBarItem) {
            this.onChangeTabBarItem(item, index)
          }
        },
        onScrollEdge: (side) => {
          if (this.onScrollEdge) {
            this.onScrollEdge(side)
          }
        }})

      // 这边index如果传入this.index会形成与Tabs绑定,导致在onAnimationStart回调中调用selectItemAtIndex时过早更新this.index,造成page切换动画很快结束,过渡不自然.
      Tabs({controller: this.tabsController, index: this._defaultIndex}) {
        ForEach(this.items, (item: PJTabBarItemInterface, index) => {
          TabContent() {
            this.contentBuilder(item, index)
          }
          .align(Alignment.TopStart)
          .margin({bottom: 42}) // 修复TabContent底部超出大概42vp屏幕问题
          // TODO: 采用onTouch手势滑动距离来处理indicator跟随page内容滚动打不到理想效果,等API11采用onGestureSwipe实现
          // .onTouch((event) => {
          //   this.tabBarController.onTouchPage(event, this.index)
          // })
        })
      }
      .barHeight(0)
      .onChange((index: number) => {
        if (this.onChangePage) {
          this.onChangePage(this.items[index], index)
        }
      })
      .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
        if (this.index !== targetIndex) {
          this.tabBarController.selectItemAtIndex(targetIndex)
        }
      })
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
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
  changeIndex(index: number) {
    this.weakMap.get(this.key)?.changeIndex(index)
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
  replace(withItems: PJTabBarItemInterface[], selectIndex: number = this.currentIndex()) {
    this.weakMap.get(this.key)?.replace(withItems, selectIndex)
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

