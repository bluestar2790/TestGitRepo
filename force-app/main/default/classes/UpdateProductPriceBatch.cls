global class UpdateProductPriceBatch implements Database.Batchable<sObject> {
    public String query;
    public Decimal addProductPrice;
    // Integer queryCount = 0;

    global UpdateProductPriceBatch(Decimal addProductPrice) {
        this.addProductPrice = addProductPrice;
        // this.query = query;

    }

    /*
    Database.Batchable接口。此接口封装了三个方法，并且三个方法构成一个批处理的生命周期。
    start()方法用于查询数据，并将查询数据封装到List中；
    execute()方法用于操作数据，形参中List为start()方法中返回的数据，可以直接对此List进行修改以达到批处理行为。
    批处理全部执行后执行finish()方法，
    finish()方法用于进行一些后期处理，比如发邮件等操作。
    */

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT ProductPrice__c FROM Product__c';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Product__c> productList) {
        for(Product__c pro : productList) {
            pro.ProductPrice__c = pro.ProductPrice__c + this.addProductPrice;
            // queryCount += 1;
         }
         UPDATE productList;
    }

    global void finish(Database.BatchableContext BC) {
        String toAddresses = '935302578@qq.com';
        String subject = '产品价格更新操作';
        String body = '产品价格已成功更新';
        EmailManager.sendMail(toAddresses, subject, body);
    }
}