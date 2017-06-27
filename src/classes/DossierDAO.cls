public with sharing class DossierDAO {
    public static Dossier__c getDossierById (Id dossierId) {
        return [select Id, Relatie__r.Debiteurnummer__c, Name, RecordTypeId, Due_Date__c, Relatie__r.Name, Afspraak_gemaakt_op__c,
                        Relatie__r.Betalingsconditie__c, Relatie__r.RecordTypeId, reference_Id__c, Handler__r.Name , Product_Exception__c , Verwijzer__c, 
                        Handler__r.Kostenplaats__c, Vervolgadvies__c, AO_percentage_direct_na_onderzoek__c,AO2_percentage_direct_na_onderzoek__c, Eindrapportage_verzonden__c , 
                        Meldingsfrequentie_actueel__c, Vervolginterventie_aangeboden__c, Invoice_Is_Sent__c ,Client__c,Client__r.Name ,ClientName__c,
                        Vervolgonderzoek_noodzakelijk__c, Verzuim_actueel__c, Verzuim_jaar_geleden__c, Soort_onderzoek__c,
                        AO_percentage_eind__c, AO_percentage_voor_onderzoek__c, AO_percentage_na_3_maanden__c, AO2_percentage_eind__c, AO2_percentage_voor_onderzoek__c, AO2_percentage_na_3_maanden__c,Kenmerk_Klant__c ,
                        Behaald__c, Cijfer_gemiddeld__c, Compliant__c, Doelstelling_vraagstelling__c, andere_reintegratieafspraak__c,Opmerkingen__c, 
                        Evaluatie_formulier_ingevuld__c, Status__c, Advies_Re_integratierichting__c , Type_vervolginterventie__c, Andere_vevolginterventie__c , Hersteldatum__c , Re_integratie_afspraken_gemaakt__c, Wanneer_Vervolgonderzoek__c, Vervolgadvies_Picklist__c, Type_Vervolgadvies__c
                    from Dossier__c where id =:dossierId];
    }
    public static List<Dossier__c> getDossiersBySetId (Set<Id> dossierIds) {
        return [select Id, Relatie__r.Debiteurnummer__c, Name, RecordTypeId,Client__c, Soort_onderzoek__c, Afspraak_gemaakt_op__c, Client__r.Name ,ClientName__c, Invoice_Is_Sent__c ,Kenmerk_Klant__c , Andere_vevolginterventie__c, Type_vervolginterventie__c , Due_Date__c, Relatie__r.Name, Relatie__r.Betalingsconditie__c, Relatie__r.RecordTypeId, reference_Id__c, Handler__r.Name , Handler__r.Kostenplaats__c
                    from Dossier__c where id in:dossierIds];
    }
    public static Map <Id, Dossier__c> getDossiersMapByIds (Set <Id> dossierIds) {
        Map <Id, Dossier__c> toReturn = new Map <Id, Dossier__c>([select Id, Relatie__r.Debiteurnummer__c, Name, RecordTypeId, Due_Date__c, Relatie__r.Name, Afspraak_gemaakt_op__c,
                        Relatie__r.Betalingsconditie__c, Relatie__r.RecordTypeId, reference_Id__c, Handler__r.Name , Product_Exception__c , Verwijzer__c, 
                        Handler__r.Kostenplaats__c, Vervolgadvies__c, AO_percentage_direct_na_onderzoek__c,AO2_percentage_direct_na_onderzoek__c, Eindrapportage_verzonden__c , 
                        Meldingsfrequentie_actueel__c, Vervolginterventie_aangeboden__c, Invoice_Is_Sent__c ,Client__c,Client__r.Name ,ClientName__c,
                        Vervolgonderzoek_noodzakelijk__c, Verzuim_actueel__c, Verzuim_jaar_geleden__c, Soort_onderzoek__c,
                        AO_percentage_eind__c, AO_percentage_voor_onderzoek__c, AO_percentage_na_3_maanden__c, AO2_percentage_eind__c, AO2_percentage_voor_onderzoek__c, AO2_percentage_na_3_maanden__c,Kenmerk_Klant__c ,
                        Behaald__c, Cijfer_gemiddeld__c, Compliant__c, Doelstelling_vraagstelling__c, andere_reintegratieafspraak__c,Opmerkingen__c, 
                        Evaluatie_formulier_ingevuld__c, Status__c, Advies_Re_integratierichting__c , Type_vervolginterventie__c, Andere_vevolginterventie__c , Hersteldatum__c , Re_integratie_afspraken_gemaakt__c, Wanneer_Vervolgonderzoek__c, Vervolgadvies_Picklist__c, Type_Vervolgadvies__c
                    from Dossier__c where id =:dossierIds]);
        return toReturn;
    }
}