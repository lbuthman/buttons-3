public without sharing class ManaBlaster implements Schedulable {

    public void execute(SchedulableContext context) {
        Boolean success = HabiticaIntegrator.useMana();
        if (success) {
            scheduleNextCallout();
        }
        else {
            sendCompletionEmail();
        }
    }

    private static void scheduleNextCallout() {
        ManaBlaster manaBlaster = new ManaBlaster();
        String schedule = '20 30 8 10 2 ?';
        String jobID = System.schedule('Mana Blaster', schedule, manaBlaster);
        Logger.debug('jobID -> ' + jobID);
    }

    public static void sendCompletionEmail() {
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'lbuthman@gmail.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Apex Sharing Recalculation ');
        mail.setPlainTextBody('The batch Apex job processed batches with ' + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}