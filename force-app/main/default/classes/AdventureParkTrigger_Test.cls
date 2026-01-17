@IsTest
private class AdventureParkTrigger_Test {
    @IsTest
    static void should_create_supporting_records_when_Park_is_created() {

        Adventure_Park__c park = createPark();

        Test.startTest();
        insert park;
        Test.stopTest();

        Adventure_Park__c parkNow = [SELECT Price_Book__c FROM Adventure_Park__c WHERE Id = :park.Id];
        Assert.isNotNull(parkNow.Price_Book__c, 'Park should have a Price Book value.');

        List<Account> accounts = [SELECT Id FROM Account WHERE Adventure_Park__c = :park.Id];
        Assert.areEqual(1, accounts.size());

        List<Product2> products = [SELECT Id FROM Product2 WHERE Adventure_Park__c = :parkNow.Id];
        Assert.areEqual(1, products.size());

        List<PricebookEntry> pricebookEntries = [SELECT Id FROM PricebookEntry WHERE Product2Id IN :products];
        Assert.areEqual(2, pricebookEntries.size());

        List<Asset> assets = [SELECT Id FROM Asset WHERE Product2Id IN :products];
        Assert.areEqual(1, assets.size());
    }

    @IsTest
    static void should_create_Service_Appointment_when_new_Park_is_Active_and_has_an_Open_Date() {
        Adventure_Park__c park = createPark();
        park.Is_Active__c = true;
        park.Open_Date__c = Date.today();

        Test.startTest();
        insert park;
        Test.stopTest();

        List<ServiceAppointment> serviceAppointments = [SELECT Status FROM ServiceAppointment];
        Assert.areEqual(1, serviceAppointments.size());
        Assert.areEqual('In Progress', serviceAppointments[0].Status);
    }

    @IsTest
    static void should_prevent_deletion_of_Price_Book_on_Park() {
        Adventure_Park__c park = createPark();
        insert park;

        park = [SELECT Price_Book__c FROM Adventure_Park__c WHERE Id = :park.Id];
        Assert.isNotNull(park.Price_Book__c);

        Test.startTest();
        park.Price_Book__c = null;
        update park;
        Test.stopTest();

        park = [SELECT Price_Book__c FROM Adventure_Park__c WHERE Id = :park.Id];
        Assert.isNotNull(park.Price_Book__c);
    }

    @IsTest
    static void should_deactivate_related_POI_when_Park_is_deactivated() {
        Adventure_Park__c park = createPark();
        park.Is_Active__c = true;
        park.Open_Date__c = Date.today().addDays(-5);
        insert park;

        Lead lead = new Lead(FirstName='Test', LastName='Lead', Company = 'Acme');
        insert lead;

        Park_Of_Interest__c poi = new Park_Of_Interest__c(
            Lead__c = lead.Id,
            Adventure_Park__c = park.Id,
            Inactive__c = false
        );
        insert poi;

        Test.startTest();
        park.Open_Date__c = Date.today().addDays(-1);
        park.Is_Active__c = false;
        park.Inactivated_Date__c = Date.today();
        update park;
        Test.stopTest();

        Park_Of_Interest__c nowPOI = [SELECT Inactive__c, Inactivated_Date__c FROM Park_Of_Interest__c WHERE Id = :poi.Id];
        Assert.isTrue(nowPOI.Inactive__c);
        Assert.areEqual(park.Inactivated_Date__c, nowPOI.Inactivated_Date__c);
    }

    private static Adventure_Park__c createPark() {
        return new Adventure_Park__c(
            Name = 'Test Park',
            Park_Number__c = '123123123123'
        );
    }

    @TestSetup
    static void setup() {
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
    }
}