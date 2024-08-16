import { PJTabBarItemInterface } from './PJTabBarItem'
import { PJTabBarOptionsInterface } from './PJTabBarOptions'

@Builder export function PJNullBuilder() {}

/*
 * 用于在Builder之间进行引用传递
 */
export interface PJCustomerBuilderInterface {
  /*
   * 当前item的index
   */
  currentItemIndex: number
  /*
   * 当前选中的item的index
   */
  selectedItemIndex: number
  item: PJTabBarItemInterface
  tabBarOptions: PJTabBarOptionsInterface
}

export class PJBuilder {
  // 自定义item视图
  customerItemBuilder?: ($$: PJCustomerBuilderInterface) => void | null
  // 自定义Indicator，不需要设置width和height
  customerIndicatorBuilder?: (item: PJTabBarItemInterface, options: PJTabBarOptionsInterface, index: number) => void | null
  // 左边附加视图
  leftItemBuilder?: () => void | null
  // 右边附加视图
  rightItemBuilder?: () => void | null
}
