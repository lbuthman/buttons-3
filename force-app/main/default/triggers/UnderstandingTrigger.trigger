trigger UnderstandingTrigger on Understanding__c (before insert, before update, after insert, after update) {

    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            UnderstandingTriggerHandler.handleBeforeInsert(Trigger.new);
        }

        if (Trigger.isAfter) {
            UnderstandingTriggerHandler.handleAfterInsert(Trigger.new, Trigger.oldMap);
        }
    }

    if (Trigger.isUpdate) {
        if (Trigger.isBefore) {
            UnderstandingTriggerHandler.handleBeforeUpdate(Trigger.new);
        }

        if (Trigger.isAfter) {
            UnderstandingTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}