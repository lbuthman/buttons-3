trigger AdventureParkTrigger on Adventure_Park__c (before insert, before update, before delete, after insert, after update, after delete) {

    //After Insert
    if (Trigger.isAfter && Trigger.isInsert) {

        AdventureParkTrigger_Handler.onAfterInsert(trigger.new);

        ServiceAppointmentHandler.createOpeningAppointments(trigger.new,trigger.newmap,null);
    }

    //Before Insert
    if(Trigger.isBefore && Trigger.isInsert) {
        AdventureParkTrigger_Handler.OnBeforeInsert(Trigger.new);
    }

    //Before Update
    if (Trigger.isBefore && Trigger.isUpdate) {
        AdventureParkTrigger_Handler.OnBeforeUpdate(Trigger.newMap,Trigger.oldMap);
    }

    //After Update
    if (Trigger.isAfter && Trigger.isUpdate) {

        AdventureParkTrigger_Handler.OnAfterUpdate(Trigger.newMap,Trigger.oldMap);

        ServiceAppointmentHandler.createOpeningAppointments(trigger.new,trigger.newmap,trigger.oldMap);
    }
}