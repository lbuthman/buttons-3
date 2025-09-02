public with sharing class DeleteMe {
    public static void create(List<Account> acctRecs){

        List<Contact> conts = new List<Contact>();

        for(Account rec : acctRecs){
            if(rec.Name.containsIgnoreCase('partner') && rec.AnnualRevenue > 1000000){
                Contact pc = new Contact();
                pc.LastName = 'Partner from ' + rec.Name;
                pc.AccountId = rec.Id;
                conts.add(pc);
            } else if(rec.Name.containsIgnoreCase('customer') && rec.AnnualRevenue > 5000){
                Contact cc = new Contact();
                cc.LastName = 'Customer from ' + rec.Name;
                cc.AccountId = rec.Id;
                conts.add(cc);
            } else {
                Contact c = new Contact();
                c.LastName = 'Other from ' + rec.Name;
                c.AccountId = rec.Id;
                conts.add(c);
            }

            if(rec.Name.containsIgnoreCase('partner')){

                String accountJson = JSON.serialize(rec);

                HttpRequest req = new HttpRequest();
                req.setEndpoint('api.netsuite/partners');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setBody(accountJson);

                Http http = new Http();
                HttpResponse res = http.send(req);

                if (res.getStatusCode() == 200) {

                    System.debug('POST request successful. Response: ' + res.getBody());
                } else {

                    System.debug('POST request failed. Status code: ' + res.getStatusCode() + ', Response: ' + res.getBody());
                }
            }

        }

        insert conts;
    }
}
