trigger ParkOfInterestTrigger on Park_Of_Interest__c (before insert, before update, before delete,
    after insert, after update, after delete, after undelete) {

    ParkOfInterestTrigger_Handler handler = new ParkOfInterestTrigger_Handler();

    if(Trigger.isBefore && Trigger.isInsert) {
        handler.onBeforeInsert(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isInsert && ParkOfInterestTrigger_Handler.avoidRecursion == false){
        handler.onAfterInsert(Trigger.new, Trigger.newMap, Trigger.oldMap);
    }

    if(Trigger.isBefore && Trigger.isUpdate) {
        handler.onBeforeUpdate(Trigger.newMap, Trigger.oldMap);
    }

    if(Trigger.isAfter && Trigger.isUpdate && ParkOfInterestTrigger_Handler.avoidRecursionUpdate == false) {
        handler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
    }

    if(Trigger.isAfter && Trigger.isDelete && ParkOfInterestTrigger_Handler.avoidRecursionDelete == false){
        handler.onAfterDelete(Trigger.old);
    }

    if(Trigger.isAfter && Trigger.isUndelete){
        handler.onAfterUnDelete(Trigger.new);
    }
}
