/**
 * Created by lbuthman on 2/3/26.
 */

public inherited sharing class SOQL_AdventurePark extends SOQL implements SOQL.Selector {
    public static SOQL_AdventurePark query() {
        return new SOQL_AdventurePark();
    }

    private SOQL_AdventurePark() {
        super(Adventure_Park__c.SObjectType);
        // default settings
        with(Adventure_Park__c.Id, Adventure_Park__c.Name)
            .userMode()
            .withSharing();
    }
}