@IsTest
private with sharing class TriggerFrameworkTester {

    @IsTest
    static void should_trigger_the_trigger() {
        Opportunity opportunity = new Opportunity(
            Name = 'Wanna Test Me',
            StageName = 'Discovery',
            CloseDate = Date.today().addDays(40)
        );
        insert opportunity;

        opportunity.Amount = 5000;
        upsert opportunity;
    }
}
