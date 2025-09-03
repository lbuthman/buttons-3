public with sharing class UtilityService {

    public static Adventurer__c getCurrentAdventurer() {
        List<Adventurer__c> adventurers = [SELECT Id, Experience_Points__c, Story_Points__c FROM Adventurer__c WHERE OwnerId = :UserInfo.getUserId() LIMIT 1];
        Adventurer__c adventurer = (adventurers.size() == 1) ? adventurers.get(0) : null;
        if (adventurer == null) {
            Logger.warn('Adventurer not found for ' + UserInfo.getName());
            Logger.saveLog();
        }
        return adventurer;
    }

    public static Adventurer__c getMyAdventurer() {
        List<Adventurer__c> adventurers = [SELECT Id, Experience_Points__c FROM Adventurer__c WHERE Name = 'Panda Power' LIMIT 1];
        Adventurer__c adventurer = (adventurers.size() == 1) ? adventurers.get(0) : null;
        if (adventurer == null) {
            Logger.warn('Adventurer not found for ' + UserInfo.getName());
            Logger.saveLog();
        }
        return adventurer;
    }
}