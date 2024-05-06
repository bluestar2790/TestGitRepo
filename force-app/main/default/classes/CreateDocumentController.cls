global without sharing class CreateDocumentController {
    @RemoteAction
    global static Map<String, Object> uploadFileAction(String filestr, String filestrId) {
    	Map<String, Object> resultMap = new Map<String, Object>();
    	if(String.isNotBlank(fileStr)){
            String myfilestrId = CreateDocument(fileStr, filestrId);
            if(String.isNotBlank(myfilestrId) && myfilestrId != 'error') {
            	resultMap.put('status', 'success');
            	resultMap.put('Id', myfilestrId);
            } else {
            	resultMap.put('status', 'error');
            }
        } else {
        	resultMap.put('status', 'error');
        }
        return resultMap;
    }

    public static String CreateDocument(String fileStr, String filestrId){
        SavePoint sp = Database.setSavepoint();

        try {
        	
            Object fileObj = JSON.deserializeUntyped(fileStr); 
            Map<String,Object> attachmentobj = (Map<String,Object>)fileObj;
            String fileName = String.valueOf(attachmentobj.get('name'));
            List<ContentVersion> lastContVerFile = new List<ContentVersion>();
            ContentVersion contVerFile = new ContentVersion();
            if(String.isNotBlank(filestrId)) {
            	lastContVerFile = getDocumentVersion(filestrId);
            	System.debug(LoggingLevel.INFO, '*** lastContVerFile: ' + lastContVerFile);
            }
            if(lastContVerFile.size() > 0) {
            	System.debug(LoggingLevel.INFO, '*** String.valueof(lastContVerFile[0].VersionData): ' + String.valueof(lastContVerFile[0].VersionData));
            	// 附件内容
            	contVerFile.VersionData = EncodingUtil.Base64Decode(EncodingUtil.base64Encode(lastContVerFile[0].VersionData) + String.valueOf(attachmentobj.get('bodybase64')));
            	System.debug(LoggingLevel.INFO, '*** contVerFile.VersionData: ' + contVerFile.VersionData);
            	contVerFile.ContentDocumentId = lastContVerFile[0].ContentDocumentId;
            } else {
            	contVerFile.VersionData = EncodingUtil.Base64Decode(String.valueOf(attachmentobj.get('bodybase64')) );
            }
            contVerFile.Title = fileName;
            contVerFile.ContentLocation = 's';
            contVerFile.PathOnClient = fileName;
            System.debug(LoggingLevel.INFO, '*** contVerFile: ' + contVerFile);
            insert contVerFile;
            System.debug(LoggingLevel.INFO, '*** contVerFile: ' + contVerFile);

            return contVerFile.Id;

        }
        catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** error.getMessage: ' + e.getMessage());
            Database.rollback(sp);

            return 'error';
        }
    }

    public static List<ContentVersion> getDocumentVersion(String filestrId) {
    	List<ContentVersion> contverList = [SELECT id, ContentDocumentId, VersionData  
                                             FROM ContentVersion 
                                             WHERE id = :filestrId];
		System.debug(LoggingLevel.INFO, '*** contverList: ' + contverList);
        return contverList;
    }
}