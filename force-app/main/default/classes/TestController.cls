public with sharing class TestController {
    public TestController() {
        
    }

    @AuraEnabled
    public static String searchData(String key){
        return key + '已调用';
    }

    //查询产品编号是否存在，返回String
    @AuraEnabled
    public static String searchCode(Decimal code){
        List<Product__c> productData = [SELECT Name, 
                                               ProductPrice__c 
                                          FROM Product__c 
                                         WHERE ProductNo__c= :code];
        if (productData.size() > 0) {
          return productData[0].Name;
        } else {
          return '产品编号可用';
        }
    }

    //查询产品编号是否存在，返回Map
    @AuraEnabled
    public static Map<String, Object> searchCodeMap(Decimal code){
        List<Product__c> productData = [SELECT Name 
                                          FROM Product__c 
                                         WHERE ProductNo__c= :code];
        Map<String, Object> codeMap = new Map<String, Object>();
        if (productData.size() > 0 && productData != null) {
          codeMap.put('status', true);
          codeMap.put('productName', productData[0].Name);
        } else {
          codeMap.put('status', false);
          codeMap.put('productName', '产品编号可用');
        }
        return codeMap;
    }
}