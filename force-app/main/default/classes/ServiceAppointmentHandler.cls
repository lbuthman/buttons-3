public with sharing class ServiceAppointmentHandler {

    public static void createOpeningAppointments(List<Adventure_Park__c> newParks, Map<Id, Adventure_Park__c> oldParksById) {

        List<Adventure_Park__c> activeParks = new List<Adventure_Park__c>();
        List<Adventure_Park__c> inactiveParks = new List<Adventure_Park__c>();
        for (Adventure_Park__c newPark : newParks) {
            Adventure_Park__c oldPark = oldParksById.get(newPark.Id);

            if (newPark.Is_Active__c != oldPark.Is_Active__c) {
                if (newPark.Is_Active__c) {
                    activeParks.add(newPark);
                } else {
                    inactiveParks.add(newPark);
                }
            }
        }

        if (!activeParks.isEmpty()) {
            AdventureParkTrigger_Helper.createServiceAppointments(activeParks);
        }

        if (!inactiveParks.isEmpty()) {
            deactivateRelatedServiceAppointments(inactiveParks);
        }
    }

    public static void deactivateRelatedServiceAppointments(List<Adventure_Park__c> parks) {
        List<ServiceAppointment> appointmentsToUpdate = new List<ServiceAppointment>();
        for (ServiceAppointment appointment : [
            SELECT Id, Account.Adventure_Park__c, Status
            FROM ServiceAppointment
            WHERE Account.Adventure_Park__c IN :parks
        ]) {
            appointment.Status = 'None';
            appointmentsToUpdate.add(appointment);
        }
        update appointmentsToUpdate;
    }
}