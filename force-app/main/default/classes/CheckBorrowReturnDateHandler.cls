/********************************************************************
* class Name:CheckBorrowReturnDateHandler
* Purpose:检查借阅记录里的归还日期，读者借阅图书时归还日期不能填写，同时改变图书状态及剩余借阅数量；
          读者归回图书时填写归还日期，同时改变图书状态及读者剩余借阅数量；读者归还图书前清空缴费金额
* Author: zhenfan chen
* Created Date:2021-1-19
* Modify Description: 
* 1. 修改逻辑 (zhenfan chen 2021-1-21）
********************************************************************/
public without sharing class CheckBorrowReturnDateHandler implements Triggers.Handler {
    public void handle() {
        /********************************************************************
        * Purpose:读者借阅图书改变图书状态及剩余借阅数量
        * bookDetailsIdSet:存储新插入借阅记录的图书详细Id
        * readerIdSet:存储新插入借阅记录的读者Id
        * bookDetailsList:存储需要更改状态的图书详细信息
        * readerList:存储需要更改状态的读者信息
        * countMap:存储新插入借阅记录的读者Id及借阅数量
        ********************************************************************/
        if (Trigger.isInsert && Trigger.isAfter) {
            Set<Id> bookDetailsIdSet = new Set<Id>();
            Set<Id> readerIdSet = new Set<Id>();
            Map<Id, Integer> countMap = new Map<Id, Integer>();
            for (Borrow__c bor: (List<Borrow__c>)Trigger.new) {
                if (bor.borrowReturnDate__c != null) {
                    bor.addError('归还日期不能填写！');
                }
                if (bor.borrowRenewStatus__c == true) {
                    bor.addError('借书的同时不能续借图书！');
                }
                Integer count = 1;
                //如果读者Id存在，则借阅图书数量 +1，否则借阅数量为 1
                if (countMap.containsKey(bor.readerId__c)) {
                    count = countMap.get(bor.readerId__c) + 1;
                    countMap.put(bor.readerId__c, count);
                } else {
                    countMap.put(bor.readerId__c, count);
                }
                bookDetailsIdSet.add(bor.borrowchildBookId__c);
                readerIdSet.add(bor.readerId__c);
            }
            List<BookDetails__c> bookDetailsList = new List<BookDetails__c>([SELECT Id, bookDetailsBStatus__c FROM BookDetails__c WHERE Id IN :bookDetailsIdSet]);
            List<Reader__c> readerList = new List<Reader__c>([SELECT Id, readerNumber__c FROM Reader__c WHERE Id IN :readerIdSet]);
            for (BookDetails__c bookdet : bookDetailsList) {
                bookdet.bookDetailsBStatus__c = '已借出';
            }
            for (Reader__c reader : readerList) {
                if (reader.readerNumber__c - countMap.get(reader.Id) < 0) {
                    reader.addError('已超过最大借书数量，请先归还借阅书籍');
                } else {
                    reader.readerNumber__c = reader.readerNumber__c - countMap.get(reader.Id);
                }
            }
            UPDATE bookDetailsList;
            UPDATE readerList;
        }

        /********************************************************************
        * Purpose:读者归回图书改变图书状态及读者剩余借阅数量
        * bookDetailsIdSet:存储更新后的借阅记录的图书详细Id
        * readerIdSet:存储更新后的借阅记录的读者Id
        * bookDetailsList:存储需要更改状态的图书详细信息
        * readerList:存储需要更改状态的读者信息
        * countMap:存储更新后的借阅记录的读者Id及归还数量
        ********************************************************************/
        if (Trigger.isUpdate && Trigger.isAfter) {
            Map<Id, Borrow__c> oldMap = (Map<Id, Borrow__c>)Trigger.oldMap;
            Set<Id> bookDetailsIdSet = new Set<Id>();
            Set<Id> readerIdSet = new Set<Id>();
            Map<Id, Integer> countMap = new Map<Id, Integer>();
            for (Borrow__c newbor : (List<Borrow__c>)Trigger.new) {
                Borrow__c oldbor = oldMap.get(newbor.Id);
                //如果读者更新前的归还日期为空，且更新前后归还日期值改变，则把记录的读者Id和图书详情Id分别存到Set中
                if (oldbor.borrowReturnDate__c == null && newbor.borrowReturnDate__c != oldbor.borrowReturnDate__c) {
                    Integer count = 1;
                    //如果读者Id存在，则归还图书数量 +1，否则借阅数量为 1
                    if (countMap.containsKey(newbor.readerId__c)) {
                        count = countMap.get(newbor.readerId__c) + 1;
                        countMap.put(newbor.readerId__c, count);
                    } else {
                        countMap.put(newbor.readerId__c, count);
                    }
                    bookDetailsIdSet.add(newbor.borrowchildBookId__c);
                    readerIdSet.add(newbor.readerId__c);
                }
            }
            List<BookDetails__c> bookDetailsList = [SELECT Id, bookDetailsBStatus__c FROM BookDetails__c WHERE Id IN :bookDetailsIdSet];
            List<Reader__c> readerList = [SELECT Id, readerNumber__c FROM Reader__c WHERE Id IN :readerIdSet];
            for (BookDetails__c bookdet : bookDetailsList) {
                bookdet.bookDetailsBStatus__c = '可借阅';
            }
            for (Reader__c reader : readerList) {
                reader.readerNumber__c = reader.readerNumber__c + countMap.get(reader.Id);
            }
            UPDATE bookDetailsList;
            UPDATE readerList;
        }
        /********************************************************************
        * Purpose:读者归还图书前清空缴费金额
        * oldborMap:存放更改前的借阅信息
        ********************************************************************/
        if (Trigger.isUpdate && Trigger.isBefore) {
            Map<Id, Borrow__c> oldborMap = (Map<Id, Borrow__c>)Trigger.oldMap;
            for (Borrow__c newbor : (List<Borrow__c>)Trigger.new) {
                Borrow__c oldbor = oldborMap.get(newbor.Id);
                //如果读者更新前的归还日期为空，且更新前后归还日期值改变,则读者已归还图书及缴清费用,清除即将到期标记
                if (oldbor.borrowReturnDate__c == null && newbor.borrowReturnDate__c != oldbor.borrowReturnDate__c) {
                    newbor.borrowPaymentAmount__c = 0;
                    newbor.borrowDateFlag__c = false;
                }
            }
        }
    }
}