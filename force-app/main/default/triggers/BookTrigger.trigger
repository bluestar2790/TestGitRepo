trigger BookTrigger on Book__c(before insert, before update, after insert, after update) {
    new Triggers()
    //剩余库存数量改变时新增出入库记录
    .bind(Triggers.Evt.afterupdate, new CheckBookInventoryHandler())

    .manage();
}