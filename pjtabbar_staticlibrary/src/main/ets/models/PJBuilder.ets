import { PJTabBarItemInterface } from './PJTabBarItem'
import { PJTabBarOptionsInterface } from './PJTabBarOptions'

export class PJBuilder {
  // 自定义item视图
  customerItemBuilder?: (item: PJTabBarItemInterface, options: PJTabBarOptionsInterface, index: number) => void | null
  // 自定义Indicator，不需要设置width和height
  customerIndicatorBuilder?: (item: PJTabBarItemInterface, options: PJTabBarOptionsInterface, index: number) => void | null
  // 左边附加视图
  leftItemBuilder?: () => void | null
  // 右边附加视图
  rightItemBuilder?: () => void | null
}
