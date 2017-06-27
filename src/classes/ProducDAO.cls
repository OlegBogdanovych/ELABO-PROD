public with sharing class ProducDAO {
    public static Product__c getproductByDossierId (Id dossierId) {
        List <DossierProduct__c> dosProds = [select Id, Product__c
                                            from DossierProduct__c where Dossier__c =: dossierId];
        Set <Id> productIds = new Set <Id>();
        for (DossierProduct__c dosProd: dosProds) {
            productIds.add(dosProd.Product__c);
        }
        List <Product__c> products = [select Id, Vervolgadvies__c, AO_percentage_direct_na_onderzoek__c, AO2_percentage_direct_na_onderzoek__c,
                                            Meldingsfrequentie_actueel__c, Vervolginterventie_aangeboden__c, 
                                            Vervolgonderzoek_noodzakelijk__c, Verzuim_actueel__c, Verzuim_jaar_geleden__c, 
                                            AO_percentage_eind__c, AO_percentage_voor_onderzoek__c, AO_percentage_na_3_maanden__c, 
                                            AO2_percentage_eind__c, AO2_percentage_voor_onderzoek__c, AO2_percentage_na_3_maanden__c, 
                                            Behaald__c, Cijfer_gemiddeld__c, Compliant__c, Doelstelling_vraagstelling__c, 
                                            Evaluatie_formulier_ingevuld__c, Advies_Re_integratierichting__c  , Eindrapportage_verzonden__c , Hersteldatum__c, Re_integratie_afspraken_gemaakt__c
                                      from Product__c where id in: productIds];
        if (products.size() > 0) {
            return products.get(0);
        } else {
            return null;
        }
    }
}