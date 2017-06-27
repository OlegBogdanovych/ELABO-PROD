public class DocumentTemplateExtension{
public Dossier__c dossier{get;set;}
    public DocumentTemplateExtension (ApexPages.StandardController controller) {
        dossier = (Dossier__c) controller.getRecord();
    }
    public Map <Id, rsdoc__Document_Action__c> actionsByIds = new Map <Id, rsdoc__Document_Action__c>([select rsdoc__Template_Name__c, Id, rsdoc__Button_Link_Code__c from rsdoc__Document_Action__c]);
    public String selectedTemplate{get;set;}
    public List<SelectOption> getTemplates(){
        List<SelectOption> options = new List<SelectOption>();     
        List <rsdoc__Document_Action__c> actions = actionsByIds.values();
        options.add(new SelectOption('None', 'None'));    
        for( rsdoc__Document_Action__c a : actions )  {
            options.add(new SelectOption(a.Id, a.rsdoc__Template_Name__c));
        }       
        return options;
    }
    
    public PageReference createTemplate() {
        System.debug('selectedTemplate '+selectedTemplate );
        if (selectedTemplate != 'None' && actionsByIds.containsKey(selectedTemplate)) {
        
            String url = actionsByIds.get(selectedTemplate).rsdoc__Button_Link_Code__c ;
            url = url.replace('{!Dossier__c.Id}', dossier.id);
            System.debug('url '+url);
            return new PageReference(url);
        } else {
            return null;
        }
    }
    public PageReference reload () {
        getTemplates();
        return null;
    }
}