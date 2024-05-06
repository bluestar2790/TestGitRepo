global class UpdateBorrowDateFlagSchedule implements Schedulable {
    /********************************************************************
    * Purpose:每天晚上11点定时计算明天到期的借阅记录
    ********************************************************************/
    global void execute(SchedulableContext sc) {
        String query = 'SELECT Name, borrowReturnDate__c, borrowDueDate__c, borrowPaymentAmount__c, borrowDateFlag__c ' + 
                         'FROM Borrow__c';
        UpdateBorrowDateFlagBatch ubdfb = new UpdateBorrowDateFlagBatch(query);
        Database.executeBatch(ubdfb);
    }

    //运行定时任务
    public static void runSchedule(){
        UpdateBorrowDateFlagSchedule ubdfs = new UpdateBorrowDateFlagSchedule();
        //设置时间格式,每天晚上11点定时处理
        String fmt = '00 00 23 * * ?';
        String nameSchedule = '即将到期借阅记录统计' + System.now().format('yyyyMMddHHmmss');
        Id sid = System.Schedule(nameSchedule, fmt, ubdfs);
    }
}