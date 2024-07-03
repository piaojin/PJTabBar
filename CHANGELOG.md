## v1.0.0

- 已实现功能
    1. 支持自定义指示器，TabBar Item, TabBar 左右附加视图
    2. 支持TabBar Item居左居中居右布局
    3. 支持更新，插入，删除TabBar Item

- 未支持功能
    1. 由于本人没有Next开发权限，故还没适配OpenHarmony SDK:API12， 将来计划适配。
    2. 指示器跟随TabContent的滑动而联动。
    3. 已知系统Scroll导致的bug, 当Scroll内容不超出屏幕时并且Scroll设置edgeEffect = EdgeEffect.Spring的情况下，左滑Scroll会出现Scroll整体向右偏移，不知API12中该系统bug有没被修复。
    4. 已知系统Scroll导致的bug, 当Scroll设置edgeEffect = EdgeEffect.Spring的情况下把TabBar滑动到低并且横竖屏切换Scroll会出现整体向右偏移，不知API12中该系统bug有没被修复。
    问题4目前的Workaround方式修复:
    ````
  在Scroll的回调onAreaChange中调用
  this.scroller.scrollEdge(Edge.Start)
  // 滚动到当前选中的item,attr当前选中item的坐标信息
  this.scroller.scrollTo({xOffset: (attr.area.position.x as number) - this.tabBarOptions.optimizeOffsetX, yOffset: this.scroller.currentOffset().yOffset, animation: {duration: this.tabBarOptions.itemAnimationDuration, curve: Curve.Linear}})
    ````