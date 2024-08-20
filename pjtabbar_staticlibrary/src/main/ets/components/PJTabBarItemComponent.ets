import { PJCustomerBuilderInterface, PJNullBuilder } from '../models/PJBuilder'
import { PJTabBarItemInterface } from '../models/PJTabBarItem'
import { PJTabBarOptionsInterface } from '../models/PJTabBarOptions'

@Extend(Text) function ItemTextCommonExtend(isSelected: boolean, options: PJTabBarOptionsInterface) {
  .fontColor(isSelected ? options.selectedFontColor : options.fontColor)
  .animation({ duration: options.selectedFontColorAnimationDuration, curve: Curve.Linear })
  .fontSize(isSelected ? options.selectedFontSize : options.fontSize)
  .fontWeight(isSelected ? options.selectedFontWeight : options.fontWeight)
  .fontStyle(isSelected ? options.selectedFontStyle : options.fontStyle)
  .fontFamily(options.fontFamily)
  .textAlign(options.textAlign)
}

@Component
export struct PJTabBarItemComponent {
  @Require @Prop currentItemIndex: number
  @Require @Prop selectedItemIndex: number
  @State item: PJTabBarItemInterface = {id: '', index: 0, title: '' }
  @Prop tabBarOptions: PJTabBarOptionsInterface

  // 自定义item视图
  @BuilderParam customerItemBuilder: ($$: PJCustomerBuilderInterface) => void = PJNullBuilder

  private isSelectedItem(): boolean {
    return this.selectedItemIndex === this.currentItemIndex
  }

  @Builder private textBuilder() {
    if (this.customerItemBuilder !== PJNullBuilder) {
      // 启用外部自定义的Item
      this.customerItemBuilder({currentItemIndex: this.currentItemIndex, selectedItemIndex: this.selectedItemIndex, item: this.item, tabBarOptions: this.tabBarOptions})
    } else {
      Text(this.item.title)
        .ItemTextCommonExtend(this.isSelectedItem(), this.tabBarOptions)
        .backgroundColor(this.isSelectedItem() ? this.tabBarOptions.selectedItemBackgroundColor : this.tabBarOptions.itemBackgroundColor)
        .border(this.isSelectedItem() ? this.tabBarOptions.selectedItemBorder : this.tabBarOptions.itemBorder)
        .margin(this.tabBarOptions.itemMargin)
        .maxLines(this.tabBarOptions.maxLines)
        .width(this.tabBarOptions.itemWidth)
        .height(this.tabBarOptions.itemHeight)
    }
  }

  build() {
    this.textBuilder()
  }
}