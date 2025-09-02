public with sharing class PetHatcherController {
    public List<String> hatchedPets { get; set; }
    public Map<String, Integer> eggs { get; set; }
    public Map<String, Integer> potions { get; set; }
    public List<SelectOption> eggOptions { get; set; }
    public List<SelectOption> potionOptions { get; set; }
    public String selectedEgg { get; set; }
    public String selectedPotion { get; set; }
    public String hatchingResult { get; set; }

    public PetHatcherController() {
        eggOptions = new List<SelectOption>();
        potionOptions = new List<SelectOption>();
        fetchData();
    }

    public void fetchData() {
        // Example API request
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.example.com/data');
        req.setMethod('GET');
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            hatchedPets = (List<String>) result.get('hatchedPets');
            eggs = (Map<String, Integer>) result.get('eggs');
            potions = (Map<String, Integer>) result.get('potions');
            updateSelectOptions();
        }
    }

    private void updateSelectOptions() {
        eggOptions.clear();
        potionOptions.clear();
        for (String key : eggs.keySet()) {
            eggOptions.add(new SelectOption(key, key + ' (' + eggs.get(key) + ' available)'));
        }
        for (String key : potions.keySet()) {
            potionOptions.add(new SelectOption(key, key + ' (' + potions.get(key) + ' available)'));
        }
    }

    public List<SelectOption> getSelectOptions(Map<String, Integer> items) {
        List<SelectOption> options = new List<SelectOption>();
        for (String key : items.keySet()) {
            options.add(new SelectOption(key, key + ' (' + items.get(key) + ')'));
        }
        return options;
    }

    public void hatchPet() {
        // Send hatching request
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.example.com/hatch?egg=' + selectedEgg + '&potion=' + selectedPotion);
        req.setMethod('POST');
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() == 200) {
            hatchingResult = 'Hatching successful!';
            fetchData(); // Refresh data to check new pets
        } else {
            hatchingResult = 'Hatching failed.';
        }
    }
}
