## v1.0.5 [2024.08.13]
1. 修复CRUD操作后item的index没有更新，导致tabbarUI状态错乱。
2. 修复CRUD操作后tabs content没更新。
3. 改善指示器滚动过程中抖动问题。
4. 添加在TabBar末尾新增元素接口: push。
5. 替换attrs数组为Map。

## v1.0.4 [2024.08.08]
1. 添加setItems接口，用于替换当前items。
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