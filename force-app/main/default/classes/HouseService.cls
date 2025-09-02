public with sharing class HouseService {
    @AuraEnabled(Cacheable=true)
    public static List<House__c> getRecords() {
        try {
            // Create a list of House records from a SOQL query
            List<House__c> houses = [
                SELECT Id, Name, Address__c, State__c, City__c, Zip__c
                FROM House__c
                WITH USER_MODE
                ORDER BY CreatedDate
                LIMIT 10
            ];
            return houses;
        }
        // Code to handle exception
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
