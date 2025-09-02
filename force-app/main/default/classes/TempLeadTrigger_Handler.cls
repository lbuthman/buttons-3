public with sharing class TempLeadTrigger_Handler {

    public static Boolean avoidRecursion = false;
    public static Set<String> tempLeadEmails = new Set<String>();

    public static void onAfterInsert(Map <Id, Temp_Lead__c> tempLeadRecords) {

        Map<String, Temp_Lead__c> tempLeadByParkNumber = new Map<String, Temp_Lead__c>();
        Set<String> tempLeadFirstNames = new Set<String>();
        Set<String> tempLeadLastNames = new Set<String>();
        Set<String> tempLeadParkNumber = new Set<String>();
        for (Temp_Lead__c tempLead : tempLeadRecords.values()) {
            if (String.isNotBlank(tempLead.Lead_Email__c)) {
                tempLeadEmails.add(tempLead.Lead_Email__c);
            }
            if (String.isNotBlank(tempLead.Lead_Last_Name__c)) {
                tempLeadLastNames.add(tempLead.Lead_Last_Name__c);
            }
            if (String.isNotBlank(tempLead.Lead_First_Name__c)) {
                tempLeadFirstNames.add(tempLead.Lead_First_Name__c);
            }
            if (String.isNotBlank(tempLead.Park_Number__c)) {
                tempLeadParkNumber.add(tempLead.Park_Number__c);
                tempLeadByParkNumber.put(tempLead.Park_Number__c, tempLead);
            }
        }

        Map<Id, Map<String, Id>> parkIdByEmailMapByTempLeadId = new Map<Id, Map<String, Id>>();
        Map<Id, Map<Id, String>> ratingByParkIdMapByTempLeadId = new Map<Id, Map<Id, String>>();
        for (Adventure_Park__c park : [
            SELECT Id, Park_Number__c
            FROM Adventure_Park__c
            WHERE Park_Number__c IN :tempLeadParkNumber
            LIMIT 50000
        ]) {
            Temp_Lead__c tempLead = tempLeadByParkNumber.get(park.Park_Number__c);
            parkIdByEmailMapByTempLeadId.put(tempLead.Id, new Map<String, Id>{tempLead.Lead_Email__c => park.Id});
            ratingByParkIdMapByTempLeadId.put(tempLead.Id, new Map<Id, String>{park.Id => tempLead.Lead_Rating__c});
        }

        Map<Id, Lead> existingLeadById = fetchLeadsForUpdate(tempLeadFirstNames, tempLeadLastNames);
        Map<Id, Contact> existingContactById = fetchContactsForUpdate(tempLeadFirstNames, tempLeadLastNames);

        //Scenario #1 - if leads have the same email and lastname, check for a duplicate first name and store duplicates
        Set<Id> sameLeadIds = new Set<Id>();
        for (Integer j = 0; j < existingLeadById.values().size() -1 ; j++) {
            Lead primaryObject = existingLeadById.values()[j];
            for (Integer i = 1; i < existingLeadById.values().size(); i++) {
                Lead comparisonObject = existingLeadById.values()[i];
                if (primaryObject.LastName != comparisonObject.LastName ||
                    primaryObject.Email != comparisonObject.Email ||
                    primaryObject.FirstName == comparisonObject.FirstName
                ) {
                    continue;
                }

                if (!tempLeadFirstNames.contains(primaryObject.FirstName)) {
                    sameLeadIds.add(primaryObject.Id);
                }

                if (!tempLeadFirstNames.contains(comparisonObject.FirstName)) {
                    sameLeadIds.add(comparisonObject.Id);
                }
            }
        }

        //Scenario #2 - if contacts have the same email and lastname, check for a duplicate first name and store duplicates
        Set<Id> sameContactIds = new Set<Id>();
        for (Integer j = 0; j < existingContactById.values().size() -1 ; j++) {
            Contact primaryContact = existingContactById.values()[j];
            for (Integer i = 1; i < existingContactById.values().size(); i++) {
                Contact comparisonContact = existingContactById.values()[i];
                if (primaryContact.LastName != comparisonContact.LastName ||
                    primaryContact.Email != comparisonContact.Email ||
                    primaryContact.FirstName == comparisonContact.FirstName
                ) {
                    continue;
                }

                if (!tempLeadFirstNames.contains(primaryContact.FirstName)) {
                    sameContactIds.add(primaryContact.Id);
                }

                if (!tempLeadFirstNames.contains(comparisonContact.FirstName)) {
                    sameContactIds.add(comparisonContact.Id);
                }
            }
        }

        //Scenario #3 - if lead/contact have the same email and lastname, check for a duplicate first name and store duplicates
        for (Id leadId : existingLeadById.keySet()) {
            Lead lead = existingLeadById.get(leadId);
            for (Id contactId : existingContactById.keySet()) {
                Contact contact = existingContactById.get(contactId);
                if (lead.Email != contact.Email ||
                    lead.LastName != contact.LastName ||
                    lead.FirstName == contact.FirstName
                ) {
                    continue;
                }

                if (!tempLeadFirstNames.contains(contact.FirstName) &&
                    tempLeadLastNames.contains(contact.LastName) &&
                    tempLeadEmails.contains(contact.Email)
                ) {
                    sameContactIds.add(contactId);
                }

                if (!tempLeadFirstNames.contains(lead.FirstName) &&
                    tempLeadLastNames.contains(lead.LastName) &&
                    tempLeadEmails.contains(lead.Email)
                ) {
                    sameLeadIds.add(leadId);
                }
            }
        }

        if (!sameLeadIds.isEmpty()) {
            for (Id leadId : existingLeadById.keySet()) {
                if (sameLeadIds.contains(leadId)) {
                    existingLeadById.remove(leadId);
                }
            }
        }

        if (!sameContactIds.isEmpty()) {
            for (Id contactId : existingContactById.keySet()) {
                if (sameContactIds.contains(contactId)) {
                    existingContactById.remove(contactId);
                }
            }
        }

        //</Addition> Levi - 01-05-20
        Set<Id> ldIds = new Set<Id>();
        Set<Id> conIds = new Set<Id>();
        Map<Id, Id> tempLeadToLead = new Map<Id, Id>();
        Map<Id, Id> templeadToContact = new Map<Id, Id>();
        Set<String> conEmail = new Set<String>();
        Set<String> conLastName = new Set<String>();
        Set<Id> accountIds = new Set<Id>();
        for (Temp_Lead__c temp : tempLeadRecords.values()) {
            if (existingLeadById != null && !existingLeadById.isEmpty()) {
                for (Lead lead : existingLeadById.values()) {
                    if (temp.Lead_Email__c == lead.Email && temp.Lead_Last_Name__c == lead.LastName) {
                        tempLeadToLead.put(temp.Id, lead.Id);
                        ldIds.add(lead.Id);
                    }
                }
            }

            if (existingContactById != null && !existingContactById.isEmpty()) {
                for (Contact con : existingContactById.values()) {
                    if (temp.Lead_Email__c == con.Email && temp.Lead_Last_Name__c == con.LastName) {
                        templeadToContact.put(temp.Id, con.Id);
                        conIds.add(con.Id);
                        accountIds.add(con.AccountId);
                        conEmail.add(con.Email);
                        conLastName.add(con.LastName);
                    }
                }
            }
        }

        Set<Id> accWithOppsInReview = new Set<Id>();
        for (Account acc : [
            SELECT Id, (SELECT Id, AccountId, StageName FROM Opportunities)
            FROM Account
            WHERE Id IN :accountIds
        ]) {
            if (acc.Opportunities != null && !acc.Opportunities.isEmpty()) {
                for (Opportunity opp : acc.Opportunities) {
                    if (opp.StageName == 'Negotiation/Review') {
                        accWithOppsInReview.add(opp.AccountId);
                    }
                }
            }
        }

        Set<Id> contactsToUpdatePartially = new Set<Id>();
        Map<Id, String> contactsToEmail = new Map<Id, String>();
        for (Contact con : [
            SELECT Id, Email, AccountId
            FROM Contact
            WHERE AccountId IN :accWithOppsInReview
            AND Email != NULL
        ]) {
            contactsToUpdatePartially.add(con.Id);
            contactsToEmail.put(con.Id, con.Email);
        }

        Boolean upsertLead = false;
        if (tempLeadToLead != null && !tempLeadToLead.isEmpty()) {
            for (Id each : tempLeadToLead.keySet()) {
                if (tempLeadToLead.containsKey(each) && tempLeadToLead.get(each) != null) {
                    upsertLead = true;
                }
            }
        }

        Boolean upsertContact = false;
        if (templeadToContact != null && !templeadToContact.isEmpty()) {
            for (Id each : templeadToContact.keySet()) {
                if (templeadToContact.containsKey(each) && templeadToContact.get(each) != null) {
                    upsertContact = true;
                }
            }
        }

        if (upsertLead && !upsertContact) {
            upsertLeadData(tempLeadRecords, tempLeadToLead, ldIds, parkIdByEmailMapByTempLeadId, conEmail, conLastName, ratingByParkIdMapByTempLeadId);
        }
        if (!upsertLead) {
            upsertLeadData(tempLeadRecords, tempLeadToLead, ldIds, parkIdByEmailMapByTempLeadId, conEmail, conLastName, ratingByParkIdMapByTempLeadId);
        }
        if (upsertContact && !upsertLead) {
            upsertContactData(tempLeadRecords, templeadToContact, conIds, parkIdByEmailMapByTempLeadId, ratingByParkIdMapByTempLeadId, contactsToUpdatePartially, contactsToEmail);
        }
        if (upsertContact && upsertLead) {
            upsertLeadData(tempLeadRecords, tempLeadToLead, ldIds, parkIdByEmailMapByTempLeadId, conEmail, conLastName, ratingByParkIdMapByTempLeadId);
            upsertContactData(tempLeadRecords, templeadToContact, conIds, parkIdByEmailMapByTempLeadId, ratingByParkIdMapByTempLeadId, contactsToUpdatePartially, contactsToEmail);
        }

    }

    private static Map<Id, Lead> fetchLeadsForUpdate(Set<String> firstNames, Set<String> lastName) {
        Map<Id, Lead> leadMap = new Map<Id, Lead>([
            SELECT Id, FirstName, LastName, Email, Phone, MobilePhone, IsConverted
            FROM Lead
            WHERE IsConverted = FALSE
            AND FirstName IN :firstNames
            AND LastName IN :lastName
            AND Email IN :tempLeadEmails
            LIMIT 50000
            FOR UPDATE
        ]);
        return leadMap;
    }

    private static Map<Id, Contact> fetchContactsForUpdate(Set<String> firstNames, Set<String> lastNames) {
        Map<Id, Contact> contactMap = new Map<Id, Contact>([
            SELECT Id, AccountId, FirstName, LastName, Email, Phone, MobilePhone
            FROM Contact
            WHERE FirstName IN :firstNames
            AND LastName IN :lastNames
            AND Email IN :tempLeadEmails
            LIMIT 50000
            FOR UPDATE
        ]);
        return contactMap;
    }

    public static String estimatedHouseHoldIncome(String s) {
        if (s != null) {
            s = s.replace('$', '').replace(',', '');
            s = s.trim();
            String[] s2 = new String[2];
            if (s.contains('+')) {
                s2[0] = '0';
                s2[1] = s.replace('+', '');
            }
            else {
                s2 = s.split('-');
            }
            Integer[] income = new Integer[2];

            income[0] = Integer.valueOf(s2[0].trim());
            income[1] = Integer.valueOf(s2[1].trim());
            if (income[1] == null) {
                s = 'Under $64K';
            }
            else if (income[1] < 65000) {
                s = 'Under $64K';
            }
            else if (income[1] <= 99999) {
                s = '$65K-99K';
            }
            else if (income[1] <= 149999) {
                s = '$100K-149K';
            }
            else if (income[1] <= 199999) {
                s = '$150K-199K';
            }
            else if (income[1] <= 249999) {
                s = '$200K-249K';
            }
            else if (income[1] <= 299999) {
                s = '$250K-299K';
            }
            else {
                s = '$300K+';
            }
        }
        return s;
    }

    public static String adventureTimeFrame(String s) {
        if (s != null) {
            s = s.trim();
            String[] s2 = new String[2];
            s2 = s.split('/');
            Integer[] n = new Integer[2];
            n[0] = Integer.valueOf(s2[0].trim());
            n[1] = Integer.valueOf(s2[1].trim());
            Date moveInDate = Date.newInstance(n[1], n[0], 01);
            Date todaysDate = Date.today();
            Integer monthDiff = todaysDate.monthsBetween(moveInDate);

            //Insructed to round down the month difference.
            if (monthDiff <= 2) {
                s = '1 Month';
            }
            else if (monthDiff <= 5) {
                s = '3 Months';
            }
            else if (monthDiff <= 8) {
                s = '6 Months';
            }
            else if (monthDiff <= 11) {
                s = '9 Months';
            }
            else {
                s = '1 Year +';
            }
        }
        return s;
    }

    public static void upsertLeadData(Map<Id, Temp_Lead__c> ldTemp, Map<Id, Id> temptoLead, Set<Id> existingLeadIds,
        Map<Id, Map<String, Id>> TemptoEmailtoPark, Set<String> emailSet, Set<String> lastNameSet,
        Map<Id, Map<Id, String>> tempToParkToRating
    ) {
        Set<String> leadEmail = new Set<String>();
        Set<String> leadLastName = new Set<String>();
        Set<Id> leadIds = new Set<Id>();
        Set<Id> existingParks = new Set<Id>();
        List<Park_Of_Interest__c> parksOfInterest = new List<Park_Of_Interest__c>();
        Map<String, Set<Id>> leadEmailtoParkId = new Map<String, Set<Id>>();
        Map<Id, Lead> tempLeadToLead = new Map<Id, Lead>();
        List<Temp_Lead__c> TempleadList = ldTemp.values();
        TempleadList.sort();
        //To sort the records in the latest created order
        List<Temp_Lead__c> finalList = new List<Temp_Lead__c>();
        for (Integer i = TempleadList.size() - 1; i >= 0; i--) {
            finalList.add(TempleadList.get(i));
        }
        for (Temp_Lead__c ld : finalList) {
            if (
                (
                    (lastNameSet == null || lastNameSet.isEmpty()) &&
                        (emailSet == null || emailSet.isEmpty())
                ) || (
                    lastNameSet != null &&
                        !lastNameSet.isEmpty() &&
                        emailSet != null &&
                        !emailSet.isEmpty() &&
                        !lastNameSet.contains(ld.Lead_Last_Name__c) &&
                        !emailSet.contains(ld.Lead_Email__c)
                )
            ) {
                Lead lead1 = new Lead(
                    FirstName = ld.Lead_First_Name__c,
                    LastName = ld.Lead_Last_Name__c,
                    Email = ld.Lead_Email__c,
                    Phone = ld.Lead_Phone_Number__c,
                    Id = temptoLead.get(ld.Id),
                    Vendor_Segment_Id__c = ld.Vendor_Segment_Id__c,
                    Company = ld.Lead_Last_Name__c,
                    Country = ld.Lead_Country_Code__c,
                    State = ld.Lead_State__c,
                    Street = ld.Lead_Street_Address__c,
                    City = ld.Lead_City__c,
                    PostalCode = ld.Lead_Postal_Code__c
                );
                if (ld.Is_Agent__c) {
                    lead1.Is_Agent__c = true;
                }

                //Update lead source
                if (temptoLead.get(ld.Id) != null) {
                    lead1.Most_Recent_Lead_Source__c = ld.Lead_Source__c;
                }
                else {
                    lead1.LeadSource = ld.Lead_Source__c;
                    lead1.Most_Recent_Lead_Source__c = ld.Lead_Source__c;
                    lead1.Status = 'Known';
                }
                //Update HouseHold Income
                lead1.Household_Income__c = estimatedHouseHoldIncome(ld.Estimated_Household_Income__c);
                //Update adventure timeline.
                lead1.Adventure_Timeframe__c = adventureTimeFrame(ld.Lead_Adventure_Date__c);


                if (temptoLead.get(ld.Id) == null ||
                    (temptoLead.get(ld.Id) != null && !leadIds.contains(temptoLead.get(ld.Id)))
                ) {
                    if (!leadEmail.contains(ld.Lead_Email__c) && !leadLastName.contains(ld.Lead_Last_Name__c)) {
                        tempLeadToLead.put(ld.Id, lead1);
                        leadEmail.add(ld.Lead_Email__c);
                        leadLastName.add(ld.Lead_Last_Name__c);
                    }
                }
                if (temptoLead.get(ld.Id) != null) {
                    leadIds.add(temptoLead.get(ld.Id));
                }
            }
        }

        if (tempLeadToLead != null && !tempLeadToLead.isEmpty()) {
            upsert tempLeadToLead.values();
        }

        List<Lead> existingLeads = [
            SELECT Id, Email, (
                SELECT Id, Lead__c, Rating__c, Adventure_Park__c, Adventure_Park__r.Park_Number__c,
                    Adventure_Park__r.Name, Lead__r.LastName, Lead__r.Email
                FROM Parks_Of_Interest__r
                WHERE Lead__c IN :existingLeadIds
            )
            FROM Lead
            WHERE Id IN :existingLeadIds
            LIMIT 50000
        ];

        for (Lead eachLead : existingLeads) {
            if (eachLead.Parks_Of_Interest__r != null && !eachLead.Parks_Of_Interest__r.isEmpty()) {
                for (Park_Of_Interest__c eachPOI : eachLead.Parks_Of_Interest__r) {
                    if (leadEmailtoParkId.containsKey(eachLead.Email)) {
                        leadEmailtoParkId.get(eachLead.Email).add(eachPOI.Adventure_Park__c);
                    }
                    else {
                        leadEmailtoParkId.put(eachLead.Email, new Set<Id>{eachPOI.Adventure_Park__c});
                    }
                }
            }
        }

        for (Park_Of_Interest__c existingPOIs : [
            SELECT Id, Lead__c, Rating__c, Adventure_Park__c, Adventure_Park__r.Park_Number__c,
                Adventure_Park__r.Name, Lead__r.LastName, Lead__r.Email
            FROM Park_Of_Interest__c
            WHERE Lead__c IN :existingLeadIds
            LIMIT 50000
        ]) {
            for (Id each : ldTemp.keySet()) {
                if (ldTemp.get(each).Lead_Rating__c != null &&
                    ldTemp.get(each).Lead_Rating__c != existingPOIs.Rating__c &&
                    ldTemp.get(each).Lead_Email__c == existingPOIs.Lead__r.Email &&
                    ldTemp.get(each).Lead_Last_Name__c == existingPOIs.Lead__r.LastName
                ) {
                    if (
                        (
                            ldTemp.get(each).Park_Number__c != null &&
                            ldTemp.get(each).Park_Number__c == existingPOIs.Adventure_Park__r.Park_Number__c
                        ) || (
                            ldTemp.get(each).Park_Number__c != null &&
                                ldTemp.get(each).Park_Number__c == existingPOIs.Adventure_Park__r.Park_Number__c
                        )
                    )
                    //update rating of existing park of interst
                    {
                        existingPOIs.Rating__c = ldTemp.get(each).Lead_Rating__c;
                    }
                    if (!parksOfInterest.contains(existingPOIs)) {
                        parksOfInterest.add(existingPOIs);
                    }
                }
            }
        }
        //<Addition> - 19-12-19- Levi
        //If multiple templead records are inserted at the same time having different park Id,
        //create POI records with those parks respectively
        for (Id each : tempLeadToLead.keySet()) {
            for (Id eachId : TemptoEmailtoPark.keySet()) {
                for (String eachEmail : TemptoEmailtoPark.get(eachId).keySet()) {
                    if (existingLeadIds.contains(tempLeadToLead.get(each).Id)) {
                        if (eachEmail == tempLeadToLead.get(each).Email) {
                            for (String park : TemptoEmailtoPark.get(eachId).values()) {
                                if (leadEmailtoParkId != null &&
                                    leadEmailtoParkId.containsKey(eachEmail) &&
                                    leadEmailtoParkId.get(eachEmail) != null
                                ) {
                                    //for(String eachEmailId : leadEmailtoParkId.keyset()){
                                    if (!leadEmailtoParkId.get(eachEmail).contains(park)) {
                                        for (String POIrating : tempToParkToRating.get(eachId).values()) {
                                            Park_Of_Interest__c poi = new Park_Of_Interest__c();
                                            poi.Adventure_Park__c = park;
                                            poi.Lead__c = tempLeadToLead.get(each).Id;
                                            poi.Rating__c = POIrating;
                                            if (!parksOfInterest.contains(poi)) {
                                                parksOfInterest.add(poi);
                                            }
                                        }
                                    }
                                    //  }
                                }
                                else {
                                    for (String POIrating : tempToParkToRating.get(eachId).values()) {
                                        Park_Of_Interest__c poi = new Park_Of_Interest__c();
                                        poi.Adventure_Park__c = park;
                                        poi.Lead__c = tempLeadToLead.get(each).Id;
                                        poi.Rating__c = POIrating;
                                        if (!parksOfInterest.contains(poi)) {
                                            parksOfInterest.add(poi);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if (!existingLeadIds.contains(tempLeadToLead.get(each).Id)) {
                        if (eachEmail == tempLeadToLead.get(each).Email) {
                            for (String park : TemptoEmailtoPark.get(eachId).values()) {
                                for (String POIrating : tempToParkToRating.get(eachId).values()) {
                                    Park_Of_Interest__c poi = new Park_Of_Interest__c();
                                    poi.Adventure_Park__c = park;
                                    poi.Lead__c = tempLeadToLead.get(each).Id;
                                    poi.Rating__c = POIrating;
                                    if (!parksOfInterest.contains(poi)) {
                                        parksOfInterest.add(poi);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        parksOfInterest.sort();
        //To sort the records in the latest created order
        List<Park_Of_Interest__c> poiFinalList = new List<Park_Of_Interest__c>();
        for (Integer i = parksOfInterest.size() - 1; i >= 0; i--) {
            poiFinalList.add(parksOfInterest.get(i));
        }

        for (Integer j = 0; j <= poiFinalList.size(); j++) {
            for (Integer i = 0; i <= poiFinalList.size() - 2; i++) {
                if (poiFinalList[i].Lead__c == poiFinalList[i + 1].Lead__c) {
                    if (poiFinalList[i].Adventure_Park__c == poiFinalList[i + 1].Adventure_Park__c) {
                        poiFinalList.remove(i + 1);
                    }
                }
            }
        }

        //</Addition> 19-12-19
        if (poiFinalList != null && !poiFinalList.isEmpty()) {
            upsert poiFinalList;
        }
    }

    public static void upsertContactData(Map<Id, Temp_Lead__c> ldTemp, Map<Id, Id> tempLeadtoContact,
        Set<Id> existingConIds, Map<Id, Map<String, Id>> TemptoEmailtoPark, Map<Id, Map<Id, String>> TempToParkToRating,
        Set<Id> conWithOppsInReview, Map<Id, String> conToEmail
    ) {
        Set<String> conEmail = new Set<String>();
        Set<String> conLastName = new Set<String>();
        Set<Id> existingParks = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Map<Id, Contact> tempParkToContact = new Map<Id, Contact>();
        List<Park_Of_Interest__c> poiList = new List<Park_Of_Interest__c>();
        Map<String, Set<Id>> conEmailtoParkId = new Map<String, Set<Id>>();
        //changes for integration ticket 311743 Added orderby to use index
        List<Account> agentAccounts = [
            SELECT Id, Name
            FROM Account
            WHERE Type = 'Agent'
            AND Email__c IN :tempLeadEmails
            LIMIT 50000
        ];
        //end changes

        List<Temp_Lead__c> TempleadList = ldTemp.values();
        TempleadList.sort();
        Contact con = new Contact();
        //To sort the records in the latest created order
        List<Temp_Lead__c> finalList = new List<Temp_Lead__c>();
        for (Integer i = TempleadList.size() - 1; i >= 0; i--) {
            finalList.add(TempleadList.get(i));
        }
        for (Temp_Lead__c ld : finalList) {
            if (tempLeadtoContact.get(ld.Id) != null) {
                if (conWithOppsInReview == null || conWithOppsInReview.isEmpty()) {
                    con = new Contact(
                        FirstName = ld.Lead_First_Name__c,
                        LastName = ld.Lead_Last_Name__c,
                        Email = ld.Lead_Email__c,
                        Phone = ld.Lead_Phone_Number__c,
                        Id = tempLeadtoContact.get(ld.Id),
                        Vendor_Segment_Id__c = ld.Vendor_Segment_Id__c,
                        MailingCountry = ld.Lead_Country_Code__c,
                        MailingState = ld.Lead_State__c,
                        MailingStreet = ld.Lead_Street_Address__c,
                        MailingCity = ld.Lead_City__c,
                        MailingPostalCode = ld.Lead_Postal_Code__c,
                        Most_Recent_Lead_Source__c = ld.Lead_Source__c
                    );
                }
                else {
                    if (conToEmail != null && !conToEmail.isEmpty()) {
                        con = new Contact(Id = tempLeadtoContact.get(ld.Id), Email = conToEmail.get(tempLeadtoContact.get(ld.Id)),
                            Vendor_Segment_Id__c = ld.Vendor_Segment_Id__c,
                            MailingCountry = ld.Lead_Country_Code__c,
                            MailingState = ld.Lead_State__c,
                            MailingStreet = ld.Lead_Street_Address__c,
                            MailingCity = ld.Lead_City__c,
                            MailingPostalCode = ld.Lead_Postal_Code__c,
                            Most_Recent_Lead_Source__c = ld.Lead_Source__c
                        );
                    }
                }
                if (ld.Is_Agent__c) {
                    if (agentAccounts != null && !agentAccounts.isEmpty()) {
                        for (Account acc : agentAccounts) {
                            acc.Agent_First_Name__c = ld.Lead_First_Name__c;
                            acc.Agent_Last_Name__c = ld.Lead_Last_Name__c;
                            acc.Phone = ld.Lead_Phone_Number__c;
                        }
                    }
                }
                //Update house hold income.
                con.Household_Income__c = estimatedHouseHoldIncome(ld.Estimated_Household_Income__c);

                //Update adventure timeframe.
                con.Adventure_Timeframe__c = adventureTimeFrame(ld.Lead_Adventure_Date__c);

                if (tempLeadtoContact.get(ld.Id) == null ||
                    (
                        tempLeadtoContact.get(ld.Id) != null &&
                            !contactIds.contains(tempLeadtoContact.get(ld.Id))
                    )
                ) {
                    if (!conEmail.contains(con.Email) && !conLastName.contains(con.LastName)) {
                        tempParkToContact.put(ld.Id, con);
                        conEmail.add(con.Email);
                        conLastName.add(con.LastName);
                    }

                }
                if (tempLeadtoContact.get(ld.Id) != null) {
                    contactIds.add(tempLeadtoContact.get(ld.Id));
                }

            }
        }
        if (tempParkToContact != null && !tempParkToContact.isEmpty()) {
            upsert tempParkToContact.values();
        }

        List<Contact> existingContacts = [
            SELECT Id, Email,
            (
                SELECT Id, Contact__c, Rating__c, Adventure_Park__c, Adventure_Park__r.Park_Number__c,
                    Adventure_Park__r.Name, Contact__r.LastName, Contact__r.Email
                FROM Parks_Of_Interest__r
                WHERE Contact__c IN :existingConIds
            )
            FROM Contact
            WHERE Id IN :existingConIds
            LIMIT 50000
        ];

        for (Contact eachCon : existingContacts) {
            if (eachCon.Parks_Of_Interest__r != null &&
                !eachCon.Parks_Of_Interest__r.isEmpty()
            ) {
                for (Park_Of_Interest__c eachPOI : eachCon.Parks_Of_Interest__r) {
                    if (conEmailtoParkId.containsKey(eachCon.Email)) {
                        conEmailtoParkId.get(eachCon.Email).add(eachPOI.Adventure_Park__c);
                    } //Map of existing contact's email to its POI reord's park
                    else {
                        conEmailtoParkId.put(eachCon.Email, new Set<Id>{eachPOI.Adventure_Park__c});
                    }
                }
            }
        }

        for (Park_Of_Interest__c existingPOIs : [
            SELECT Id, Contact__c, Rating__c, Adventure_Park__c, Adventure_Park__r.Park_Number__c,
                Adventure_Park__r.Name, Contact__r.LastName, Contact__r.Email
            FROM Park_Of_Interest__c
            WHERE Contact__c IN :existingConIds
            LIMIT 50000
        ]) {
            for (Id each : ldTemp.keySet()) {
                if (ldTemp.get(each).Lead_Rating__c != null &&
                    ldTemp.get(each).Lead_Rating__c != existingPOIs.Rating__c &&
                    ldTemp.get(each).Lead_Email__c == existingPOIs.Contact__r.Email &&
                    ldTemp.get(each).Lead_Last_Name__c == existingPOIs.Contact__r.LastName
                ) {
                    if (
                        (
                            ldTemp.get(each).Park_Number__c != null &&
                            ldTemp.get(each).Park_Number__c == existingPOIs.Adventure_Park__r.Park_Number__c
                        ) || (
                            ldTemp.get(each).Park_Number__c != null &&
                                ldTemp.get(each).Park_Number__c == existingPOIs.Adventure_Park__r.Park_Number__c
                        )
                    )
                    //update rating of existing POI
                    {
                        existingPOIs.Rating__c = ldTemp.get(each).Lead_Rating__c;
                    }
                    if (!poiList.contains(existingPOIs)) {
                        poiList.add(existingPOIs);
                    }
                }
            }
        }
        //<Addition> - 19-12-19- Levi
        //If multiple templead records are inserted at the same time having different park Id,
        //create POI records with those parks respectively
        for (Id each : tempParkToContact.keySet()) {
            for (Id eachId : TemptoEmailtoPark.keySet()) {
                for (String eachEmail : TemptoEmailtoPark.get(eachId).keySet()) {
                    if (existingConIds.contains(tempParkToContact.get(each).Id)) {
                        if (eachEmail == tempParkToContact.get(each).Email) {
                            for (String park : TemptoEmailtoPark.get(eachId).values()) {
                                if (conEmailtoParkId != null &&
                                    conEmailtoParkId.containsKey(eachEmail) &&
                                    conEmailtoParkId.get(eachEmail) != null
                                ) {
                                    //for(String eachEmailId : conEmailtoParkId.keyset()){
                                    if (!conEmailtoParkId.get(eachEmail).contains(park)) { //check if the park already exists
                                        for (String POIrating : TempToParkToRating.get(eachId).values()) {
                                            Park_Of_Interest__c poi = new Park_Of_Interest__c();
                                            poi.Adventure_Park__c = park;
                                            poi.Contact__c = tempParkToContact.get(each).Id;
                                            poi.Rating__c = POIrating;
                                            if (!poiList.contains(poi)) {
                                                poiList.add(poi);
                                            }
                                        }
                                    }
                                    //}
                                }
                                else {
                                    for (String POIrating : TempToParkToRating.get(eachId).values()) {
                                        Park_Of_Interest__c poi = new Park_Of_Interest__c();
                                        poi.Adventure_Park__c = park;
                                        poi.Contact__c = tempParkToContact.get(each).Id;
                                        poi.Rating__c = POIrating;
                                        if (!poiList.contains(poi)) {
                                            poiList.add(poi);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        //</Addition> 19-12-19

        poiList.sort();
        //To sort the records in the latest created order
        List<Park_Of_Interest__c> poiFinalList = new List<Park_Of_Interest__c>();
        for (Integer i = poiList.size() - 1; i >= 0; i--) {
            poiFinalList.add(poiList.get(i));
        }

        for (Integer j = 0; j <= poiFinalList.size(); j++) {
            for (Integer i = 0; i <= poiFinalList.size() - 2; i++) {
                if (poiFinalList[i].Contact__c == poiFinalList[i + 1].Contact__c) {
                    if (poiFinalList[i].Adventure_Park__c == poiFinalList[i + 1].Adventure_Park__c) {
                        poiFinalList.remove(i + 1);
                    }
                }
            }
        }
        if (poiFinalList != null && !poiFinalList.isEmpty()) {
            upsert poiFinalList;
        }
    }
}
