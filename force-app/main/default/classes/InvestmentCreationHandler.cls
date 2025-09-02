public with sharing class InvestmentCreationHandler {

    @InvocableMethod(Label = 'Create Investment')
    public static List<Response> createInvestment(List<RequestPayload> requests) {
        RequestPayload request = requests[0];

        Lead l = new Lead();
        l.Id = request.treasureChestId;
        l.Status = 'Opened';
        update l;

        Database.LeadConvert leadConvert = new Database.LeadConvert();
        Account acc = new Account();
        Contact con = new Contact();
        Opportunity opp = new Opportunity();
        Id acctId = null;
        Id conId = null;
        Boolean createOpp = true;
        Id opportunityId = null;

        Lead ld = [SELECT Id, Status, FirstName, LastName, Email, Phone, Company FROM Lead WHERE Id = :request.treasureChestId];
        leadConvert.setLeadId(ld.Id);
        //<Addition> ThatOneConsultant 30-10-19 To make the logged in user the owner of converted Account, Contact and Opportunity
        leadConvert.setOwnerId(UserInfo.getUserId());
        //</Addition> ThatOneConsultant 30-10-19

        List<Investment_Idea__c> iilist = [SELECT Category__c, Story_Points__c, Time_Investment__c, Is_Active__c, Name  FROM Investment_Idea__c WHERE Id = :request.investmentIdeaId];
        if (iilist != null && !iilist.isEmpty() && iilist.size() > 0) {
            List<Account> acctList = [SELECT Id FROM Account WHERE Type = :iilist.get(0).Category__c];
            acctId = acctList.isEmpty() ? null : acctList.get(0).Id;
        }

        if (acctId != null && acctId != '') {
            conId = [SELECT Id FROM Contact WHERE AccountId = :acctId].Id;
        }

        if (acctId != null && acctId != '') {
            leadConvert.setAccountId((Id) acctId);
        }
        else{
            acc = createNewAccount(iilist.get(0));
            insert acc;
            leadConvert.setAccountId(acc.Id);
        }
        if (conId != null && conId != '') {
            leadConvert.setContactId((Id) conId);
        }
        else{
            if(acctId!=null && acctId!=''){
                con = createNewContact(ld,acctId);
                insert con;
                leadConvert.setContactId(con.Id);
            }
            else{
                con = createNewContact(ld,acc.Id);
                System.debug('ld.firstName__'+ld.FirstName);
                System.debug('ld.lastName__'+ld.LastName);
                System.debug('ld.phone__'+ld.Phone);
                System.debug('ld.email__'+ld.Email);
                insert con;
                leadConvert.setContactId(con.Id);
            }

        }
        if(createOpp){
            if (opportunityId != null && opportunityId != '') {
                leadConvert.setOpportunityId((Id) opportunityId);
                leadConvert.setDoNotCreateOpportunity(createOpp);
            }
            else{
                if (con.Id != null && acc.Id != null) {
                    opp = createNewOpportunity(ld, '', acc.Id, con.Id, iilist[0]);
                }
                else if (con.Id == null && acc.Id != null) {
                    opp = createNewOpportunity(ld, '', acc.Id, (Id) conId, iilist[0]);
                }
                else if (con.Id != null && acc.Id == null) {
                    opp = createNewOpportunity(ld, '', (Id) acctId, con.Id, iilist[0]);
                }
                else if (con.Id == null && acc.Id == null) {
                    opp = createNewOpportunity(ld, '', (Id) acctId, (Id) conId, iilist[0]);
                }

                insert opp;
                leadConvert.setOpportunityId(opp.Id);
            }
        }
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=TRUE LIMIT 1];
        leadConvert.setConvertedStatus(convertStatus.MasterLabel);
        leadConvert.sendNotificationEmail = true;
        Database.LeadConvertResult lcr = Database.convertLead(leadConvert);

        Investment_Idea__c ii = iilist[0];
        ii.Is_Active__c = false;
        update ii;

        Task task = new Task();
        if (opportunityId != '' || opportunityId != null) {
            task.WhatId = opportunityId;
        }
        else {
            task.WhatId = opp.Id;
        }
        task.Subject = ii.Name;
        insert task;

        Response response = new Response();
        if (opportunityId != null) {
            response.investmentLink = Url.getOrgDomainUrl().toExternalForm() + '/' + opportunityId;
        }
        else {
            response.investmentLink = Url.getOrgDomainUrl().toExternalForm() + '/' + opp.Id;
        }
        if (acctId != null) {
            response.portfolioLink = Url.getOrgDomainUrl().toExternalForm() + '/' + acctId;
        }
        else {
            response.portfolioLink = Url.getOrgDomainUrl().toExternalForm() + '/' + acc.Id;
        }
        response.taskLink = Url.getOrgDomainUrl().toExternalForm() + '/' + task.Id;
        return new List<Response>{response};
    }

    public static Account createNewAccount(Investment_Idea__c ii){
        Account acc = new Account();
        acc.Name = ii.Category__c + ' Portfolio';
        return acc;
    }

    public static Contact createNewContact(Lead ld,Id accountId){
        Contact con= new Contact ();
        con.FirstName = ld.FirstName;
        con.AccountId = accountId;
        con.LastName = ld.LastName ;
        return con;
    }
    public static Opportunity createNewOpportunity(Lead ld, String RecordType,Id accountId,Id contactId, Investment_Idea__c ii){
        Opportunity opp= new Opportunity();
        opp.AccountId= accountId;
        opp.StageName = 'Created';
        opp.CloseDate= Date.today().addDays(1);
        opp.Name = ii.Name;
        opp.Experience_Points__c = Integer.valueOf(ii.Time_Investment__c);
        opp.Story_Points__c = Integer.valueOf(ii.Story_Points__c);
        return opp;
    }

    public class RequestPayload {
        @InvocableVariable(Label='Treasure Chest Id' Required=true)
        public String treasureChestId;

        @InvocableVariable(Label='Investment Idea Id' Required=true)
        public String investmentIdeaId;
    }

    public class Response {
        @InvocableVariable(Label='Investment Link' Description='Link to the created investment.')
        public String investmentLink;

        @InvocableVariable(Label='Portfolio Link' Description='Link to the found/created Portfolio.')
        public String portfolioLink;

        @InvocableVariable(Label='Task Link' Description='Link to the Task to Complete.')
        public String taskLink;
    }
}
