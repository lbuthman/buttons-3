public with sharing class ServiceAppointmentHandler {

    public static void createOpeningAppointments(List<Adventure_Park__c> newParks, Map<Id, Adventure_Park__c> oldParksById) {


        Set<Id> parkIds = new Set<Id>();
        for (Adventure_Park__c newPark : newParks) {
            if (oldParksById == null) {
                continue;
            }
            Adventure_Park__c oldPark = oldParksById.get(newPark.Id);

            if (oldPark != null && (newPark.Is_Active__c != oldPark.Is_Active__c)) {
                parkIds.add(newPark.Id);
            }
        }

        Map<Id, ServiceAppointment> existingAppointByParkId = new Map<Id, ServiceAppointment>();
        for (ServiceAppointment appointment : [
            SELECT Id, Account.Adventure_Park__c, Status
            FROM ServiceAppointment
            WHERE Account.Adventure_Park__c IN :parkIds
        ]) {
            existingAppointByParkId.put(appointment.Account.Adventure_Park__c, appointment);
        }

        List<ServiceAppointment> appointsToUpdate = new List<ServiceAppointment>();
        for (Adventure_Park__c newPark : newParks) {
            if (oldParksById == null) {
                continue;
            }
            Adventure_Park__c oldPark = oldParksById.get(newPark.Id);

            if ((!newPark.Is_Active__c && oldPark.Is_Active__c) &&
                existingAppointByParkId != null &&
                !existingAppointByParkId.isEmpty() &&
                existingAppointByParkId.containsKey(newPark.Id)
            ) {
                ServiceAppointment updateRecord = existingAppointByParkId.get(newPark.Id);
                updateRecord.Status = 'None';
                appointsToUpdate.add(updateRecord);
            }

            if ((newPark.Is_Active__c && !oldPark.Is_Active__c)) {
                if (existingAppointByParkId.containsKey(newPark.Id)) {
                    ServiceAppointment updateRecord = existingAppointByParkId.get(newPark.Id);
                    updateRecord.Status = newPark.Open_Date__c == Date.today() ? 'In Progress' : 'Scheduled';
                    appointsToUpdate.add(updateRecord);
                } else {
                    //activatedParks.add(newPark);
                }
            }
        }

        if (appointsToUpdate != null && !appointsToUpdate .isEmpty()) {
            update appointsToUpdate ;
        }
    }
}