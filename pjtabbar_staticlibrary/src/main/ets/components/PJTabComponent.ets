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

@Component
export struct PJTabComponent {
  private tabsController: TabsController = new TabsController()
  private tabBarController: PJTabBarController = new PJTabBarController()
  private hasInit: boolean = false

  @State index: number = 0
  @State items: PJTabBarItemInterface[] = []
  @State @Watch('didUpdateTabBarOptions') tabBarOptions: PJTabBarOptionsInterface = new PJTabBarOptions()
  controller: PJTabComponentController | null

  // 点击了item
  onClickTabBarItem: (item: PJTabBarItemInterface, index: number) => void | null
  // 切换了item
  onChangeTabBarItem: (item: PJTabBarItemInterface, index: number) => void | null
  // 切换了page
  onChangePage: (item: PJTabBarItemInterface, index: number) => void | null
  // tabbar滚动到头
  onScrollEdge: (side: Edge) => void | null

  // 自定义page内容视图
  @BuilderParam contentBuilder?: (item: PJTabBarItemInterface, index: number) => void | null = null
  // 自定义item视图
  @BuilderParam customerItemBuilder?: (item: PJTabBarItemInterface, options: PJTabBarOptionsInterface, index: number) => void | null = null
  // 自定义Indicator，不需要设置width和height
  @BuilderParam customerIndicatorBuilder?: (item: PJTabBarItemInterface, options: PJTabBarOptionsInterface, index: number) => void | null = null
  // 左边附加视图
  @BuilderParam leftItemBuilder?: () => void | null = null
  // 右边附加视图
  @BuilderParam rightItemBuilder?: () => void | null = null

  aboutToAppear() {
    if (!this.hasInit) {
      this.hasInit = true
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

  private didUpdateTabBarOptions() {
    // TODO: Update indicator pos
    // this.tabBarController.selectItemAtIndex(this.index)
  }

  /// CRUD Actions

  update(index: number, item: PJTabBarItemInterface) {
    this.tabBarController.update(index, item)
  }

  insert(atIndex: number, item: PJTabBarItemInterface) {
    this.tabBarController.insert(atIndex, item)
  }

  delete(atIndex: number): PJTabBarItemInterface | undefined {
    return this.tabBarController.delete(atIndex)
  }

  findIndex(predicate: (value: PJTabBarItemInterface, index: number, obj: PJTabBarItemInterface[]) => unknown, thisArg?: any): number {
    return this.tabBarController.findIndex(predicate)
  }

  find(predicate: (value: PJTabBarItemInterface, index: number, obj: PJTabBarItemInterface[]) => unknown, thisArg?: any): PJTabBarItemInterface | undefined {
    return this.tabBarController.find(predicate)
  }

  getItem(atIndex: number): PJTabBarItemInterface | undefined {
    return this.tabBarController.getItem(atIndex)
  }

  build() {
    Column() {
      PJTabBar({index: $index, items: $items, tabBarOptions: $tabBarOptions, controller: this.tabBarController,
        customerItemBuilder: this.customerItemBuilder,
        customerIndicatorBuilder: this.customerIndicatorBuilder,
        leftItemBuilder: this.leftItemBuilder,
        rightItemBuilder: this.rightItemBuilder,
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

      Tabs({controller: this.tabsController, index: this.index}) {
        ForEach(this.items, (item, index) => {
          TabContent() {
            if (this.contentBuilder) {
              this.contentBuilder(item, index)
            }
          }
          .align(Alignment.TopStart)
          // TODO: 采用onTouch手势滑动距离来处理indicator跟随page内容滚动打不到理想效果,等API11采用onGestureSwipe实现
          // .onTouch((event) => {
          //   this.tabBarController.onTouchPage(event, this.index)
          // })
        })
      }
      .barHeight(0)
      .onChange((index: number) => {
        if (this.index !== index) {
          this.tabBarController.selectItemAtIndex(index)
        }

        if (this.onChangePage) {
          this.onChangePage(this.items[index], index)
        }
      })
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
  }
}

export class PJTabComponentController {
  private weakMap = new WeakMap<object, PJTabComponent>()
  private key = {}

  currentIndex(): number {
    return this.weakMap.get(this.key)?.currentIndex() ?? 0
  }

  changeIndex(index: number) {
    this.weakMap.get(this.key)?.changeIndex(index)
  }

  bind(tabComponent: PJTabComponent) {
    this.weakMap.set(this.key, tabComponent)
  }

  update(index: number, item: PJTabBarItemInterface) {
    this.weakMap.get(this.key)?.update(index, item)
  }

  insert(atIndex: number, item: PJTabBarItemInterface) {
    this.weakMap.get(this.key)?.insert(atIndex, item)
  }

  delete(atIndex: number): PJTabBarItemInterface | null {
    return this.weakMap.get(this.key)?.delete(atIndex)
  }

  findIndex(predicate: (value: PJTabBarItemInterface, index: number, obj: PJTabBarItemInterface[]) => unknown, thisArg?: any): number {
    return this.weakMap.get(this.key)?.findIndex(predicate) ?? -1
  }

  find(predicate: (value: PJTabBarItemInterface, index: number, obj: PJTabBarItemInterface[]) => unknown, thisArg?: any): PJTabBarItemInterface | undefined {
    return this.weakMap.get(this.key)?.find(predicate)
  }

  getItem(atIndex: number): PJTabBarItemInterface | undefined {
    return this.weakMap.get(this.key)?.getItem(atIndex)
  }
}

