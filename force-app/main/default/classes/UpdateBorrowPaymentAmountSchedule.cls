global class UpdateBorrowPaymentAmountSchedule implements Schedulable {
    /********************************************************************
    * Purpose:每天凌晨5点计算超期未归还借阅，并生成罚款金额。
    ********************************************************************/
    global void execute(SchedulableContext sc) {
        String query = 'SELECT Name, borrowchildBookId__c, borrowDueDate__c, borrowPaymentAmount__c, borrowReturnDate__c ' + 
                         'FROM Borrow__c';
        UpdateBorrowPaymentAmountBatch ubpab = new UpdateBorrowPaymentAmountBatch(query);
        Database.executeBatch(ubpab);
    }

    //运行定时任务
    public static void runSchedule(){
        UpdateBorrowPaymentAmountSchedule ubpas = new UpdateBorrowPaymentAmountSchedule();
        //设置时间格式，每天凌晨5点定时处理
        String fmt = '00 00 05 * * ?';
        String nameSchedule = '缴费金额改变提醒' + System.now().format('yyyyMMddHHmmss');
        Id sid = System.Schedule(nameSchedule, fmt, ubpas);
    }
}