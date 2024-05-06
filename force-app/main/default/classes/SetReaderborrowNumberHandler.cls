/********************************************************************
* class Name:SetReaderborrowNumberHandler
* Purpose:读者表插入新数据时，根据读者类型设置剩余借阅数量
* Author: zhenfan chen
* Created Date:2021-1-15
********************************************************************/
public without sharing class SetReaderborrowNumberHandler implements Triggers.Handler {
    /********************************************************************
    * Purpose:根据读者类型设置剩余借阅数量
    ********************************************************************/
    public void handle() {
        if (Trigger.isInsert && Trigger.isBefore) {
            for (Reader__c reader: (List<Reader__c>)Trigger.new) {
                if (reader.readerType__c == '教职工') {
                    reader.readerNumber__c = 20;
                } else {
                    reader.readerNumber__c = 10;
                }
            }
        }
    }
}