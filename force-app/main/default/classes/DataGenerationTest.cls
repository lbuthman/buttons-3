@IsTest
private class DataGenerationTest {
    @TestSetup
    static void dataCreation() {
        Account account = TestFactory.getAccount('Muddy Waters Inc.', true);
        TestFactory.getContact(account.Id, 'Muddy', 'Waters', true);
        Opportunity opp = new Opportunity();
        opp.Name = 'Long lost record';
        opp.AccountId = account.Id;
        opp.CloseDate = Date.today().addDays(14);
        opp.StageName = 'Prospecting';
        insert opp;
    }
    @IsTest
    static void testBruteForceAccountCreation() {
        List<Account> accounts = new List<Account>();
        Test.startTest();
        accounts = [SELECT Id FROM Account];
        Test.stopTest();
        Assert.isTrue(accounts.size() > 0, 'Was expecting to find at least one account created on the Test Setup');
    }
    @IsTest
    static void testUseTestFactoryToCreateAccountsWithContacts() {
        List<Account> accounts;
        List<Contact> contacts;
        TestFactory.generateAccountWithContacts(5);
        Test.startTest();
        accounts = [SELECT Id FROM Account];
        contacts = [SELECT Id FROM Contact];
        Test.stopTest();
        Assert.isTrue(accounts.size() > 0, 'Was expecting to find at least one account created');
        Assert.areEqual(contacts.size(), 6, 'Was expecting to find 6 contacts');
        Assert.areNotEqual(accounts.size(), contacts.size(), 'Was expecting there to be a different number of account and contacts');
    }
    @IsTest
    static void testAtTestSetupMethodsRule() {
        List<Opportunity> opportunity = [SELECT Id, AccountId FROM Opportunity];
        Assert.areEqual(1, opportunity.size(), 'Expected test to find a single Opp');
    }
}