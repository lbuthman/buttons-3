public with sharing class ExperienceCreditScheduler implements Schedulable {

    public void execute(SchedulableContext context) {
        Database.executeBatch(new ExperienceCreditBatcher(), 5);
    }
}