public without sharing class CorningTestExtension {
    public CorningTestExtension() {

    }

    @AuraEnabled(cacheable=false)
    public static List<User> getUserList() {
        return [SELECT Id, Name FROM User];
    }

    @AuraEnabled(cacheable=false)
    public static List<Book__c> getBookList(String userId) {
        return [SELECT Id, Name, bookName__c, bookType__c 
                FROM Book__c
                WHERE OwnerId = :userId];
    }

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getAllOpps() {
        return [SELECT Id, Name ,StageName, CloseDate FROM Opportunity Order By Name asc];
    }
}