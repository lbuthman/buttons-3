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

            //todo: move this logic into a Scheduled Batch job
//            if (newPark.Open_Date__c >= Date.today() && newPark.Is_Active__c == false) {
//                newPark.Is_Active__c = true;
//            }

            //todo: move this logic into a Scheduled Batch job
//            if (newPark.Is_Active__c == false && newPark.Open_Date__c < Date.today()) {
//                newPark.Inactivated_Date__c = Date.today();
//            }
        }
    }

    public static void onAfterUpdate(Map<Id, Adventure_Park__c> newParksById, Map<Id, Adventure_Park__c> oldParksById) {
        Map<Id, Date> deactivatedDatesByParkId = new Map<Id, Date>();
        for (Id parkId : newParksById.keySet()) {
            Adventure_Park__c newPark = newParksById.get(parkId);
            Adventure_Park__c oldPark = oldParksById.get(parkId);
            if (newPark.Open_Date__c < Date.today() &&
                newPark.Is_Active__c != oldPark.Is_Active__c &&
                !newPark.Is_Active__c &&
                newPark.Inactivated_Date__c != null
            ) {
                deactivatedDatesByParkId.put(parkId, newPark.Inactivated_Date__c);
            }
        }

        if (!deactivatedDatesByParkId.isEmpty()) {
            AdventureParkTrigger_Helper.deactivateRelatedPOI(deactivatedDatesByParkId);
        }
    }
}