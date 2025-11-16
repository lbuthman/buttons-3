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
        Map<Id, Account> accountByParkId = new Map<Id, Account>();
        Map<Id, Product2> productByParkId = new Map<Id, Product2>();
        for (Adventure_Park__c newPark : parks) {
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

            Asset asset = new Asset(
                Name = newPark.Name + ' Asset',
                Product2Id = productByParkId.get(newPark.Id).Id,
                AccountId = accountByParkId.get(newPark.Id).Id
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
 }