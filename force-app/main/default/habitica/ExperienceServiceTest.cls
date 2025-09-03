@IsTest
private class ExperienceServiceTest {
    @IsTest
    static void should_create_20_experiences() {

        Test.startTest();
        ExperienceService.logExperiences(20);
        Test.stopTest();

        List<Experience__c> experiences = [SELECT Id FROM Experience__c];
        Assert.areEqual(20, experiences.size());
    }

    @TestSetup
    static void testSetup() {
        Adventurer__c adventurer = new Adventurer__c(Name = 'Test Person');
        insert adventurer;
    }
}