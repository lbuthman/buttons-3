public without sharing class HabiticaIntegrator {

    public static void integrateTask(String title) {
        HabiticaTask habiticaTask = new HabiticaTask(title, 'todo', 2);
        HttpRequest request = createRequest('https://habitica.com/api/v3/tasks/user', 'POST');
        request.setBody(JSON.serialize(habiticaTask));
        try {
            submitRequest(request);
        }
        catch (Exception ex) {
            Logger.error(ex.getMessage(), ex);
        }
    }

    public static Boolean useMana() {
        String baseUri = 'https://habitica.com/api/v3/user/class/cast/fireball?targetId=9ad0918b-5961-4ffb-808d-4359c36eb673';
        HttpRequest request = HabiticaIntegrator.createRequest(baseUri, 'POST');
        request.setHeader('Content-length', '0');
        String response = HabiticaIntegrator.submitRequest(request);

        //{"success":false,"error":"NotAuthorized","message":"Not enough mana."}
        Map<String, Object> raw = (Map<String, Object>) JSON.deserializeUntyped(response);
        Boolean success = (Boolean) raw.get('success');
        if (success) {
            Map<String, Object> data = (Map<String, Object>) raw.get('data');
            Map<String, Object> user = (Map<String, Object>) data.get('user');
            Map<String, Object> stats = (Map<String, Object>) user.get('stats');
            Integer remainingMana = Integer.valueOf(stats.get('mp'));
            System.debug('remainingMana=' + remainingMana);
        }
        return success;
    }

    public static void getGoldCount() {
        HttpRequest request = createRequest('https://habitica.com/api/v3/user?userFields=stats.gp', 'GET');
        String rawResponse = submitRequest(request);

        Map<String, Object> raw = (Map<String, Object>) JSON.deserializeUntyped(rawResponse);
        Map<String, Object> data = (Map<String, Object>) raw.get('data');
        if (data != null) {
            Map<String, Object> stats = (Map<String, Object>) data.get('stats');
            Integer gold = Integer.valueOf(stats.get('gp'));
            System.debug('remaining gold = ' + gold);
        }
        else {
            System.debug('no response');
        }
    }

    public static String buyEnchantedArmoire() {
        HttpRequest request = createRequest('https://habitica.com/api/v3/user/buy-armoire', 'POST');
        request.setHeader('Content-length', '0');
        String rawResponse = submitRequest(request);

        Map<String, Object> raw = (Map<String, Object>) JSON.deserializeUntyped(rawResponse);
        String message = (String) raw.get('message');
        String valuable = message.replaceAll('(?<span>)(.*)(span>)', '');

        return valuable;
    }

    public static HttpRequest createRequest(String endpoint, String method) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setHeader('x-api-user', 'ae1239fd-5173-431b-9590-e00e6326ddac');
        request.setHeader('x-api-key', 'b0b9fcd4-f617-4ecf-b547-196fc24ee3f8');
        request.setHeader('x-client', 'ae1239fd-5173-431b-9590-e00e6326ddac-Salesforce');
        request.setHeader('Content-Type', 'application/json');
        request.setMethod(method);
        return request;
    }

    public static String submitRequest(HttpRequest request) {
        Http http = new Http();
        HttpResponse response;
        try {
            response = http.send(request);
            return response.getBody();
        }
        catch (Exception ex) {
            System.debug('ex.getMessage()=' + ex.getMessage());
            return '';
        }
    }

    public class HabiticaTask {
        String text;
        String type;
        Integer priority;

        public HabiticaTask(String text, String type, Integer priority) {
            this.text = text;
            this.type = type;
            this.priority = priority;
        }
    }

}