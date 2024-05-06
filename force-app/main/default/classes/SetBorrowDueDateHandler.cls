/********************************************************************
* class Name:SetBorrowDueDateHandler
* Purpose:读者表插入新数据时，根据读者类型设置应还日期
* Author: zhenfan chen
* Created Date:2021-1-15
********************************************************************/
public with sharing class SetBorrowDueDateHandler implements Triggers.Handler {
    public void handle() {
        /********************************************************************
        * Purpose:根据读者类型设置应还日期
        * readerIdSet:存放新插入的借阅记录的读者Id
        * readerMap:存放根据新插入的借阅记录的读者Id查找出的读者信息
        ********************************************************************/
        if (Trigger.isInsert && Trigger.isBefore) {
            Set<Id> readerIdSet = new Set<Id>();
            for (Borrow__c bor : (List<Borrow__c>)Trigger.new) {
                readerIdSet.add(bor.readerId__c);
            }
            Map<Id, Reader__c> readerMap = new Map<Id, Reader__c>([SELECT Id, readerType__c FROM Reader__c WHERE Id IN :readerIdSet]);
            for (Borrow__c bor : (List<Borrow__c>)Trigger.new) {
                Reader__c reader = readerMap.get(bor.readerId__c);
                //如果读者为教职工，则借阅天数为45天，否则读者是学生，借阅天数为30天
                if (reader.readerType__c == '教职工') {
                    bor.borrowDueDate__c = bor.borrowingDate__c + 45;
                } else {
                    bor.borrowDueDate__c = bor.borrowingDate__c + 30;
                }
            }
        }
    }
}