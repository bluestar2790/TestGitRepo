/********************************************************************
* class Name:ReaderBorrowBookComponentController
* Purpose:前端借书页面ReaderReturnBookComponent的后端控制类，进行数据交互
* Author: zhenfan chen
* Created Date:2021-1-25
********************************************************************/
public without sharing class ReaderBorrowBookComponentController {
    /********************************************************************
    * Purpose:查询全部可借阅的图书信息并返回给前端页面
    ********************************************************************/
    @AuraEnabled
    public static List<BookDetails__c> getbookDetails() {
        List<BookDetails__c> bookDetails = [SELECT Id, 
                                                   Name, 
                                                   bookName__c, 
                                                   bookDetailsBStatus__c, 
                                                   bookPrice__c 
                                              FROM BookDetails__c 
                                             WHERE bookDetailsBStatus__c = '可借阅'];
        return bookDetails;
    }
    /********************************************************************
    * Purpose:根据读者Id和图书详细Id批量插入借阅记录
    ********************************************************************/
    @AuraEnabled
    public static List<BookDetails__c> setBorrowinfo(String readerIdList, List<String> bookDetailsIdList) {
        List<Borrow__c> borrowList = new List<Borrow__c>();
        Reader__c reader = [SELECT Id, Name, readerName__c, readerNumber__c 
                              FROM Reader__c 
                              WHERE Id = :readerIdList];
        if (reader.readerNumber__c < bookDetailsIdList.size()) {
            reader.addError('借阅数量大于剩余可借阅数量');
        } else {
            for (String bookDetails : bookDetailsIdList) {
                Borrow__c borrow = new Borrow__c();
                borrow.borrowchildBookId__c = bookDetails;
                borrow.readerId__c = readerIdList;
                borrow.borrowingDate__c = System.today();
                borrowList.add(borrow);
            }
            INSERT borrowList;
        }
        return getbookDetails();
    }
}