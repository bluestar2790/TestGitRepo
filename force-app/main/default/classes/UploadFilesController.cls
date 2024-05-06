public without sharing class UploadFilesController {
    public UploadFilesController() {

    }

    /**
    * 文件分块保存
    * @param filestr 上传的文件内容
    * @param filestrId 文件版本id
    * @return Map<String, Object> 调用是否成功信息及文件版本id
    */
    @RemoteAction
    public static Map<String, Object> uploadFileAction(String filestr, String filestrId) {
        Map<String, Object> resultMap = new Map<String, Object>();
        try {
            if(String.isNotBlank(fileStr)){
                Map<String, Object> myfileMap = CreatePartDocument(fileStr, filestrId);
                if(myfileMap.get('status') == 'success') {
                    resultMap.put('status', 'success');
                    resultMap.put('Id', myfileMap.get('recordId'));
                } else {
                    resultMap.put('status', 'error');
                    resultMap.put('status', myfileMap.get('Msg'));
                }
            } else {
                resultMap.put('status', 'error');
                resultMap.put('Msg', '文件内容为空');
            }
        } catch(Exception e) {
            resultMap.put('status', 'error');
            resultMap.put('Msg', e.getMessage());
        }
        return resultMap;
    }

    /**
    * 文件分块保存
    * @param filestr 上传的文件内容
    * @param filestrId 文件版本id
    * @return Map<String, Object> 调用是否成功信息及文件版本id
    */
    public static Map<String, Object> CreatePartDocument(String fileStr, String filestrId){
        //返回的信息
        Map<String, Object> resultMap = new Map<String, Object>();
        SavePoint sp = Database.setSavepoint();
        try {
        	System.debug(LoggingLevel.INFO, '*** filestrId: ' + filestrId);
            //文件内容
            Object fileObj = JSON.deserializeUntyped(fileStr); 
            Map<String,Object> attachmentobj = (Map<String,Object>)fileObj;
            String fileName = String.valueOf(attachmentobj.get('name'));
            //存放上一版本信息
            List<ContentVersion> lastContVerFile = new List<ContentVersion>();
            ContentVersion contVerFile = new ContentVersion();
            //如果文件版本不为空
            if(String.isNotBlank(filestrId)) {
                //根据文件版本id获取文件版本内容
                lastContVerFile = getDocumentVersion(filestrId);
                System.debug(LoggingLevel.INFO, '*** lastContVerFile: ' + lastContVerFile);
            }
            //如果存在上一版本，则叠加内容，关联文件id
            if(lastContVerFile.size() > 0) {
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

            //插入文件版本
            insert contVerFile;

            resultMap.put('status', 'success');
            resultMap.put('recordId', contVerFile.Id);

        }
        catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** error.getMessage: ' + e.getMessage());
            resultMap.put('status', 'error');
            resultMap.put('Msg', e.getMessage());
            Database.rollback(sp);
        }
        return resultMap;
    }
    /**
    * 根据文件版本id获取文件版本内容
    * @param filestrId 文件版本id
    * @return List<ContentVersion> 文件版本内容
    */
    public static List<ContentVersion> getDocumentVersion(String filestrId) {
        List<ContentVersion> contverList = [SELECT id, ContentDocumentId, VersionData, Title, 
                                                   ContentLocation, PathOnClient 
                                             FROM ContentVersion 
                                             WHERE id = :filestrId];
        System.debug(LoggingLevel.INFO, '*** contverList: ' + contverList);
        return contverList;
    }

}