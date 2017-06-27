public with sharing class UserDAO {
    public static User getCurrentUser () {
        return [select Id, Kostenplaats__c from User where Id =: UserInfo.getUserId()];
    }
    public static User getUserById (Id userId) {
        return [select Id, Kostenplaats__c from User where Id =: UserId];
    }
}