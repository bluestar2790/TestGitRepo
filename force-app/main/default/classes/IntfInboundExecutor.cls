/**********************************************************************
*Name：提供外部调用接口执行类
*Description：
将公共逻辑放到统一的地方处理，减少整体代码复杂度，方便后续维护
======================================================
History                                                            
-------                                                            
    VERSION  AUTHOR          DATE            DETAIL                
	1.0      lijun        2020-06-01         Created

***********************************************************************/ 
public with sharing class IntfInboundExecutor {

	public IntfInboundData theData {get;set;} // 基础参数
	public IntfInboundBase baseClass {get;set;} // 外部调用的基础处理类接口
	public InboundDefine__mdt theDefine {get;set;} // 接口配置定义
	public IntegratedLog__c theLog {get;set;} // 集成日志
    /*
        构造数据
        intfName: 接口名称
        bodyStr: 接口传递过来的数据
        log: 接口日志
    */
    public IntfInboundExecutor(String intfName, String bodyStr, IntegratedLog__c log) {

        if (intfName == null) {
            throw new IntfException('The Interface name is not exist.');
        }

        theLog = log;
        // 通过接口名获取接口配置
        theDefine = IntfUtility.getInboundDefineByName(intfName);
        System.debug(LoggingLevel.INFO, '*** bodyStr: ' + bodyStr);
        Map<String,Object> jsonMap = (Map<String,Object>)JSON.deserializeUntyped(bodyStr);
        System.debug(LoggingLevel.INFO, '*** jsonMap: ' + (jsonMap.containsKey('DATA')));
        if(!jsonMap.containsKey('DATA')){
            throw new IntfException('Data structure error.'); 
        }
        // 基础参数
        IntfInboundData inboundData = initInboundData(bodyStr);
        

        if (theDefine == null) {
            throw new IntfException('The Interface name is not exist.');
        }

        if ((theDefine.NoNeedLogin__c == null || !theDefine.NoNeedLogin__c)
            && theLog.InvokeSession__c == null ) {
            throw new IntfException('Please login first.');
        }

        inboundData.theDefine = theDefine; // 接口配置定义
        inboundData.theIntfName = intfName; // 接口名称
        theData = inboundData; // 基础参数
    }

    public IntfInboundResult execute(){
        // 接口名称， 配置标签
    	theLog.InterfaceName__c = theDefine.MasterLabel;
        // 执行类名
        theLog.ExecuteClass__c = theDefine.ExecuteClass__c;
        // 处理类日志记录
        theLog.ExecuteLog__c = '';
        // 外部系统名称
        theLog.SystemName__c = theDefine.ExternalSystemName__c;
        // 日志保留时间(天)
        if (theDefine.LogExpiryDate__c != null) {
            theLog.LogExpiryDate__c = Date.today().addDays(Integer.valueOf(theDefine.LogExpiryDate__c)); 
        }
        System.debug('theDefine::::' + theDefine);

        // 是否自动构建对象
        // MapConfigName__c：映射配置主对象名(SF)
        // MapConfigObjectName__c：映射配置主对象名
        if (theDefine.IsAutoBuildObject__c
            && String.isNotBlank(theDefine.MapConfigName__c)
            && String.isNotBlank(theDefine.MapConfigObjectName__c)
        ) {
            IntfFieldMappingUtil fieldMapUtil = new IntfFieldMappingUtil(theDefine.IntfFieldMapping__c);
            // 把接口传递过来的数据转成SF对象数据
            fieldMapUtil.toSobject(theData.DATA, theDefine.MapConfigName__c, theDefine.MapConfigObjectName__c);
            theData.errorMap = fieldMapUtil.allResult.errorMap; // 错误信息
            theData.allData = fieldMapUtil.allResult.allData; // 全部数据
            theData.invalidData = fieldMapUtil.allResult.invalidData; // 有效数据

            theData.fieldMap = fieldMapUtil.fieldMap; // 接口字段数据结构
            // 处理类日志记录
            theLog.ExecuteLog__c += '自动构建对象结果集： \n';
            theLog.ExecuteLog__c += ' invalidData : ' + JSON.serialize(theData.invalidData);
            theLog.ExecuteLog__c += ' allData : ' + JSON.serialize(theData.allData);
            theLog.ExecuteLog__c += ' errorMap : ' + JSON.serialize(theData.errorMap); 
        }


        // 执行业务逻辑 // 执行类名
        String clsName = theDefine.ExecuteClass__c;
        if (String.isBlank(clsName)){
            theLog.ExecuteLog__c += '【无可执行类】\n' + JSON.serialize(theDefine);

            throw new IntfException('not matching the api define.');
        }

        System.debug(LoggingLevel.INFO, '*** clsName: ' + clsName);
        // 获取类定义
        Type t = Type.forName(clsName);
        // 类实例化
        baseClass =  (IntfInboundBase)t.newInstance();

        System.debug(LoggingLevel.INFO, '*** theData: ' + theData);
        // 执行类逻辑
        IntfInboundResult result = baseClass.execute(theData);

        //TODO 如果内容过大，则用附件来保存
        // theLog.ReturnsContent__c = JSON.serialize(result);
        theLog.ExecuteLog__c += baseClass.debugLog;

        if (result.code != 200) {
            setErrorResponse(result);
        }
        return result;
    }




    // 获取业务请求信息 // 返回基本参数 bodyStr: 接口传递过来的数据
    public IntfInboundData initInboundData (String bodyStr) {
        IntfInboundData inboundData = new IntfInboundData();
            
        try{
            // 接口传递过来的数据Map
            Map<String,Object> jsonMap = (Map<String,Object>)JSON.deserializeUntyped(bodyStr);

            // 判断是否需要解密 (接口配置选择了加密，并且加密/解密秘钥、加密/解密方式不为空)
            if (theDefine.NeedEncode__c && String.isNotBlank(theDefine.EncodeType__c) && String.isNotBlank(theDefine.EncodeKey__c)) {
                
                String encryStr = String.valueOf(jsonMap.get('DATA'));
                // 解密后的数据
                String decryBodyStr = IntfUtility.decryptByType(theDefine.EncodeType__c, encryStr, theDefine.EncodeKey__c);

                // 日志中保存解密结果
                theLog.ReqBodyBeforeDecrypt__c = bodyStr;
                // 发送内容（即解密后接口传递过来的数据）
                theLog.SendContent__c = decryBodyStr;
                bodyStr = decryBodyStr;
            }
            
            // initCommonLogField(jsonMap, log);
            System.debug(LoggingLevel.INFO, '***initInboundData jsonMap: ' + jsonMap);
            
            if (jsonMap.containsKey('DATA')) {
                Object value = jsonMap.get('DATA');
                String dataJson = JSON.serialize(value);
                inboundData.dataStr = dataJson; // 接口传递过来的具体数据Json
                inboundData.DATA = value; // 接口传递过来的具体数据
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** (' + e.getLineNumber() + '): ' + e.getMessage());

            //该json 没有head 和 data 信息
            inboundData.dataStr = bodyStr;
            // inboundData.DATA = JSON.deserializeUntyped(bodyStr);
        }
        return inboundData;
    }


    public void setErrorResponse (IntfInboundResult result) {
        if (theData.errorMap == null || theData.errorMap.keySet().isEmpty()) {
            return;
        }

        List<Map<String, String>> errorList = new List<Map<String, String>>();
        for (String key : theData.errorMap.keySet()) {
            String error = theData.errorMap.get(key);
            Map<String, String> aItem = new Map<String, String>();
            aItem.put('key', key);
            aItem.put('msg', error);
            errorList.add(aItem);
        }

        result.data = errorList;
        result.msg = '失败';
        result.code = 400;
    }

    // save upsert error
    public static void saveUpsertErrorResult (List<Database.UpsertResult> upsertResults,  String keyFieldValue, List<Sobject> invalidList, IntfInboundData inboundData) {
        // 保存错误结果

        for(Integer index = 0; index < upsertResults.size() ; index++){
            Database.UpsertResult areslut = upsertResults.get(index);
            if (areslut.isSuccess()) {
                continue;
            }
            System.debug(LoggingLevel.INFO, '=================================' );
            Sobject aItem = invalidList[index];
            String keyValue = String.valueOf(aItem.get(keyFieldValue));
            System.debug(LoggingLevel.INFO, '*** keyValue: ' +keyValue );
            System.debug(LoggingLevel.INFO, '*** aItem: '+ JSON.serialize(aItem));
            System.debug(LoggingLevel.INFO, '*** areslut.getErrors(): ' + areslut.getErrors());

            // String errorMsg =  Utility.formatException(areslut.getErrors()[0].getMessage()) ;
            String errorMsg =  areslut.getErrors()[0].getMessage();
            if (inboundData.errorMap.containsKey(keyValue)) {
                errorMsg +=  ';'  + inboundData.errorMap.get(keyValue);
            }

            inboundData.errorMap.put(keyValue, errorMsg);
        }

    }


}