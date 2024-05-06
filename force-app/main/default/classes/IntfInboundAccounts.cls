/********************************************************************
* Class Name: IntfInboundAccounts
* Purpose: 同步客户数据到SF系统
* Author: zyf(zhaoyuefeng@bluelinksys.com)
* Created Date: 2021-12-15
* TestClassName : IntfInboundAccountsTest  Coverage：92.97%
********************************************************************/
public without sharing class IntfInboundAccounts extends IntfInboundBase{
    public Override IntfInboundResult execute(IntfInboundData inboundData) {
    	IntfInboundResult resultRes = new IntfInboundResult();
    	System.debug(LoggingLevel.INFO, '***inboundData : ' + inboundData);
	 	System.debug(LoggingLevel.INFO, '***inboundData.allData : ' + inboundData.allData);
	 	System.debug(LoggingLevel.INFO, '***inboundData.invalidData : ' + inboundData.invalidData);
	 	System.debug(LoggingLevel.INFO, '***inboundData.errorMap : ' + inboundData.errorMap);


	 	if (!inboundData.invalidData.containsKey('Account') ) {
	 		resultRes.msg = '数据缺失';
        	resultRes.code = 400;
            return resultRes;
        }

        try{
            saveCustomerCredits(inboundData); 
            if (inboundData.errorMap == null || inboundData.errorMap.isEmpty()) {
                System.debug(LoggingLevel.INFO, '*** errorMap: ' + inboundData.errorMap);
                resultRes.code = 200;
                resultRes.msg = '成功';
            }
        }catch(Exception e){
            resultRes.msg = '失败';
            resultRes.code = 400;
            System.debug(LoggingLevel.INFO, '*** e.getStackTraceString(): ' + e.getStackTraceString());
        }
        return resultRes;
    }

    // /*******************************************************************
    // * 给客户赋值第一所有人和第二所有人的relationship
    // * @Author zyf(zhaoyuefeng@bluelinksys.com)
    // * @DateTime  2022-01-26
    // * @param  inboundData  [框架封装的对象,接口字段和对象的映射关系]
    // * @return  NULL  
    // ********************************************************************/
    // private void saveCustomerCredits (IntfInboundData inboundData) {
    //     List<Account> dataList = new List<Account>();
    //     dataList.addAll((List<Account>)inboundData.invalidData.get('Account'));
    //     System.debug(LoggingLevel.INFO, '*** dataList.size(): ' + dataList.size());

    //     // 获取外键名
    //     InterfaceFieldMapping__c keyFieldMapping = inboundData.fieldMap.sobjectKeyMap.get('Account');
    //     String keyFieldValue = (keyFieldMapping == null ? '' : keyFieldMapping.SfdcField__c);
    //     System.debug(LoggingLevel.INFO, '***keyFieldValue : ' + keyFieldValue);
    //     Schema.SObjectType convertType = Schema.getGlobalDescribe().get('Account');
    //     Schema.SObjectField afield = convertType.getDescribe().fields.getMap().get(keyFieldValue);
    //     //客户所有人相关信息
    //     Set<String> emailList = new Set<String>();

    //     RecordType  shop = Utility.getRecordType('Account',CommonConstant.ACCOUNT_RECORDTYPE_SHOP);
    //     RecordType  hq = Utility.getRecordType('Account',CommonConstant.ACCOUNT_RECORDTYPE_HQ );

    //     for(Account acc : dataList){
    //         emailList.add(acc.Sales_Email__c);
    //         emailList.add(acc.Second_Sales_Email__c);
    //         if(acc.CZV_Customer_Number_DE__c.endsWith(CommonConstant.PARENT_ACCOUNT_SIGN)){
    //             acc.CZV_Type_of_Customer_US__c = CommonConstant.ACCOUNT_RECORDTYPE_HQ ;
    //             acc.RecordTypeId = hq.Id;
    //         }else{
    //             acc.CZV_Type_of_Customer_US__c = CommonConstant.ACCOUNT_RECORDTYPE_SHOP;
    //             acc.RecordTypeId = shop.Id;
    //         }
    //     }

    //     Map<String,User> userMap  = Utility.getUserByEmail(emailList);
    //     emailList.clear();
    //     String currentUserId = UserInfo.getUserId();

    //     //客户要求取消邮箱校验
    //     for(Integer i = dataList.size()-1;i>=0; i--){
    //         Account acc = dataList.get(i);
    //         //找不到专营业务员
    //         String email = acc.Sales_Email__c;
    //         if(String.isNotBlank(email)){
    //             email = email.toLowerCase();
    //         }
    //         if(userMap.containsKey(email)){
    //             acc.Sales_Owner__c = userMap.get(email).Id;
    //             //所有人赋值为专营业务员
    //             acc.OwnerId  = acc.Sales_Owner__c;
    //         }else{
    //             acc.Sales_Owner__c = currentUserId;
    //         }
    //         //找不到策略巴业务员
    //         email = acc.Second_Sales_Email__c;
    //         if(String.isNotBlank(email)){
    //             email = email.toLowerCase();
    //         }
    //         if(userMap.containsKey(email)){
    //             acc.Second_Owner__c = userMap.get(email).Id;
    //         }else{
    //             acc.Second_Owner__c =null;
    //         }
    //     }

    //     List<Database.UpsertResult> upsertResults =  Database.upsert(dataList, afield, FALSE);
    //     Set<String> successIdList = new Set<String>();
    //     for(Database.UpsertResult r : upsertResults){
    //         if(r.isSuccess()){
    //             successIdList.add(r.getId());
    //         }
    //     }
        
        
    //     if(successIdList.size()>0){  //查询开票公司和客户编码
    //         asynRelatedParentAccount(successIdList);
    //     }

    //     IntfInboundExecutor.saveUpsertErrorResult(upsertResults, keyFieldValue, dataList, inboundData);
    
    // }


    /*******************************************************************
    * 给客户赋值第一所有人和第二所有人的relationship
    * @Author czf(chenzhenfan@bluelinksys.com)
    * @DateTime  2022-05-24
    * @param  inboundData  [框架封装的对象,接口字段和对象的映射关系]
    * @return  NULL  
    ********************************************************************/
    private void saveCustomerCredits (IntfInboundData inboundData) {
        List<Account> dataList = new List<Account>();
        dataList.addAll((List<Account>)inboundData.invalidData.get('Account'));
        System.debug(LoggingLevel.INFO, '*** dataList.size(): ' + dataList.size());

        // 获取外键名
        InterfaceFieldMapping__c keyFieldMapping = inboundData.fieldMap.sobjectKeyMap.get('Account');
        String keyFieldValue = (keyFieldMapping == null ? '' : keyFieldMapping.SfdcField__c);
        System.debug(LoggingLevel.INFO, '***keyFieldValue : ' + keyFieldValue);
        Schema.SObjectType convertType = Schema.getGlobalDescribe().get('Account');
        Schema.SObjectField afield = convertType.getDescribe().fields.getMap().get(keyFieldValue);
        // //客户所有人相关信息
        // Set<String> emailList = new Set<String>();

        // // RecordType  shop = Utility.getRecordType('Account',CommonConstant.ACCOUNT_RECORDTYPE_SHOP);
        // // RecordType  hq = Utility.getRecordType('Account',CommonConstant.ACCOUNT_RECORDTYPE_HQ );
        // // 服务商
        // RecordType  service = Utility.getRecordType('Account',CommonConstant.ACCOUNT_RECORDTYPE_SERVICE);
        // // 终端客户
        // RecordType  terminaluser = Utility.getRecordType('Account',CommonConstant.ACCOUNT_RECORDTYPE_TERMINALUSER);
        // // 终端门店
        // RecordType  terminalstore = Utility.getRecordType('Account',CommonConstant.ACCOUNT_RECORDTYPE_TERMINALSTORE);
        // // 虚拟账号
        // RecordType  virtualtype = Utility.getRecordType('Account',CommonConstant.ACCOUNT_RECORDTYPE_VIRTUAL);

        // for(Account acc : dataList){
        //     emailList.add(acc.Sales_Email__c);
        //     emailList.add(acc.Second_Sales_Email__c);
        //     // if(acc.CZV_Customer_Number_DE__c.endsWith(CommonConstant.PARENT_ACCOUNT_SIGN)){
        //     //     acc.CZV_Type_of_Customer_US__c = CommonConstant.ACCOUNT_RECORDTYPE_HQ ;
        //     //     acc.RecordTypeId = hq.Id;
        //     // }else{
        //     //     acc.CZV_Type_of_Customer_US__c = CommonConstant.ACCOUNT_RECORDTYPE_SHOP;
        //     //     acc.RecordTypeId = shop.Id;
        //     // }
        //     // 服务商
        //     if(acc.Account_Properties__c == CommonConstant.ACCOUNT_ACCPROPERTY_SERVICE) {
        //         acc.RecordTypeId = service.Id;
        //     } else if(acc.Account_Properties__c == CommonConstant.ACCOUNT_ACCPROPERTY_TERMINALUSER) { // 终端客户
        //         acc.RecordTypeId = terminaluser.Id;
        //     } else if(acc.Account_Properties__c == CommonConstant.ACCOUNT_ACCPROPERTY_TERMINALSTORE) { // 终端门店
        //         acc.RecordTypeId = terminalstore.Id;
        //     } else if(acc.Account_Properties__c == CommonConstant.ACCOUNT_ACCPROPERTY_VIRTUAL) { // 虚拟账号
        //         acc.RecordTypeId = virtualtype.Id;
        //     }

        // }

        // Map<String,User> userMap  = Utility.getUserByEmail(emailList);
        // emailList.clear();
        // String currentUserId = UserInfo.getUserId();

        // //客户要求取消邮箱校验
        // for(Integer i = dataList.size()-1;i>=0; i--){
        //     Account acc = dataList.get(i);
        //     //找不到专营业务员
        //     String email = acc.Sales_Email__c;
        //     if(String.isNotBlank(email)){
        //         email = email.toLowerCase();
        //     }
        //     if(userMap.containsKey(email)){
        //         acc.Sales_Owner__c = userMap.get(email).Id;
        //         //所有人赋值为专营业务员
        //         acc.OwnerId  = acc.Sales_Owner__c;
        //     }else{
        //         acc.Sales_Owner__c = currentUserId;
        //     }
        //     //找不到策略巴业务员
        //     email = acc.Second_Sales_Email__c;
        //     if(String.isNotBlank(email)){
        //         email = email.toLowerCase();
        //     }
        //     if(userMap.containsKey(email)){
        //         acc.Second_Owner__c = userMap.get(email).Id;
        //     }else{
        //         acc.Second_Owner__c =null;
        //     }
        // }
        System.debug(LoggingLevel.INFO, '*** dataList: ' + dataList);
        System.debug(LoggingLevel.INFO, '*** afield: ' + afield);
        List<Database.UpsertResult> upsertResults = afield != null ? Database.upsert(dataList, afield, FALSE) : Database.upsert(dataList, FALSE);
        Set<String> successIdList = new Set<String>();
        for(Database.UpsertResult r : upsertResults){
            if(r.isSuccess()){

                successIdList.add(r.getId());
            }
        }
        
        
        // if(successIdList.size()>0){  //查询开票公司和客户编码
        //     asynRelatedParentAccount(successIdList);
        // }

        IntfInboundExecutor.saveUpsertErrorResult(upsertResults, keyFieldValue, dataList, inboundData);
    
    }


    /*******************************************************************
    * 共享客户
    * @Author zyf(zhaoyuefeng@bluelinksys.com)
    * @DateTime  2022-01-26
    * @param  shareMap  [key:记录Id;value:被共享人Id]
    * @return  NULL  
    ********************************************************************/
    // public static void shareAccount(Map<String,String> shareMap){
    //     //手动共享，当所有人和策略巴业务员同一个人不共享
    //     List<AccountShare> shareList = new  List<AccountShare>();
    //     for(AccountShare share :[SELECT Id,AccountId,UserOrGroupId
    //                              FROM   AccountShare 
    //                              WHERE  AccountId IN: shareMap.keySet()
    //                              AND    UserOrGroupId  IN: shareMap.values()]){

    //         String value = shareMap.get(share.AccountId);
    //         if(value == share.UserOrGroupId){
    //             shareMap.remove(share.AccountId);
    //         }
    //     }

    //     for(String key : shareMap.keySet()){
    //         String value = shareMap.get(key);
    //         AccountShare sh = new AccountShare();
    //         sh.AccountId = key ;
    //         sh.AccountAccessLevel = CommonConstant.ACCESS_LEVEL_READ ;
    //         sh.CaseAccessLevel  = CommonConstant.ACCESS_LEVEL_READ;
    //         sh.OpportunityAccessLevel  = CommonConstant.ACCESS_LEVEL_READ;
    //         sh.RowCause = CommonConstant.ACCESS_TYPE_MANUAL;
    //         //被共享人ID
    //         sh.UserOrGroupId = value ;
    //         shareList.add(sh);
    //     }
    //     if(shareList.size()>0){
    //         INSERT shareList;
    //     }
    // }

    /*******************************************************************
    * 异步调用 relatedParentAccount方法
    * @Author zyf(zhaoyuefeng@bluelinksys.com)
    * @DateTime  2022-01-26
    * @param  accId  [客户Id]
    * @return  NULL  
    ********************************************************************/
    // @future
    // public static void asynRelatedParentAccount (Set<String> accId){
    //     relatedParentAccount(accId, '');
    // }

    /*******************************************************************
    * 更新客户的母公司
    * @Author zyf(zhaoyuefeng@bluelinksys.com)
    * @DateTime  2022-01-26
    * @param  accId  [客户Id]
    * @param  updateType  [更新类型]
    * @return  NULL  
    ********************************************************************/
    // public static void relatedParentAccount(Set<String> accId, String updateType){
    //     if(accId.size()==0){
    //         return ;
    //     }
    //     // 终端门店
    //     Map<String,List<Account>> accMap = new Map<String,List<Account>> ();
    //     // 服务商
    //     Map<String,List<Account>> serviceAccMap = new Map<String,List<Account>> ();

    //     // modified by czf 2023-05-24 s
    //     // //先查询成功插入的客户(门店)
    //     // for(Account acc : [SELECT Id,ParentId,CZV_Customer_Number_DE__c, Report_Form_Org__c 
    //     //                      FROM Account 
    //     //                     WHERE Id IN:accId]){
    //     //     //报表汇总单位：门店
    //     //     if(String.isNotBlank(acc.Report_Form_Org__c) &&acc.CZV_Customer_Number_DE__c != acc.Report_Form_Org__c){
    //     //         String key = acc.Report_Form_Org__c;
    //     //         List<Account> midAccount = accMap.get(key) ; 
    //     //         if(midAccount ==null){
    //     //             midAccount = new List<Account>();
    //     //             accMap.put(key,midAccount);
    //     //         }
    //     //         midAccount.add(acc);
    //     //     }
    //     // }
    //     // 
    //     // List<Account> uAccount = new List<Account>();
    //     // for(Account acc : [SELECT Id,CZV_Customer_Number_DE__c
    //     //                         FROM Account 
    //     //                        WHERE CZV_Customer_Number_DE__c IN:accMap.keySet()]){

    //     //     if(accMap.containsKey(acc.CZV_Customer_Number_DE__c)){
    //     //         for(Account accEntity : accMap.get(acc.CZV_Customer_Number_DE__c)){
    //     //             accEntity.ParentId = acc.Id;
    //     //             uAccount.add(accEntity);
    //     //         }
    //     //     }
    //     // }
    //     // 
    //     // if(uAccount.size()>0){
    //     //     UPDATE uAccount;
    //     // }
        
    //     //先查询成功插入的客户(门店)
    //     for(Account acc : [SELECT Id,ParentId,CZV_Customer_Number_DE__c, Terminal_User_Code__c, 
    //                               RecordType.DeveloperName, Service_Code__c    
    //                          FROM Account 
    //                         WHERE Id IN:accId]){
    //         //报表汇总单位：门店
    //         if(acc.RecordType.DeveloperName == CommonConstant.ACCOUNT_RECORDTYPE_TERMINALSTORE 
    //             && String.isNotBlank(acc.Terminal_User_Code__c) 
    //             && acc.CZV_Customer_Number_DE__c != acc.Terminal_User_Code__c 
    //             && updateType != CommonConstant.SERVICE){
    //             String key = acc.Terminal_User_Code__c;
    //             List<Account> midAccount = accMap.get(key) ; 
    //             if(midAccount ==null){
    //                 midAccount = new List<Account>();
    //                 accMap.put(key,midAccount);
    //             }
    //             midAccount.add(acc);
    //         }
    //         // 终端门店、终端客户关联服务商
    //         if((acc.RecordType.DeveloperName == CommonConstant.ACCOUNT_RECORDTYPE_TERMINALUSER || 
    //            acc.RecordType.DeveloperName == CommonConstant.ACCOUNT_RECORDTYPE_TERMINALSTORE) 
    //             && String.isNotBlank(acc.Service_Code__c) 
    //             && acc.CZV_Customer_Number_DE__c != acc.Service_Code__c 
    //             && updateType != CommonConstant.PARENT) {
    //             String keyStr = acc.Service_Code__c;
    //             if(!serviceAccMap.containsKey(acc.Service_Code__c)) {
    //                 serviceAccMap.put(keyStr, new List<Account>());
    //             }
    //             serviceAccMap.get(keyStr).add(acc);
    //         }
    //     }

    //     System.debug(LoggingLevel.INFO, '*** serviceAccMap: ' + serviceAccMap);
        
    //     Set<String> allAccSet = new Set<String>();
    //     allAccSet.addAll(accMap.keySet());
    //     allAccSet.addAll(serviceAccMap.keySet());

    //     // List<Account> uAccount = new List<Account>();
    //     Map<Id, Account> uAccountMap = new Map<Id, Account>();
    //     for(Account acc : [SELECT Id,CZV_Customer_Number_DE__c
    //                             FROM Account 
    //                            WHERE CZV_Customer_Number_DE__c IN:allAccSet]){
    //         // 终端门店
    //         if(accMap.containsKey(acc.CZV_Customer_Number_DE__c)){
    //             for(Account accEntity : accMap.get(acc.CZV_Customer_Number_DE__c)){
    //                 accEntity.ParentId = acc.Id;
    //                 // uAccount.add(accEntity);
    //                 uAccountMap.put(accEntity.Id, accEntity);
    //             }
    //         }
    //         // 服务商
    //         if(serviceAccMap.containsKey(acc.CZV_Customer_Number_DE__c)){
    //             for(Account accEntity : serviceAccMap.get(acc.CZV_Customer_Number_DE__c)){
    //                 accEntity.Service_Provider__c = acc.Id;
    //                 // uAccount.add(accEntity);
    //                 if(uAccountMap.containsKey(accEntity.Id)) {
    //                     uAccountMap.get(accEntity.Id).Service_Provider__c = acc.Id;
    //                 } else {
    //                     uAccountMap.put(accEntity.Id, accEntity);
    //                 }
    //             }
    //         }
    //     }
    //     // System.debug(LoggingLevel.INFO, '*** uAccount: ' + uAccount);

    //     // if(uAccount.size()>0){
    //     //     UPDATE uAccount;
    //     // }
    //     if(!uAccountMap.isEmpty()) {
    //         UPDATE uAccountMap.values();
    //     }
    //     // modified by czf 2023-05-24 e
    // }
    
}