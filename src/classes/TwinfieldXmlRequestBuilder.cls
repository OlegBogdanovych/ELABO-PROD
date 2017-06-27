public class TwinfieldXmlRequestBuilder {
  private static final String TF_USERNAME = Remote_API_Setting__c.getValues('Twinfield Account')!=null?Remote_API_Setting__c.getValues('Twinfield Account').value__c:'';
  private static final String TF_PASSWORD = Remote_API_Setting__c.getValues('Twinfield Pw')!=null?Remote_API_Setting__c.getValues('Twinfield Pw').value__c:'';
  private static final String TF_ORGANISATION = Remote_API_Setting__c.getValues('Twinfield Organisation')!=null?Remote_API_Setting__c.getValues('Twinfield Organisation').value__c:'';//'TWF-SAAS';
  private static final String TF_OFFICE = Remote_API_Setting__c.getValues('Twinfield Office')!=null?Remote_API_Setting__c.getValues('Twinfield Office').value__c:'';
  public static Map <String, TF_Ledger_Settings__c> ledgers = TF_Ledger_Settings__c.getAll();

  private static final String curr = 'EUR';

  public static final String XML_ENCODING = 'UTF-8';
  public static final String XML_VERSION = '1.0';
  
  public static String session_Id = null;
  public static String cluster_Url = null;
   
  /** 
   * BTW nummer
   * Not static from Twinfield. This could change.
   */
  public static final String VAT_CODE_FIELD_NAME = 'field4';
  
  /**
   * KVK - kamer van koophandel nummer
   * Not static from Twinfield. This could change.
   */
  public static final String COC_FIELD_NAME = 'field5';

  /**
   * Not static from Twinfield. This could change.
   */
  public static final String ADDRESS_FIELD_NAME = 'field2';
  
  public static String getTurnover (Id recordTypeId) {
    RecordType rT = [select Name from RecordType where Id =: recordTypeId];
    if (ledgers.containsKey('Turnover '+rT.Name)) {
      return ledgers.get('Turnover '+rT.Name).account_number__c;
    } else if (ledgers.containsKey('Debtor')) {
      return ledgers.get('Debtor').account_number__c;
    } else {
      return '';
    }
  }


  public static String sendRequest(String xmlRequest) {
    System.debug('TwinfieldXmlRequestBuilder TF_USERNAME ' + TF_USERNAME + ' ' + TF_PASSWORD);
    TF_SESSION.Logon(TF_USERNAME, TF_PASSWORD, TF_ORGANISATION);
    System.debug('TwinfieldXmlRequestBuilder login result ' + TF_SESSION.LogonResult);
    if(TF_SESSION.LogonResult != 'OK' || !TF_SESSION.loggedOn){
      throw new NotAuthorizedTwinfieldException('You first should logon before running the `processXml(String xmlRequest)` method.');
    }
    //enableRemoteSite(TF_SESSION.cluster_Url);
    TF_ProcessXML.ProcessXmlSoap xmlProcessor = new TF_ProcessXML.ProcessXmlSoap(TF_SESSION.cluster_Url, TF_SESSION.session_Id);
    String xmlResult = xmlProcessor.ProcessXmlString(xmlRequest);
    system.debug('result: '+xmlResult);
    TF_SESSION.abandon();
    return xmlResult;
  }
  
  public static String getCreateProjectRequest(String dossierName, String clienName, String dossierReference) {
    Xmlstreamwriter writer = new Xmlstreamwriter();
    
    writer.writeStartDocument(XML_ENCODING, XML_VERSION);
    writer.writeStartElement(null, 'dimension', null);
    writer.writeAttribute(null, null, 'status', 'active');
      writer.writeStartElement(null, 'office', null);
        writer.writeCharacters(TF_OFFICE);
      writer.writeEndElement();
      writer.writeStartElement(null, 'type', null);
        writer.writeCharacters('PRJ');
      writer.writeEndElement();
      writer.writeStartElement(null, 'code', null);
        writer.writeCharacters(dossierName+'');
      writer.writeEndElement();
      writer.writeStartElement(null, 'name', null);
        writer.writeCharacters(clienName);
      writer.writeEndElement();
      writer.writeStartElement(null, 'projects', null);
        writer.writeStartElement(null, 'customer ', null);
          writer.writeCharacters(dossierReference);
        writer.writeEndElement();
        writer.writeStartElement(null, 'billable ', null);
          writer.writeCharacters('false');
        writer.writeEndElement();
      writer.writeEndElement();
      /*writer.writeStartElement(null, 'financials', null);
        writer.writeStartElement(null, 'substitutionlevel', null);
          writer.writeCharacters('2');
        writer.writeEndElement();
        writer.writeStartElement(null, 'substitutewith', null);
        writer.writeAttribute(null, null, 'dimensiontype', 'KPL');
          //Can become variable in future
          writer.writeCharacters(TF_Ledger_Settings__c.getValues('Kostenplaats').account_number__c);
        writer.writeEndElement();
      writer.writeEndElement();*/
    writer.writeEndElement();
    system.debug(Logginglevel.INFO, 'writer contents after getCreateProjectRequest: '+writer.getXmlString());
    return writer.getXmlString();
  }
  public static String sendInvoice (Dossier__c dossier, String kenmerk, String polisnummer, String description, String invoicetype, String hoursType, Decimal amount, Decimal amountTar, String quantity, List <Task>tasks) {
    Xmlstreamwriter writer = new Xmlstreamwriter();
    Date dued = date.today();
    if (dossier.Relatie__r.Betalingsconditie__c != null) {
        dued = dued .addDays(Integer.valueOf(dossier.Relatie__r.Betalingsconditie__c));
    }
    if (amount == null) {
        amount = 0;
    }
    if (amountTar == null) {
        amountTar = 0;
    }
    String soort = '';
    if (dossier.Soort_onderzoek__c != null) {
        soort = dossier.Soort_onderzoek__c;
    }
    System.debug('duedate '+dued );
    System.debug('task '+tasks.size() + ' ' + tasks);
    
    String duedate = String.valueOf(dued).replace('-', '');
    String invoiceDate = String.valueOf(date.today()).replace('-', '');
    String costCenter = '';
    String dateS = '';
    if (dossier.Handler__c != null && dossier.Handler__r.Kostenplaats__c != null) {
        costCenter = dossier.Handler__r.Kostenplaats__c;
    }
    String client = '';
    if (dossier.Client__c != null) {
       client =  dossier.Client__r.Name;
    }
    if (quantity == null || quantity == '') {
        quantity = '1';
    }
      String afDate = '';
      if (dossier.Afspraak_gemaakt_op__c != null) {
          String d = String.valueOf(dossier.Afspraak_gemaakt_op__c.day());
          if (d.length() == 1){
              d = '0'+d;
          }
          String m = String.valueOf(dossier.Afspraak_gemaakt_op__c.month());
          if (m.length() == 1){
              m = '0'+m;
          }
          afDate = String.valueOf(d+'/'+m+'/'+dossier.Afspraak_gemaakt_op__c.year());
          
      }
      
    writer.writeStartDocument(XML_ENCODING, XML_VERSION);
    writer.writeStartElement(null, 'salesinvoice', null);
    writer.writeAttribute(null, null, 'status', 'Concept');
      
      writer.writeStartElement(null, 'header', null);
        writer.writeStartElement(null, 'invoicetype', null);
          writer.writeCharacters('FACTUUR');
        writer.writeEndElement();
        writer.writeStartElement(null, 'invoiceaddressnumber', null);
          writer.writeCharacters('1');
        writer.writeEndElement();
        writer.writeStartElement(null, 'office', null);
          writer.writeCharacters(TF_OFFICE);
        writer.writeEndElement();
        writer.writeStartElement(null, 'invoicedate', null);
          writer.writeCharacters(invoiceDate);//invoiceDate
        writer.writeEndElement();
        writer.writeStartElement(null, 'customer', null);
          writer.writeCharacters(dossier.Relatie__r.Debiteurnummer__c);
        writer.writeEndElement();
        writer.writeStartElement(null, 'currency', null);
          writer.writeCharacters('EUR');
        writer.writeEndElement();
        writer.writeStartElement(null, 'duedate', null);
          writer.writeCharacters(duedate);
        writer.writeEndElement();
        writer.writeStartElement(null, 'paymentmethod', null);
          writer.writeCharacters('bank');
        writer.writeEndElement();
        writer.writeStartElement(null, 'headertext', null);
          writer.writeCharacters('Onze referentie: '+dossier.Name+'\nUw referentie: '+kenmerk+' ' + polisnummer+'\nBetreft: '+soort +
                                '\nClient: ' +  client  +'\nProfessional: ' + dossier.Handler__r.Name + '\nBezoekdatum: '+afDate);
        writer.writeEndElement();
      
      writer.writeEndElement();
      writer.writeStartElement(null, 'lines', null);
     
          if (invoiceType == 'Uurtarief') {
            for (Task task: tasks){
              String am;

              Boolean inTask = false;
              if (task.RecordType.Name == 'Urenregistratie') {
                inTask = true;
                if (task.Aantal_uur__c!= null) {
                    quantity = String.valueOF(task.Aantal_uur__c);
                } 
                if (task.Uursoort__c!= null) {
                    description = String.valueOF(task.Uursoort__c);
                } 
                if (task.Datum__c!= null) {
                    dateS = String.valueOF(task.Datum__c);
                }   
                am = String.valueOf(amount);
              } else if (hoursType.contains('KM') && task.RecordType.Name == 'Kilometerregistratie') {
                inTask = true;
                if (task.Aantal_Kilometers_gereden__c != null) {
                    quantity = String.valueOF(task.Aantal_Kilometers_gereden__c);
                }
                if (task.Reden__c!= null) {
                    description = String.valueOF(task.Reden__c);
                } 
                if (task.Datum_gereden__c!= null) {
                    dateS = String.valueOF(task.Datum_gereden__c);
                } 
                am = String.valueOf(amountTar);
              }
              
                if (quantity == null || quantity == '') {
                    quantity = '1';
                }
              if (quantity != '' && inTask  ) {
                writer.writeStartElement(null, 'line', null);
                  writer.writeAttribute(null, null, 'id', '1');
                  writer.writeStartElement(null, 'article', null);
                    writer.writeCharacters('0');
                  writer.writeEndElement();
                  
                  writer.writeStartElement(null, 'vatcode', null);
                    writer.writeCharacters(getVatCode());
                  writer.writeEndElement();
                  
                  writer.writeStartElement(null, 'quantity', null);
                    writer.writeCharacters(quantity);
                  writer.writeEndElement();
                  writer.writeStartElement(null, 'description', null);
                    writer.writeCharacters(description);
                  writer.writeEndElement();
                  dateS = String.valueOf(dateS.replace('-', ''));
                  /*writer.writeStartElement(null, 'invoicedate', null);
                    writer.writeCharacters(dateS);//invoiceDate
                  writer.writeEndElement();
  */
              
                  writer.writeStartElement(null, 'unitspriceexcl', null);
                    writer.writeCharacters(String.valueOF(am));//'vergoeding per km'
                  writer.writeEndElement();


                  writer.writeStartElement(null, 'freetext1', null);
                    writer.writeCharacters( getTurnover(dossier.RecordTypeId));
                  writer.writeEndElement();
                  writer.writeStartElement(null, 'freetext2', null);
                    writer.writeCharacters(costCenter);
                  writer.writeEndElement();
                  writer.writeStartElement(null, 'freetext3', null);
                      writer.writeCharacters(dossier.Name);
                    writer.writeEndElement();
                  writer.writeStartElement(null, 'performancetype', null);
                    writer.writeCharacters('');
                  writer.writeEndElement();
                writer.writeEndElement();
              }
            }
          } else  {
              writer.writeStartElement(null, 'line', null);
                writer.writeAttribute(null, null, 'id', '1');
                writer.writeStartElement(null, 'article', null);
                  writer.writeCharacters('0');
                writer.writeEndElement();
                writer.writeStartElement(null, 'description', null);
                  writer.writeCharacters(description);
                writer.writeEndElement();
                writer.writeStartElement(null, 'vatcode', null);
                  writer.writeCharacters(getVatCode());                                                     ////////?????????
                writer.writeEndElement();
                writer.writeStartElement(null, 'quantity', null);
                  writer.writeCharacters(quantity);
                writer.writeEndElement();
                writer.writeStartElement(null, 'unitspriceexcl', null);
                  writer.writeCharacters(String.valueOF(amount));
                writer.writeEndElement();
               writer.writeStartElement(null, 'freetext1', null);
                writer.writeCharacters( getTurnover(dossier.RecordTypeId));
              writer.writeEndElement();
              writer.writeStartElement(null, 'freetext2', null);
                writer.writeCharacters(dossier.Handler__r.Kostenplaats__c);
              writer.writeEndElement();
              writer.writeStartElement(null, 'freetext3', null);
                  writer.writeCharacters(dossier.Name);
                writer.writeEndElement();
                writer.writeStartElement(null, 'performancetype', null);
                  writer.writeCharacters('');
                writer.writeEndElement();
              writer.writeEndElement();
            }
            
        
      writer.writeEndElement();
    writer.writeEndElement();

    system.debug(Logginglevel.INFO, 'writer contents after sendInvoice: '+writer.getXmlString());
    return writer.getXmlString();
  }

  /*public static String getCreateCostCenter (String dossierName,  String code) {
    Xmlstreamwriter writer = new Xmlstreamwriter();
    
    writer.writeStartDocument(XML_ENCODING, XML_VERSION);
    writer.writeStartElement(null, 'dimension', null);
    writer.writeAttribute(null, null, 'status', 'active');
      writer.writeStartElement(null, 'office', null);
        writer.writeCharacters(TF_OFFICE);
      writer.writeEndElement();
      writer.writeStartElement(null, 'type', null);
        writer.writeCharacters('KPL');
      writer.writeEndElement();
      writer.writeStartElement(null, 'code', null);
        writer.writeCharacters(code+'');
      writer.writeEndElement();
      writer.writeStartElement(null, 'name', null);
        writer.writeCharacters(dossierName);
      writer.writeEndElement();
    writer.writeEndElement();
    system.debug(Logginglevel.INFO, 'writer contents after getCreateCostCenter: '+writer.getXmlString());
    return writer.getXmlString();
  }
*/
  public static String getVatCode () {
    String vatcode = '';
    List <Vat_code__c> vatcodes = [select Id, Name from Vat_code__c limit 1];
    if (vatcodes!= null) {
      vatcode = vatcodes.get(0).Name;
    }
    return vatcode;
  }
  public static String getCreateRelationRequest(String relationType, Account company, String duedate) {
    Set<String> allowedTypes = new Set<String>{'DEB'};
    relationType = relationType!=null?relationType.toUpperCase():null;
    if(relationType == null || !allowedTypes.contains(relationType)) {
      NotAuthorizedTwinfieldException excep = new NotAuthorizedTwinfieldException();
      excep.setMessage('Fout in Relatie type.');
      throw excep;
    }
        
    if(company==null) {
      NotAuthorizedTwinfieldException excep = new NotAuthorizedTwinfieldException();
      excep.setMessage('Een Relatie die crediteur of debiteur is moet gekoppeld zijn aan een bedrijf.');
      throw excep;
    }
    
    String code = '';
    String coc = '';
    if (company.KVK_Nummer__c != null) {
        coc = company.KVK_Nummer__c;
        }
    if (company.Debiteurnummer__c != null) {
      code = company.Debiteurnummer__c;
    }
    String inputName = company.name;
    String website = company.website;
    String address = '';//company.BillingAddres;
    String terAlt = '';
    if (company.Ter_attentie_van__c != null) {
        terAlt  = company.Ter_attentie_van__c ;
    }
    String cocnr = '';//company.cocNr__c;
    String postcode = '';
    if (company.BillingPostalCode != null){
      postcode = company.BillingPostalCode;
    }
    if ((postcode == null || postcode == '') && company.ShippingPostalCode != null) {
      postcode = company.ShippingPostalCode;
    }
    String street = '';
    if (company.BillingStreet != null){
      street = company.BillingStreet;
    }
    if ((street == null || street == '') && company.ShippingStreet != null) {
      street = company.ShippingStreet;
    }
    String city = '';
    if (company.BillingCity != null) {
      city = company.BillingCity;
    }
    if ((city == null || city == '') && company.ShippingCity != null) {
      city = company.ShippingCity;
    }
    String country ='NL';// company.countryCode__c;
    String telephone = company.Phone;
   
    String email = company.Factuur_E_mail__c;
    String vatcode = getVatCode();
    String dueDays = '';
    if (company.Betalingsconditie__c != null) {
      dueDays = String.valueOf(company.Betalingsconditie__c);
    } 
   
    Xmlstreamwriter writer = new Xmlstreamwriter();
    
    writer.writeStartDocument(XML_ENCODING, XML_VERSION);
    writer.writeStartElement(null, 'dimension', null);
      writer.writeStartElement(null, 'type', null);
        writer.writeCharacters('DEB');
      writer.writeEndElement();
      writer.writeStartElement(null, 'office', null);
        writer.writeCharacters(TF_OFFICE);
      writer.writeEndElement();
      writer.writeStartElement(null, 'name', null);
        writer.writeCharacters(inputName+'');
      writer.writeEndElement();
      writer.writeStartElement(null, 'website', null);
        writer.writeCharacters(website+'');
      writer.writeEndElement();
      if (code != ''){
        writer.writeStartElement(null, 'code', null);
          writer.writeCharacters(code+'');
        writer.writeEndElement();
      }
      writer.writeStartElement(null, 'financials', null);
        writer.writeStartElement(null, 'matchtype', null);            
          writer.writeCharacters('customersupplier');
        writer.writeEndElement();
        writer.writeStartElement(null, 'duedays', null);
          writer.writeCharacters(dueDays);                                 
        writer.writeEndElement();
        writer.writeStartElement(null, 'payavailable', null);
          writer.writeCharacters('FALSE');
        writer.writeEndElement();
        writer.writeStartElement(null, 'meansofpayment', null);
          writer.writeCharacters('none');
        writer.writeEndElement();
        writer.writeStartElement(null, 'ebilling', null);
          writer.writeCharacters('false');                                  
        writer.writeEndElement();
        writer.writeStartElement(null, 'ebillmail', null);
          writer.writeCharacters(company.Factuur_E_mail__c+'');                                  
        writer.writeEndElement();
        writer.writeStartElement(null, 'vatcode', null);
          writer.writeCharacters(vatcode);
        writer.writeEndElement();
      writer.writeEndElement();

      writer.writeStartElement(null, 'addresses', null);
        writer.writeStartElement(null, 'address', null);
        writer.writeAttribute(null, null, 'id', '1');
        writer.writeAttribute(null, null, 'type', 'invoice');
        writer.writeAttribute(null, null, 'default', 'true');
          
          writer.writeStartElement(null, 'name', null);
            writer.writeCharacters(inputName+'');
          writer.writeEndElement();
          
          writer.writeStartElement(null, 'postcode', null);
            writer.writeCharacters(postcode+'');
          writer.writeEndElement();
          writer.writeStartElement(null, 'city', null);
            writer.writeCharacters(city+'');
          writer.writeEndElement();
          writer.writeStartElement(null, 'country', null);
            writer.writeCharacters(country+'');
          writer.writeEndElement();
          writer.writeStartElement(null, 'telephone', null);
            writer.writeCharacters(telephone+'');
          writer.writeEndElement();
          writer.writeStartElement(null, 'email', null);
            writer.writeCharacters(email+'');
          writer.writeEndElement();
          writer.writeStartElement(null, 'field1', null);
            writer.writeCharacters(terAlt  );
          writer.writeEndElement();
          writer.writeStartElement(null, 'field2', null);
            writer.writeCharacters(street);//Dantestraat 17
          writer.writeEndElement();
         
          writer.writeStartElement(null, 'field5', null);
            writer.writeCharacters(coc);
          writer.writeEndElement();
        writer.writeEndElement();
      writer.writeEndElement();

   
    writer.writeEndElement();
    System.debug('customer ' +  writer.getXmlString());
    return writer.getXmlString();
  }
  
  public static String encapsulateXLMString(String xmlString) {
    String retXMLString = '<?xml version="1.0" encoding="UTF-8"?><transactions>'+xmlString+'</transactions>';
    return retXMLString;
  }
  
  
  
  
  
  /*public static Xmlstreamwriter addLine(Xmlstreamwriter writer, String dim2Value , String lineType, Integer lineId, String dCAccount, Decimal amount, String description, String debitCredit, String vatCode, String dim3Value) {
    writer.writeStartElement(null, 'line', null);
    writer.writeAttribute(null, null, 'type', lineType);
    writer.writeAttribute(null, null, 'id', String.valueOf(lineId));
      writer.writeStartElement(null, 'dim1', null);
        writer.writeCharacters(dCAccount);
      writer.writeEndElement();
      if(dim2Value!=null) {
        writer.writeStartElement(null, 'dim2', null);
          writer.writeCharacters(dim2Value);
        writer.writeEndElement();
      }
      if(dim3Value!=null) {
        writer.writeStartElement(null, 'dim3', null);
          writer.writeCharacters(dim3Value);
        writer.writeEndElement();
      }
      writer.writeStartElement(null, 'value', null);
        writer.writeCharacters(String.valueOf(amount));
      writer.writeEndElement();
      writer.writeStartElement(null, 'debitcredit', null);
        writer.writeCharacters(debitCredit);
      writer.writeEndElement();
      if(description != null) {
        description = description.length() > 110?description.subString(0, 110): description;
        writer.writeStartElement(null, 'description', null);
          writer.writeCharacters(description);
        writer.writeEndElement();
      }
      
      writer.writeStartElement(null, 'vatcode', null);
        writer.writeCharacters(getVatCode());
      writer.writeEndElement();
      
    writer.writeEndElement();
    system.debug(Logginglevel.INFO, 'writer contents after addLine: '+writer.getXmlString());
    return writer;
  }*/

}