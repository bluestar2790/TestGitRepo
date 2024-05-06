global with sharing class ProductController {
    public ProductController() {
        
    }

    WebService static Product__c queryProduct(String proName){
        Product__c strName = [SELECT Name,
                                     ProductCategoriesFirst__c,
                                     ProductCategoriesSecond__c,
                                     ProductInventoryMax__c,
                                     ProductInventoryMin__c,
                                     ProductInventory__c,
                                     ProductPrice__c,
                                     ProductUnit__c,
                                     ProductStatus__c,
                                     ProductDescription__c 
                                FROM Product__c
                                WHERE Name = :proName];
        return strName;
    }
}