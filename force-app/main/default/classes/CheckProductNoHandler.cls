public without sharing class CheckProductNoHandler implements Triggers.Handler {
    public void handle() {
        if (Trigger.isInsert && Trigger.isBefore) {
            Set<Decimal> proNoSet = new Set<Decimal>();

            for (Product__c pro: (List<Product__c>)Trigger.new ) {
                proNoSet.add(pro.ProductNo__c);
            }

            List<Product__c> proNoList = [SELECT ProductNo__c
                                          FROM  Product__c
                                          WHERE ProductNo__c IN :proNoSet];

            Map<Decimal, String> proNoMap = new Map<Decimal, String>();

            for (Product__c pro: proNoList) {
                proNoMap.put(pro.ProductNo__c, pro.Id);
            }

            for (Product__c pro: (List<Product__c>)Trigger.new ) {
                if (pro.ProductNo__c != null && proNoMap.containsKey(pro.ProductNo__c)) {
                    pro.addError('产品编号已存在');
                }
            }
        }

        
    }
}