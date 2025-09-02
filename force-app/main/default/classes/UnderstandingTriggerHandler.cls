public with sharing class UnderstandingTriggerHandler {

    public static void handleBeforeInsert(List<Understanding__c> understandings) {
        for (Understanding__c understanding : understandings) {
            understanding.Source_Material__c = basicHTML();
            understanding.Distillation__c = basicHTML();
            understanding.Clarification__c = basicHTML();
        }
    }

    private static String basicHTML() {
        return '<p><span style="font-size: 18px; font-family: Lato, sans-serif; color: rgb(34, 34, 34);">placeholder</span></p>';
    }

    public static void handleAfterInsert(List<Understanding__c> understandings, Map<Id, Understanding__c> oldUnderstandings) {

    }

    public static void handleBeforeUpdate(List<Understanding__c> understandings) {

        for (Understanding__c understanding : understandings) {
            if (thisUnderstandingIsNoLongerNovel(understanding)) {
                understanding.Is_Novel__c = false;
            }
        }
    }

    private static Boolean thisUnderstandingIsNoLongerNovel(Understanding__c understanding) {
        return String.isNotBlank(understanding.Sharing__c) || understanding.Has_Been_Reviewed__c;
    }

    public static void handleAfterUpdate(List<Understanding__c> understandings, Map<Id, Understanding__c> oldUnderstandings) {

    }
}