## v1.1.1 [2024.12.17] With My M4 Pro Mac Min🌝
### 修复以下Issues:
1. 设置options.itemHeight=0时下面会有一段间距如何控制
2. PJTabBar({ index: this.customTabIndex, items: this.items, tabBarOptions: this.options } index传值总是被重置为0
3. tabcontent 底部有一点间距, 感觉很不合理, 如果必须可以默认, 也可以增加熟悉进行设置
4. 默认选中索引问题
5. 希望内容也可以支持设置edgeEffect
6. indicatorAnimationType = PJIndicatorAnimationType.Linear时的bug
7. tabBarVerticalAlign属性设置后好像没有用
8. indicatorAnimationDuration 感觉属性好像没用

## v1.1.0 [2024.09.19]
1. 修复PJTabBarOptionsInterface.itemEqualDistributionType无法赋值问题。

## v1.0.9 [2024.08.28]
1. PJTabComponent添加Swiper实现(设置enableRecycling = true), 当页签滑出屏幕外时，回收该页签内存以节省内存。
回收时机依据`PJTabBarOptions`中的`cachedCount`属性值，e.g: cachedCount = 2, 页签有1，2，3，4，5，6，当页签1被滑动出去后并且当前滑动到页签4，此时页签1被回收, 页签2，3还在cache中(`cachedCount = 2`), 即`cachedCount`指可以被滑动出界面并且被缓存的页签数量。

## v1.0.8 [2024.08.27]
1. 修复设置isSameWidthWithItem=true时，指示器从长变短时一闪而过，不平滑的问题。
2. Item添加均分布局PJItemEqualDistributionType，注意至于单item不超出PJTabBar宽度时才有效果。

## v1.0.7 [2024.08.21]
1. 指示器添加联动效果
2. 对于传入接口的index添加有效范围判断，如果传入的index无效，则不响应操作。
3. 添加接口`preloadItems`,用于提前加载指定的tab content.
4. 添加配置项`tabsAnimationDuration: number`,设置tab content切换page时的动画时长。
5. 添加配置项`tabContentScrollable: boolean`,控制tab content是否可以滑动。

## v1.0.6 [2024.08.16]
1. 修复当选中非第一个页签时，调用`PJTabComponentController`的`CRUD`操作后会跳转选中第一个页签的问题。
2. 修复调用`PJTabComponentController`的`update`操作后, `contentBuiler` | `customerItemBuilder`中使用`PJTabBarItem`的`title`等属性的组件的UI没有跟着更新的问题。
3. 修复调用`PJTabComponentController`的`update`操作后, 指示器的位置不居中的问题。
4. 对数据源的操作统一放在`PJTabDataSource`中。
5. 更新示例代码。

## v1.0.5 [2024.08.13]
1. 修复CRUD操作后item的index没有更新，导致tabbarUI状态错乱。
2. 修复CRUD操作后tabs content没更新。
3. 改善指示器滚动过程中抖动问题。
4. 添加在TabBar末尾新增元素接口: push。
5. 替换attrs数组为Map。

## v1.0.4 [2024.08.08]
1. 添加replace接口，用于替换当前items。
2. PJTabComponentController与PJTabBarController接口添加注释。

## v1.0.3 [2024.08.06]
1. 加快指示器与Change Page之间的联动。
2. 修复DevEco Studio: NEXT Developer Beta2, Preview模式下, 无法预览PJTabComponent问题。

## v1.0.2 [2024.07.17]
1. 适配API12。
2. 修复TabContent底部超出大概42vp屏幕问题。
3. 修复简介Demo gif加载不出来问题。
4. 版本v1.0.0中的bug iii,iv验证在API12下已被系统修复，并删除相应Workaround修复方法。

## v1.0.1 [2024.07.09]
1. 修复PJComponent index默认值为4问题。
2. 修复简介Demo gif加载不出来问题。

## v1.0.0 [2024.07.05]

- 已实现功能
    1. 支持自定义指示器，TabBar Item, TabBar 左右附加视图。
    2. 支持TabBar Item居左居中居右布局。
    3. 支持更新，插入，删除TabBar Item。

- 未支持功能
    1. 由于本人没有Next开发权限，故还没适配OpenHarmony SDK:API12， 将来计划适配。
    2. 指示器跟随TabContent的滑动而联动。
    3. 已知系统Scroll导致的bug, 当Scroll内容不超出屏幕时并且Scroll设置edgeEffect = EdgeEffect.Spring的情况下，左滑Scroll会出现Scroll整体向右偏移，不知API12中该系统bug有没被修复。
       修复方法见函数`fixScrollXoffsetIssueIfNeeded`
    4. 已知系统Scroll导致的bug, 当Scroll设置edgeEffect = EdgeEffect.Spring的情况下把TabBar滑动到低并且横竖屏切换Scroll会出现整体向右偏移，不知API12中该系统bug有没被修复。
    问题4目前的Workaround方式修复:
    ````
  在Scroll的回调onAreaChange中调用
  this.scroller.scrollEdge(Edge.Start)
  // 滚动到当前选中的item,attr当前选中item的坐标信息
  this.scroller.scrollTo({xOffset: (attr.area.position.x as number) - this.tabBarOptions.optimizeOffsetX, yOffset: this.scroller.currentOffset().yOffset, animation: {duration: this.tabBarOptions.itemAnimationDuration, curve: Curve.Linear}})
    ````