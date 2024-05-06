/**********************************************************************
 * 
 *
 * @url: /services/apexrest/rest
 * @data:
 *  {
        
    }
*************************************************************************/
@RestResource(urlMapping='/rest/*')
global with sharing class IntfInboundRestWithName 
{
    @HttpPost
    global static void doPost() 
    {
        String respBody = doExecute(RestContext.request);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.statusCode = 200;
        RestContext.response.responseBody = Blob.valueOf(respBody);
    }

    // @HttpGet
    // global static void doGet() 
    // {
    //     RestContext.response.responseBody = Blob.valueOf('success.');
    // }

    public static String doExecute (RestRequest req) {
        // 接口日志
        IntegratedLog__c log = new IntegratedLog__c();
        // 提供外部调用的返回值
        IntfInboundResult result;
        // 返回内容
        String respBody = '';
        // 外部调用接口执行
        IntfInboundExecutor executor;
        try{
            // 接口传递过来的数据
            String bodystr = req.requestBody.tostring();
            // 根据接口Url获取调用的接口名称
            String intfName = getIntfNameFromUrl(req.requestURI, req.httpMethod);
            //  生成时间
            log.GeneratedTime__c = System.now();
            // 调用人
            log.InvokeUser__c = UserInfo.getUserId();
            // 调用会话
            log.InvokeSession__c = UserInfo.getSessionId();
            // 发送内容，即接口传递过来的数据
            log.SendContent__c = bodystr;
            // 接口头信息
            log.HeaderContent__c = String.valueOf(req.headers);
            // 调用方IP
            log.IP__c = req.remoteAddress;
            // 接口URL
            log.URL__c = req.requestURI;
            // 类型
            log.Type__c = '入站';

            // if (!IntfUtility.isTheValidIp(intfName, log.IP__c)) {
            //     throw new IntfException('The ip is not valid.');
            // }
            // 调用接口执行类（接口名称，接口传递过来的数据，接口日志）
            executor = new IntfInboundExecutor(intfName, bodystr, log);
            // 调用接口执行类，执行数据处理
            result = executor.execute();

            if (result == null) {
                throw new IntfException('Apex_Error: IntfInboundResult is null.');
            }

            
        } catch (LimitException e) {
            String message = e.getMessage();
            result = new IntfInboundResult();
            result.code = 400;
            result.msg = message;

            log.ErrorContent__c = Json.serialize('(' + e.getLineNumber() 
                                + ') : ' + message 
                                + '\n' + e.getStackTraceString());

            System.debug(LoggingLevel.INFO, '*** log.ErrorContent__c: ' + log.ErrorContent__c);
        }catch (Exception e) {
            String message = e.getMessage();
            result = new IntfInboundResult();
            result.code = 400;
            result.msg = message;

            log.ErrorContent__c = Json.serialize('(' + e.getLineNumber() 
                                + ') : ' + message 
                                + '\n' + e.getStackTraceString());

            System.debug(LoggingLevel.INFO, '*** log.ErrorContent__c: ' + log.ErrorContent__c);
        }

        
        if(result.data == null){
            result.data = new List<object>();
        }
        respBody = JSON.serialize(result, true);
        log.ReturnsContent__c = respBody;
        if (result.code == 200) {
            log.Results__c = '成功';
        } else {
            log.Results__c = '失败';
        }

        //判断返回结果是否加密
        if (executor != null
             && executor.theDefine != null
             && executor.theDefine.NeedEncode__c
             && String.isNotBlank(executor.theDefine.EncodeType__c)
             && String.isNotBlank(executor.theDefine.EncodeKey__c)
        ) {

            String respBodyStr = IntfUtility.encryptByType(executor.theDefine.EncodeType__c, respBody, executor.theDefine.EncodeKey__c);
            System.debug(LoggingLevel.INFO, '*** respBodyStr: ' + respBodyStr);

            Map<String, String> amap = new Map<String, String>{'DATA' => respBodyStr};
            String respJson = JSON.serialize(amap);

            log.RespBodyAfterEncrypt__c = respJson; //respBodyStr;
            respBody = respJson;
        }

        // 保存日志
        IntfUtility.insertLog(log);
        return respBody;
    }

    // 根据接口Url获取调用的接口名，返回接口名称（接口url, 调用方式）
    public static String getIntfNameFromUrl (String requestUrl, String method) {
        String theURI = requestUrl;
        if ('GET' == method) {
            theURI = theURI.substringBefore('?');
        }

        System.debug(LoggingLevel.INFO, '*** theURI: ' + theURI);
        String intfName = theURI.substringAfter('/rest/');

        System.debug(LoggingLevel.INFO, '*** intfName: ' + intfName);
        return intfName;
    }
}