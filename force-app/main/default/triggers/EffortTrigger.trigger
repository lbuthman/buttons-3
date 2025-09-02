trigger EffortTrigger on Effort__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            EffortTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}