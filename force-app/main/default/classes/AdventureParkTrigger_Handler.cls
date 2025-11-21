public with sharing class AdventureParkTrigger_Handler {

    public static void onBeforeInsert(List<Adventure_Park__c> parks) {

        List<Adventure_Park__c> parksThatNeedPriceBooks = new List<Adventure_Park__c>();
        for (Adventure_Park__c newPark: parks) {
            if (newPark.Price_Book__c == null) {
                parksThatNeedPriceBooks.add(newPark);
            }
        }

        if (!parksThatNeedPriceBooks.isEmpty()) {
            AdventureParkTrigger_Helper.setPriceBooks(parksThatNeedPriceBooks);
        }
    }

    public static void onAfterInsert(List<Adventure_Park__c> newParks) {
        if (!newParks.isEmpty()) {
            AdventureParkTrigger_Helper.createRelatedData(newParks);
        }
    }

    public static void onBeforeUpdate(Map<Id, Adventure_Park__c> newMap, Map<Id, Adventure_Park__c> oldParks) {

        for (Adventure_Park__c newPark : newMap.values()) {
            Adventure_Park__c oldPark = oldParks.get(newPark.Id);

            if (newPark.Price_Book__c == null && oldPark.Price_Book__c != null) {
                newPark.Price_Book__c = oldPark.Price_Book__c;
            }

            if (newPark.Open_Date__c >= Date.today() && newPark.Is_Active__c == false) {
                newPark.Is_Active__c = true;
            }

            if (newPark.Is_Active__c == false && newPark.Open_Date__c < Date.today()) {
                newPark.Inactivated_Date__c = Date.today();
            }
        }
    }

    public static void onAfterUpdate(Map<Id, Adventure_Park__c> newMap, Map<Id, Adventure_Park__c> oldMap) {
        Set<Id> parksIds = new Set<Id>();
        for (Id parkId : newMap.keySet()) {
            if (newMap.get(parkId).Open_Date__c < Date.today() &&
                newMap.get(parkId).Is_Active__c != oldMap.get(parkId).Is_Active__c &&
                !newMap.get(parkId).Is_Active__c &&
                newMap.get(parkId).Inactivated_Date__c != null
            ) {
                parksIds.add(parkId);
            }
        }

        if (parksIds != null && !parksIds.isEmpty()) {
            List<Park_Of_Interest__c> parkOfInterests = new List<Park_Of_Interest__c>();
            for (Park_Of_Interest__c parkOfInterest : [
                SELECT Inactive__c, Adventure_Park__c
                FROM Park_Of_Interest__c
                WHERE Adventure_Park__c IN :oldMap.keySet()
            ]) {
                parkOfInterest.Inactive__c = true;
                parkOfInterest.Inactivated_Date__c = newMap.get(parkOfInterest.Adventure_Park__c).Inactivated_Date__c;
                parkOfInterests.add(parkOfInterest);
            }
            update parkOfInterests;
        }
    }
}