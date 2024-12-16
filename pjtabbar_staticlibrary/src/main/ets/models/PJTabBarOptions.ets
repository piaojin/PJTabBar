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

export interface PJTabBarOptionsInterface {
  fontSize: number
  selectedFontSize?: number
  fontColor: ResourceColor
  selectedFontColor?: ResourceColor
  selectedFontColorAnimationDuration: number
  fontWeight: number | FontWeight | string
  selectedFontWeight?: number | FontWeight | string
  fontStyle?: FontStyle
  selectedFontStyle?: FontStyle
  fontFamily?: string | Resource
  textAlign?: TextAlign
  itemBackgroundColor?: ResourceColor
  selectedItemBackgroundColor?: ResourceColor
  itemSpace?: number
  itemWidth?: number
  itemHeight?: number
  itemBorder?: BorderOptions
  selectedItemBorder?: BorderOptions
  itemMargin?: Margin
  itemAnimationDuration?: number
  // 所有item的布局位置
  itemAlign?: Alignment
  // item均分布局
  itemEqualDistributionType: PJItemEqualDistributionType
  tabBarVerticalAlign?: VerticalAlign
  maxLines?: number
  indicatorWidth?: number
  indicatorHeight?: number
  indicatorBorderRadius?: number
  indicatorMargin?: Margin
  indicatorColor?: ResourceColor
  indicatorPosition?: PJIndicatorPosition
  indicatorAnimationType?: PJIndicatorAnimationType
  isSameWidthWithItem?: boolean
  isSameHeightWithItem?: boolean
  indicatorAnimationDuration?: number
  isHideIndicator?: boolean
  scrollable?: ScrollDirection
  isLeftItemFixed?: boolean
  isRightItemFixed?: boolean
  isLeftItemSameHeightWithTabBar?: boolean
  isRightItemSameHeightWithTabBar?: boolean
  isHideLeftItem?: boolean
  isHideRightItem?: boolean
  edgeEffect?: EdgeEffect
  tabBarBackGround?: ResourceColor
  // tabbar整个内容的间距
  tabBarContentMargin?: Margin
  tabBarBorder?: BorderOptions
  // tabbar的高度，默认由item内容撑开高度。
  tabBarHeight?: number
  isTabBarWidthFillParent?: boolean
  shouldScrollToCurrentIndexWhenTabBarWidthChanged?: boolean
  // 使item尽量滚到中间位置
  optimizeOffsetX?: number
  tabsAnimationDuration: number
  tabContentScrollable: boolean
  enableRecycling: boolean
  cachedCount: number
  disableSwipe: boolean
  displayArrow: [ArrowStyle | boolean, boolean]
  expandSafeArea: [types?: Array<SafeAreaType>, edges?: Array<SafeAreaEdge>]
}

@Observed
export class PJTabBarOptions implements PJTabBarOptionsInterface {
  fontSize: number = 15
  selectedFontSize: number = 15
  fontColor: ResourceColor = Color.Black
  selectedFontColor: ResourceColor = Color.Blue
  selectedFontColorAnimationDuration: number = 200
  fontWeight: number | FontWeight | string = FontWeight.Regular
  selectedFontWeight: number | FontWeight | string = FontWeight.Regular
  fontStyle: FontStyle = FontStyle.Normal
  selectedFontStyle: FontStyle = FontStyle.Normal
  fontFamily: string | Resource = ''
  textAlign: TextAlign = TextAlign.Center
  itemBackgroundColor: ResourceColor = Color.Transparent
  selectedItemBackgroundColor: ResourceColor = Color.Transparent
  itemSpace: number = 20
  itemWidth?: number
  itemHeight?: number
  itemBorder: BorderOptions = {radius: 0, width: 0, color: Color.White}
  selectedItemBorder: BorderOptions = {radius: 0, width: 0, color: Color.White}
  itemMargin: Margin = {top: 0, bottom: 0, left: 0, right: 0}
  itemAnimationDuration: number = 300
  itemAlign: Alignment = Alignment.Center
  // item均分布局
  itemEqualDistributionType: PJItemEqualDistributionType = PJItemEqualDistributionType.None
  tabBarVerticalAlign?: VerticalAlign = VerticalAlign.Top
  maxLines: number = 1
  indicatorWidth: number = 20
  indicatorHeight: number = 4
  indicatorBorderRadius: number = 2
  indicatorMargin: Margin = {top: 10, bottom: 0, left: 0, right: 0}
  indicatorColor: ResourceColor = Color.Blue
  indicatorAnimationDuration: number = 300
  indicatorPosition: PJIndicatorPosition = PJIndicatorPosition.Bottom
  indicatorAnimationType: PJIndicatorAnimationType = PJIndicatorAnimationType.Linear
  isSameWidthWithItem: boolean = false
  isSameHeightWithItem: boolean = false
  isHideIndicator: boolean = false
  scrollable: ScrollDirection = ScrollDirection.Horizontal
  isLeftItemFixed: boolean = true
  isRightItemFixed: boolean = true
  isLeftItemSameHeightWithTabBar: boolean = true
  isRightItemSameHeightWithTabBar: boolean = true
  isHideLeftItem: boolean = false
  isHideRightItem: boolean = false
  edgeEffect: EdgeEffect = EdgeEffect.Spring
  tabBarBackGround: ResourceColor = Color.White
  tabBarContentMargin: Margin = {top: 0, bottom: 0, left: 0, right: 0}
  tabBarBorder?: BorderOptions = undefined
  tabBarHeight?: number
  isTabBarWidthFillParent?: boolean = true
  shouldScrollToCurrentIndexWhenTabBarWidthChanged?: boolean = true
  // 使item尽量滚到中间位置
  optimizeOffsetX: number = 120
  tabsAnimationDuration: number = 300
  tabContentScrollable: boolean = true
  enableRecycling: boolean = false
  cachedCount: number = 1
  disableSwipe: boolean = false
  displayArrow: [ArrowStyle | boolean, boolean] = [false, false]
  expandSafeArea: [types?: Array<SafeAreaType>, edges?: Array<SafeAreaEdge>] = [[SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]]
}

/// 指示器位置（上，中，下）
export enum PJIndicatorPosition {
  Top, Center, Bottom
}

/// 指示器滚动动画
export enum PJIndicatorAnimationType {
  Linear,
  Linkage
}

export enum PJItemEqualDistributionType {
  /*
   * Item不均分布局
  */
  None,
  /*
   * Flex主轴方向均匀分配弹性元素，相邻元素之间距离相同。第一个元素与行首对齐，最后一个元素与行尾对齐。
  */
  SpaceBetween,
  /*
   * Flex主轴方向均匀分配弹性元素，相邻元素之间距离相同。第一个元素到行首的距离和最后一个元素到行尾的距离是相邻元素之间距离的一半。
  */
  SpaceAround,
  /*
   * Flex主轴方向均匀分配弹性元素，相邻元素之间的距离、第一个元素与行首的间距、最后一个元素到行尾的间距都完全一样。
  */
  SpaceEvenly
}