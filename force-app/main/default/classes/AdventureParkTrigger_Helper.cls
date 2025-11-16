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
}