trigger BorrowTrigger on Borrow__c(before insert, before update, after insert, after update) {
    new Triggers()
    //读者归还图书改变图书状态及读者剩余借阅数量
    .bind(Triggers.Evt.afterupdate, new CheckBorrowReturnDateHandler())
    //读者归还图书前清空缴费金额
    .bind(Triggers.Evt.beforeupdate, new CheckBorrowReturnDateHandler())
    //读者借阅图书改变图书状态及剩余借阅数量
    .bind(Triggers.Evt.afterinsert, new CheckBorrowReturnDateHandler())
    //根据读者类型设置应还日期
    .bind(Triggers.Evt.beforeinsert, new SetBorrowDueDateHandler())
    //读者续借图书改变图书应还日期
    .bind(Triggers.Evt.beforeupdate, new CheckBorrowRenewStatusHandler())
    
    .manage();
}