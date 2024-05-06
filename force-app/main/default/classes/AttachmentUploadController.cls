public without sharing class AttachmentUploadController {
    @RemoteAction
    public static String uploadFileAndLinkTo(String parentId, String recordId, String fileName, String dataString) {
        ContentVersion content;
        if (String.isEmpty(recordId)) {
            content = new ContentVersion(Title=fileName, VersionData=EncodingUtil.base64Decode(dataString), PathOnClient='/' + fileName);
            insert content;
            content = [select id, ContentDocumentId from ContentVersion WHERE Id =: content.Id];
            ContentDocumentLink link = new ContentDocumentLink(ContentDocumentId=content.ContentDocumentId, LinkedEntityId=parentId, ShareType='V', Visibility='AllUsers');
            insert link;
        } else {
            ContentVersion partialContent = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Id =: recordId];
            String currentData = EncodingUtil.base64Encode(partialContent.VersionData);
            content = new ContentVersion(Title=fileName, PathOnClient='/' + fileName, ContentDocumentId=partialContent.ContentDocumentId);
            content.VersionData = EncodingUtil.base64Decode(currentData + dataString);
            insert content;
        }
        return content.Id;
    }
}