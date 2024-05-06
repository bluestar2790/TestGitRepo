global class UpdateProductPriceSchedule implements Schedulable {
    Decimal addPrice = 10;

    global void execute(SchedulableContext sc) {
        
        UpdateProductPriceBatch uppb = new UpdateProductPriceBatch(addPrice);
        Database.executeBatch(uppb);

    }

    //运行定时任务
    public static void runSchedule(){
        UpdateProductPriceSchedule upps = new UpdateProductPriceSchedule();

        //设置时间格式
        String fmt = '00 08 1 * * ?';
        String nameSchedule = '产品价格更改提醒' + System.now().format('yyyyMMddHHmmss');
        Id sid = System.Schedule(nameSchedule, fmt, upps);
    }
}