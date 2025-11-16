trigger AdventureParkTrigger on Adventure_Park__c (before insert, before update, before delete, after insert, after update, after delete) {

    if (Trigger.isAfter && Trigger.isInsert) {
        AdventureParkTrigger_Handler.onAfterInsert(Trigger.new);
        ServiceAppointmentHandler.createOpeningAppointments(Trigger.new, null);
    }

    if (Trigger.isBefore && Trigger.isInsert) {
        AdventureParkTrigger_Handler.onBeforeInsert(Trigger.new);
    }

    if (Trigger.isBefore && Trigger.isUpdate) {
        AdventureParkTrigger_Handler.onBeforeUpdate(Trigger.newMap);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        AdventureParkTrigger_Handler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
        ServiceAppointmentHandler.createOpeningAppointments(Trigger.new, Trigger.oldMap);
    }
}