public without sharing class InspirationCreditQueueable implements Queueable, Database.AllowsCallouts {

    public void execute(QueueableContext context) {
        InspirationCreditService.createInspirationCredits();
    }
}