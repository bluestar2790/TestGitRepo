/********************************************************************
* class Name:CheckBorrowPaymentAmountHandler
* Purpose:检测读者缴费金额，如果读者缴费金额发生改变且缴费金额大于0则发送邮件提醒
* Author: zhenfan chen
* Created Date:2021-1-20
********************************************************************/
public with sharing class CheckBorrowPaymentAmountHandler implements Triggers.Handler {
    public void handle() {
        /********************************************************************
        * Purpose:检测缴费金额发送邮件通知
        * oldreaderMap:存放更新前的读者信息
        * readIdSet:存放需要缴费的读者Id
        * borrowList:存放需要缴费的读者的具体需缴费借阅记录
        ********************************************************************/
        if (Trigger.isUpdate && Trigger.isAfter) {
            Map<Id, Reader__c> oldreaderMap = (Map<Id, Reader__c>)Trigger.oldMap;
            Set<Id> readIdSet = new Set<Id>();
            for (Reader__c newreader : (List<Reader__c>)Trigger.new) {
                Reader__c oldreader = oldreaderMap.get(newreader.Id);
                //如果更新后读者的缴费金额大于0，且更新前的缴费金额不等于更新后的缴费金额，则把读者的Id存进readIdSet
                if (newreader.readerPaymentAmount__c > 0 && oldreader.readerPaymentAmount__c != newreader.readerPaymentAmount__c) {
                    readIdSet.add(newreader.Id);
                }
            }
            List<Borrow__c> borrowList = [SELECT readerId__c, 
                                                 readerName__c, 
                                                 borrowPaymentAmount__c, 
                                                 bookName__c 
                                            FROM Borrow__c 
                                           WHERE readerId__c IN : readIdSet AND borrowPaymentAmount__c > 0];
            for (Reader__c newreader : (List<Reader__c>)Trigger.new) {
                Reader__c oldreader = oldreaderMap.get(newreader.Id);
                //如果更新后读者的缴费金额大于0，且更新前的缴费金额不等于更新后的缴费金额，
                //则遍历借阅记录,根据读者Id取出图书名称，放进bookNameList
                if (newreader.readerPaymentAmount__c > 0 && oldreader.readerPaymentAmount__c != newreader.readerPaymentAmount__c) {
                    List<String> bookNameList = new List<String>();
                    for (Borrow__c borrow : borrowList) {
                        if (borrow.readerId__c == newreader.Id) {
                            bookNameList.add(borrow.bookName__c);
                        }
                    }
                    //toAddresses:邮箱地址,title:邮件标题,body:邮件内容
                    String toAddresses = newreader.readerEmail__c;
                    String title = '图书逾期未归还欠费通知';
                    String body = '您好，亲爱的' + newreader.readerName__c +
                                    '，您在图书馆借阅的书籍' + bookNameList + 
                                    '未及时归还，需缴纳' + newreader.readerPaymentAmount__c + 
                                    '元，请及时缴纳并归还图书';
                    EmailManager.sendMail(toAddresses, title, body);
                }
            }
        }
    }
}