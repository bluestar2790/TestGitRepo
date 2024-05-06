trigger ProductTrigger on Product__c(before insert, before update, after insert, after update) {
    
    new Triggers()

    //在产品插入前设置标准的默认编号为产品编号的值
    .bind(Triggers.Evt.beforeinsert, new SetProductNumberHandler())
    //检查产品编号是否存在，存在报错
    .bind(Triggers.Evt.beforeinsert, new CheckProductNoHandler())


    .manage();


    // if (Trigger.isUpdate) {
    //     List<Product__c> productsListOld =Trigger.old;
    //     Product__c productOld=productsListOld.get(0);
    //     System.debug(LoggingLevel.INFO, '*** productOld: ' + JSON.serialize(productOld));
    //     List<Product__c> productsListNew =Trigger.new;
    //     Product__c productNew=productsListNew.get(0);
    //     System.debug(LoggingLevel.INFO, '*** productNew: ' + JSON.serialize(productNew));

    //     if (productOld.ProductPrice__c != productNew.ProductPrice__c && productOld.ProductInventory__c != productNew.ProductInventory__c) {
    //             EmailManager.sendMail('935302578@qq.com', '产品价格及库存改变提醒', 
    //             '产品<' + productOld.Name + '>的价格由' + productOld.ProductPrice__c + 
    //             '变成' + productNew.ProductPrice__c + '||产品<' + productOld.Name + 
    //             '>的库存由' + productOld.ProductInventory__c + '变成'+productNew.ProductInventory__c);
    //     }
    // }
}