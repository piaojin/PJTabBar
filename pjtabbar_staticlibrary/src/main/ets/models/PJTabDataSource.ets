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

import systemDateTime from '@ohos.systemDateTime';
import { PJTabBarItemInterface } from './PJTabBarItem';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';

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
    item.id = this.generateId()
    item.index = atIndex
    // 插入新数据前需要更新插入位置后后移的item的index和id
    for(let index = atIndex; index < this.items.length; index++) {
      this.items[index].index = index + 1
      this.items[index].id = this.generateId()
    }
    this.items.splice(atIndex, 0, item)
    this.notifyDataAdd(atIndex)
  }

  public push(... items: PJTabBarItemInterface[]): number {
    let oldLength = this.items.length
    for (let i = 0; i < items.length; i++) {
      items[i].index = i + oldLength
      items[i].id = this.generateId()
    }
    let newLength = this.items.push(...items)
    this.notifyDataAdd(this.items.length - 1)
    return newLength
  }

  public update(atIndex: number, item: PJTabBarItemInterface) {
    this.items[atIndex].title = item.title
    this.notifyDataChange(atIndex)
  }

  public setItems(witItems: PJTabBarItemInterface[]) {
    this.setUpItems(witItems)
    this.items = witItems
    this.reloadData()
  }

  public delete(atIndex: number): PJTabBarItemInterface[] {
    if (atIndex >= this.items.length) {
      return []
    }

    let deletedItems = this.items.splice(atIndex, 1)
    this.updateItemIndexs(atIndex)
    this.updateItemIds(atIndex)
    this.notifyDataDelete(atIndex)
    return deletedItems
  }

  public updateItemIndexs(fromIndex: number = 0) {
    for(let index = fromIndex; index < this.items.length; index++) {
      this.items[index].index = index
    }
  }

  public updateItemIds(fromIndex: number = 0) {
    for(let index = fromIndex; index < this.items.length; index++) {
      this.items[index].id = this.generateId()
    }
  }

  /*
   * Sync the item index and generate the item id.
   */
  public setUpItems(witItems: PJTabBarItemInterface[]) {
    for(let index = 0; index < witItems.length; index++) {
      witItems[index].index = index
      witItems[index].id = this.generateId()
    }
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

  public generateId(): string {
    let idStr = util.generateRandomUUID(false)
    try {
      let time = systemDateTime.getTime(true)
      idStr += '_' + time
    } catch (e) {
      let error = e as BusinessError;
      console.info(`Failed to get time. message: ${error.message}, code: ${error.code}`);
    }
    return idStr
  }

  public identifier(index: number): string {
    let item = this.getData(index)
    if (item) {
      return item.id
    }
    return util.generateRandomUUID(false)
  }
}