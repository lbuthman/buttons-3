public with sharing class ServiceAppointmentHandler {

    public static void createOpeningAppointments(List<Adventure_Park__c> newParks, Map<Id, Adventure_Park__c> oldParksById) {
        Map<Id, Account> accountByParkId = new Map<Id, Account>();
        for (Account account : [SELECT Adventure_Park__c FROM Account WHERE Adventure_Park__c IN :newParks]) {
            accountByParkId.put(account.Adventure_Park__c, account);
        }
        Map<Id, Asset> assetsByAccountId = new Map<Id, Asset>();
        for (Asset asset : [SELECT AccountId FROM Asset WHERE AccountId IN :accountByParkId.values()]) {
            assetsByAccountId.put(asset.AccountId, asset);
        }

        List<ServiceAppointment> appointsToInsert = new List<ServiceAppointment>();
        Set<Id> parkIds = new Set<Id>();
        for (Adventure_Park__c newPark : newParks) {
            Adventure_Park__c oldPark = oldParksById.get(newPark.Id);

            if (newPark.Is_Active__c && Trigger.isInsert) {
                Account account = accountByParkId.get(newPark.Id);
                appointsToInsert.add(createServiceAppointment(assetsByAccountId, account, newPark));
            }

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
            Adventure_Park__c oldRecord = oldParksById.get(newPark.Id);

            if ((!newPark.Is_Active__c && oldRecord.Is_Active__c) &&
                existingAppointByParkId != null &&
                !existingAppointByParkId.isEmpty() &&
                existingAppointByParkId.containsKey(newPark.Id)
            ) {
                ServiceAppointment updateRecord = existingAppointByParkId.get(newPark.Id);
                updateRecord.Status = 'None';
                appointsToUpdate.add(updateRecord);
            }

            if ((newPark.Is_Active__c && !oldRecord.Is_Active__c)) {
                //todo: this code should never execute, unless there is other automation that creates Appointments
                if (existingAppointByParkId.containsKey(newPark.Id)) {
                    ServiceAppointment updateRecord = existingAppointByParkId.get(newPark.Id);
                    updateRecord.Status = newPark.Open_Date__c == Date.today() ? 'In Progress' : 'Scheduled';
                    appointsToUpdate.add(updateRecord);
                } else {
                    Account account = accountByParkId.get(newPark.Id);
                    appointsToInsert.add(createServiceAppointment(assetsByAccountId, account, newPark));
                }
            }
        }
        if (appointsToInsert != null && !appointsToInsert.isEmpty()) {
            insert appointsToInsert;
        }
        if (appointsToUpdate != null && !appointsToUpdate .isEmpty()) {
            update appointsToUpdate ;
        }
    }

    private static ServiceAppointment createServiceAppointment(Map<Id, Asset> assetsByAccountId, Account account, Adventure_Park__c newPark) {
        ServiceAppointment appointment = new ServiceAppointment(
            ParentRecordId = assetsByAccountId.get(account.Id).Id,
            Status = newPark.Open_Date__c == Date.today() ? 'In Progress' : 'Scheduled',
            EarliestStartTime = Datetime.newInstance(newPark.Open_Date__c, Time.newInstance(9, 0, 0, 0)),
            DueDate = Datetime.newInstance(newPark.Open_Date__c, Time.newInstance(9, 0, 0, 0)).addDays(7),
            Subject = 'Opening Day Party Kickoff!'
        );
        return appointment;
    }
}