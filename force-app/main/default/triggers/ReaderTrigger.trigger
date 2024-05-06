trigger ReaderTrigger on Reader__c(before insert, before update, after insert, after update) {
    new Triggers()
    //根据读者类型设置剩余借阅数量
    .bind(Triggers.Evt.beforeinsert, new SetReaderborrowNumberHandler())
    //检测缴费金额发送邮件通知
    .bind(Triggers.Evt.afterupdate, new CheckBorrowPaymentAmountHandler())
    
    .manage();
}