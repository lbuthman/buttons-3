public without sharing class CreditService {

    // this is used ad-hoc via anon apex
    public static void createBonusCredits(Integer numberOfCredits) {
        for (Integer i = 0; i < numberOfCredits; i++) {
            HabiticaIntegrator.integrateTask('Credit ' + (i + 1));
        }
    }
}