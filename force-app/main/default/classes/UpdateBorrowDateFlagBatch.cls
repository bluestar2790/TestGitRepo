/********************************************************************
* class Name:UpdateBorrowDateFlagBatch
* Purpose:每天晚上11点定时计算明天到期的借阅记录，并标识
* Author: zhenfan chen
* Created Date:2021-1-19
********************************************************************/
global class UpdateBorrowDateFlagBatch implements Database.Batchable<sObject> {
    public String query;

    global UpdateBorrowDateFlagBatch(String query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    /********************************************************************
    * Purpose:标识明天到期借阅记录
    ********************************************************************/
    global void execute(Database.BatchableContext BC, List<Borrow__c> borrowList) {
        for(Borrow__c borrow : borrowList) {
            //如果读者未归还图书，归还日期为空且今天与应还日期的差值为1，则更改即将到期标识为true，否则即将到期标识为false
            if (borrow.borrowReturnDate__c == null && System.today().daysBetween(borrow.borrowDueDate__c) == 1) {
                borrow.borrowDateFlag__c = true;
            } else {
                borrow.borrowDateFlag__c = false;
            }
        }
        UPDATE borrowList;
    }

    global void finish(Database.BatchableContext BC) {

    }
}