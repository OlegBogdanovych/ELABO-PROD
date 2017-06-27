public with sharing class TestData {
    public static void init_TF_Ledger_Settings() {
    List<TF_Ledger_Settings__c> tfLS = new List<TF_Ledger_Settings__c>();
    
    Map<String, TF_Ledger_Settings__c> ledgerSettings = TF_Ledger_Settings__c.getAll();
    if(!ledgerSettings.containsKey('Bank')) {
      tfLS.add(new TF_Ledger_Settings__c(Name='Bank', 
      account_number__c='15500'));
    }
    if(!ledgerSettings.containsKey('Crediteuren')) {
      tfLS.add(new TF_Ledger_Settings__c(Name='Crediteuren', 
      account_number__c='14000'));
    }
    if(!ledgerSettings.containsKey('Debiteuren')) {
      tfLS.add(new TF_Ledger_Settings__c(Name='Debiteuren', 
      account_number__c='13000'));
    }
    if(!ledgerSettings.containsKey('Dekking projecturen')) {
      tfLS.add(new TF_Ledger_Settings__c(Name='Dekking projecturen', 
      account_number__c='60000'));
    }
    if(!ledgerSettings.containsKey('Kostenplaats')) {
      tfLS.add(new TF_Ledger_Settings__c(Name='Kostenplaats', 
      account_number__c='K-0000'));
    }
    if(!ledgerSettings.containsKey('Onderhanden projecten gemaakte kosten')) {
      tfLS.add(new TF_Ledger_Settings__c(Name='Onderhanden projecten gemaakte kosten', 
      account_number__c='38300'));
    }
    if(!ledgerSettings.containsKey('Onderhanden projecten mutatie')) {
      tfLS.add(new TF_Ledger_Settings__c(Name='Onderhanden projecten mutatie', 
      account_number__c='60001'));
    }
    if(!ledgerSettings.containsKey('Onderhanden projecten verstuurd')) {
      tfLS.add(new TF_Ledger_Settings__c(Name='Onderhanden projecten verstuurd', 
      account_number__c='38301'));
    }
    if(!ledgerSettings.containsKey('Onderhanden projecten voorziening')) {
      tfLS.add(new TF_Ledger_Settings__c(Name='Onderhanden projecten voorziening', 
      account_number__c='38302'));
    }
    if(!ledgerSettings.containsKey('OPV')) {
      tfLS.add(new TF_Ledger_Settings__c(Name='OPV', 
      account_number__c='38303'));
    }
    if(!ledgerSettings.containsKey('Overige bedrijfskosten')) {
      tfLS.add(new TF_Ledger_Settings__c(Name='Overige bedrijfskosten', 
      account_number__c='43900'));
    }
    
    insert tfLS;
  }
  
  public static void init_Remote_Api_Settings() {
    List<Remote_API_Setting__c> rAS = new List<Remote_API_Setting__c>();
    
    Map<String, Remote_API_Setting__c> remoteApiSettings = Remote_API_Setting__c.getAll();
    //Google
    if(!remoteApiSettings.containsKey('Google Domain')) {
      rAS.add(new Remote_API_Setting__c(Name='Google Domain', 
      value__c='-'));
    }
    if(!remoteApiSettings.containsKey('Google User')) {
      rAS.add(new Remote_API_Setting__c(Name='Google User', 
      value__c='-@-.-'));
    }
    if(!remoteApiSettings.containsKey('Google_gToken')) {
      rAS.add(new Remote_API_Setting__c(Name='Google_gToken', 
      value__c='none'));
    }
    //TWINFIELD
    if(!remoteApiSettings.containsKey('Twinfield Account')) {
      rAS.add(new Remote_API_Setting__c(Name='Twinfield Account', 
      value__c='-'));
    }
    if(!remoteApiSettings.containsKey('Twinfield Auth Endpoint')) {
      rAS.add(new Remote_API_Setting__c(Name='Twinfield Auth Endpoint', 
      value__c='https://login.twinfield.com/webservices/session.asmx'));
    }
    if(!remoteApiSettings.containsKey('Twinfield Namespace')) {
      rAS.add(new Remote_API_Setting__c(Name='Twinfield Namespace', 
      value__c='http://www.twinfield.com/'));
    }
    if(!remoteApiSettings.containsKey('Twinfield Organisation')) {
      rAS.add(new Remote_API_Setting__c(Name='Twinfield Organisation', 
      value__c='-'));
    }
    if(!remoteApiSettings.containsKey('Twinfield Office')) {
      rAS.add(new Remote_API_Setting__c(Name='Twinfield Office', 
      value__c='-'));
    }
    if(!remoteApiSettings.containsKey('Twinfield Pw')) {
      rAS.add(new Remote_API_Setting__c(Name='Twinfield Pw', 
      value__c='-'));
    }
    if(!remoteApiSettings.containsKey('Twinfield Soap Namespace')) {
      rAS.add(new Remote_API_Setting__c(Name='Twinfield Soap Namespace', 
      value__c='http://schemas.xmlsoap.org/soap/envelope/'));
    }

    insert rAS;
  }
  public static void init_Custom_Settings() {
    
    List <Periodic__c> periodics = new List <Periodic__c>();
    periodics.add(new Periodic__c(Name = 'Wekelijks', number__c = 7, isDay__c = true));
    insert periodics;
    
    List <TF_Ledger_Settings__c> ledgers = new List <TF_Ledger_Settings__c>();
    ledgers.add(new TF_Ledger_Settings__c(Name = 'Turnover Elabo', account_number__c = '8080'));
    ledgers.add(new TF_Ledger_Settings__c(Name = 'Turnover Kie', account_number__c = '8080'));
    ledgers.add(new TF_Ledger_Settings__c(Name = 'Turnover Mediation', account_number__c = '8080'));
    ledgers.add(new TF_Ledger_Settings__c(Name = 'Debtor', account_number__c = '8080'));
    insert ledgers;

    List<Remote_API_Setting__c> rAS = new List<Remote_API_Setting__c>();
    
    Map<String, Remote_API_Setting__c> remoteApiSettings = Remote_API_Setting__c.getAll();
    
    if(!remoteApiSettings.containsKey('Twinfield Account')) {
      rAS.add(new Remote_API_Setting__c(Name='Twinfield Account', 
      value__c='271607002'));
    }
    
    if(!remoteApiSettings.containsKey('Twinfield Organisation')) {
      rAS.add(new Remote_API_Setting__c(Name='Twinfield Organisation', 
      value__c=' DJL-MKB'));
    }
    if(!remoteApiSettings.containsKey('Twinfield Office')) {
      rAS.add(new Remote_API_Setting__c(Name='Twinfield Office', 
      value__c='2716072'));
    }
    if(!remoteApiSettings.containsKey('Twinfield Pw')) {
      rAS.add(new Remote_API_Setting__c(Name='Twinfield Pw', 
      value__c='@lopK39!T'));
    }
    

    insert rAS;

    Vat_code__c vat = new Vat_code__c(Name = 'VH21'        );
    insert vat;

    Task_types__c type = new Task_types__c(name = 'Afspraak_maken_met_partijen__c' , Record_Type_Name__c = 'Afspraak maken met partijen',
                        RelatedField__c = 'Binnen_aantal_uur_na_aanmelding__c', 
                        Account_Related__c = 'Binnen_aantal_uur_na_aanmelding__c',
                        AccountField__c = 'Afspraak_maken_met_partijen__c',
                        TaskSubject__c = 'Maak afspraak met partijen'
                        );
    insert type;
    type = new Task_types__c(name = 'Bewaken_vervolgadvies__c' , Record_Type_Name__c = 'Bewaken vervolgadvies',
                        RelatedField__c = 'Aantal_maanden_na_afronden_dossier__c', 
                        Account_Related__c = 'Aantal_maanden_na_afronden_dossier__c',
                        AccountField__c = 'Bewaken_vervolgadvies__c',
                        TaskSubject__c = 'Nabellen'
                        );
    insert type;
    type = new Task_types__c(name = 'Tussenrapportage__c' , Record_Type_Name__c = 'Tussenrapportage',
                        RelatedField__c = 'Hoeveel_dagen_verzenden__c', 
                        Account_Related__c = 'Hoeveel_dagen_na_bezoekdatum_verzenden__c',
                        AccountField__c = 'Tussenrapportage__c',
                        TaskSubject__c = 'Verzend tussenrapportage'
                        );
    insert type;
    type = new Task_types__c(name = 'Versturen_eindrapport__c' , Record_Type_Name__c = 'Versturen eindrapport',
                        RelatedField__c = 'Doorlooptijd_in_dagen__c', 
                        Account_Related__c = 'Doorlooptijd_in_werkdagen__c',
                        AccountField__c = 'Versturen_eindrapport__c',
                        TaskSubject__c = 'Verstuur eindrapport'

                        );
    insert type;
    type = new Task_types__c(name = 'Vervolgafspraak__c' , Record_Type_Name__c = 'Vervolgafspraak',
                        RelatedField__c = 'Minimaal_aantal_afspraken__c', 
                        Account_Related__c = 'Afspraak_maken_met_partijen__c',
                        AccountField__c = 'Minimaal_aantal_afspraken__c',
                        TaskSubject__c = 'Maak vervolgafspraak'

                        );
    insert type;
    type = new Task_types__c(name = 'Concept_rapportage_voorleggen__c' , Record_Type_Name__c = 'Concept rapportage voorleggen',
                        RelatedField__c = 'Concept_binnen_hoeveel_dagen_voorleggen__c', 
                        Account_Related__c = 'Concept_binnen_hoeveel_dagen_voorleggen__c',
                        AccountField__c = 'Concept_rapportage_voorleggen__c',
                        TaskSubject__c = 'Change Afwijkende product afspraken'

                        );
    insert type;

  }
}