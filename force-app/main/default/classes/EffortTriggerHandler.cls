public with sharing class EffortTriggerHandler {

    public static void
    onAfterUpdate(List<Effort__c> newEfforts, Map<Id, Effort__c> oldEfforts) {

        Boolean shouldAwardCredits = false;
        for (Effort__c newEffort : newEfforts) {
            Effort__c oldEffort = oldEfforts.get(newEffort.Id);

            if (theEffortHasBeenCompleted(newEffort, oldEffort)) {
                //HabiticaIntegrator.getGoldCount();
                //https://salesforce.stackexchange.com/questions/269035/callout-from-trigger-is-not-supported
                // - to do this, getGoldCount() would need to be @Future
                // - but my use case was an external package that is already @Future
                // - this is a good thing to demonstrate and my eventual workaround .. what are some better ones?
                // - by presenting one and then asking the community, the best one appears
                // - it could be fun to talk about one, two, or a few
                shouldAwardCredits = true;
            }
        }

        if (shouldAwardCredits) {
            Logger.debug('Credit is being awarded.');
            awardInspirationCredits();
        }
    }

    private static void awardInspirationCredits() {
        InspirationCreditQueueable queueable = new InspirationCreditQueueable();
        System.enqueueJob(queueable);
    }

    public static Boolean theEffortHasBeenCompleted(Effort__c newEffort, Effort__c oldEffort) {
        return newEffort.End_Time__c != null && oldEffort.End_Time__c == null;
    }
}
