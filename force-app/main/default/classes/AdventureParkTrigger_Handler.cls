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
        Map<Id, Account> accountByParkId = new Map<Id, Account>();
        Map<Id, Product2> productByParkId = new Map<Id, Product2>();
        for (Adventure_Park__c newPark : newParks) {
            Account account = new Account(
                Name = newPark.Name + ' Account',
                Adventure_Park__c = newPark.Id,
                AccountSource = 'Automation'
            );
            accountByParkId.put(newPark.Id, account);

            Product2 product = new Product2(
                Name = newPark.Name + ' Product',
                Adventure_Park__c = newPark.Id,
                IsActive = true
            );
            productByParkId.put(newPark.Id, product);
        }

        if (!accountByParkId.isEmpty()) {
            insert accountByParkId.values();
        }

        if (!productByParkId.isEmpty()) {
            insert productByParkId.values();
        }

        Pricebook2 standardPriceBook = [SELECT Id, IsActive FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1];
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        List<Asset> assets = new List<Asset>();
        for (Adventure_Park__c park : newParks) {
            // Create a Pricebook Entry in the Standard Price Book
            PricebookEntry standardPBE = new PricebookEntry(
                Pricebook2Id = standardPriceBook.Id,
                Product2Id = productByParkId.get(park.Id).Id,
                UnitPrice = park.Admission_Price__c,
                IsActive = true
            );
            pricebookEntries.add(standardPBE);

            // Create a Pricebook Entry in the Custom Price Book
            PricebookEntry customPBE = new PricebookEntry(
                Pricebook2Id = park.Price_Book__c,
                Product2Id = productByParkId.get(park.Id).Id,
                UnitPrice = park.Admission_Price__c,
                IsActive = true
            );
            pricebookEntries.add(customPBE);

            Asset asset = new Asset(
                Name = park.Name + ' Asset',
                Product2Id = productByParkId.get(park.Id).Id,
                AccountId = accountByParkId.get(park.Id).Id
            );
            assets.add(asset);
        }

        if (!pricebookEntries.isEmpty()) {
            insert pricebookEntries;
        }

        if (!assets.isEmpty()) {
            insert assets;
        }
    }

    public static void onBeforeUpdate(Map<Id, Adventure_Park__c> newMap) {

        List<Adventure_Park__c> parksThatNeedPriceBooks = new List<Adventure_Park__c>();
        for (Adventure_Park__c park : newMap.values()) {
            if (park.Open_Date__c >= Date.today() && park.Is_Active__c == false) {
                park.Is_Active__c = true;
            }

            if (park.Price_Book__c == null) {
                parksThatNeedPriceBooks.add(park);
            }

            if (park.Is_Active__c == false && park.Open_Date__c < Date.today()) {
                park.Inactivated_Date__c = Date.today();
            }
        }

        if (!parksThatNeedPriceBooks.isEmpty()) {
            AdventureParkTrigger_Helper.setPriceBooks(parksThatNeedPriceBooks);
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