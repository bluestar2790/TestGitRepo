global without sharing class TestInvocableMethod {
    @InvocableMethod(label='mytest')
    global static void SendSMS(List<String> argList) {
    	System.debug(LoggingLevel.INFO, '*** : 调用');
    	System.debug(LoggingLevel.INFO, '*** argList: ' + argList);
    }
}