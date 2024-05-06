/********************************************************************
* class Name:ReaderReturnBookComponentController
* Purpose:前端还书页面ReaderReturnBookComponent的后端控制类，进行数据交互
* Author: zhenfan chen
* Created Date:2021-1-19
********************************************************************/
public without sharing class ReaderReturnBookComponentController {
    public ReaderReturnBookComponentController() {
        
    }

    /********************************************************************
    * Purpose:查询全部未归还的借阅信息记录并返回给前端页面
    ********************************************************************/
    @AuraEnabled
    public static List<Borrow__c> getBorrow() {
        List<Borrow__c> borrowList = [SELECT Id, 
                                             Name, 
                                             bookName__c, 
                                             readerName__c, 
                                             readerId__c, 
                                             borrowingDate__c, 
                                             borrowDueDate__c, 
                                             borrowReturnDate__c, 
                                             borrowPaymentAmount__c 
                                        FROM Borrow__c 
                                        WHERE borrowReturnDate__c = null];
        return borrowList;
    }

    /********************************************************************
    * Purpose:根据读者姓名查询未归还的借阅信息记录并返回给前端页面
    ********************************************************************/
    @AuraEnabled
    public static List<Borrow__c> getByName(String name) {
        List<Borrow__c> borrowList = [SELECT Id, 
                                             Name, 
                                             bookName__c, 
                                             readerName__c, 
                                             readerId__c, 
                                             borrowingDate__c, 
                                             borrowDueDate__c, 
                                             borrowReturnDate__c, 
                                             borrowPaymentAmount__c 
                                        FROM Borrow__c 
                                        WHERE borrowReturnDate__c = null AND readerName__c = :name];
        return borrowList;
    }
    /********************************************************************
    * Purpose:根据选中的借阅记录Id查询借阅记录，并更新对应记录归还日期，完成还书操作;
              同时回显未归还的借阅信息
    ********************************************************************/
    @AuraEnabled
    public static List<Borrow__c> setReturnDate(List<String> borrowIdList) {
        List<Borrow__c> borrowList = [SELECT Id, Name, readerId__c, borrowReturnDate__c 
                                        FROM Borrow__c 
                                       WHERE Id IN :borrowIdList];
        Set<Id> borrowSet = new Set<Id>();
        for (Borrow__c borrow : borrowList) {
            borrow.borrowReturnDate__c = System.today();
            borrowSet.add(borrow.readerId__c);
        }
        UPDATE borrowList;
        System.debug(LoggingLevel.INFO, '*** borrowSet: ' + borrowSet);
        List<Borrow__c> reborrowList = [SELECT Id, 
                                               Name, 
                                               bookName__c, 
                                               readerName__c, 
                                               readerId__c, 
                                               borrowingDate__c, 
                                               borrowDueDate__c, 
                                               borrowReturnDate__c, 
                                               borrowPaymentAmount__c 
                                         FROM  Borrow__c 
                                         WHERE borrowReturnDate__c = null AND readerId__c IN :borrowSet];
        System.debug(LoggingLevel.INFO, '*** reborrowList : ' + reborrowList);
        System.debug(LoggingLevel.INFO, '*** getBorrow(): ' + getBorrow());
        if (borrowSet.size() > 1) {
            return getBorrow();
        } else {
            return reborrowList;
        }
    }

    @AuraEnabled
    public static void setAutoReturnDate(String borrowchildBookId) {
        Borrow__c borrow = [SELECT Id, borrowReturnDate__c, borrowchildBookId__c 
                              FROM Borrow__c 
                             WHERE borrowReturnDate__c = null AND borrowchildBookId__c = :borrowchildBookId];
        if (borrow != null) {
            borrow.borrowReturnDate__c = System.today();
            UPDATE borrow;
        }
    }
}