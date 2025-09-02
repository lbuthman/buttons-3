public with sharing class ExperienceService {

    public static void logStoryPoints(Integer storyPoints) {
        Adventurer__c adventurer = UtilityService.getCurrentAdventurer();
        adventurer.Story_Points__c += storyPoints;
        System.debug('adventurer.Story_Points__c=' + adventurer.Story_Points__c);

        List<Experience__c> experiences = new List<Experience__c>();
        for (Integer i=0 ; i < storyPoints; i++) {
            Experience__c experience = new Experience__c(
                Adventurer__c = adventurer.Id
            );
            experiences.add(experience);
        }

        insert experiences;
        update adventurer;
    }

    //created by the user, experiences can be measured in min, sec, hours, tasks accomplish, production, progress, etc.
    public static void logExperiences(Decimal minutesSpent) {
        Adventurer__c adventurer = UtilityService.getCurrentAdventurer();
        adventurer.Experience_Points__c += minutesSpent;

        Integer credits = calculateCredits(minutesSpent);

        List<Experience__c> experiences = new List<Experience__c>();
        for (Integer i=0 ; i < credits; i++) {
            Experience__c experience = new Experience__c(
                Adventurer__c = adventurer.Id
            );
            experiences.add(experience);
        }

        insert experiences;
        update adventurer;
    }

    private static Integer calculateCredits(Decimal duration) {
        //For each minute, 2/3 of a credit is earned and rounded up, with a minimum of 1.
        Integer total = Math.round((.6 * duration));
        return total > 0 ? total : 1;
    }

    public static Effort__c createEffort(String context) {
        if (findIncompleteEffort(true) != null) {
            throw new CommittedEffortNeedsCompletionException();
        }
        context = String.isNotBlank(context) ? context : 'No context.';
        Effort__c effort = new Effort__c(
            Context__c = context,
            Start_Time__c = Datetime.now()
        );
        insert effort;
        return effort;
    }

    public class CommittedEffortNeedsCompletionException extends Exception {}

    @Future
    public static void completeEffort(String context) {
        Effort__c effortToComplete = findIncompleteEffort(false);
        if (effortToComplete == null) {
            Logger.debug('tried to complete, but no existing effort was found.');
            effortToComplete = new Effort__c();
            effortToComplete.Start_Time__c = Datetime.now();
            effortToComplete.Context__c = String.isNotBlank(context) ? context : 'Created by Automation'; //todo: rename
            effortToComplete.End_Time__c = Datetime.now();
            insert effortToComplete;
        }
        else {
            Logger.debug('completing effort now.');
            effortToComplete.End_Time__c = Datetime.now();
            effortToComplete.Context__c = String.isNotBlank(context) ? context : effortToComplete.Context__c;
            update effortToComplete;
        }
    }

    public static Effort__c findIncompleteEffort(Boolean shouldNotBeFound) {
        Effort__c foundEffort = null;
        List<Effort__c> efforts = [
            SELECT Id
            FROM Effort__c
            WHERE Start_Time__c != NULL
            AND End_Time__c = NULL
        ];
        System.debug('efforts=' + efforts);
        if (efforts.size() > 1) {
            foundEffort = efforts.get(0);
            Logger.warn('There should only be one active Effort.\n\n' +
                UserInfo.getName() + ' has '  + efforts.size() + ' active efforts.');
            Logger.saveLog();
        }
        else if (efforts.size() > 0 && shouldNotBeFound) {
            foundEffort = efforts.get(0);
            Logger.info('Active effort found during create request.');
            Logger.saveLog();
        }
        else if (efforts.size() == 1) {
            foundEffort = efforts.get(0);
        }

        return foundEffort;
    }

}