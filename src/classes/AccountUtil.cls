public with sharing class AccountUtil {
    public static void entry(TriggerParams triggerParams) {
        List<Account> triggerNew = (List<Account>)triggerParams.triggerNew;
        List<Account> triggerOld = (List<Account>)triggerParams.triggerOld;
        Map<Id, Account> oldMap = (Map<Id, Account>)triggerParams.oldMap;
        Map<Id, Account> newMap = (Map<Id, Account>)triggerParams.newMap;
        List <Account> accountsToSetNextDate = new List <Account>();
        Set <Id> accountIds = new Set <Id>();
        if (triggerParams.isBefore) {
            if(triggerParams.isUpdate) {
                
                for (Account acc: triggerNew) {
                    if (oldMap.get(acc.Id).Facturatieritme__c !=newMap.get(acc.Id).Facturatieritme__c ) {
                        
                        accountsToSetNextDate.add(acc);
                    }
                    
                }
                setNextDateForInvoiceSend( accountsToSetNextDate);
             } else if (triggerParams.IsInsert) {
                setNextDateForInvoiceSend( triggerNew);
             }
        }
        if (triggerParams.isAfter) {
            if(triggerParams.isUpdate) {
                
                for (Account acc: triggerNew) {
                   
                    if (acc.Send_request_to_TF__c) {//&& acc.Debiteurnummer__c == null
                        accountIds.add(acc.Id);
                    }
                }
                
            } 
            if(!triggerHelper.entryHasStartedTFAcc){
                if((!System.isFuture() && !System.isScheduled() && !System.isBatch())||(!System.isFuture() && Test.isRunningTest()) ) {
                    getTFNumber(accountIds);
                }
            } 
            if (!triggerHelper.entryHasStartedTFAcc){
              triggerHelper.recursiveHelperTFAcc(true);
            } 
        } 
    }
    public static void setNextDateForInvoiceSend(List <Account> accounts) {
        Map <String, Periodic__c> periodics = Periodic__c.getAll();
        for (Account account: accounts) {
            
            account.NextSend__c = date.today();
            
            if (periodics.containsKey(account.Facturatieritme__c) ) {
                if (periodics.get(account.Facturatieritme__c).isDay__c) {
                    account.NextSend__c = account.NextSend__c.addDays(Integer.valueOf(periodics.get(account.Facturatieritme__c).number__c));
                } else {
                    account.NextSend__c = account.NextSend__c.addMonths(Integer.valueOf(periodics.get(account.Facturatieritme__c).number__c));
                }
                account.NextSend__c = account.NextSend__c.addDays(1);
            }
        }
    }
    public static void getTfNumberForDeb(Set <ID> accountIds){
        Map <Id, Account> accountByIds = new Map <Id, Account>(AccountDAO.getParentAccounts(accountIds));
        System.debug('acc' + accountByIds.size()+ ' ' + accountByIds);
        for (Account account: accountByIds.values()) {
            Boolean hasErrors = false;
            String credRequestString = TwinfieldXmlRequestBuilder.getCreateRelationRequest('DEB', account, '30');
            System.debug('hasErrors:' + hasErrors);
            if (!hasErrors) {
                System.debug('credRequestString:' + credRequestString);
                hasErrors = sentToTwinfield('DEB', credRequestString, account);
            }
        }
    }
    @future(callout = true)
    public static void getTFNumber(Set <ID> accountIds){
        System.debug('@future AccountUtil.getTFNumber' + accountIds);
        getTfNumberForDeb(accountIds);
    }
    private static boolean sentToTwinfield(String dimType, String requestString, Account account) {
        boolean hasErrors = true;
        String responce = '';
        List<TwinfieldXmlErrorMessage> errorForLog = new List <TwinfieldXmlErrorMessage>();
        try {
          String xmlResult = '';
          if (Test.isRunningTest()) {
            if (dimType == 'DEB') {
              xmlResult = '<dimension status="active" result="1"><type name="Debiteuren" shortname="Debiteuren">DEB</type><name>Jantje</name><website>null</website>'+
              '<addresses><address type="invoice" default="true" id="1"><field2>null</field2><postcode>null</postcode><city>null</city><country name="Nederland" shortname="">NL</country>'+
              '<telephone>null</telephone><name>Jantje</name><telefax></telefax><email></email><contact></contact><field1></field1><field3></field3><field4></field4><field5></field5><field6>'+
              '</field6></address></addresses><office name="NLI Test" shortname="">8109999937</office><code>D-0001</code><uid>0563b953-fd63-43e5-b130-47bb4e5afa87</uid><inuse>false</inuse><shortname>'+
              '</shortname><behaviour>normal</behaviour><touched>0</touched><beginperiod>0</beginperiod><beginyear>0</beginyear><endperiod>0</endperiod><endyear>0</endyear><vatnumber></vatnumber>'+
              '<cocnumber></cocnumber><editdimensionname>true</editdimensionname><financials><level>2</level><matchtype>customersupplier</matchtype><accounttype>inherit</accounttype>'+
              '<subanalyse>false</subanalyse><payavailable>false</payavailable><meansofpayment>none</meansofpayment><paycode></paycode><ebilling>false</ebilling><ebillmail></ebillmail>'+
              '<duedays>30</duedays><relationsreference></relationsreference><substitutionlevel>1</substitutionlevel><substitutewith>13000</substitutewith><vatobligatory>false</vatobligatory>'+
              '<performancetype /><collectmandate><id>D-0053</id><signaturedate></signaturedate><firstrundate></firstrundate></collectmandate><vatcode name="" shortname="" type=""></vatcode>'+
              '<vattype name="" shortname=""></vattype><childvalidations><childvalidation type="code" level="1">13000</childvalidation></childvalidations></financials><creditmanagement>'+
              '<responsibleuser></responsibleuser><basecreditlimit>0.00</basecreditlimit><sendreminder>true</sendreminder><reminderemail></reminderemail><blocked locked="true" modified="">false</blocked>'+
              '<freetext1></freetext1><freetext2></freetext2><freetext3></freetext3><comment></comment><responsibleuser name="" shortname=""></responsibleuser><basecreditlimit>0.00</basecreditlimit>'+
              '<sendreminder>true</sendreminder><reminderemail></reminderemail><blocked locked="true" modified="">false</blocked><freetext1></freetext1><freetext2></freetext2><freetext3></freetext3>'+
              '<comment></comment></creditmanagement><banks /></dimension>';
            } 
          } else {
            xmlResult = TwinfieldXmlRequestBuilder.sendRequest(requestString);
            //ErrorHandeling.saveLog('REQUEST ' + System.now(), requestString, account.id);
          }
          List<TwinfieldXmlErrorMessage> errors = TwinfieldXmlUtil.parseXmlErrors(xmlResult);
          responce = xmlResult;
          errorForLog.addAll(errors);
          String errorString = '';
            for(TwinfieldXmlErrorMessage error : errorForLog) {
              errorString += error.getFormattedError() + '\n------\n';
            }
          if (errors.size() > 0) {
              ErrorHandeling.saveLog(errorString , responce, account.id);
          }
          Twinfield_ParsedXmlResult result = TwinfieldXmlUtil.parseXmlResult(xmlResult, '/dimension/code');
          hasErrors = result.hasErrors;
          System.debug('hasErrors' + hasErrors);
          System.debug('result' + result);
          if (!result.hasErrors) {
            if (dimType.equals('DEB')) {
                if (account.Debiteurnummer__c == null ||  account.Debiteurnummer__c == '') {
                    account.Debiteurnummer__c = result.identifier;
                }
            }
            hasErrors = false;
          }
          update account;
        } catch (Exception e) {
            
            hasErrors = true;
            System.debug('Error : ' + e.getMessage());
            String errorString = '';
            for(TwinfieldXmlErrorMessage error : errorForLog) {
              errorString += error.getFormattedError() + '\n------\n';
            }
            ErrorHandeling.saveLog(errorString + ' ' +e.getMessage(), responce, account.id);
        }
        return hasErrors;
  }
}