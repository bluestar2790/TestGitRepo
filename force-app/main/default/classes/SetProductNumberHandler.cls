public without sharing class SetProductNumberHandler implements Triggers.Handler {
    public void handle() {
        if (Trigger.isInsert && Trigger.isBefore) {
            for (Product__c pro: (List<Product__c>)Trigger.new ) {
                pro.ProductCode__c = pro.ProductNo__c;
            }
        }
    }
}