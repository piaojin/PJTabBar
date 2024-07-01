export interface PJTabBarItemInterface {
  title: string
  index: number
}

@Observed
export class PJTabBarItem implements PJTabBarItemInterface {
  index: number = 0
  title: string

  constructor(title: string, index: number = 0) {
    this.title = title
    this.index = index
  }
}