public without sharing class SearchController {
    public SearchController() {

    }

    @RemoteAction
    public static List<User> getOrgUser(String userName){
        userName = '%' + userName + '%';
        return [SELECT Id, Name, Email, IsActive, ProfileId, SmallPhotoUrl  
                FROM User 
                WHERE IsActive = true 
                  AND Name LIKE: userName];
    }
}