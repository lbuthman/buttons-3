@IsTest
private class ServiceAppointmentHandler_Test {


    @IsTest
    static void should_create_Service_Appointment_when_existing_Park_with_an_Open_Date_becomes_Active() {
        Adventure_Park__c park = createPark();
        park.Open_Date__c = Date.today().addDays(-1);
        insert park;

        Test.startTest();
        park.Is_Active__c = true;
        update park;
        Test.stopTest();

        List<ServiceAppointment> serviceAppointments = [SELECT Id, Status FROM ServiceAppointment];
        Assert.areEqual(1, serviceAppointments.size());
        Assert.areEqual('Scheduled', serviceAppointments[0].Status);
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