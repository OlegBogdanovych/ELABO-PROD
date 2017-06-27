public with sharing class TaskGenerator {
    /*
    * Depends on producten__c record related to dossier create tasks for dossier. Account fields has higher priority than producten, 
    * so if they aren't empty - tasks are generated accordig to account.
    */
    public TaskGenerator() {
        
    }
    public static Map<String, Task_types__c> types = Task_types__c.getAll();
    
    public static void generateTasks(Set <Id> dossierIds){
        String subject;
        System.debug('TaskGeneration ' + dossierIds);
        Set <Id> accountIds = new Set <Id>();
        Map <Id, Dossier__c> dossiersById = new Map <Id, Dossier__c>([select Id, ClosedDate__c ,Verwijzer__c, Product_Exception__c, 
                                                                        handler__c, CreatedDate, RecordTypeId, Relatie__c, Verwijzer__r.RecordTypeId , 
                                                                        Verwijzer__r.RecordType.Name , Relatie__r.RecordTypeId ,Relatie__r.RecordType.Name,  
                                                                        Datum_Binnenkomst__c, Ingangsdatum__c
                                                                        from Dossier__c 
                                                                        where id in: dossierIds]);
        for (Dossier__c dos: dossiersById.values()) {
            if (dos.Product_Exception__c == 'Relatie') {
                accountIds.add(dos.Relatie__c);
            } else if (dos.Product_Exception__c == 'Verwijzer') {
                accountIds.add(dos.Verwijzer__c);
            }
        }
        List<Dossierproduct__c> dossierProducts = [select Id, Dossier__c, Product__r.Doorlooptijd_in_dagen__c, Product__c 
                                                        from Dossierproduct__c 
                                                        where Dossier__c in: dossiersById.keySet() and Tasks_are_created__c = false];
        Map <Id, Dossierproduct__c>  dossierProductsById = new Map <Id, Dossierproduct__c>();  
        List <Task> tasksToCheck = new List <Task>();
        Map <Id, Boolean> existForDossier = new Map <Id, Boolean>();
        for (Task task: tasksToCheck) {
            existForDossier.put(task.DossierProduct__c, true);
        }
        System.debug('existForDossier'+existForDossier);
        Set <Id> productIds = new Set <Id>();
        Map <Id, Map <Id, List <Dossierproduct__c>>> dossierProductsByPrIdByDosId = new Map <Id, Map <Id, List <Dossierproduct__c>>>();
        for (Dossierproduct__c dp: dossierProducts) {
            if (dossierProductsByPrIdByDosId.containsKey(dp.Dossier__c)) {
                if (dossierProductsByPrIdByDosId.containsKey(dp.Product__c)){
                    dossierProductsByPrIdByDosId.get(dp.Dossier__c).get(dp.Product__c).add(dp);
                } else {
                    dossierProductsByPrIdByDosId.get(dp.Dossier__c).put(dp.Product__c, new List <Dossierproduct__c>{dp});
                } 
            } else {
                Map <Id, List <Dossierproduct__c>> dossierProductsByPrId = new Map <Id, List <Dossierproduct__c>> ();
                dossierProductsByPrId.put(dp.Product__c, new List <Dossierproduct__c>{dp});
                dossierProductsByPrIdByDosId.put(dp.Dossier__c, dossierProductsByPrId);
            }
        }
        for (Dossierproduct__c pr: dossierProducts) {
            productIds.add(pr.Product__c);
        }
        List <Product_Exeption__c> exeptions = ProductExeptionDAO.getPrExByAccAndPrIds(accountIds, productIds);                                                        
        Map <Id, Map <Id, Product_Exeption__c>> exeptionsByPrByAcc = new Map <Id, Map <Id, Product_Exeption__c>>();
        for (Product_Exeption__c ex: exeptions)   {
            if (exeptionsByPrByAcc.containsKey(ex.Account__c)){
                exeptionsByPrByAcc.get(ex.Account__c).put(ex.Product__c, ex);
            } else {
                Map <Id, Product_Exeption__c> exeps = new Map <Id, Product_Exeption__c>();
                exeps.put(ex.Product__c, ex);
                exeptionsByPrByAcc.put(ex.Account__c, exeps);
            }
        }

        List <Product__c> products = TaskDao.getProductsTaskTypebyPId(productIds);
        Map <Id, Product__c> productsById = new Map <Id, Product__c>();
        if (products != null) {
            productsById = new Map <Id, Product__c>(products);
        }
        Map <Id, List <Product__c>> productsByDossierId = new Map <Id, List<Product__c>>();
        for (Dossierproduct__c pr: dossierProducts) {
            if (productsByDossierId.containsKey(pr.Dossier__c)) {
                productsByDossierId.get(pr.Dossier__c).add(productsById.get(pr.Product__c));
            } else {
                productsByDossierId.put(pr.Dossier__c, new List <product__c> {productsById.get(pr.Product__c)});
            }
        }
        
        
        List <Dossier__c> dossiersToGenerate  = new List <Dossier__c>();
        
        for (Dossier__c dossier: dossiersById.values()) {
            System.debug('[***] dossiersById :' + dossier);
            
            if (dossier.Relatie__r.RecordType.Name == '1 Opdrachtgever' && dossier.handler__c != null 
                && productsByDossierId.containsKey(dossier.id) && productsByDossierId.get(dossier.id).size() > 0) {
                    dossiersToGenerate.add(dossier);
                    System.debug('[***] Added :' + dossier);

            }
        }
      
        List <Task> tasks = new List <Task>();
        List <RecordType> recordTypes = [select id, Name from RecordType where SObjectType = 'Task' ];
        Map <String, RecordType> recordTypesByName = new Map <String, RecordType>();
        for (RecordType rT: recordTypes) {
            recordTypesByName.put(rT.Name, rt);
            System.debug(' ++++ rT.Name, rt   = ' + rT.Name + ', ' +  rt);
        }
        List <Dossierproduct__c> dpstoUpdate = new List <Dossierproduct__c>();
        Set <Dossierproduct__c> dpstoUpdateSet = new Set <Dossierproduct__c>();
        System.debug('dossiersToGenerate'+dossiersToGenerate.size() + ' ' + dossiersToGenerate);

        for (Dossier__c dos: dossiersToGenerate) {
            System.debug('[***] dossiersToGenerate :' + dos);

            for (Product__c product: productsByDossierId.get(dos.Id)) {
                System.debug('dossierProductsByPrIdByDosId.get(dos.Id).get(product.id)'+dossierProductsByPrIdByDosId.get(dos.Id).get(product.id));
                if (dossierProductsByPrIdByDosId.get(dos.Id).get(product.id)!= null
                    && dossierProductsByPrIdByDosId.get(dos.Id).get(product.id).size() > 0
                    && !existForDossier.containsKey(dossierProductsByPrIdByDosId.get(dos.Id).get(product.id).get(0).id)
                    ) {
                        id currentAccountId = null;
                        if (dos.Product_Exception__c == 'Relatie') {
                            currentAccountId = dos.Relatie__c;
                        } else if (dos.Product_Exception__c == 'Verwijzer') {
                            currentAccountId = dos.Verwijzer__c;
                        }
                
                    if (currentAccountId != null && exeptionsByPrByAcc.containsKey(currentAccountId) && exeptionsByPrByAcc.get(currentAccountId).containsKey(product.id)) {
                        overrideProduct(product, exeptionsByPrByAcc.get(currentAccountId).get(product.id));
                    }
                    Set <String> typesName = getRecordTypeNames(product);
                    for (String typeOfTask: typesName) {
                        Task task = new Task();
                        System.debug('--- types.get(typeOfTask).Record_Type_Name__c = ' + types.get(typeOfTask).Record_Type_Name__c);
                        System.debug('*** typeOfTask  = ' + typeOfTask);
                        System.debug('--- recordTypesByName.get(types.get(typeOfTask).Record_Type_Name__c) = ' + recordTypesByName.get(types.get(typeOfTask).Record_Type_Name__c));

                        task.RecordTypeId = recordTypesByName.get(types.get(typeOfTask).Record_Type_Name__c).id;                        
                        task.OwnerId = dos.handler__c;
                        task.WhatId = dos.Id;
                        task.DossierProduct__c = dossierProductsByPrIdByDosId.get(dos.Id).get(product.id).get(0).id;
                        if (typeOfTask == 'Afspraak_maken_met_partijen__c' && dos.Ingangsdatum__c != null) {

                            Date datum = dos.Ingangsdatum__c;
                            Double addedDaysDouble = getRelatedName(typeOfTask, dos, product) / 24;
                            Long addedDaysRound = addedDaysDouble.round();
                            Integer addedDays = addedDaysRound.intValue();
                            System.debug('{******************} addedDays ' + addedDays);
                            task.ActivityDate =  TaskUtil.getSkipDate(datum, addedDays);

                            task.Subject = types.get(typeOfTask).TaskSubject__c;
                            task.DossierProduct__c = dossierProductsByPrIdByDosId.get(dos.Id).get(product.id).get(0).id;
                            tasks.add(task);
                            System.debug('MAAK' + isHoliday(task.ActivityDate) + ' ' + task.ActivityDate);
                        } else if (typeOfTask == 'Bewaken_vervolgadvies__c') {
                            if (dos.ClosedDate__c != null) {
                                task.Subject = types.get(typeOfTask).TaskSubject__c;
                                task.DossierProduct__c = dossierProductsByPrIdByDosId.get(dos.Id).get(product.id).get(0).id;
                                task.ActivityDate = Date.valueOf(dos.ClosedDate__c.addMonths(getRelatedName(typeOfTask, dos, product)));
                                tasks.add(task);
                            }   
                        } else if (typeOfTask == 'Versturen_eindrapport__c') {
                            
                        }  else if (typeOfTask == 'Tussenrapportage__c' && dos.Ingangsdatum__c != null){
                            /*task.Subject = 'Verzend tussenrapportage';*/
                        }
                        System.debug(isHoliday(task.ActivityDate) + ' ' + task.ActivityDate);
                        while (isHoliday(task.ActivityDate)){
                            System.debug(isHoliday(task.ActivityDate));
                            task.ActivityDate = task.ActivityDate.addDays(1);
                        }

                    }
                    
                    List <Dossierproduct__c> currectDosPrs = dossierProductsByPrIdByDosId.get(dos.Id).get(product.id);
                    for (Dossierproduct__c currectDosPr: currectDosPrs) {
                        currectDosPr.Tasks_are_created__c = true;
                        if (currentAccountId != null && exeptionsByPrByAcc.containsKey(currentAccountId) && exeptionsByPrByAcc.get(currentAccountId).containsKey(product.id)) {
                           currectDosPr.Product_Exeption__c = exeptionsByPrByAcc.get(currentAccountId).get(product.id).id;
                        }
                        
                        dpstoUpdateSet.add(currectDosPr);
                    }
                }
            }
        }
        
        System.debug('tasks ' + tasks.size() + ': ' + tasks);
        try {
            insert tasks;
            dpstoUpdate = new List <Dossierproduct__c>(dpstoUpdateSet);
            Set <Id> dosPtToUp = new Set <Id>();
            for (Dossierproduct__c d: dpstoUpdate) {
                dosPtToUp.add(d.id);
            }
            update dpstoUpdate;
           
        } catch (Exception e) {
            System.debug('ERROR: ' + e.getMessage());
        }
        
    }


    public static  Map <String, Holiday> holiDates {
      get {
        if (holiDates == null) {
            List<Holiday> holidays = [select ActivityDate from Holiday];
            holiDates = new Map <String, Holiday>();
            for (Holiday h: holidays) {
                //System.debug(h);
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
            System.debug(dayOfWeek);
            System.debug('dayOfWeek  ' +dayOfWeek );
            System.debug('activityDate1' +activityDate1);
            if (dayOfWeek.equals('Saturday') || dayOfWeek.equals('Sunday')) {
                return true;
            }
        }
        return false;
    }
   
    public static Product__c overrideProduct (Product__c dosProduct, Product_exeption__c ex) {
       System.debug('Override' + dosProduct +' ' + ex);
        try {
            for (Task_types__c taskType: types.values()) {
                System.debug(taskType );
                System.debug(taskType.Account_Related__c  );
                if (taskType.Account_Related__c != null && ex.get((String)taskType.Account_Related__c) != null) {
                    System.debug(ex.get((String)taskType.Account_Related__c));
                    if (taskType.AccountField__c != null && String.valueOf(ex.get((String)taskType.AccountField__c))  == 'true') {
                        dosProduct.put(taskType.RelatedField__c, ex.get((String)taskType.Account_Related__c));
                    }
                }
                System.debug(taskType.AccountField__c );
                if (taskType.AccountField__c != null && ex.get((String)taskType.AccountField__c) != null) {
                    System.debug(ex.get((String)taskType.AccountField__c));
                    if (String.valueOf(ex.get((String)taskType.AccountField__c)) == 'true') {
                        dosProduct.put(taskType.name, ex.get((String)taskType.AccountField__c));
                    }
                }
            }
            System.debug('Override' + dosProduct );
            return dosProduct;
        } catch (Exception e) {
            System.debug('ERROR '+ e.getMessage());
            return dosProduct;
        }
    }
    public static Set<String> getRecordTypeNames (Product__c dosProduct) {
        Set <String> names = new Set <String>();
        for (String name: types.keySet()) {
            System.debug('*** getRecordTypeNames =  ' + name);
            if ((Boolean)dosProduct.get(name) && !types.get(name).CreateAlways__c) {
                System.debug('*** getRecordTypeNames Boolean =  ' + (Boolean)dosProduct.get(name));

                names.add(name);
            }
        }
            System.debug('*** RT names  =  ' + names);

        return names;
    }

    public static Set<String> getRecordTypeNames (Product_exeption__c dosProductEx) {
        Set <String> names = new Set <String>();
        
        for (String name: types.keySet()) {
            if ((Boolean)dosProductEx.get(name) && !types.get(name).CreateAlways__c) {
                names.add(name);
            }
        }
        return names;
    }


    public static Integer getRelatedName (String typeOfTask, Dossier__c dos, Product__c product) {
        Integer toReturn = 0;

        Map <Id, Dossierproduct__c> productsById = new Map <Id, Dossierproduct__c>([select Id, Product__c, Dossier__c 
                                                                                    from Dossierproduct__c 
                                                                                    where Dossier__c =: dos.Id]);
        Map <Id, Product_exeption__c> exeptionsByIdMap = new Map <Id, Product_exeption__c>();
        Map <Id, Id> dosPrByDosId = new Map <Id, Id>();
        Map <Id, Id> prByDosId = new Map <Id, Id>();

        for (Dossierproduct__c pr: productsById.values() ) {
            dosPrByDosId.put(pr.Dossier__c, pr.Id);
            prByDosId.put(pr.Dossier__c, pr.Product__c);
        }

        Set <id> accId = new Set <id>();
        accId.add(dos.Relatie__c);
        accId.add(dos.Verwijzer__c);

        Map <Id, Account> accountsById = new Map <Id,Account>([select Id from Account where id in: accId]);
        List <Product_exeption__c> exeptionsById = ProductExeptionDAO.getPrExByAccIds(accId);
        for(Product_exeption__c prEx : exeptionsById){
            exeptionsByIdMap.put(prEx.Id, prEx);
        }
        Map <Id, Map <Id, Product_exeption__c>> exceptionsByProductByAccount = new Map <Id, Map <Id, Product_exeption__c>>();

        for (Product_exeption__c pr: exeptionsByIdMap.values()) {
            if (exceptionsByProductByAccount.containsKey(pr.Account__c)){
         
              exceptionsByProductByAccount.get(pr.Account__c).put(pr.Product__c, pr);
            } else {
              Map <Id, Product_exeption__c> exceptionByProduct = new Map <Id, Product_exeption__c>();
              exceptionByProduct.put(pr.Product__c, pr);
              exceptionsByProductByAccount.put(pr.Account__c, exceptionByProduct);
            }
            
        }
        if (dos.Product_exception__c == 'Relatie'){
          
            Dossierproduct__c dp = productsById.get(dosPrByDosId.get(dos.id));

            if (exceptionsByProductByAccount.containsKey(dos.Relatie__c)
                && exceptionsByProductByAccount.get(dos.Relatie__c).containsKey(dp.Product__c)
                && exeptionsByIdMap.containsKey(exceptionsByProductByAccount.get(dos.Relatie__c).get(dp.Product__c).id)  ) {

                if(typeOfTask == types.get(typeOfTask).Name){
                      toReturn = Integer.valueOf(exeptionsByIdMap.get(exceptionsByProductByAccount.get(dos.Relatie__c).get(dp.Product__c).id).get(types.get(typeOfTask).Account_Related__c));
                }

            } else {
               toReturn = Integer.valueOf(product.get(types.get(typeOfTask).RelatedField__c));
            }
        }
        if (dos.Product_exception__c == 'Verwijzer'){
            Dossierproduct__c dp = productsById.get(dosPrByDosId.get(dos.id));

            if (exceptionsByProductByAccount.containsKey(dos.Verwijzer__c)
                && exceptionsByProductByAccount.get(dos.Verwijzer__c).containsKey(dp.Product__c)
                && exeptionsByIdMap.containsKey(exceptionsByProductByAccount.get(dos.Verwijzer__c).get(dp.Product__c).id)  ) {

                if(typeOfTask == types.get(typeOfTask).Name){
                      toReturn = Integer.valueOf(exeptionsByIdMap.get(exceptionsByProductByAccount.get(dos.Verwijzer__c).get(dp.Product__c).id).get(types.get(typeOfTask).Account_Related__c));
                }

            } else {
               toReturn = Integer.valueOf(product.get(types.get(typeOfTask).RelatedField__c));
            }
        }
        if (dos.Product_exception__c == 'Geen uitzondering' || toReturn  == null){
            toReturn = Integer.valueOf(product.get(types.get(typeOfTask).RelatedField__c));
        } 
        return toReturn;
    }
}