public without sharing class ExperienceCreditBatcher
    implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful
{

    public Integer batchSize = 0;

    public List<Experience__c> start(Database.BatchableContext context) {
        return fetchFiveUncreditedExperiencesFromYesterday();
    }

    public void execute(Database.BatchableContext context, List<Experience__c> experiences) {
        this.batchSize = experiences.size();

        Integer integrationFails = createEarnedCredits(experiences.size());
        deleteCreditedExperiences(experiences, integrationFails);
    }

    public void finish(Database.BatchableContext context) {
        if (this.batchSize == 5) {
            nextBatchRunsInOneMinute();
        }
        else {
            resetCounterToZero();
        }
    }

    private static List<Experience__c> fetchFiveUncreditedExperiencesFromYesterday() {
        Adventurer__c adventurer = UtilityService.getMyAdventurer();
        return [
            SELECT Id
            FROM Experience__c
            WHERE Adventurer__c = :adventurer.Id
            AND Credited__c = FALSE
            LIMIT 5
        ];
    }

    public static Integer createEarnedCredits(Integer numberOfCredits) {
        Integer integrationFails = 0;

        Temp_Credit_Counter__c creditCounter = [SELECT Id, Current_Count__c FROM Temp_Credit_Counter__c LIMIT 1];
        Integer currentCount = (Integer) creditCounter.Current_Count__c;
        for (Integer i = 0; i < numberOfCredits ; i++) {
            currentCount += 1;
            HabiticaIntegrator.integrateTask('Credit ' + String.valueOf(currentCount));
        }
        creditCounter.Current_Count__c = currentCount;
        update creditCounter;

        if (Logger.getBufferSize() > 0) {
            integrationFails = Logger.getBufferSize();
            Logger.saveLog();
        }
        return integrationFails;
    }

    private static void deleteCreditedExperiences(List<Experience__c> experiences, Integer integrationFails) {
        List<Experience__c> creditedExperiences = new List<Experience__c>();
        for (Integer i = 0; i < experiences.size() - integrationFails; i++) {
            Experience__c experience = experiences.get(i);
            //totally unnecessary, but left in for context
            experience.Credited__c = true;
            creditedExperiences.add(experience);
        }
        delete creditedExperiences;
        Database.emptyRecycleBin(experiences);
    }

    private static void nextBatchRunsInOneMinute() {
        System.scheduleBatch(
            new ExperienceCreditBatcher(),
            'Experience Credits recursion',
            1,
            5
        );
    }

    private static void resetCounterToZero() {
        Temp_Credit_Counter__c creditCounter = [
            SELECT Id, Current_Count__c
            FROM Temp_Credit_Counter__c
            LIMIT 1
        ];
        creditCounter.Current_Count__c = 0;
        update creditCounter;
    }
}