public with sharing class UnderstandingReviewerService {

//    @AuraEnabled
//    public static UnderstandingsAndStats getUnderstandingsByResource(String resourceId) {
//        List<Understanding> unreviewedUnderstandings = new List<Understanding>();
//        Integer hasBeenReviewedCount = 0;
//        Integer hasNotBeenReviewedCount = 0;
//        for (Understanding__c understanding: [
//            SELECT Id, Name, Description__c, Resource__r.Name, Has_Been_Reviewed__c
//            FROM Understanding__c
//            WHERE Resource__c = :resourceId
//            ORDER BY Name
//        ]) {
//            if (understanding.Has_Been_Reviewed__c) {
//                hasBeenReviewedCount += 1;
//            }
//            else {
//                hasNotBeenReviewedCount += 1;
//                Understanding u = new Understanding(
//                    understanding.Id, understanding.Name, understanding.Description__c, understanding.Resource__r.Name
//                );
//                unreviewedUnderstandings.add(u);
//            }
//        }
//
//        return new UnderstandingsAndStats(unreviewedUnderstandings, hasBeenReviewedCount, hasNotBeenReviewedCount);
//    }

    @AuraEnabled
    public static void markUnderstandingsAsReviewed(String understandings) {
        List<Understanding> deserializedUnderstandings = (List<Understanding>) JSON.deserialize(
            understandings, List<Understanding>.class
        );
        List<Understanding__c> updatedUnderstandings = new List<Understanding__c>();
        for (Understanding understanding : deserializedUnderstandings) {
            Understanding__c updatedUnderstanding = new Understanding__c(
                Id = understanding.recordId,
                Has_Been_Reviewed__c = true
            );
            updatedUnderstandings.add(updatedUnderstanding);
        }
        try {
            update updatedUnderstandings;
        }
        catch(Exception ex) {
            Logger.debug(JSON.serializePretty(ex));
        }
    }

    public class UnderstandingsAndStats {

        public UnderstandingsAndStats(
            List<Understanding> understandings, Integer totalReviewed, Integer totalNotReviewed
        ) {
            this.understandings = understandings;
            this.totalReviewed = totalReviewed;
            this.totalNotReviewed = totalNotReviewed;
        }

        @AuraEnabled
        public List<Understanding> understandings;
        @AuraEnabled
        public Integer totalReviewed;
        @AuraEnabled
        public Integer totalNotReviewed;
    }

    public class Understanding {

        public Understanding(String recordId, String recordName, String description, String resource) {
            this.recordId = recordId;
            this.recordName = recordName;
            this.description = description;
            this.resource = resource;
        }

        @AuraEnabled
        public String recordId;
        @AuraEnabled
        public String recordName;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public String resource;
    }
}