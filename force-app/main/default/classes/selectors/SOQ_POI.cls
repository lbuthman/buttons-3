public inherited sharing class SOQ_POI extends SOQL implements SOQL.Selector {
    public static SOQ_POI query() {
        return new SOQ_POI();
    }

    private SOQ_POI() {
        super(Park_Of_Interest__c.SObjectType);
        // default settings
        with(Park_Of_Interest__c.Id, Park_Of_Interest__c.Adventure_Park__c,
            Park_Of_Interest__c.Lead__c, Park_Of_Interest__c.Contact__c
        )
            .userMode()
            .withSharing();
    }

    public SOQ_POI byAdventurePark(List<String> adventureParkIds) {
        whereAre(Filter.with(Park_Of_Interest__c.Adventure_Park__c).isIn(adventureParkIds));
        return this;
    }
}