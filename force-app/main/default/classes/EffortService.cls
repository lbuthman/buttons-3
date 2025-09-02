public with sharing class EffortService {

    @AuraEnabled
    public static Effort__c createEffort(String challengeId) {
        Effort__c effort = new Effort__c(
            Challenge__c = challengeId,
            Start_Time__c = Datetime.now()
        );
        insert effort;
        return effort;
    }

    @AuraEnabled
    public static Boolean endEffort(String effortDataString) {
        System.debug('starting to end effort');
        try {
            EffortData effortData = (EffortData) JSON.deserialize(effortDataString, EffortData.class);
            System.debug('effortData -> ' + effortData);
            Effort__c effort = new Effort__c(
                Id = effortData.recordId,
                Context__c = effortData.context,
                Temp_Notes__c = effortData.tempNotes,
                End_Time__c = Datetime.now()
            );
            update effort;

            createExperienceCredits(effort.Id);
            return true;
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
            System.debug(ex);
            return false;
        }
    }

    @Future
    private static void createExperienceCredits(Id effortId) {
        Effort__c effort = [SELECT Time_Elapsed__c, Challenge__r.Journey__r.Adventurer__c FROM Effort__c WHERE Id = :effortId];
        ExperienceService.logExperiences(effort.Time_Elapsed__c);
    }


    public class EffortData {
        @AuraEnabled
        public String recordId;
        @AuraEnabled
        public String context;
        @AuraEnabled
        public String tempNotes;
    }
}