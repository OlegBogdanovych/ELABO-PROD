public with sharing class TaskUtil {
    public static Map<String, Task_types__c> types = Task_types__c.getAll();
    public static Map <Id, RecordType> recordTypeById1 {
        get {
            if (recordTypeById1 == null) {
               recordTypeById1   = new Map <Id, RecordType>([SELECT Id, Name FROM  RecordType WHERE SObjectType = 'Task' and Name in ('Afspraak maken met partijen')]);
            }
            return recordTypeById1 ;
        } set;
    }

    
    public static void entry(TriggerParams triggerParams) {
        List<Task> triggerNew = (List<Task>)triggerParams.triggerNew;
        List<Task> triggerOld = (List<Task>)triggerParams.triggerOld;
        Map<Id, Task> oldMap = (Map<Id, Task>)triggerParams.oldMap;
        Map<Id, Task> newMap = (Map<Id, Task>)triggerParams.newMap;
       
        Set <Id> completedAfTask = new Set <Id>();
        Set <Id> taskForEmail = new Set <Id>();
        if (triggerParams.isAfter && triggerParams.IsInsert) {
            for (Task task: triggerNew) {
                if (recordTypeById1.containsKey(task.RecordTypeId)) {
                    taskForEmail.add(task.id);
                }
            }
            if (!System.isFuture() && !System.isBatch()) {
                setEmails(taskForEmail);
                }
        }
        if (triggerParams.isBefore && triggerParams.IsUpdate) {
            for (Task task: triggerNew) {
               if (oldMap.get(task.Id).Status != newMap.get(task.Id).Status && task.Subject.contains('Maak afspraak met partijen')) {
                   task.Datum_afspraak_gemaakt_op__c = date.today();
               }
            }

            //setDatumFields(oldMap, triggerNew);
        }
        if (triggerParams.isAfter && triggerParams.IsUpdate) {
            for (Task task: triggerNew) {
                if (oldMap.get(task.Id).isClosed != newMap.get(task.Id).isClosed && newMap.get(task.Id).isClosed  && recordTypeById1.containsKey(task.RecordTypeId)) {
                    completedAfTask.add(task.id);
                }
            }
            if (!System.isFuture() && !System.isBatch()) {
              createAdditionalTask(completedAfTask);
            }
        }
   }

   //private static void setDatumFields(Map<Id, Task> oldMap, List<Task> triggerNew) {
   //   Map <Id, RecordType> recordTypeById = new Map <Id, RecordType>([SELECT Id, Name FROM  RecordType WHERE SObjectType = 'Task']);
   //   for (Task task: triggerNew) {
   //       if (recordTypeById.get(task.RecordTypeId).Name == 'Afspraak maken met partijen') {
   //           if (oldMap.get(task.Id).isClosed != task.isClosed && task.isClosed) {
   //               task.Afspraakdatum__c = Date.newInstance((task.Afspraakdatum_tijd__c).year(), (task.Afspraakdatum_tijd__c).month(), (task.Afspraakdatum_tijd__c).day());
   //               task.Tijdstip__c = '08:00';
   //           }
   //       }
   //   }
   //}

   @future
   public static void setEmails (Set <Id> metTasksid) {
       List <Task> metTasks = [SELECT Id, WhatId, RecordTypeId FROM Task WHERE Id IN: metTasksid];
       System.debug('setEmail ' + metTasks);
       Set <Id> dosIds = new Set <Id>();
       for (Task task: metTasks) {
           if (task.WhatId.getSObjectType().getDescribe().getName() == 'Dossier__c') {
               dosIds.add(task.WhatId);
           }
           
       }
       Map <Id, Dossier__c> dosById = new Map <Id, Dossier__c>([SELECT Id,Contactpersoon_opdrachtgever__c,  Case_Manager__r.Email, Case_Manager__c, Contactpersoon_opdrachtgever__r.Email FROM Dossier__c WHERE id IN: dosIds]);
       System.debug('dosById ' + dosById );
       for (Task task: metTasks) {
           if ((task.WhatId.getSObjectType().getDescribe().getName() == 'Dossier__c') && dosById.get(task.WhatId).Contactpersoon_opdrachtgever__c != null) {
               task.Email_contactpersoon_opdrachtgever__c = dosById.get(task.WhatId).Contactpersoon_opdrachtgever__r.Email;
              
           }
           if ((task.WhatId.getSObjectType().getDescribe().getName() == 'Dossier__c') && recordTypeById1.containsKey(task.RecordTypeId) && dosById.get(task.WhatId).Case_Manager__c != null) {
               task.Email_Case_Manager__c = dosById.get(task.WhatId).Case_Manager__r.Email;
           }
       }
       System.debug('metTasks' + metTasks);
       update metTasks;
   }
   @future
   public static void createAdditionalTask(Set<Id> taskIds) {
      String fieldDays;
      String subject;
      List <Product__c> productList;
      Map <Id, Product__c> productMapFROMDao = new Map<Id, Product__c>();

      List <Task> toCreate = new List <Task>();
      List <Task> completedTasks = [SELECT id, WhatId, Afspraakdatum__c, RecordTypeId,OwnerId, 
                                                                ActivityDate, Dossierproduct__c, Dossierproduct__r.Product__c  
                                                                FROM Task WHERE id IN: taskIds];
      Set <Id> accountIds = new Set<Id>();
      Set <Id> dosIds = new Set <Id>();
      Set <Id> productIdsbyDosPr = new Set<Id>();

      for (Task task: completedTasks) {
           dosIds.add(task.WhatId);
      }
      Map <Id, Product_Exeption__c> exeps;
      Map <Id, Integer> daysByDosId = new Map <Id, Integer>();
      Map <Id, Integer> daysAFByDosId = new Map <Id, Integer>();       
      Map <Id, Integer> daysConByDosId = new Map <Id, Integer>();       
      Map <Id, Dossierproduct__c> dossierProds = new Map<Id, Dossierproduct__c>();
      Map <Id, Product__c> dosPrwithProdByDosPr = new Map<Id, Product__c>();
      Map <Id, RecordType> recordTypeById = new Map <Id, RecordType>([SELECT Id, Name FROM  RecordType WHERE SObjectType = 'Task' ]);
      Map <Id, Dossier__c> dosById = new Map <Id, Dossier__c>([SELECT Id,Contactpersoon_opdrachtgever__c,  Case_Manager__r.Email, 
                                                                Case_Manager__c,  Contactpersoon_opdrachtgever__r.Email, Client__c, 
                                                                Client__r.Email, Product_Exception__c , Verwijzer__c, Relatie__c
                                                                FROM Dossier__c WHERE id IN: dosIds]);

      List <Dossierproduct__c> dossierProdsSet = DossierProductDAO.getDossierPrWithPRFieldsByDosId(dosIds);
      for(Dossierproduct__c dosPr : dossierProdsSet){
        dossierProds.put(dosPr.Id, dosPr);
      }

      Map <String, RecordType> recTypeByName = new Map <String, RecordType>();
      Map <Id, Map <Id, Product_Exeption__c>> exeptionsByPrByAcc = new Map <Id, Map <Id, Product_Exeption__c>>();

      for (RecordType rT: recordTypeById.values()) {
           recTypeByName.put(rT.Name, rT);
      }
      
      for (Task task: completedTasks) {  
            if(dosById.get(task.WhatId).Product_Exception__c == 'Relatie'){
              accountIds.add(dosById.get(task.WhatId).Relatie__c);
            }else if(dosById.get(task.WhatId).Product_Exception__c == 'Verwijzer'){
              accountIds.add(dosById.get(task.WhatId).Verwijzer__c);
            }
      }

      for (Dossierproduct__c dosPr: dossierProds.values()) {
            productIdsbyDosPr.add(dosPr.Product__c);
      }
      productList = TaskDAO.getProductsTaskTypebyPId(productIdsbyDosPr);
      for (Dossierproduct__c dosPr: dossierProds.values()) {
        for(Product__c prod : productList){
          if(dosPr.Product__c == prod.Id){
            dosPrwithProdByDosPr.put(dosPr.Id, prod);
          }
        }
      }

      Set <Id> productIds = new Set <Id>();
      for(Product__c prod : dosPrwithProdByDosPr.values()){
          productIds.add(prod.Id);
      }
      List <Product_Exeption__c> exeptions = ProductExeptionDAO.getPrExByAccAndPrIds(accountIds, productIds);
      for (Product_Exeption__c ex: exeptions)   {
          if (exeptionsByPrByAcc.containsKey(ex.Account__c)){
              exeptionsByPrByAcc.get(ex.Account__c).put(ex.Product__c, ex);
          } else {
              exeps = new Map <Id, Product_Exeption__c>();
              exeps.put(ex.Product__c, ex);
              exeptionsByPrByAcc.put(ex.Account__c, exeps);
          }
      }
              
     for (Task task: completedTasks) {  
          Id currentAccountId;
          if(dosById.get(task.WhatId).Product_Exception__c == 'Relatie'){
            currentAccountId = dosById.get(task.WhatId).Relatie__c;
            }else if(dosById.get(task.WhatId).Product_Exception__c == 'Verwijzer'){
            currentAccountId = dosById.get(task.WhatId).Verwijzer__c;
          }
          Product__c product = dosPrwithProdByDosPr.get(dossierProds.get(task.DossierProduct__c).Id);

          // Overides the Product values with the Product Exeption values.
          if (currentAccountId != null && exeptionsByPrByAcc.containsKey(currentAccountId) 
                                       && exeptionsByPrByAcc.get(currentAccountId).containsKey(task.Dossierproduct__r.Product__c)) {
              product = TaskGenerator.overrideProduct(product, exeptionsByPrByAcc.get(currentAccountId).get(task.Dossierproduct__r.Product__c));
          }
          Set <String> typesName = TaskGenerator.getRecordTypeNames(product);

          if (task.Afspraakdatum__c != null ) {
              if (recordTypeById.get(task.RecordTypeId).Name == 'Afspraak maken met partijen') { // && daysByDosId.containsKey(task.WhatId) && daysByDosId.get(task.WhatId) != null
                for(Task_types__c taskType : types.values()){
                    if(types.get(taskType.Name).CreateAlways__c){
                        //if(types.get(taskType.Name).Name != 'Bewaken_vervolgadvies__c' || types.get(taskType.Name).Name != 'Afspraak_maken_met_partijen__c'){
                           toCreate.add(createAdditionalTask(task, taskType.Name, product, recTypeByName, dosById));
                        //}
                    }
                }
                for(String typeName : typesName){
                  //if(!typeName.contains('Afspraak_maken_met_partijen__c') || !typeName.contains('Bewaken_vervolgadvies__c')){
                  if(!typeName.contains('Afspraak_maken_met_partijen__c')){
                    toCreate.add(createAdditionalTask(task, typeName, product, recTypeByName, dosById));
                  }
                }
              } 
          }
     }
     System.debug('to create' + toCreate.size() + ' ' + toCreate) ;
     insert toCreate;
   }

    public static  Map <String, Holiday> holiDates {
      get {
        if (holiDates == null) {
            List<Holiday> holidays = [SELECT ActivityDate FROM Holiday];
            holiDates = new Map <String, Holiday>();
            for (Holiday h: holidays) {
                holiDates.put(String.valueOf(h.ActivityDate), h);
            }        
          } return holiDates;
      } set;
    }  


   public static Boolean isHoliday (Date activityDate ) {
        
        if (activityDate != null){
            if (holiDates.containsKey(String.valueOf(activityDate)) ) {
                return true;
            }
            Datetime activityDate1 =  (Datetime )activityDate;

            String dayOfWeek = activityDate1.format('EEEE');

            if (dayOfWeek.equals('Saturday') || dayOfWeek.equals('Sunday')) {
                return true;
            }
        }
        return false;
    }

    public static Date getSkipDate (Date stDate, Integer pDays){
      System.debug('OBDEB pDays -->> ' + pDays);
      System.debug('OBDEB stDate -->> ' + stDate);
      Date skipedDate = stDate;
      Integer addSkipedDays = pDays;
      if(stDate != null && pDays != null){
          Integer addDay = 0;
          while(addDay <= pDays){
            Date st2Date = stDate.addDays(addDay);
            addDay ++;
            if (isHoliday(st2Date)){
                addSkipedDays ++;   

            }
          }

      }
      System.debug('OBDEB addSkipedDays -->> ' + addSkipedDays);
      System.debug('OBDEB skipedDate -->> ' + skipedDate);
      skipedDate = skipedDate.addDays(addSkipedDays);
      return skipedDate;
    }

    public static Task createAdditionalTask(Task task, String taskType , Product__c product , Map <String, RecordType> recTypeByName, Map <Id, Dossier__c> dosById){
        Integer ADDDAYS = 1;
        Task newTask;
        String fieldDays = types.get(taskType).RelatedField__c;
        String subject = types.get(taskType).TaskSubject__c;
        String recordType = types.get(taskType).Record_Type_Name__c;
        Integer days;
        Date datum = task.Afspraakdatum__c;
        Integer num = Integer.valueOf(types.get(taskType).AddDueDate__c);
        if(num != null){
          days = num;
        }else{
          days = Integer.valueOf(product.get(fieldDays));
        }

        newTask = new Task(Subject = subject,
                    RecordTypeId = recTypeByName.get(recordType).id,                     
                    OwnerId = task.OwnerId,
                    ActivityDate =  getSkipDate(datum, days),
                    Dossierproduct__c = task.Dossierproduct__c,
                    Email_contactpersoon_opdrachtgever__c = dosById.get(task.WhatId).Contactpersoon_opdrachtgever__r.Email,
                    Email_Case_Manager__c = dosById.get(task.WhatId).Case_Manager__r.Email,
                    WhatId = task.WhatId);

        if(dosById.get(task.WhatId).Client__c != null){
          newTask.Email_client__c = dosById.get(task.WhatId).Client__r.Email;
        }
        while (isHoliday(newTask.ActivityDate)){
            newTask.ActivityDate = newTask.ActivityDate.addDays(ADDDAYS);
        }
        return newTask;
    } 

}