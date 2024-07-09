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
import {PJTabBarOptionsInterface, PJIndicatorPosition, PJTabBarOptions} from '../models/PJTabBarOptions'
import {PJTabBarItem, PJTabBarItemInterface} from '../models/PJTabBarItem'
import {PJTabBarItemAttribute} from '../models/PJTabBarItemAttribute'

@Extend(Text) function ItemTextCommonExtend(isSelected: boolean, options: PJTabBarOptionsInterface) {
  .fontSize(isSelected ? options.selectedFontSize : options.fontSize)
  .fontColor(isSelected ? options.selectedFontColor : options.fontColor)
  .fontWeight(isSelected ? options.selectedFontWeight : options.fontWeight)
  .fontStyle(isSelected ? options.selectedFontStyle : options.fontStyle)
  .fontFamily(options.fontFamily)
  .textAlign(options.textAlign)
}

@Component
export struct PJTabBar {
  // 第一次设置的index, 用于计算indicatorOffsetX
  private defaultIndex: number = 0
  @Link index: number
  @Link @Watch('updateItems') items: PJTabBarItem[]
  // tabbar配置
  @Link @Watch('didUpdateOtions') tabBarOptions: PJTabBarOptionsInterface
  controller: PJTabBarController | null
  private scroller: Scroller = new Scroller()
  // indicator移动的距离, 即移动到选中的item的centerX下
  @State private indicatorOffsetX: number = 0
  // item坐标数据
  private attrs: PJTabBarItemAttribute[] = []
  private hasInitData: boolean = false
  private hasInitTabPos: boolean = false
  @State private scrollHeight: number = 0
  private scrollWidth: number = 0
  onSelectItem?: (item: PJTabBarItemInterface, index: number) => void
  // tabbar滚动到头
  onScrollEdge: (side: Edge) => void | null

  // 自定义item视图
  @BuilderParam customerItemBuilder?: (item: PJTabBarItemInterface, options: PJTabBarOptionsInterface, index: number) => void | null = null
  // 自定义Indicator，不需要设置width和height
  @BuilderParam customerIndicatorBuilder?: (item: PJTabBarItemInterface, options: PJTabBarOptionsInterface, index: number) => void | null = null
  // 左边附加视图
  @BuilderParam leftItemBuilder?: () => void | null = null
  // 右边附加视图
  @BuilderParam rightItemBuilder?: () => void | null = null

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
    if (!this.tabBarOptions) {
      this.tabBarOptions = new PJTabBarOptions()
    }

    this.hasInitData = true
    this.defaultIndex = this.index

    // 初始化item的index
    this.updateItems()

    if (this.controller) {
      this.controller.bind(this)
    }

