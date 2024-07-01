export interface PJTabBarOptionsInterface {
  fontSize: number
  selectedFontSize?: number
  fontColor: Color
  selectedFontColor?: Color
  fontWeight: number | FontWeight | string
  selectedFontWeight?: number | FontWeight | string
  fontStyle?: FontStyle
  selectedFontStyle?: FontStyle
  fontFamily?: string | Resource
  textAlign?: TextAlign
  itemBackgroundColor?: Color
  selectedItemBackgroundColor?: Color
  tabBarBackGround?: Color
  itemSpace?: number
  itemWidth?: number
  itemHeight?: number
  itemBorder?: BorderOptions
  selectedItemBorder?: BorderOptions
  itemMargin?: Margin
  itemAnimationDuration?: number
  // 所有item的布局位置
  itemAlign?: Alignment
  tabBarVerticalAlign?: VerticalAlign
  maxLines?: number
  indicatorWidth?: number
  indicatorHeight?: number
  indicatorBorderRadius?: number
  indicatorMargin?: Margin
  indicatorColor?: Color
  indicatorPosition?: PJIndicatorPosition
  scrollStyle?: PJScrollStyle
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
  // tabbar整个内容的间距
  tabBarContentMargin?: Margin
  // 使item尽量滚到中间位置
  optimizeOffsetX?: number
}

@Observed
export class PJTabBarOptions implements PJTabBarOptionsInterface {
  fontSize: number = 15
  selectedFontSize: number = 15
  fontColor: Color = Color.Black
  selectedFontColor: Color = Color.Blue
  fontWeight: number | FontWeight | string = FontWeight.Regular
  selectedFontWeight: number | FontWeight | string = FontWeight.Regular
  fontStyle: FontStyle = FontStyle.Normal
  selectedFontStyle: FontStyle = FontStyle.Normal
  fontFamily: string | Resource = ''
  textAlign: TextAlign = TextAlign.Center
  itemBackgroundColor: Color = Color.Transparent
  selectedItemBackgroundColor: Color = Color.Transparent
  tabBarBackGround: Color = Color.White
  itemSpace: number = 20
  itemWidth?: number
  itemHeight?: number
  itemBorder: BorderOptions = {radius: 0, width: 0, color: Color.White}
  selectedItemBorder: BorderOptions = {radius: 0, width: 0, color: Color.White}
  itemMargin: Margin = {top: 0, bottom: 0, left: 0, right: 0}
  itemAnimationDuration: number = 300
  itemAlign: Alignment = Alignment.Center
  tabBarVerticalAlign?: VerticalAlign = VerticalAlign.Top
  maxLines: number = 1
  indicatorWidth: number = 20
  indicatorHeight: number = 4
  indicatorBorderRadius: number = 2
  indicatorMargin: Margin = {top: 10, bottom: 0, left: 0, right: 0}
  indicatorColor: Color = Color.Blue
  indicatorAnimationDuration: number = 300
  indicatorPosition: PJIndicatorPosition = PJIndicatorPosition.Bottom
  scrollStyle: PJScrollStyle = PJScrollStyle.Normal
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
  tabBarContentMargin: Margin = {top: 0, bottom: 0, left: 0, right: 0}
  // 使item尽量滚到中间位置
  optimizeOffsetX: number = 120
}

export enum PJIndicatorPosition {
  Top, Center, Bottom
}

export enum PJScrollStyle {
  Normal
}