/********************************************************************
* class Name:CheckBookInventoryHandler
* Purpose:检查图书剩余库存数量，库存数量减少则新增出库记录，库存量增加则新增入库记录
* Author: zhenfan chen
* Created Date:2021-1-18
* Modify Description: 
* 1. 修改逻辑 (zhenfan chen 2021-1-22）
********************************************************************/
public without sharing class CheckBookInventoryHandler implements Triggers.Handler {
    public void handle() {
        /********************************************************************
        * Purpose:剩余库存数量改变时新增出入库记录
        * oldBookMap:存放更新前的图书信息
        * ioInventoryList:存放新增的出入库记录
        ********************************************************************/
        if (Trigger.isUpdate && Trigger.isAfter) {
            Map<Id, Book__c> oldBookMap = (Map<Id, Book__c>)Trigger.oldMap;
            List<IOinventory__c> ioInventoryList = new List<IOinventory__c>();
            for (Book__c newbook: (List<Book__c>)Trigger.new) {
                Book__c oldBook = oldBookMap.get(newbook.Id);
                //如果旧记录的图书剩余库存和新记录的图书剩余库存不相等，则库存数量发生改变，生成出入库记录
                if (oldBook.bookInventory__c != newbook.bookInventory__c) {
                    IOinventory__c ioInventory = new IOinventory__c();
                    ioInventory.bookId__c = newbook.Id;
                    ioInventory.ioInventoryDate__c = System.now();
                    ioInventory.InventoryQuantity__c = newbook.bookInventory__c;
                    //如果旧记录的图书剩余库存小于新记录的图书剩余库存，为入库;否则为出库
                    if (oldBook.bookInventory__c < newbook.bookInventory__c) {
                        ioInventory.ioInventoryStatus__c = '入库';
                        ioInventory.ioInventoryQuantity__c = newbook.bookInventory__c - oldBook.bookInventory__c;
                    } else {
                        ioInventory.ioInventoryStatus__c = '出库';
                        ioInventory.ioInventoryQuantity__c = oldbook.bookInventory__c - newBook.bookInventory__c;
                    }
                    ioInventoryList.add(ioInventory);
                }
            }
            INSERT ioInventoryList;
        }
    }
}