/********************************************************************
* class Name:CheckBorrowRenewStatusHandler
* Purpose:检查图书的续借状态，当读者续借时图书改变图书应还日期
* Author: zhenfan chen
* Created Date:2021-1-18
********************************************************************/
public without sharing class CheckBorrowRenewStatusHandler implements Triggers.Handler {
    public void handle() {
        /********************************************************************
        * Purpose:读者续借图书改变图书应还日期
        * oldMap:存放更新前的借阅记录
        ********************************************************************/
        if (Trigger.isUpdate && Trigger.isBefore) {
            Map<Id, Borrow__c> oldMap = (Map<Id, Borrow__c>)Trigger.oldMap;
            for (Borrow__c newbor : (List<Borrow__c>)Trigger.new) {
                Borrow__c oldbor = oldMap.get(newbor.Id);
                //如果归还日期为空，则继续判断续借状态，否则不能更改续借状态
                if (oldbor.borrowReturnDate__c == null) {
                    //如果更新前续借状态为false，读者为第一次续借，更改前后续借状态发生改变，且续借日期没超过应还日期
                    //则读者续借30天
                    if (!oldbor.borrowRenewStatus__c && (oldbor.borrowingDate__c.daysBetween(oldbor.borrowDueDate__c) < 46) && oldbor.borrowRenewStatus__c != newbor.borrowRenewStatus__c) {
                        if (System.today().daysBetween(oldbor.borrowDueDate__c) < 0) {
                            newbor.addError('已超过应还日期，不能续借！');
                        } 
                        newbor.borrowDueDate__c = newbor.borrowDueDate__c + 30;
                    } else if (oldbor.borrowRenewStatus__c) {
                        newbor.borrowRenewStatus__c = true;
                    }
                } else if (oldbor.borrowRenewStatus__c) {
                    newbor.borrowRenewStatus__c = true;
                } else if (!oldbor.borrowRenewStatus__c) {
                    newbor.borrowRenewStatus__c = false;
                }
            }
        }
    }
}