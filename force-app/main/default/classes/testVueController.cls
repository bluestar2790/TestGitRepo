public with sharing class testVueController {
    public ActivityPlan__c activityPlan {get; set;}
    /*public String myString{
        get{
            System.Debug('第1个方法');
            System.Debug('myString::' + myString);
            if(myString == null){ 
               myString ='a'; 
            } 
            System.Debug('myString::' + myString);
           return myString;
        }  
        private set;
    }
    public String getMyString(){
        System.Debug('第2个方法');
        System.Debug('getMyString');
        return 'getMyString';
    }     
    public String getStringMethod(){
        System.Debug('第3个方法');
        System.Debug('myString::' + myString);
        if(myString == null){
            myString ='b';
        }
        System.Debug('myString::' + myString);
        return myString;
    } */


    public testVueController() {
        
    }

    /********************************************************************
    * Purpose:查询ActivityPlan__c的所有数据，放入activityList中
    ********************************************************************/
    @RemoteAction
    public static List<ActivityPlan__c> queryAll() {
        List<ActivityPlan__c> activityList = [SELECT department__c, title__c, address__c, number__c FROM ActivityPlan__c];
        return activityList;
    }

    /********************************************************************
    * Purpose:获取ActivityPlan__c选项列表department__c的值
    ********************************************************************/
    @RemoteAction
    public static List<String> getDepartment() {
        Schema.DescribeFieldResult F = ActivityPlan__c.department__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        System.debug(LoggingLevel.INFO, '*** P: ' + P);
        List<String> departmentList = new List<String>();
        for (Schema.PicklistEntry dep : P) {
            departmentList.add(dep.getValue());
        }
        return departmentList;
    }

    /********************************************************************
    * Purpose:对ActivityPlan__c进行插入、更新和删除操作
    *.addList:存放插入的数据
    *.delList:存放删除的数据
    *.updateList:存放更新的数据
    ********************************************************************/
    @RemoteAction
    public static Boolean saveData(List<ActivityPlan__c> addList, List<ActivityPlan__c> delList, List<ActivityPlan__c> updateList) {
        if (addList != null) {
            INSERT addList;
        }
        if (delList != null) {
            DELETE delList;
        }
        if (updateList != null) {
            UPDATE updateList;
        }
        return true;
    }
}