public without sharing class testAuraController {
    @AuraEnabled
    public static String getUserId()  {
    	return UserInfo.getUserId();
    }
}