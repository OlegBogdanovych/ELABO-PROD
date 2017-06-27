public without sharing class DossierUtil {
    public DossierUtil() {
    }
    
    public static void entry(TriggerParams triggerParams) {
        List<Dossier__c> triggerNew = (List<Dossier__c>)triggerParams.triggerNew;
        List<Dossier__c> triggerOld = (List<Dossier__c>)triggerParams.triggerOld;
        Map<Id, Dossier__c> oldMap = (Map<Id, Dossier__c>)triggerParams.oldMap;
        Map<Id, Dossier__c> newMap = (Map<Id, Dossier__c>)triggerParams.newMap;

        Set <Id> oldMapSet;
        Set <Id> newMapSet;

        Boolean addDebNumber = false;
        
        List <Account> accounts = new List <Account>();
        Set <Id> dossierIds = new Set <Id>();
        if (triggerParams.isBefore) {
            if ( triggerParams.isUpdate) {

                SetDateToGes(newMap);
                //List <Dossier__c> trigNew = new List  <Dossier__c>();
                //trigNew.addAll(triggerNew);
                Map<Id, Dossier__c> doss = new Map<Id, Dossier__c>();
                //List <Dossier__c> trigNewToShare = new List  <Dossier__c>();
                List <Dossier__c> trigNewToShare = new List  <Dossier__c>();
                List <Dossier__c> checkTasksForNewProf = new List  <Dossier__c>();
                Map<Id, Dossier__c> toclose = new Map<Id, Dossier__c>();
                //Map<Id, Dossier__c> changeDateDoss = new Map<Id, Dossier__c>();
                Set<Id> changeDateDossId = new Set <Id>();
                for (Dossier__c dos: triggerNew) {
                    if (newMap.get(dos.id).status__c != oldMap.get(dos.id).status__c && newMap.get(dos.Id).status__c == 'Gesloten') {
                        
                        doss.put(dos.Id, dos);
                    }
                    if (newMap.get(dos.id).handler__c != oldMap.get(dos.id).handler__c ) {
                        trigNewToShare.add(dos);
                    }
                    if (newMap.get(dos.id).Ingangsdatum__c != oldMap.get(dos.id).Ingangsdatum__c  || newMap.get(dos.id).Soort_onderzoek__c != oldMap.get(dos.id).Soort_onderzoek__c ) {
                        //changeDateDoss.put(dos.Id, dos);
                        changeDateDossId.add(dos.Id);
                        System.debug('*** changeDateDossId -- ' + dos.Name + ' - ' + dos.Id);
                    }
                    if (newMap.get(dos.id).Drive_document_link__c!= oldMap.get(dos.id).Drive_document_link__c && newMap.get(dos.id).Drive_document_link__c != null) {
                        dos.Document_link__c = dos.Drive_document_link__c.substring(0, dos.Drive_document_link__c.lastIndexOf('/')) + '/export?format=pdf';
                    }
                    if (newMap.get(dos.id).Tussenrapportage__c != oldMap.get(dos.id).Tussenrapportage__c && newMap.get(dos.id).Tussenrapportage__c != null) {
                        dos.Drive_Tussenrapportage__c = dos.Tussenrapportage__c.substring(0, dos.Tussenrapportage__c.lastIndexOf('/')) + '/export?format=pdf';
                    }
                    if (newMap.get(dos.id).handler__c != oldMap.get(dos.id).handler__c && newMap.get(dos.id).handler__c  != null ) {
                        checkTasksForNewProf.add(dos);
                    }

                }

                if((!System.isFuture() && !System.isBatch())||(!System.isFuture() && Test.isRunningTest()) ) {
                  if(!triggerHelper.entryHasStartedBeforeUp){
                    apexSharingUpdate(trigNewToShare, oldMap , null);
                  }
                }
                if (doss.size() > 0 || checkTasksForNewProf.size() > 0) {
                    for (dossier__c dos: doss.values()) {
                        
                            toclose.put(dos.id, dos);
                    }
                    
                  checkTasks(oldMap , toclose, newMap);
                } 
                if((!System.isFuture() && !System.isBatch())||(!System.isFuture() && Test.isRunningTest()) ) {
                  if(!triggerHelper.entryHasStartedBeforeUp){

                    addEndDate(changeDateDossId);
                  }            
                }
                if(!triggerHelper.entryHasStartedBeforeUp){
                   triggerHelper.recursiveHelperBeforeUp(true);
                }
            }
            if (triggerParams.isInsert){
                //SetDateToGes(newMap);
            }
        }else if (triggerParams.isAfter)  {
            if(triggerParams.isInsert) {
                if(!System.isFuture() ) {
                  if (!triggerHelper.entryHasStartedAfterIn){
                    apexSharingInsert(newMap.keyset(), null);
                    GoogleDrive.createFolderForDossier(newMap.keyset());
                  }
                  if (!triggerHelper.entryHasStartedAfterIn){
                    triggerHelper.recursiveHelperAfterIn(true);
                  }
                }
            }   
            if(triggerParams.isUpdate) {
                if(!System.isFuture() && !System.isScheduled() && !System.isBatch() ) {
                    Set <Id> dosIds = new Set <Id>();
                    for (Dossier__c dos: newMap.values()) {
                        if (newMap.get(dos.id).handler__c != oldMap.get(dos.id).handler__c ) {
                          dosIds.add(dos.id);
                        }
                    }

                    if (!triggerHelper.entryHasStartedAfterUp){
                      if(!triggerHelper.entryHasStartedAfterIn){

                        GoogleDrive.createFolderForDossier(newMap.keyset());

                      }
                      System.debug(' ***  entryHasStartedAfterUp');
                      Map<Id, Dossier__c> changedDossierMap = new Map<Id, Dossier__c>();
                      for(Dossier__c dos : newMap.values()){
                        if (newMap.get(dos.id).Product_exception__c != oldMap.get(dos.id).Product_exception__c){
                          changedDossierMap.put(dos.Id, dos);
                      }
                      if(changedDossierMap != null){
                        changeProductException(changedDossierMap);
                      }
                    }
                    TaskGenerator.generateTasks(dosIds);
                }
                Set <Id> accountIds = new Set <Id>();
                //List <Dossier__c> dossiers = DossierDao.getDossiersBySetId(newMap.keySet());
                for (Dossier__c dos: newMap.values()) {
                    accountIds.add(dos.Relatie__c);
                }
                  Map <Id, Account> accountsById = new Map <Id, Account>(AccountDao.getParentAccounts(accountIds));
                  for (Dossier__c dossier: newMap.values()) {
                    if (dossier.Relatie__c != null && dossier.handler__c != null && accountsById.get(dossier.Relatie__c).RecordType.Name == '1 Opdrachtgever') {
                    System.debug(accountsById.get(dossier.Relatie__c).Debiteurnummer__c);
                      if (accountsById.get(dossier.Relatie__c).Debiteurnummer__c == null || accountsById.get(dossier.Relatie__c).Debiteurnummer__c == ''){
                        addDebNumber = true;
                        accounts.add(accountsById.get(dossier.Relatie__c));
                        dossierIds.add(dossier.id);
                      }
                    }
                  }
                  System.debug(' addDebNumber '+ addDebNumber);
                  System.debug(' dossierIds '+ dossierIds);
                  System.debug(' accounts '+ accounts);
                  Set <Account> accSet = new Set <Account>(accounts);
                   accounts = new List <Account>();
                    accounts.addAll(accSet);
                  if (addDebNumber) {  
                    if(!System.isFuture() && !System.isScheduled() && !System.isBatch()) {
                      for (Account acc: accounts) {
                          acc.Send_request_to_TF__c = true;
                      }
                      update accounts;
                      System.debug('dossierIds' + dossierIds);
                      AccountSchedule accountFuture = new AccountSchedule(dossierIds);
                      try {
                          List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name, State, NextFireTime
                                  FROM CronTrigger where CronJobDetail.Name=:'Run future'+dossierIds];
                          
                          if (jobs.size() == 0) {
                              String jobId = System.scheduleBatch(accountFuture, 'Run future'+dossierIds, 1);
                          }
                      } catch(Exception e) {
                          for (Dossier__c dossier: newMap.values()) {
                          try {
                              if(  Oldmap.containsKey(dossier.id)){ 
                                  dossier.addError(Label.Wait_for_future);
                              }
                              } catch (Exception ec){
                                  System.debug('ERROR' + ec.getMessage());
                              }
                          }
                      }
                    }
                  }else{
                    if((!System.isFuture() && !System.isScheduled() && !System.isBatch())||(!System.isFuture() && Test.isRunningTest()) ) {

                      if(!triggerHelper.entryHasStartedTFDos){
                        getTFNumberFuture(newMap.keySet());
                      }
                      //Set <ID> dosIds = new Set <Id>();
                      for (Dossier__c dos: newMap.values()) {
                        if (newMap.get(dos.id).status__c != oldMap.get(dos.id).status__c && newMap.get(dos.Id).status__c == 'Gesloten' && !dos.Invoice_Is_Sent__c) {
                            dosIds.add(dos.Id);
                            sendInvoices(dosIds);

                        }
                      //}
                      //if(!System.isFuture() && !System.isScheduled() && !System.isBatch() ) {
                      //  System.debug('******* sendInvoices  -  ' + dosIds);

                      //  sendInvoices(dosIds);
                      //  System.debug('******* sendInvoices completed');
                      }   
                    }
                  }
                  if (!triggerHelper.entryHasStartedAfterUp){
                    triggerHelper.recursiveHelperAfterUp(true);
                  } 
                  if (!triggerHelper.entryHasStartedTFDos){
                    triggerHelper.recursiveHelperTFDos(true);
                  } 
              }

        }       
        

    }
}

    public static void changeProductException(Map<Id, Dossier__c> changedDossier) {
      //Map <Id, Dossier__c> changedDossier = new Map <Id, Dossier__c>([SELECT Id, Name, Relatie__c, Verwijzer__c, Product_exception__c FROM Dossier__c WHERE Id in: changedDossierSet]);
      Map <Id, Dossierproduct__c> productsById = new Map <Id, Dossierproduct__c>([select Id, Product__c, Dossier__c from Dossierproduct__c where Dossier__c in: changedDossier.values()]);

      Map <Id, Id> dosPrByDosId = new Map <Id, Id>();
      Map <Id, Id> prByDosId = new Map <Id, Id>();
      for (Dossierproduct__c pr: productsById.values() ) {
        dosPrByDosId.put(pr.Dossier__c, pr.Id);
        prByDosId.put(pr.Dossier__c, pr.Product__c);
      }

      Set <id> accId = new Set <id>();

      for (Dossier__c pr: changedDossier.values()) {
        accId.add(pr.Relatie__c);
        accId.add(pr.Verwijzer__c);
      }

      System.debug('accId ' + accId.size() + ' ' + accId );
      Map <Id, Account> accountsById = new Map <Id,Account>([select Id from Account where id in: accId]);
      Map <Id, Product_exeption__c> exeptionsById = new Map <Id, Product_exeption__c>([select Id, Account__c, Product__c from Product_exeption__c where Account__c in: accId]);
      System.debug('exeptionsById ' + exeptionsById.size() + ' ' + exeptionsById );
      Map <Id, Map <Id, Product_exeption__c>> exceptionsByProductByAccount = new Map <Id, Map <Id, Product_exeption__c>>();
      for (Product_exeption__c pr: exeptionsById.values()) {
        if (exceptionsByProductByAccount.containsKey(pr.Account__c)){
     
          exceptionsByProductByAccount.get(pr.Account__c).put(pr.Product__c, pr);
        } else {
          Map <Id, Product_exeption__c> exceptionByProduct = new Map <Id, Product_exeption__c>();
          exceptionByProduct.put(pr.Product__c, pr);
          exceptionsByProductByAccount.put(pr.Account__c, exceptionByProduct);
        }
        
      }
      System.debug('exceptionsByProductByAccount '+exceptionsByProductByAccount.size() + ' ' + exceptionsByProductByAccount);

      List <Dossierproduct__c> toUpdate = new List <Dossierproduct__c>();
      for (Dossier__c dos: changedDossier.values()){
        System.debug('******* changedDossier **** - ' + changedDossier.get(dos.id));
          if (dosPrByDosId.containsKey(dos.id)) {
            System.debug(changedDossier.get(dos.id).Product_exception__c);
            if (changedDossier.get(dos.id).Product_exception__c == 'Geen uitzondering'){
              
                Dossierproduct__c dp = productsById.get(dosPrByDosId.get(dos.id));
                dp.Product_exeption__c = null;
                toUpdate.add(dp);
            } 
            if (changedDossier.get(dos.id).Product_exception__c == 'Relatie'){
              
                Dossierproduct__c dp = productsById.get(dosPrByDosId.get(dos.id));
                //System.debug('exceptionsByProductByAccount.get(dos.Relatie__c) ' + exceptionsByProductByAccount.get(dos.Relatie__c));
                //System.debug('prByDosId.get(dp.Product__c)' + prByDosId + ' ' + dp.Product__c);
                //System.debug('exceptionsByProductByAccount.get(dos.Relatie__c).get(prByDosId.get(dp.Product__c) ' + exceptionsByProductByAccount.get(dos.Relatie__c).get(prByDosId.get(dp.Product__c)));
                //System.debug('exeptionsById.get(exceptionsByProductByAccount.get(dos.Relatie__c).get(prByDosId.get(dp.Product__c)).id) ' + exeptionsById.get(exceptionsByProductByAccount.get(dos.Relatie__c).get(dp.Product__c).id));
                if (exceptionsByProductByAccount.containsKey(dos.Relatie__c)
                    && exceptionsByProductByAccount.get(dos.Relatie__c).containsKey(dp.Product__c)
                    && exeptionsById.containsKey(exceptionsByProductByAccount.get(dos.Relatie__c).get(dp.Product__c).id)  ) {
                  dp.Product_exeption__c = exeptionsById.get(exceptionsByProductByAccount.get(dos.Relatie__c).get(dp.Product__c).id).id;
                  System.debug('********dp.Product_exeption__c Relatie' + dp.Product_exeption__c);

                } else {
                  dp.Product_exeption__c = null;
                }
                toUpdate.add(dp);
            }
            if (changedDossier.get(dos.id).Product_exception__c == 'Verwijzer'){
                Dossierproduct__c dp = productsById.get(dosPrByDosId.get(dos.id));
                //System.debug('exceptionsByProductByAccount.get(dos.Verwijzer) ' + exceptionsByProductByAccount.get(dos.Verwijzer__c));
                //System.debug('prByDosId.get(dp.Product__c)' + prByDosId + ' ' + dp.Product__c);
                //System.debug('exceptionsByProductByAccount.get(dos.Verwijzer).get(prByDosId.get(dp.Product__c) ' + exceptionsByProductByAccount.get(dos.Verwijzer__c).get(prByDosId.get(dp.Product__c)));
                //System.debug('exeptionsById.get(exceptionsByProductByAccount.get(dos.Verwijzer).get(prByDosId.get(dp.Product__c)).id) ' + exeptionsById.get(exceptionsByProductByAccount.get(dos.Verwijzer__c).get(dp.Product__c).id));
                
                
                if (exceptionsByProductByAccount.containsKey(dos.Verwijzer__c)
                    && exceptionsByProductByAccount.get(dos.Verwijzer__c).containsKey(dp.Product__c)
                    && exeptionsById.containsKey(exceptionsByProductByAccount.get(dos.Verwijzer__c).get(dp.Product__c).id)  ) {
                  dp.Product_exeption__c = exeptionsById.get(exceptionsByProductByAccount.get(dos.Verwijzer__c).get(dp.Product__c).id).id;
                } else {
                  dp.Product_exeption__c = null;
                }
                toUpdate.add(dp);
            }
          }
        
      }
      System.debug(toUpdate);
      update toUpdate;
    }

    @future
    public static void addEndDate(Set <Id> dossierBySetId) {

        Map<Id, Dossier__c> dossierById = new Map <Id, Dossier__c>([SELECT Id, Name, Einddatum__c, Ingangsdatum__c FROM Dossier__c WHERE Id in: dossierBySetId]);
        Map<Id, Dossierproduct__c> dosProds = new Map <Id, Dossierproduct__c>([select Id, Dossier__c, 
                                              Dossier__r.Ingangsdatum__c , Doorlooptijd_in_werkdagen__c
                                              from Dossierproduct__c where Dossier__r.Id in: dossierById.keySet()]);
        Map <Id, Date> daysByDosId = new Map <Id, Date>();
        if(dosProds != null){
          for (Dossierproduct__c dosPr: dosProds.values()){
            System.debug('*** Doorlooptijd_in_werkdagen__c --' + dosPr.Doorlooptijd_in_werkdagen__c + '***');
            if (dosPr.Doorlooptijd_in_werkdagen__c!= null) {

            daysByDosId.put(dosPr.Dossier__c, checkBusinessDays(dossierById.get(dosPr.Dossier__c).Ingangsdatum__c , Integer.valueOf(dosPr.Doorlooptijd_in_werkdagen__c)));
            }

          }
        }
        List<Dossier__c> updateRecords = new List<Dossier__c>();
        for (Dossier__c dos: dossierById.values()) {
          if (daysByDosId.containsKey(dos.Id)) {

            dos.Einddatum__c = daysByDosId.get(dos.Id);
            updateRecords.add(dos);
          }
          System.debug('*** dos.Einddatum__c ' + dos.Einddatum__c + ' ***');

        }
        update updateRecords;
    }
    public static List<Holiday> holidays {
      get {
        if (holidays == null) {
         holidays = [select ActivityDate from Holiday]; 
        } return holidays;
      } set;
    } 
    public static Date checkBusinessDays (Date startDate, Integer period) {
      if (startDate != null) {
          System.debug('period'+period);
            
            Map <String, Holiday> dates = new Map <String, Holiday>();
            for (Holiday h: holidays) {
                System.debug(h);
                dates.put(String.valueOf(h.ActivityDate), h);
           }
           System.debug('getBusinessDays dates ' + dates);
           for (Integer i = 0; i <= period; i++) {

               String curDate = String.valueOf(startDate.addDays(i));
               Datetime activityDate =  (Datetime )startDate.addDays(i);
               //activityDate = activityDate.addHours(-5);
               String dayOfWeek = activityDate.format('EEEE');
           
                 
               System.debug('getBusinessDays curDate ' + curDate);
               if (dates.containskey(curDate)) {
                   period++;
               } else if (dayOfWeek.equals('Saturday') || dayOfWeek.equals('Sunday')) {
                   period++;

               }
           }
           System.debug('getBusinessDays period ' + period);
           return startDate.addDays(period);
       } else {
         return null;
       }

   }
    public static Boolean checkTasks (Map <Id, Dossier__c> oldDossiers, Map <Id, Dossier__c> dosById, Map <Id, Dossier__c> newDossiers ) {
        Boolean hasErrors = true;
        List <Task> toUpdate = new List <Task>();
        List <Task> tasks = [select Id, IsClosed, WhatId from Task where WhatId in:dosById.keySet() and IsClosed = false and RecordType.Name != 'Bewaken vervolgadvies' ];
        List <Task> tasksToUpdate = [select Id, IsClosed, WhatId from Task where WhatId in : newDossiers.keySet() and IsClosed = false  ];
        System.debug('To check: ' +tasksToUpdate.size() + '  ' + tasksToUpdate);
        Map <Id, List<Task>> tasksByDosId = new Map <Id, List <Task>>();
        Map <Id, List<Task>> tasksToUpdateByDosId = new Map <Id, List <Task>>();
        for (Task task: tasks) {
            if (tasksByDosId.containsKey(task.WhatId)) {
                tasksByDosId.get(task.WhatId).add(task);
            } else {
                tasksByDosId.put(task.WhatId, new List <Task> {task});
            }
        }
        for (Task task: tasksToUpdate ) {
            if (tasksToUpdateByDosId.containsKey(task.WhatId)) {
                tasksToUpdateByDosId.get(task.WhatId).add(task);
            } else {
                tasksToUpdateByDosId.put(task.WhatId, new List <Task> {task});
            }
        }
        System.debug('To tasksToUpdateByDosId: ' +tasksToUpdateByDosId.size() + '  ' + tasksToUpdateByDosId);
        checkResults(dosById.values());
        Set <Id> dosToSendInvoice = new Set <Id>();
        for (Dossier__c dos: dosById.values()) {
            if (tasksByDosId.containsKey(dos.id) && oldDossiers.containsKey(dos.id)) {
                dos.addError(Label.CantCloseDossier);
                
            } else {
                dosToSendInvoice.add(dos.id);
            }
            
        }
        for (Dossier__c dos: newDossiers.values()) {
            System.debug('oldDossiers.get(dos.Id).handler__c ' +oldDossiers.get(dos.Id).handler__c + ' new ' +  dos.handler__c);
            if (oldDossiers.get(dos.Id).handler__c != dos.handler__c  && dos.handler__c != null) {
                if (tasksToUpdateByDosId.containsKey(dos.id)){
                    for (Task task : tasksToUpdateByDosId.get(dos.id)) {
                        task.OwnerId = dos.handler__c;
                        toUpdate.add(task);
                    }
                }
            }
        }
        System.debug('TASKS' + toUpdate.size() + ' '+ toUpdate );
        try {
            update toUpdate;
            hasErrors = false;
            
        } catch (Exception e){
            System.debug('ERROR' + e.getMessage());
        }
        return hasErrors;
    }
    @future (callout = true)
    public static void getTFNumberFuture (Set <Id> dossierIds) {
      System.debug('DossierUtil.getTFNumberFuture'+dossierIds);
      getTFNumber(dossierIds);
    }
    public static void checkResults (List <Dossier__c> dossiers) {
        Map<String, Schema.SObjectField> M = Schema.SObjectType.Dossier__c.fields.getMap();
        List <ResultVisibility__mdt> resultsDependencies = [SELECT Id, DeveloperName, DossierField__c, MasterLabel, Label, Language, Order__c ,Prevent_for_close__c,
                                NamespacePrefix, ProductField__c, QualifiedApiName FROM ResultVisibility__mdt where Prevent_for_close__c = true ];
        Set <String> fieldsToPrevent = new Set <String>();
        for (ResultVisibility__mdt res: resultsDependencies ) {
            fieldsToPrevent.add(res.DossierField__c);
        }
        for (Dossier__c dos : dossiers) {
            ApexPages.StandardController sc = new ApexPages.StandardController(dos);
            ResultExtension ctl = new ResultExtension (sc);
            ctl.fillList();
            System.debug('visibilityByFieldName ' + ctl.visibilityByFieldName );
            
            
            for (ResultExtension.FieldVisibility  fv: ctl.visibilityByFieldName ) {
                
                if (fv.visibility) {
                    Schema.SObjectField field = M.get(fv.fieldName);
                    Schema.DisplayType FldType = field.getDescribe().getType();
                    System.debug(fv.fieldName + ' ' + FldType );
                    if ((String.valueOf(FldType )=='PICKLIST' && dos.get(fv.fieldName) == null) || (fieldsToPrevent.contains(fv.fieldName) && dos.get(fv.fieldName) == null) ) {
                        System.debug('Add error');
                        dos.addError(Label.CantCloseDossier);
                    }
                }
            }
        }
        
    }
    public static void getTFNumber(Set <Id> dossierIds){
        Map <Id, Dossier__c> dossiersById = new Map <Id, Dossier__c>([Select Id, Relatie__c, ClientName__c, Relatie__r.RecordType.Name , Relatie__r.Debiteurnummer__c, handler__c, Name from Dossier__c where id in: dossierIds and sent_to_tf__c  = false]);
        Set <Id> accountIds = new Set <Id>();
        for (Dossier__c dos: dossiersById.values()) {
            accountIds.add(dos.Relatie__c);
        }
        Boolean addDebNumber = false;
        List <Dossier__c> dossierToUpdate = new List <Dossier__c>();
        for (Dossier__c dossier: dossiersById.values()) {
            if (dossier.Relatie__c != null && dossier.handler__c != null && dossier.Relatie__r.RecordType.Name == '1 Opdrachtgever') {
                if (dossier.Relatie__r.Debiteurnummer__c == null ){
                    dossier.Relatie__r.Debiteurnummer__c = '';
                    addDebNumber = true;
                }
                String requestString = TwinfieldXmlRequestBuilder.getCreateProjectRequest(dossier.Name, dossier.ClientName__c, dossier.Relatie__r.Debiteurnummer__c);
                try {
                  String xmlResult = '';
                  if(Test.isRunningTest()) {
                    xmlResult = '<dimension status="active" result="1"></dimension>';
                  } else {
                    xmlResult = TwinfieldXmlRequestBuilder.sendRequest(requestString);
                  }
                  List<TwinfieldXmlErrorMessage> errors = TwinfieldXmlUtil.parseXmlErrors(xmlResult);
                  Twinfield_ParsedXmlResult res = TwinfieldXmlUtil.parseXmlResult(xmlResult, '/dimension/code');
                  System.debug('DossierUtil' + res );
                  System.debug('errors' + errors );
                  if (errors.isEmpty() && !res.hasErrors) {
                    
                        
                        dossier.sent_to_tf__c = true;
                        dossierToUpdate.add(dossier);
                    
                  } else {
                    String errorString = '';
                    for(TwinfieldXmlErrorMessage error : errors) {
                      errorString += error.getFormattedError() + '\n-----------------\n';
                    }
                    throw new ApplicationException.InvalidStateException(errorString);
                  }
                } catch(Exception e) {
                  throw new ApplicationException.InvalidStateException(e.getMessage());
                }
            }
        }
        update dossierToUpdate;
        
    }
    public static Map<Id, User> proffesionalsByIds(List<Dossier__c> dossiers){
      Map<Id,User> retMap = new Map<Id,User>();
      Set<Id> usersIdsToGet = new Set<Id>();
      for(Dossier__c dossier : dossiers) {
        if(dossier.handler__c != null){
          usersIdsToGet.add(dossier.handler__c);    
        }
      }
      if(!usersIdsToGet.isEmpty()) {
        List<User> users = [select Id, ProfileId From User Where Id In: usersIdsToGet];
        retMap = new Map<Id,User>(users);
      }
      return retMap;
    }
    public static void apexSharingInsertForUser (Set<id> triggerNewIds, Set<Id> usersIds) {
      System.debug('DossierUtil.apexSharingInsert');
      List <Dossier__c> triggerNew = [select Id, handler__C, OwnerId from Dossier__c where Id in: triggerNewIds];
      Map <Id, User>  usersByIds;
      if(usersIds != null){
         usersByIds = new Map <Id, User>([select Id from User where id in: usersIds]); 
         //Map <Id, User>  usersByIds = new Map <Id, User>([select Id from User where id in: usersIds]); 

      }
      if(null == usersByIds || usersByIds.size() == 0){
        usersByIds = proffesionalsByIds(triggerNew);
      }
      System.debug('DossierUtil.triggerNew ' + triggerNew .size() + ' ' + usersByIds.size());
      Set<String> profileNames = new Set<String>{'Professional intern', 'Professional extern', 'Community Professional Extern'};
      //List<Profile> profiles = [Select Id,Name from Profile where Name in :profileNames];
      Map<Id, Profile> profiles = new Map<Id, Profile>([Select Id,Name from Profile where Name in :profileNames]);
      if(profiles != null && !profiles.isEmpty()) {
        //Id profileId = profiles[0].Id;
        List<Dossier__Share> dossierAddShare = new List<Dossier__Share>();
        for(Dossier__c dossier : triggerNew){
          //check if not nul
          System.debug(dossier.handler__c + ' ' + dossier.OwnerID);
          if(dossier.handler__c != null && dossier.OwnerID != dossier.Id ) {
            User currentUserProf = usersByIds.get( dossier.handler__c);
            System.debug('currentUserProf '+currentUserProf );
            //if(currentUserProf != null && currentUserProf.profileId == profileId ) {
            if(currentUserProf != null && profiles.containsKey(currentUserProf.profileId) ) {
              Dossier__Share dossierShare = new Dossier__Share();
              // Set the access level
              dossierShare.AccessLevel = 'edit';
              // Set the ID of record being shared
              dossierShare.ParentId = dossier.Id;
              // Set the ID of user or group being granted access
              dossierShare.UserOrGroupId = dossier.handler__c;

              dossierAddShare.add(dossierShare);
              System.debug('dossierAddShare: ' + dossierAddShare);
            }
        }
      }
      insert dossierAddShare;
      System.debug('dossierAddShare line 187: ' + dossierAddShare);
      } 
    }

    @future
    public static void apexSharingInsert (Set<id> triggerNewIds, Set<Id> usersIds) {
      apexSharingInsertForUser(triggerNewIds, usersIds);
    }
       
    public static void apexSharingUpdate (List<Dossier__c> triggerNew, Map<Id, Dossier__c> oldMap, Map<Id,User> usersByIds) {


      if(null == usersByIds){
        usersByIds = proffesionalsByIds(triggerNew);
      }
      System.debug('*******CREATE PROFILES(apexSharingUpdate)');
      Set<String> profileNames = new Set<String>{'Professional intern', 'Professional extern', 'Community Professional Extern'};
      //List<Profile> profiles = [Select Id,Name from Profile where Name='Professional intern' limit 1];
      Map<Id, Profile> profiles = new Map<Id, Profile>([Select Id,Name from Profile where Name in :profileNames]);
      if(profiles != null && !profiles.isEmpty()) {
        //Id profileId = profiles[0].Id;
        List<Dossier__Share> recodstoDelete = new List<Dossier__Share>();
        Set<Id> dossierRecordsIds = new Set<Id>();
        List<Dossier__c> dossiersWithChangedHandlers = new List<Dossier__c>();
          for(Dossier__c dossier : triggerNew) {
             Dossier__c dossierOldValue = oldMap.get(dossier.id);
            if(dossier.handler__c != dossierOldValue.handler__c) {
              dossierRecordsIds.add(dossier.id);
              dossiersWithChangedHandlers.add(dossier);
            }
          }
          if(dossierRecordsIds != null && !dossierRecordsIds.isEmpty()) {
            List<Dossier__Share> dossierAllChilds= [select Id, ParentId, UserOrGroupId 
                                                    from Dossier__Share 
                                                    where ParentId IN:dossierRecordsIds];                                       
            for(Dossier__c dossier : dossiersWithChangedHandlers) {
              Dossier__c dossierOldValue = oldMap.get(dossier.id);
              if(dossierOldValue.handler__c != dossierOldValue.OwnerId
                && dossierOldValue.handler__c != dossier.OwnerId){
                User currentUserProf = usersByIds.get( dossier.handler__c);
                //if(currentUserProf == null || currentUserProf.profileId == profileId) {
                //if(currentUserProf != null && profiles.containsKey(currentUserProf.profileId) ) {
                if(currentUserProf == null || profiles.containsKey(currentUserProf.profileId) ) {
                  for(Dossier__Share dossierShare : dossierAllChilds) {
                    if( dossierShare.UserOrGroupId == dossierOldValue.handler__c){ 
                      recodstoDelete.add(dossierShare);
                    }
                  }
                }
              }
            }
          if(!recodstoDelete.isEmpty()) {
            delete recodstoDelete;
          }
          Map <Id, Dossier__c> newMapDoss = new Map <Id, Dossier__c>(dossiersWithChangedHandlers);
          apexSharingInsert(newMapDoss.keySet(),null);
          }
        
      }
      //insert dossierAddShare;
    }
    @future(callout=true)
    public static void sendInvoices(Set<Id> dossiersIds) {
      System.debug('******* INSIDE OF SEND INVOISE ******');

        
      List <Dossier__c> dossiers = [select Id, Status__c, Invoice_is_sent__c   from Dossier__c where Id in: dossiersIds];
      for (Dossier__c dos: dossiers) {
          if (dos.Status__c == 'Gesloten' && !dos.Invoice_is_sent__c) {
              ApexPages.StandardController ctrl = new ApexPages.StandardController(dos);
              SendInvoice s  = new SendInvoice(ctrl);

              s.sendInvoice();
              System.debug('************* SENDED');

          }
      }
        
    }

    public static void SetDateToGes(Map<Id, Dossier__c> newMap){
      for(Dossier__c dossier : newMap.values()){
        if(dossier.Status__c == 'Gesloten'){
          Date today = Date.valueOf(date.today());
          dossier.ClosedDate__c =  today;
        }else{ 
          dossier.ClosedDate__c = null;
        }
      }
    }


   
}