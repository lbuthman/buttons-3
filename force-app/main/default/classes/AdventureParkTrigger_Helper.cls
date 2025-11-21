public with sharing class AdventureParkTrigger_Helper {

    public static void setPriceBooks(List<Adventure_Park__c> parks) {
        Map<Id, Pricebook2> priceBookByParkId = createPriceBooksFromParks(parks);
        for (Adventure_Park__c park : parks) {
            Pricebook2 priceBook = priceBookByParkId.get(park.Id);
            if (priceBook != null) {
                park.Price_Book__c = priceBook.Id;
            }
        }
    }

    private static Map<Id, Pricebook2> createPriceBooksFromParks(List<Adventure_Park__c> parks) {
        Map<Id, Pricebook2> priceBookByParkId = new Map<Id, Pricebook2>();
        for (Adventure_Park__c park : parks) {
            Pricebook2 priceBook = new Pricebook2(
                Name = park.Name,
                IsActive = true
            );
            priceBookByParkId.put(park.Id, priceBook);
        }
        insert priceBookByParkId.values();
        return priceBookByParkId;
    }

    public static void createRelatedData(List<Adventure_Park__c> parks) {
        Map<Id, Account> accountByParkId = createAccounts(parks);
        Map<Id, Product2> productByParkId = createProducts(parks);

        createPBEs(parks, productByParkId);
        createAssets(parks, productByParkId, accountByParkId);
    }

    private static Map<Id, Account> createAccounts(List<Adventure_Park__c> parks) {
        Map<Id, Account> accountByParkId = new Map<Id, Account>();
        for (Adventure_Park__c newPark : parks) {
            Account account = new Account(
                Name = newPark.Name + ' Account',
                Adventure_Park__c = newPark.Id,
                AccountSource = 'Automation'
            );
            accountByParkId.put(newPark.Id, account);
        }

        if (!accountByParkId.isEmpty()) {
            insert accountByParkId.values();
        }
        return accountByParkId;
    }

    private static Map<Id, Product2> createProducts(List<Adventure_Park__c> parks) {
        Map<Id, Product2> productByParkId = new Map<Id, Product2>();
        for (Adventure_Park__c newPark : parks) {
            Product2 product = new Product2(
                Name = newPark.Name + ' Product',
                Adventure_Park__c = newPark.Id,
                IsActive = true
            );
            productByParkId.put(newPark.Id, product);
        }

        if (!productByParkId.isEmpty()) {
            insert productByParkId.values();
        }
        return productByParkId;
    }

    private static void createPBEs(List<Adventure_Park__c> parks, Map<Id, Product2> productByParkId) {
        Pricebook2 standardPriceBook = [SELECT Id, IsActive FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1];
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for (Adventure_Park__c newPark : parks) {
            PricebookEntry standardPBE = new PricebookEntry(
                Pricebook2Id = standardPriceBook.Id,
                Product2Id = productByParkId.get(newPark.Id).Id,
                UnitPrice = newPark.Admission_Price__c,
                IsActive = true
            );
            pricebookEntries.add(standardPBE);

            PricebookEntry customPBE = new PricebookEntry(
                Pricebook2Id = newPark.Price_Book__c,
                Product2Id = productByParkId.get(newPark.Id).Id,
                UnitPrice = newPark.Admission_Price__c,
                IsActive = true
            );
            pricebookEntries.add(customPBE);
        }

        if (!pricebookEntries.isEmpty()) {
            insert pricebookEntries;
        }
    }

    private static void createAssets(List<Adventure_Park__c> parks, Map<Id, Product2> productByParkId, Map<Id, Account> accountByParkId) {
        List<Asset> assets = new List<Asset>();
        for (Adventure_Park__c newPark : parks) {

            Asset asset = new Asset(
                Name = newPark.Name + ' Asset',
                Product2Id = productByParkId.get(newPark.Id).Id,
                AccountId = accountByParkId.get(newPark.Id).Id
            );
            assets.add(asset);
        }

        if (!assets.isEmpty()) {
            insert assets;
        }
    }

    public static void deactivateRelatedPOI(Map<Id, Date> deactivatedDatesByParkId) {
        List<Park_Of_Interest__c> poiListToUpdate = new List<Park_Of_Interest__c>();
        for (Park_Of_Interest__c poi : [
            SELECT Inactive__c, Adventure_Park__c
            FROM Park_Of_Interest__c
            WHERE Adventure_Park__c IN :deactivatedDatesByParkId.keySet()
            AND Inactive__c = FALSE
        ]) {
            poi.Inactive__c = true;
            poi.Inactivated_Date__c = deactivatedDatesByParkId.get(poi.Adventure_Park__c);
            poiListToUpdate.add(poi);
        }
        update poiListToUpdate;
    }
}