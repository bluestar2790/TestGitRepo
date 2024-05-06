public without sharing class SelfBorrowBookComponentController {
    public SelfBorrowBookComponentController() {
        
    }

    @AuraEnabled
    public static List<BookDetails__c> setBookSelfFlag(String readerId, String bookDetailsId) {
        List<BookDetails__c> bookDetailsList = [SELECT Id, 
                                                       Name, 
                                                       bookName__c, 
                                                       bookDetailsBStatus__c, 
                                                       bookPrice__c, 
                                                       bookSelfFlag__c 
                                                  FROM BookDetails__c 
                                                 WHERE bookDetailsBStatus__c = '可借阅' AND 
                                                       (Id = :bookDetailsId OR bookSelfFlag__c = :readerId)];
        for (BookDetails__c bookDetails : bookDetailsList) {
            bookDetails.bookSelfFlag__c = readerId;
        }
        UPDATE bookDetailsList;
        return bookDetailsList;
    }

    @AuraEnabled
    public static void selfBorrowBooks(String readerId) {
        List<BookDetails__c> bookDetailsList = [SELECT Id,  
                                                       bookSelfFlag__c 
                                                  FROM BookDetails__c 
                                                 WHERE bookDetailsBStatus__c = '可借阅' AND bookSelfFlag__c = :readerId];
        if (bookDetailsList != null) {
            List<Borrow__c> borrowList = new List<Borrow__c>();
            for (BookDetails__c bookDetails : bookDetailsList) {
                Borrow__c borrow = new Borrow__c();
                bookDetails.bookSelfFlag__c = '';
                borrow.readerId__c = readerId;
                borrow.borrowchildBookId__c = bookDetails.Id;
                borrow.borrowingDate__c = System.today();
                borrowList.add(borrow);
            }
            UPDATE bookDetailsList;
            INSERT borrowList;
        } else {

        }
    }

    @AuraEnabled
    public static void clearselfFlag() {
        List<BookDetails__c> bookDetailsList = [SELECT Id,  
                                                       bookSelfFlag__c 
                                                  FROM BookDetails__c 
                                                 WHERE bookDetailsBStatus__c = '可借阅' AND bookSelfFlag__c != null];
        if (bookDetailsList != null) {
            for (BookDetails__c bookDetails : bookDetailsList) {
                bookDetails.bookSelfFlag__c = '';
            }
            UPDATE bookDetailsList;
        } else {

        }
    }

}