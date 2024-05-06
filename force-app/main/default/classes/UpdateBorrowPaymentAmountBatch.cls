/********************************************************************
* class Name:UpdateBorrowPaymentAmountBatch
* Purpose:每天凌晨5点计算超期未归还借阅，并生成罚款金额
* Author: zhenfan chen
* Created Date:2021-1-19
********************************************************************/
global class UpdateBorrowPaymentAmountBatch implements Database.Batchable<sObject> {
    public String query;

    global UpdateBorrowPaymentAmountBatch(String query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    /********************************************************************
    * Purpose:计算读者超时未归还的罚款金额
    ********************************************************************/
    global void execute(Database.BatchableContext BC, List<Borrow__c> borrowList) {
        Map<Id, BookDetails__c> bookDetailsMap = new Map<Id, BookDetails__c>([SELECT Id, bookPrice__c, bookDetailsBStatus__c 
                                                                                FROM BookDetails__c 
                                                                               WHERE bookDetailsBStatus__c = '已借出']);
        for(Borrow__c borrow : borrowList) {
            //如果读者未归还图书，归还日期为空且当天与应还日期的差值为大于0
            if (borrow.borrowReturnDate__c == null && borrow.borrowDueDate__c.daysBetween(System.today()) > 0) {
                BookDetails__c bookDetails = bookDetailsMap.get(borrow.borrowchildBookId__c);
                //当天与应还日期的差值不超过图书价格，则设置罚款金额为今天与应还日期相差的天数，否则为图书价格
                if (borrow.borrowDueDate__c.daysBetween(System.today()) < bookDetails.bookPrice__c) {
                    borrow.borrowPaymentAmount__c = borrow.borrowDueDate__c.daysBetween(System.today());
                } else {
                    borrow.borrowPaymentAmount__c = bookDetails.bookPrice__c;
                }
            }
         }
         UPDATE borrowList;
    }

    global void finish(Database.BatchableContext BC) {

    }
}