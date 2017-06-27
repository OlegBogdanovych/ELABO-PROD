public with sharing class UserUtil {
    public UserUtil() {
        
    }
    public static void entry(TriggerParams triggerParams) {
        List<User> triggerNew = (List<User>)triggerParams.triggerNew;
        List<User> triggerOld = (List<User>)triggerParams.triggerOld;
        Map<Id, User> oldMap = (Map<Id, User>)triggerParams.oldMap;
        Map<Id, User> newMap = (Map<Id, User>)triggerParams.newMap;


        if((triggerParams.isBefore && triggerParams.isUpdate) || (triggerParams.isAfter && triggerParams.isInsert)){
            if ((!System.isBatch() && !System.isFuture()) || Test.isRunningTest()&& !System.isFuture()) {
                setGeolocation(newMap.keySet());
            }           

        }
        if(triggerParams.isAfter) {
            if(triggerParams.isUpdate || triggerParams.isInsert) {
                addUserToGroup(triggerNew);         
            }
            if(triggerParams.isUpdate) {
                updateUser(triggerNew,oldMap);              
            }
        }
    }
    
    public static void addUserToGroup(List<User> triggerNew) {
        List<Profile> profiles = [Select Id,Name from Profile where Name='Professional intern' limit 1];
        Map<Id, Profile> prs = new Map<Id, Profile> ([Select Id,Name from Profile where Name='Chatter Free User' or Name = 'Chatter Moderator User' limit 1]);
        Map<Id,Profile> profilesById = new Map<Id,Profile>(profiles);
        List<Group> groups = [select id from Group where DeveloperName='access_to_dossiers'];
        List<GroupMember> groupMembersToSelect = [select Id, UserOrGroupId from GroupMember where GroupId =: groups[0].Id];
        Map<Id,GroupMember> idGroupMember = new Map<Id,GroupMember>();
        List<GroupMember> memersToDelete = new List<GroupMember>();
        for (GroupMember grpMember : groupMembersToSelect) {
            idGroupMember.put(grpmember.UserOrGroupId, grpMember);
        }
        List<GroupMember> groupMembers = new List<GroupMember>();
        if(groups != null && !groups.isEmpty()){
            for(User user : triggerNew) {
                if(!profilesById.containsKey(user.ProfileId) && !idGroupMember.containsKey(user.id) && !prs.containsKey(user.ProfileId)){
                    GroupMember grpMr = new GroupMember();
                    grpMr.UserOrGroupId = user.Id;
                    grpMr.GroupId = groups[0].Id;
                    groupMembers.add(grpMr);
                }
                else if(profilesById.containsKey(user.ProfileId) && idGroupMember.containsKey(user.id)) {   
                    memersToDelete.add(idGroupMember.get(user.id));
                }
            }
            System.debug(groupMembers);
            if (!Test.isRunningTest()){
                insert groupMembers; 
                delete memersToDelete;
            }
        }
    }

    public static void updateUser(List<User> triggerNew,Map<Id, User> oldMap) {
        Set<id> usersIdsOfInernProfile = new Set<id>();
        List<Profile> profiles = [Select Id,Name from Profile where Name='Professional intern' limit 1];
        if(!profiles.isEmpty() && profiles != null){
            Id profileId = profiles[0].Id;
            for(User user : triggerNew) {
                Id currentProfileId = user.profileId;
                if(user.profileId != oldMap.get(user.id).profileId) {
                    if(currentProfileId == profileId) {
                        usersIdsOfInernProfile.add(user.id);
                    }
                }   
            }
            if(!usersIdsOfInernProfile.isEmpty()) {
                callDossierUtil(usersIdsOfInernProfile);
            }
        }
    }    

    @future(Callout=true)
    public static void setGeolocation (Set<Id> userIds) {
        List <User> users = [select Id, Address, City, Street, Country, PostalCode, State from User where id in: userIds];
        for (User user: users) {
            String address = '';
            if (user.Street != null)
                address += user.Street +', ';
            if (user.City != null)
                address += user.City +', ';
            if (user.State != null)
                address += user.State +' ';
            if (user.PostalCode != null)
                address += user.PostalCode +', ';
            if (user.Country != null)
                address += user.Country;

            address = EncodingUtil.urlEncode(address, 'UTF-8');
            System.debug('address ' + address);
            try{
                List <Decimal> coordinates = GeolocationCallout.getLocation(address);
                if (coordinates.size()>1){
                    user.Latitude = coordinates.get(0);
                    user.Longitude = coordinates.get(1);
                    user.Geolocatie__Latitude__s = coordinates.get(0);
                    user.Geolocatie__Longitude__s = coordinates.get(1);
                }
                System.debug(user);
                update user;
            } catch (Exception e) {
                System.debug(e.getMessage());
                
            }
        }

    }

        @future(callout=true)
    public static void callDossierUtil(Set<Id> usersIdsOfInernProfile) {
        Map<Id, Dossier__c> dossierWithProffesional = new Map <Id, Dossier__c>([select handler__c, Id, OwnerId From Dossier__c where handler__c IN:  usersIdsOfInernProfile]);
        System.debug('dossierWithProffesional future: ' + dossierWithProffesional);
        DossierUtil.apexSharingInsert(dossierWithProffesional.keyset(),null);
    }
}