    if (this.tabBarOptions.indicatorPosition === PJIndicatorPosition.Center) {
      this.tabBarOptions.indicatorMargin = {top: 0, bottom: 0, left: 0, right: 0}
    }
  }

  private updateItems() {
    for(let index = 0; index < this.items.length; index++) {
      this.items[index].index = index
    }
  }

  // item坐标大小变化
  private didAreaChange(ofIndex: number, oldArea: Area, newArea: Area) {
    // 更新保存所有item的position
    this.updateItemAttribute(ofIndex, {area: newArea})
    // 第一次加载出来滚动到默认选中的item位置
    if (!this.hasInitTabPos && this.index === ofIndex) {
      this.hasInitTabPos = true
      this.scrollItemToIndex(this.index)
      if (this.tabBarOptions.isSameHeightWithItem) {
        this.tabBarOptions.indicatorHeight = newArea.height as number
      }

      if (this.tabBarOptions.isSameWidthWithItem) {
        this.tabBarOptions.indicatorWidth = newArea.width as number
      }
    }
  }

  private updateItemAttribute(index: number, attr: PJTabBarItemAttribute) {
    this.attrs[index] = attr
  }

  private didUpdateOtions() {
    // 修复先将tabar滚到到底，在隐藏Left/Right Item时tabbar没更新xOffset
    if ((this.tabBarOptions.isHideRightItem && !this.tabBarOptions.isRightItemFixed) || (this.tabBarOptions.isHideLeftItem && !this.tabBarOptions.isLeftItemFixed)) {
      this.scroller.scrollTo({xOffset: this.scroller.currentOffset().xOffset - 1, yOffset: this.scroller.currentOffset().yOffset, animation: {duration: this.tabBarOptions.itemAnimationDuration, curve: Curve.Linear}})
    }
  }

  /// 滚动indicator到新选中的item位置
  private scrollIndicatorToIndex(newIndex: number) {
    if (newIndex < this.attrs.length) {
      let oldArea = this.attrs[this.defaultIndex]
      let newArea = this.attrs[newIndex]
      if (newArea) {
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
        this.tempOffsetX = newIndicatorOffseX
        animateTo({duration: this.tabBarOptions.indicatorAnimationDuration, curve: Curve.Linear}, () => {
          this.indicatorOffsetX = newIndicatorOffseX
          if (this.tabBarOptions.isSameWidthWithItem) {
            // 更新indicatorWidth
            animateTo({duration: this.tabBarOptions.indicatorAnimationDuration, curve: Curve.Linear}, () => {
              this.tabBarOptions.indicatorWidth = newArea.area.width as number
            })
          }

          if (this.tabBarOptions.isSameHeightWithItem && this.tabBarOptions.indicatorHeight !== (newArea.area.height as number)) {
            this.tabBarOptions.indicatorHeight = newArea.area.height as number
          }
        })
      }
    }
  }

  /// 滚动item到指定index
  private scrollItemToIndex(index: number) {
    if (index < this.attrs.length) {
      let attr = this.attrs[index]
      if (attr) {
        // 使item尽量滚到中间位置
        this.scroller.scrollTo({xOffset: (attr.area.position.x as number) - this.tabBarOptions.optimizeOffsetX, yOffset: this.scroller.currentOffset().yOffset, animation: {duration: this.tabBarOptions.itemAnimationDuration, curve: Curve.Linear}})
      }
    }
  }

  selectItemAtIndex(index: number) {
    this.index = index
    this.scrollItemToIndex(index)
    this.scrollIndicatorToIndex(this.index)
  }

  private isSelectedItem(item: PJTabBarItemInterface): boolean {
    return this.index === item.index
  }

  private getItemCenterX(index: number): number | null {
    if (index >= this.attrs.length) {
      return null
    }

    let targetArea = this.attrs[index]
    let newItemX = (targetArea.area.position.x ?? 0) as number
    let newItemCenterX = newItemX + (targetArea.area.width as number) / 2
    return newItemCenterX
  }

  private getItemWidth(index: number): number | null {
    if (index >= this.attrs.length) {
      return null
    }

    let targetArea = this.attrs[index]
    return targetArea.area.width as number
  }

  private delay(duration: number, handler: () => void) {
    new Promise<void>((resolve, reject) => {
      setTimeout(() => {
        resolve()
      }, duration)
    })
      .then(() => {
        handler()
      })
  }

  /// TODO: 采用onTouch手势滑动距离来处理indicator跟随page内容滚动打不到理想效果,等API11采用onGestureSwipe实现
  onTouchPage(event: TouchEvent, currentIndex: number) {
    if (this.tabBarOptions.indicatorPosition !== PJIndicatorPosition.Center) {
      return
    }

    let startX = this.moveStartX
    let offset = 0
    if (event.type === TouchType.Down) {
      this.moveStartX = event.touches[0].x
      this.moveStartTime = Date.now()
    }

    if (event.type === TouchType.Move) {
      offset = event.touches[0].x - startX
      if ((offset >= 0 && currentIndex > 0) || (offset <= 0 && currentIndex < this.items.length - 1)) {
        let isMoveToLeft: boolean = offset > 0
        let targetIndex = isMoveToLeft ? currentIndex - 1 : currentIndex + 1
        let targetCenterX = this.getItemCenterX(targetIndex)
        if (targetCenterX) {
          // 计算滚动百分比
          let movePercentage = Math.abs(offset) / px2vp(display.getDefaultDisplaySync().width)
          movePercentage = Math.min(movePercentage, 1)
          let currentCenterX = this.getItemCenterX(currentIndex)
          if (currentCenterX) {
            let subIndicatorOffsetX = targetCenterX - currentCenterX
            this.indicatorOffsetX = this.tempOffsetX + subIndicatorOffsetX * movePercentage
            if (this.tabBarOptions.isSameWidthWithItem) {
              let targetWidth = this.getItemWidth(targetIndex)
              let newIndicatorWidth = targetWidth > this.tabBarOptions.indicatorWidth ? targetWidth * movePercentage : targetWidth * (1 - movePercentage)
              this.tabBarOptions.indicatorWidth = newIndicatorWidth
            }
          }
        }
      }
    }

    if (event.type === TouchType.Up) {
      this.moveEndTime = Date.now()
      if (this.moveEndTime - this.moveStartTime <= 500) {
        offset = 0
        this.moveStartX = 0
        this.moveStartTime = 0
        this.moveEndTime = 0
        return
      }

      let movePercentage = Math.abs(offset) / px2vp(display.getDefaultDisplaySync().width)
      offset = 0
      this.moveStartX = 0
      this.moveStartTime = 0
      this.moveEndTime = 0

      if (movePercentage >= 0.5) {
        this.delay(this.tabBarOptions.indicatorAnimationDuration, () => {
          this.scrollIndicatorToIndex(this.index + (offset > 0 ? -1 : 1))
        })
      } else {
        this.delay(this.tabBarOptions.indicatorAnimationDuration, () => {
          this.scrollIndicatorToIndex(this.index)
        })
      }
    }
  }

  /// CRUD Actions

  update(index: number, item: PJTabBarItemInterface) {
    this.items[index] = item
  }

  insert(atIndex: number, item: PJTabBarItemInterface) {
    if (atIndex <= this.index) {
      this.index += 1
    }
    this.items.splice(atIndex, 0, item)
    this.delay(200, () => {
      this.scrollIndicatorToIndex(this.index)
    })
  }

  delete(atIndex: number): PJTabBarItemInterface | undefined {
    if (atIndex >= this.items.length) {
      return undefined
    }

    let hasChangeIndex: boolean = false
    if (atIndex < this.index) {
      this.index -= 1
    } else if (atIndex === this.index) {
      this.index = 0
      hasChangeIndex = true
    }

    let deletedItems = this.items.splice(atIndex, 1)
    this.delay(200, () => {
      this.scrollIndicatorToIndex(this.index)
      if (hasChangeIndex && this.onSelectItem) {
        this.onSelectItem(this.items[this.index], this.index)
      }
    })
    // 修复先将tabar滚到到底，在删除Item时tabbar没更新xOffset
    this.scroller.scrollTo({xOffset: this.scroller.currentOffset().xOffset - 1, yOffset: this.scroller.currentOffset().yOffset, animation: {duration: this.tabBarOptions.itemAnimationDuration, curve: Curve.Linear}})
    return deletedItems.length > 0 ? deletedItems[0] : undefined
  }

  findIndex(predicate: (value: PJTabBarItemInterface, index: number, obj: PJTabBarItemInterface[]) => unknown, thisArg?: any): number {
    return this.items.findIndex(predicate)
  }

  find(predicate: (value: PJTabBarItemInterface, index: number, obj: PJTabBarItemInterface[]) => unknown, thisArg?: any): PJTabBarItemInterface | undefined {
    return this.items.find(predicate)
  }

  getItem(atIndex: number): PJTabBarItemInterface | undefined {
    if (atIndex < this.items.length) {
      return this.items[atIndex]
    }
    return undefined
  }

  @Styles private indicatorStyles() {
    .width(this.tabBarOptions.indicatorWidth)
    .height(this.tabBarOptions.indicatorHeight)
    .borderRadius(this.tabBarOptions.indicatorBorderRadius)
    .clip(true)
    .margin(this.tabBarOptions.indicatorMargin)
  }

  @Builder private itemBuilder(item: PJTabBarItemInterface, index: number) {
    Column() {
      if (this.tabBarOptions.indicatorPosition === PJIndicatorPosition.Center) {
        Stack() {
          this.indicatorBuilder(item, index)
          this.textBuilder(item, index)
        }
        .alignContent(Alignment.Center)
      } else {
        // 滚动条位置在Text上
        if (this.tabBarOptions.indicatorPosition === PJIndicatorPosition.Top) {
          this.indicatorBuilder(item, index)
        }

        this.textBuilder(item, index)

        // 滚动条位置在Text下
        if (this.tabBarOptions.indicatorPosition === PJIndicatorPosition.Bottom) {
          this.indicatorBuilder(item, index)
        }
      }
    }
    .onAreaChange((oldArea, newArea) => {
      this.didAreaChange(index, oldArea, newArea)
    })
    .onClick(() => {
      this.selectItemAtIndex(index)
      if (this.onSelectItem) {
        this.onSelectItem(this.items[index], index)
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
            if (this.customerIndicatorBuilder) {
              Column() {
                this.customerIndicatorBuilder(item, this.tabBarOptions, index)
              }
              .width(this.tabBarOptions.indicatorWidth)
              .height(this.tabBarOptions.indicatorHeight)
              .margin(this.tabBarOptions.indicatorMargin)
              .clip(true)
            } else {
              Divider()
                .indicatorStyles()
                .color(this.tabBarOptions.indicatorColor)
                .strokeWidth(this.tabBarOptions.indicatorHeight)
            }
          }
          .width(this.tabBarOptions.indicatorWidth)
        }
        /// 这里控制indicator的位置, indicatorOffsetX的值为被选中的item的centerX
        .offset({x: this.indicatorOffsetX, y: 0})
        .width(1)
        .clip(false)
        .backgroundColor(Color.Transparent)
      } else {
        Divider()
          .width(0)
          .height(this.tabBarOptions.indicatorHeight)
          .margin(this.tabBarOptions.indicatorMargin)
          .color(Color.Transparent)
      }
    }
  }

  @Builder private textBuilder(item: PJTabBarItemInterface, index: number) {
    if (this.customerItemBuilder) {
      // 启用外部自定义的Item
      this.customerItemBuilder(item, this.tabBarOptions, index)
    } else {
      Text(item.title)
        .ItemTextCommonExtend(this.isSelectedItem(item), this.tabBarOptions)
        .backgroundColor(this.isSelectedItem(item) ? this.tabBarOptions.selectedItemBackgroundColor : this.tabBarOptions.itemBackgroundColor)
        .border(this.isSelectedItem(item) ? this.tabBarOptions.selectedItemBorder : this.tabBarOptions.itemBorder)
        .margin(this.tabBarOptions.itemMargin)
        .maxLines(this.tabBarOptions.maxLines)
        .width(this.tabBarOptions.itemWidth)
        .height(this.tabBarOptions.itemHeight)
    }
  }

  build() {
    Row() {
      // 左侧固定住的附加视图
      if (this.leftItemBuilder && this.tabBarOptions.isLeftItemFixed) {
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
          if (this.leftItemBuilder && !this.tabBarOptions.isLeftItemFixed) {
            Column() {
              this.leftItemBuilder()
            }
            .height(this.tabBarOptions.isLeftItemSameHeightWithTabBar ? this.scrollHeight : null)
            .visibility(this.tabBarOptions.isHideLeftItem ? Visibility.None : Visibility.Visible)
          }

          ForEach(this.items, (item, index) => {
            this.itemBuilder(item, index)
          }, (item: PJTabBarItemInterface) => item.index.toString() + '_' + item.title)

          // 右侧附加视图
          if (this.rightItemBuilder && !this.tabBarOptions.isRightItemFixed) {
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
        this.fixScrollXoffsetIssueIfNeeded(side)
      })

      // 右侧固定住的附加视图
      if (this.rightItemBuilder && this.tabBarOptions.isRightItemFixed) {
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

    this.scrollWidth = newArea.width as number

    if (oldArea.width !== newArea.width) {
      if (this.tabBarOptions.edgeEffect === EdgeEffect.Spring) {
        // 修复系统Scroll Bug: 已知系统Scroll导致的bug, 当Scroll内容不超出屏幕时并且Scroll设置edgeEffect = EdgeEffect.Spring的情况下，左滑Scroll会出现Scroll整体向右偏移, 或者选中靠后的item时在横竖屏也会触发该Bug。
        this.scroller.scrollEdge(Edge.Start)
      }

      if (this.tabBarOptions.shouldScrollToCurrentIndexWhenTabBarWidthChanged) {
        let selectedIndexArea = this.attrs[this.index]
        // 如果当前选中的item已经可见则不需要滚动item的位置
        if (selectedIndexArea && !(selectedIndexArea.area.position.x >= 0 && ((selectedIndexArea.area.position.x as number) + (selectedIndexArea.area.width as number)) <= newArea.width)) {
          this.delay(500, () => {
            this.scrollItemToIndex(this.index)
          })
        }
      }
    }
  }

  /// Workaround方式修复系统BUG,效果不完美,但是勉强可以接受: 已知系统Scroll导致的bug, 当Scroll内容不超出屏幕时并且Scroll设置edgeEffect = EdgeEffect.Spring的情况下，左滑Scroll会出现Scroll整体向右偏移，不知API12中该系统bug有没被修复。
  private fixScrollXoffsetIssueIfNeeded(side: Edge) {
    if (this.tabBarOptions.edgeEffect === EdgeEffect.Spring && this.tabBarOptions.scrollable === ScrollDirection.Horizontal && side === Edge.Center) {
      if (this.attrs.length <= 0) {
        return
      }
      let firstItemX = (this.attrs[0].area.position.x ?? 0) as number
      let lastItemMaxX = (this.attrs[this.attrs.length - 1].area.position.x ?? 0) as number + (this.attrs[this.attrs.length - 1].area.width as number)
     if ((lastItemMaxX - firstItemX) < this.scrollWidth) {
       let scrollable = this.tabBarOptions.scrollable
       this.tabBarOptions.scrollable = ScrollDirection.None
       this.delay(300, () => {
         this.tabBarOptions.scrollable = scrollable
       })
     }
    }
  }
}

export class PJTabBarController {
  private weakMap = new WeakMap<object, PJTabBar>()
  private key = {}

  currentIndex(): number {
    return this.weakMap.get(this.key)?.index ?? 0
  }

  selectItemAtIndex(index: number) {
    this.weakMap.get(this.key)?.selectItemAtIndex(index)
  }

  onTouchPage(event: TouchEvent, currentIndex: number) {
    this.weakMap.get(this.key)?.onTouchPage(event, currentIndex)
  }

  bind(tabBar: PJTabBar) {
    this.weakMap.set(this.key, tabBar)
  }

  /// CRUD Actions

  update(index: number, item: PJTabBarItemInterface) {
    this.weakMap.get(this.key)?.update(index, item)
  }

  insert(atIndex: number, item: PJTabBarItemInterface) {
    this.weakMap.get(this.key)?.insert(atIndex, item)
  }

  delete(atIndex: number): PJTabBarItemInterface | undefined {
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


