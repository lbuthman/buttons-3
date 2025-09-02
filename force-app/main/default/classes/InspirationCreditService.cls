public without sharing class InspirationCreditService {

    public static void createInspirationCredits() {
        for (String title: getInspiringQuotes()) {
            HabiticaIntegrator.integrateTask(title);
        }
        if (Logger.getBufferSize() > 0) {
            Logger.saveLog();
        }
    }

    public static List<String> getInspiringQuotes() {
        List<String> quotes = new List<String>();
        for (Inspiring_Quote__mdt inspiringQuote: [SELECT Quote__c FROM Inspiring_Quote__mdt]) {
            quotes.add(inspiringQuote.Quote__c);
        }
        return quotes;
    }
}