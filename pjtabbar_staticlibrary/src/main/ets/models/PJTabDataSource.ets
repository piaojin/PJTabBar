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

import { PJTabBarItemInterface } from './PJTabBarItem';
import { util } from '@kit.ArkTS';

/// Basic implementation of IDataSource to handle data listener
export class PJTabDataSource implements IDataSource {
  private listeners: DataChangeListener[] = []
  private items: Array<PJTabBarItemInterface> = []

  public totalCount(): number {
    return this.items.length
  }

  public getData(atIndex: number): PJTabBarItemInterface | undefined {
    if (atIndex < this.items.length) {
      return this.items[atIndex]
    }
    return undefined
  }

  public insert(atIndex: number, item: PJTabBarItemInterface) {
    this.items.splice(atIndex, 0, item)
    // 更新局部item.index值
    this.updateItemValues(atIndex)
    this.notifyDataAdd(atIndex)
  }

  public push(... items: PJTabBarItemInterface[]): number {
    let oldLength = this.items.length
    let newLength = this.items.push(...items)
    this.updateItemValues(oldLength, true)
    this.notifyDataAdd(this.items.length - 1)
    return newLength
  }

  public update(atIndex: number, item: PJTabBarItemInterface) {
    this.items.splice(atIndex, 1, item)
    this.notifyDataChange(atIndex)
  }

  public updateItemValues(fromIndex: number = 0, shouldResetId: boolean = false) {
    for(let index = fromIndex; index < this.items.length; index++) {
      this.items[index].index = index
      if (shouldResetId) {
        this.items[index].id = util.generateRandomUUID(false)
      }
    }
  }

  public setItems(items: PJTabBarItemInterface[]) {
    this.items = items
    this.updateItemValues(0, true)
    this.reloadData()
  }

  public delete(atIndex: number): PJTabBarItemInterface[] {
    if (atIndex >= this.items.length) {
      return []
    }

    let deletedItems = this.items.splice(atIndex, 1)
    this.updateItemValues(atIndex)
    this.notifyDataDelete(atIndex)
    return deletedItems
  }

  findIndex(predicate: (value: PJTabBarItemInterface, index: number, obj: PJTabBarItemInterface[]) => boolean, thisArg?: undefined): number {
    return this.items.findIndex(predicate, thisArg)
  }

  find(predicate: (value: PJTabBarItemInterface, index: number, obj: PJTabBarItemInterface[]) => boolean, thisArg?: undefined): PJTabBarItemInterface | undefined {
    return this.items.find(predicate, thisArg)
  }

  public reloadData() {
    this.notifyDataReload()
  }

  // 该方法为框架侧调用，为LazyForEach组件向其数据源处添加listener监听
  registerDataChangeListener(listener: DataChangeListener) {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  // 该方法为框架侧调用，为对应的LazyForEach组件在数据源处去除listener监听
  unregisterDataChangeListener(listener: DataChangeListener) {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) {
      this.listeners.splice(pos, 1)
    }
  }

  // 通知LazyForEach组件需要重载所有子组件
  notifyDataReload() {
    this.listeners.forEach(listener => {
      listener.onDataReloaded()
    })
  }

  // 通知LazyForEach组件需要在index对应索引处添加子组件
  notifyDataAdd(index: number) {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index)
    })
  }

  // 通知LazyForEach组件在index对应索引处数据有变化，需要重建该子组件
  notifyDataChange(index: number) {
    this.listeners.forEach(listener => {
      listener.onDataChange(index)
    })
  }

  // 通知LazyForEach组件需要在index对应索引处删除该子组件
  notifyDataDelete(index: number) {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index)
    })
  }

  public identifier(index: number): string {
    let item = this.getData(index)
    if (item) {
      let idstr = item.id + '_' + item.index.toString() + '_' + item.title
      return idstr
    }
    return util.generateRandomUUID(false)
  }
}