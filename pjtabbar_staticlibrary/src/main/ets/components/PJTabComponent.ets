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
  @Require @BuilderParam contentBuilder: (item: PJTabBarItemInterface, index: number) => void

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

      Tabs({controller: this.tabsController, index: this.index}) {
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

class PJTabComponentControllerKey {}

export class PJTabComponentController {
  private weakMap = new WeakMap<object, PJTabComponent>()
  private key: PJTabComponentControllerKey = {}

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
    let tabBar = this.weakMap.get(this.key)
    if (tabBar) {
      return tabBar.delete(atIndex)
    }
    return null
  }

  findIndex(predicate: (value: PJTabBarItemInterface, index: number, obj: PJTabBarItemInterface[]) => boolean, thisArg?: undefined): number {
    return this.weakMap.get(this.key)?.findIndex(predicate, thisArg) ?? -1
  }

  find(predicate: (value: PJTabBarItemInterface, index: number, obj: PJTabBarItemInterface[]) => boolean, thisArg?: undefined): PJTabBarItemInterface | undefined {
    return this.weakMap.get(this.key)?.find(predicate, thisArg)
  }

  getItem(atIndex: number): PJTabBarItemInterface | undefined {
    return this.weakMap.get(this.key)?.getItem(atIndex)
  }
}

