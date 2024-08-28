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
import { common } from '@kit.AbilityKit'

/// id与index由TabBar内部赋值，无需外部传入值。
export interface PJTabBarItemInterface {
  id: string
  index: number
  title: string
}

@Observed
export class PJTabBarItem implements PJTabBarItemInterface {
  id: string = ''
  index: number = 0
  title: string

  constructor(title: string | Resource) {
    if (typeof title === 'string') {
      this.title = title
    } else {
      this.title = this.getStringFromResource(title)
    }
  }

  private getStringFromResource(source: Resource): string {
    let context = getContext(this) as common.UIAbilityContext
    return context.resourceManager.getStringSync(source.id)
  }
}

/*
 * 用于在@Builder中引用传递: 按引用传递参数时，传递的参数可为状态变量，且状态变量的改变会引起@Builder方法内的UI刷新 (https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V2/arkts-builder-0000001524176981-V2)
 */
export interface PJReferenceTabBarItemInterface {
  currentItemIndex: number
  selectedItemIndex: number
  item: PJTabBarItemInterface
}