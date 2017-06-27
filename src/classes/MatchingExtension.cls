public without sharing class MatchingExtension {
    public MatchingExtension(ApexPages.StandardController ctrl) {
        
    }
    public Boolean productShow {get{if (productShow == null){productShow = true;}return productShow;}set;}
    public MatchingExtension(){}
    public String errorMessage {get;set;}

    public List <Dossier> unmatchedDossiers {
        get {
            if (unmatchedDossiers == null) {
                unmatchedDossiers = new List <Dossier>();
            }
            return unmatchedDossiers;
        } set;
    }
    public List <Dossier> voorDossiers {
        get {
            if (voorDossiers == null) {
                voorDossiers = new List <Dossier>();
            }
            return voorDossiers;
        } set;
    }
    public List <Dossier__c> todayDossiers {
        get {
            if (todayDossiers == null) {
                todayDossiers = new List <Dossier__c>();
            }
            return todayDossiers;
        } set;
    }
    public List <UserList> users {
        get {
            if (users == null) {
                users = new List <UserList>();
            }
            return users;
        } set;
    }
    public Boolean showUsers{get;set;}
    public Boolean showVoorDoos{get;set;}
    public Boolean showUnDoos{get;set;}
    public Boolean showTeamOnly {get{if (showTeamOnly == null){showTeamOnly = true;} return showTeamOnly;}set;}
    public void loadData() {
        showVoorDoos = true;
        showUnDoos = true;
        unmatchedDossiers = new List <Dossier>();
        voorDossiers = new List <Dossier>();
        List <Dossier__c> dossiers = [ SELECT Id, Name, Andere_reden_sluiten_na_deadline__c, Product_gekoppeld__c , Datum_Binnenkomst__c, 
                                            Einddatum__c, reference_Id__c, Label__c, Status__c , Ingangsdatum__c, Verwijzer__c, Product_Exception__c,
                                             handler__r.Name, handler__c, ClientName__c, Relatie__r.Name, Relatie__c, PostCode__c, Straat__c, Plaats__c, Land__c,
                                             Branche3__c, Client__r.OtherLongitude, Client__r.OtherLatitude, Client__r.OtherCity,OtherLatitude__c, OtherLongitude__c,
                                            Client__r.OtherStreet, Client__r.OtherPostalCode, Client__r.OtherState, Client__r.OtherCountry
                                        FROM Dossier__c where (Status__c = 'Unmatched' or Status__c = 'Voorlopig gematched') ];
        Map <Id, Dossier__c> dossiersByIds = new Map <Id, Dossier__c>(dossiers);
        List <Dossierproduct__c> dosProds = [select Id, Product__r.Product_tijd_UU_MM__c, Dossier__r.Verwijzer__c, Dossier__r.Relatie__c, 
                                                        Product__r.Doorlooptijd_in_dagen__c, Dossier__r.Datum_Binnenkomst__c,Product_exeption__c,
                                                        Dossier__r.Einddatum__c, Dossier__c, Dossier__r.Handler__c, Product__c, 
                                                        Dossier__r.Product_Exception__c, Dossier__r.Name  from Dossierproduct__c where Dossier__c in: dossiersByIds.keySet()];
        Set <Id> prodIds = new Set <Id>();
        Map <Id, List<Dossierproduct__c>> dosProdByDosId = new Map <Id, List<Dossierproduct__c>>();
        for (Dossierproduct__c dosProd: dosProds) {
            prodIds.add(dosProd.Product__c);
            if (dosProdByDosId.containsKey(dosProd.Dossier__c)) {
               dosProdByDosId.get(dosProd.Dossier__c).add(dosProd);
            } else {
                dosProdByDosId.put(dosProd.Dossier__c, new List <Dossierproduct__c>{dosProd});
            }
        }
        Map <Id, Product__c> productsByIds = new Map <Id, Product__c>([select Id, Name, Doorlooptijd_in_dagen__c, Productgroep__c, Product_tijd_UU_MM__c from Product__c where Id in: prodIds]);
        
        todayDossiers = [SELECT Id, Name, Datum_Binnenkomst__c, Einddatum__c, reference_Id__c, Status__c , Label__c, Ingangsdatum__c,  
                                             handler__r.Name, handler__c, ClientName__c, Relatie__r.Name, Relatie__c
                                             FROM Dossier__c WHERE Status__c = 'In Behandeling' 
                                AND Id IN(SELECT ParentId FROM Dossier__History WHERE Field = 'Status__c' AND CreatedDate = TODAY ) order by LastModifiedDate desc];

        Set <Id> accountIds = new Set <Id>();
        Set <Id> prExIds = new Set <Id>();
        Map <Id , Product_exeption__c>  prExByProd = new Map <Id , Product_exeption__c>();

        Map <Id, Map <Id , Product_exeption__c>>  prExByProdByAcc = new Map <Id, Map< Id , Product_exeption__c>>();
        for(Dossier__c dos : dossiers){
            if(dos.Relatie__c != null){
                accountIds.add(dos.Relatie__c);
            }
            if(dos.Verwijzer__c != null){
                accountIds.add(dos.Verwijzer__c);
            }
        }

        Map <Id, Product_exeption__c> prExMap = new Map <Id, Product_exeption__c>([SELECT Id, Name, Product__c, Account__c, Product_tijd_UU_MM__c FROM Product_exeption__c WHERE Account__c =: accountIds]);

        for(Product_exeption__c prEx : prExMap.values()){
            if (prExByProdByAcc.containsKey(prEx.Account__c)) {
                if(!prExByProdByAcc.get(prEx.Account__c).containskey(prEx.Product__c)){
                    prExByProdByAcc.get(prEx.Account__c).put(prEx.Product__c, prEx);
                }
            } else {
                Map <Id, Product_exeption__c> prExMp = new MAp <Id, Product_Exeption__c> ();
                prExMp.put(prEx.Product__c, prEx);
                prExByProdByAcc.put(prEx.Account__c,prExMp );
            }

        }
        String jsonStr = '[';
        for (Dossier__c dos: dossiers) {
            Product__c prod = new Product__c();
            Product__c prod2;
            System.debug(' *++* DOSSIER === ' +dos.Name +' -- ' + dos.ID);
            System.debug('*** BEf prod = ' + prod);
            if (dosProdByDosId.containsKey(dos.Id) &&  productsByIds.containsKey(dosProdByDosId.get(dos.Id).get(0).Product__c)) {
                Product__c curProd = productsByIds.get(dosProdByDosId.get(dos.Id).get(0).Product__c);
                 System.debug('*** MIDDLE dosProdByDosId = ' + productsByIds.get(dosProdByDosId.get(dos.Id).get(0).Product__c));
                 //System.debug('*** MIDDLE prod = ' + prod);
                 //prod2 = overrideProduct(prod, prExMap.get(dosProdByDosId.get(dos.Id).get(0).Product_exeption__c));
                 //System.debug('*** MIDDLE prodex = ' + prExMap.get(dosProdByDosId.get(dos.Id).get(0).Product_exeption__c));
                  System.debug('prExByProdByAcc' + prExByProdByAcc);
                

                prod = overrideProductPartOne(dos, curProd , prExByProdByAcc);
                //prod.id = null;
                //if(dos.Product_Exception__c == 'Verwijzer'){ 
                //    System.debug('dos Verwijzer + ' + dos.id);

                //    System.debug('prExByProdByAcc.get Verwijzer = ' + dos.Verwijzer__c);
                //    System.debug('prExByProdByAcc.get(dos.Verwijzer__c) = ' + prExByProdByAcc.get(dos.Verwijzer__c));
                //    if(prExByProdByAcc.containskey(dos.Verwijzer__c) && prExByProdByAcc.get(dos.Verwijzer__c).containskey(prod.Id)){
                //         System.debug('***  dP prodEx Verwijzer : ' + prExByProdByAcc.get(dos.Verwijzer__c).get(prod.Id).Name);

                //        prod = overrideProduct(prod, prExByProdByAcc.get(dos.Verwijzer__c).get(prod.Id));

                //    }
                    
                //}else if(dos.Product_Exception__c == 'Relatie'){
                //    System.debug('dos Relatie + ' + dos.id);

                //    if(prExByProdByAcc.containskey(dos.Relatie__c) && prExByProdByAcc.get(dos.Relatie__c).containskey(prod.Id)){
                //         System.debug('***  dP prodEx Relatie : ' + prExByProdByAcc.get(dos.Relatie__c).get(prod.Id).Name);

                //        prod = overrideProduct(prod, prExByProdByAcc.get(dos.Relatie__c).get(prod.Id));

                //    }
                //    //prod = overrideProduct(prod, prExByProdByAcc.get(dos.Relatie__c).get(prod.Id));

                //}
                for(Dossier dos2 : unmatchedDossiers){
                    System.debug('*** dos2 bef user = ' + dos2.dossier.Name + ' --- ' + dos2.product.Product_tijd_UU_MM__c);
                }

            }else{
                prod = new Product__c();
            }
            System.debug('*** Af prod = ' + prod + '*++* DOSSIER === ' +dos.Name +' -- ' + dos.ID);

            if (dos.Status__c == 'Unmatched' ) {
                
                Dossier d = new Dossier (dos, false, true,prod);
                System.debug('------- NEW DOSSIER + ' + d);
                unmatchedDossiers.add(d);  
                System.debug('unmatched'+ unmatchedDossiers.size() + ' ' + unmatchedDossiers);
                
                jsonStr +=  JSON.serialize(d) +',';

            } else {
                voorDossiers.add(new Dossier (dos, false, true, prod));
            }
            
            //if (dosProdByDosId.containsKey(dos.Id) &&  productsByIds.containsKey(dosProdByDosId.get(dos.Id).get(0).Product__c)) {

            //    productsByIds.get(dosProdByDosId.get(dos.Id).get(0).Product__c).Product_tijd_UU_MM__c = '000:15';

            //} // TEST ETST TEST TES TEST TES TEST TES TES TES TEST
        }
        if (jsonStr != '['){
            jsonStr = jsonStr.substring(0, jsonStr.length()-1);
        }
        jsonStr+=']';
        System.debug('json' + jsonStr );
        unmatchedDossiers = new List <Dossier>();
        unmatchedDossiers = (List<Dossier>)JSON.deserialize(jsonStr, List<Dossier>.class);
        for(Dossier dos : unmatchedDossiers){
            System.debug('*** dos bef user = ' + dos.dossier.Name + ' --- ' + dos.product.Product_tijd_UU_MM__c);

        }
        List <User> userList = [select Id, Medewerker_Type__c , Name, Uren_per_week__c, Address, City, State, Country, Street, PostalCode, Productgroep__c, Label__c, Longitude, Latitude, Type_Gebruiker__c from User where isActive = true order by Type_Gebruiker__c ];
        for (User u: userList) {
            users.add(new UserList(u, false, true, 0));
        }

    }
    public void setOpen () {
        errorMessage  = '';

        Dossier selected;
        List <Dossier__c> toUpdate = new List <Dossier__c>();
        Set <Id> accIds = new Set <Id>();
        for (Dossier d: voorDossiers) {
            if (d.isSelected) {
                selected = d;
                d.dossier.Status__c = 'In Behandeling';
                accIds.add(d.dossier.Relatie__c);
                toUpdate.add(d.dossier);
                
                
            }
        }
        try{
            update toUpdate ;
        }catch(Exception e) {
            errorMessage = e.getDmlMessage(0) ;
        }
        
        loadData();
    }
    public String selectedSkillUn {get;set;}
    public String selectedSkill1 {get;set;}
    public String selectedProduct1 {get;set;}
    public String seacrhByNumber {get;set;}
    public String seacrhByClientName {get;set;}
    public String seacrhByEndDate  {get;set;}
    public String searchByAddress {get;set;}
    public String searchByDate {get;set;}
    public String seacrhByBranche {get;set;}
    public String selectedProductUn {get;set;}

    public void addFilterToDossiers () {
        if (seacrhByNumber == null) {
            seacrhByNumber = '';
        }
        if (seacrhByClientName == null) {
            seacrhByClientName = '';
        }
        if (selectedSkillUn == null) {
            selectedSkillUn = '';
        }
        if (selectedProductUn == null) {
            selectedProductUn = '';
        }
        if (searchByAddress == null) {
            searchByAddress = '';
        }
        if (seacrhByBranche == null) {
            seacrhByBranche = '';
        }
        
        
        for (Dossier dos: unmatchedDossiers) {
            String address = '';
            if (dos.dossier != null) {
                address = dos.dossier.Plaats__c + ' ' + dos.dossier.Straat__c + ' ' + dos.dossier.Postcode__c; 

            }
           
           System.debug(dos.dossier.Label__c + '==' +selectedSkillUn );
            System.debug(dos.product.Productgroep__c + '==' +selectedProductUn);
            if (dos.dossier.Name.contains(seacrhByNumber) && dos.dossier.Relatie__r.Name.contains(seacrhByClientName) 
                   && address.containsIgnoreCase(searchByAddress) && ((dos.dossier.Branche3__c != null && dos.dossier.Branche3__c.contains(seacrhByBranche)) || (seacrhByBranche == '' && dos.dossier.Branche3__c == null))
                   && (dos.dossier.Label__c!= null && dos.dossier.Label__c.contains(selectedSkillUn)|| selectedSkillUn == '' || selectedSkillUn  == 'All')
                   &&  (dos.product.Productgroep__c != null && dos.product.Productgroep__c.contains(selectedProductGroup) || selectedProductGroup== 'All' || selectedProductGroup== '' ) ) {
                   
                dos.show = true;
            } else {
                dos.show = false;
                
            }
            if (selectedSkillUn == 'All' && seacrhByNumber == '' && seacrhByClientName == '' && searchByAddress == '' && seacrhByBranche =='' && selectedProductUn == 'All') {
                dos.show = true;
                
            }
            
        }
        
    } 
    public void closeMatchUser () {
        
        showUsers = false;
        for (UserList u: users) {
            u.show =  true;
        }
        loadData();
    }
    public void addFilterPr () {
    
        
    }
    public void finishMatching () {
        errorMessage  = '';

        Dossier selected;
        for (Dossier d: unmatchedDossiers) {
            if (d.isSelected) {
                selected = d;
                d.dossier.Status__c = 'Voorlopig gematched';
                User handler;
                for (UserList u: users) {
                    if (u.isSelected) {
                        handler = u.user;
                    }
                }
                d.dossier.handler__c = handler.id ;
                try{
                    update d.dossier;
                }catch(Exception e) {
                    errorMessage = e.getDmlMessage(0) ;
                }
            }
        }
        showUsers = false;
        for (UserList u: users) {
            u.show =  true;
        }
        loadData();
    }
    public List <Holiday> holidays {
        get {
            if (holidays == null) {
                holidays = [select ActivityDate from Holiday];
            }
            return holidays;
        } set;

    }

    public Integer getBusinessDays (Date startDate, Integer period){
        
        if (startDate != null) {
            //holidays = [select ActivityDate from Holiday];
            Map <String, Holiday> dates = new Map <String, Holiday>();
            for (Holiday h: holidays) {
                //System.debug(h);
                dates.put(String.valueOf(h.ActivityDate), h);
            }
            //System.debug('getBusinessDays dates ' + dates);
            for (Integer i = 0; i < period; i++) {

                String curDate = String.valueOf(startDate.addDays(i));
                Datetime activityDate =  (Datetime )startDate.addDays(i);
                String dayOfWeek = activityDate.format('EEEE');
             
                   
                //System.debug('getBusinessDays curDate ' + curDate);
                if (dates.containskey(curDate)) {
                    period++;
                } else if (dayOfWeek.equals('Saturday') || dayOfWeek.equals('Sunday')) {
                    period++;

                }
            }
            System.debug('getBusinessDays period ' + period + ' date ' + startDate );
        }
        return period;

    }
    public String selectedSkill{get;set;} 
    public List<SelectOption> getSkillFilter(){
        List<SelectOption> options = new List<SelectOption>();     
        Schema.DescribeFieldResult fieldResult = User.Label__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        options.add(new SelectOption('All', 'Alle'));    
        for( Schema.PicklistEntry f : ple)  {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    public String selectedProductGroup{get;set;} 
      public String selectedProductGroup1{get;set;} 
    public List<SelectOption> getProductGroupFilter(){
        List<SelectOption> options = new List<SelectOption>();     
        Schema.DescribeFieldResult fieldResult = User.Productgroep__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        options.add(new SelectOption('All', 'Alle'));    
        for( Schema.PicklistEntry f : ple)  {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    public String selectedType{get {if (selectedType == null){selectedType = 'Eigen';}return selectedType;}set;} 
    public List<SelectOption> getTypeFilter(){
        List<SelectOption> options = new List<SelectOption>();     
        Schema.DescribeFieldResult fieldResult = User.Medewerker_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        options.add(new SelectOption('All', 'Alle'));    
        for( Schema.PicklistEntry f : ple)  {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    public void addFilter () {
        if (selectedType == null) {
            selectedType = '';
        }
        if (filterByUserName == null) {
            filterByUserName = '';
        }
        if (filterByUserAddress == null) {
            filterByUserAddress = '';
        }
        if (selectedSkill1 == null) {
            selectedSkill1 = '';
        }
        if (selectedProductGroup1== null) {
            selectedProductGroup1= '';
        }
        Dossier selected;
        for (Dossier d: unmatchedDossiers) {
            if (d.isSelected) {
                selected = d;
            }
        }
        errorMessage  = '';
        if (selected != null) {
            Account account = [select Id from Account where Id =: selected.dossier.Relatie__c];
            
            List <AccountTeamMember> members = [SELECT AccountAccessLevel, AccountId, Id,  TeamMemberRole, UserId FROM AccountTeamMember where AccountId =: account.Id];
            Set <Id> usersIds = new Set <Id>();
            for (AccountTeamMember member:members  ) {
                usersIds.add(member.UserId );
            }
            filterByUserName = filterByUserName.toLowerCase();
            filterByUserAddress = filterByUserAddress.toLowerCase();
            Set<String> allSkill = new Set <String>();
            Map <Id, User> usersById = new Map <Id,User>([select Id from User where id in: usersIds and isActive = true]);
                Map<Id, Dossier__c> dossiersByUser = new Map <Id, Dossier__c>([select Id, handler__c   from Dossier__c where handler__c in: usersById.keySet() and Status__c = 'In Behandeling']);
                List <DossierProduct__c> dosProds = [select Id, Product__r.Product_tijd_UU_MM__c, Dossier__c, Dossier__r.Handler__c, Dossier__r.Product_Exception__c, Dossier__r.Verwijzer__c, Dossier__r.Relatie__c  from DossierProduct__c where Dossier__c in: dossiersByUser.keySet() ];
                /*Map <Id, Decimal> urenPerUser = new Map <Id, Decimal>();
                for (DossierProduct__c dP: dosProds) {
                    Decimal hours = 0;
                    
                    if (dP.Product__r.Product_tijd_UU_MM__c != null && selected.product != null && selected.product.Product_tijd_UU_MM__c!= null) {
                            System.debug(dP.Product__r.Product_tijd_UU_MM__c);
                            System.debug(selected.product);
                            System.debug(selected.product.Product_tijd_UU_MM__c);
                            hours  = Decimal.valueOf(selected.product.Product_tijd_UU_MM__c.substring(0,3))+Decimal.valueOf(selected.product.Product_tijd_UU_MM__c.substring(4,6))/100;
                        }
                    if (urenPerUser.containsKey(dP.dossier__r.Handler__c)) {
                        urenPerUser.put(dP.dossier__r.Handler__c, urenPerUser.get(dP.dossier__r.Handler__c) + hours );
                        System.debug(dP.dossier__r.Handler__c);
                            System.debug(urenPerUser.get(dP.dossier__r.Handler__c));
                            System.debug(urenPerUser);
                    } else {
                        urenPerUser.put(dP.dossier__r.Handler__c,  hours );
                        System.debug(urenPerUser);
                    }
                }*/
            for (UserList u: users) {
             /*Decimal loadSum = 0;
                    if (urenPerUser.containsKey(u.user.Id)) {
                        loadSum = urenPerUser.get(u.user.Id);
                    }*/
                String address = u.user.City + ' ' + u.user.Street + ' ' + u.user.PostalCode; 
                
                if ((u.user.Label__c != null && u.user.Label__c.contains(selectedSkill1) || selectedSkill1 == 'All' )  && u.user.Name.toLowerCase().contains(filterByUserName) 
                            && (address.containsIgnoreCase(filterByUserAddress))
                            ){
                    u.show = true;         
                    if (usersIds.contains(u.user.ID) && (((usersIds.contains(u.user.ID) || usersIds.size()==0 ) && showTeamOnly) || !showTeamOnly)) {
                        u.voorkeur = 'Ja';
                    } else {
                        u.voorkeur  = 'Nee';
                    }
                   
                    /*Decimal loadDos = 0;
                    if (selected.product != null && selected.product.Doorlooptijd_in_dagen__c != null && selected.product.Product_tijd_UU_MM__c != null && u.user.Uren_per_week__c != null) {
                        Decimal workLoadPerDay = u.user.Uren_per_week__c / 5;
                        if (workLoadPerDay > 8) {
                            workLoadPerDay = 8;
                        }
                        Decimal businessDaysInDossier = getBusinessDays(selected.dossier.Datum_Binnenkomst__c ,Integer.valueOf(selected.product.Doorlooptijd_in_dagen__c) ) ;
                        
                        Decimal businessHoursAvailableInDossierPeriod = businessDaysInDossier * workLoadPerDay;
                        Decimal emptyHours = businessHoursAvailableInDossierPeriod - loadSum;
                        loadDos = emptyHours ;
    
                    }
                    u.loadDos = loadDos  ;
                    
          */
                    
                    Boolean userContainsProd = false;
                    if (selected.product != null && selected.product.productgroep__c!= null) {
                        List <String> prodGroeps = selected.product.productgroep__c.split(';');
                        if ( u.user.ProductGroep__c != null) {
                            List <String> userGroeps = u.user.productgroep__c.split(';');
                            for (String pr: prodGroeps) {
                                System.debug('pr ' + pr);
                                for (String us: userGroeps ) {
                                   System.debug('us ' + us  + '. pr ' + pr + '. ' + us.indexOf(pr));
                                    if (us.indexOf(pr) != -1) {
                                        System.debug('TRUE');
                                        userContainsProd = true;
                                        break;
                                    }
                                }
                                if (userContainsProd ){
                                    break;
                                }
                            }
                        }
                    }
                    
                    if ((u.mogelick == 'Nee' && showLessThanLoad ) || (u.voorkeur  == 'Nee' && showTeamOnly) 
                        || (productShow && u.user.ProductGroep__c != null  && !userContainsProd )
                        || (productShow && u.user.productgroep__c == null && selected.product!=null && selected.product.productgroep__c != null)  
                        || (productShow && selected.product!=null && selected.product.productgroep__c== null) 
                        || ((u.user.Medewerker_Type__c != null && !u.user.Medewerker_Type__c.contains(selectedType) && selectedType != 'All' ) || (u.user.Medewerker_Type__c == null && selectedType!= 'All')  )) {
                           u.show = false;
                            
                        } else {
                           
                            //u.show = true;
                        }    
                       
    
                    allSkill.add(u.user.Label__c );
                    /*if (productShow && u.user.ProductGroep__c!= null && selected.product != null && selected.product.productgroep__c!= null && !(u.user.ProductGroep__c.contains(selected.product.productgroep__c))) {
                        u.show = false;
                        System.debug('u.show ' +productShow + ' ' + u.user);
                    }*/
                } else {
                    u.show = false;
                    u.isSelected = false;
                    
                }
                
    
            }
            if (allSkill.size() == 1) {
                List <String> l = new List<String>(allSkill);
                selectedSkill = l.get(0);
            } else {
    
                selectedSkill = 'All'; 
                selectedProductGroup = 'All';
                /*for (UserList u: users) {
                    u.show = true;
                }*/
            }
        } else {
            errorMessage = Label.No_dos_selected ;
            
        }
    }
    public Boolean showLessThanLoad {get{if(showLessThanLoad == null){showLessThanLoad = true;}return showLessThanLoad;}set;}
    public String filterByUserName {get;set;}
    public String filterByUserAddress {get;set;}
    public void findUsers () {
        showVoorDoos = false;
        
        showUsers = true;
        Dossier selected;
        for (Dossier d: unmatchedDossiers) {
            if (d.isSelected) {
                selected = d;
            }
        }
        errorMessage  = '';
        if (selected != null)  {
                Account account = [select Id from Account where Id =: selected.dossier.Relatie__c];
               
                List <AccountTeamMember> members = [SELECT AccountAccessLevel, AccountId, Id,  TeamMemberRole, UserId FROM AccountTeamMember where AccountId =: account.Id];
                Set <Id> usersIds = new Set <Id>();
                for (AccountTeamMember member:members  ) {
                    usersIds.add(member.UserId );
                }
                
                users = new List <UserList>();
                Decimal lat;
                Decimal lon;
                if ( selected.dossier.OtherLatitude__c == null 
                        || selected.dossier.OtherLongitude__c  == null) {
                    lat = 0;
                    lon = 0;
                } else {
                    lat =  selected.dossier.OtherLatitude__c ;
                    lon = selected.dossier.OtherLongitude__c  ;
                }
                List <User> userList = Database.query('SELECT Id, '+
                    //'DISTANCE(Geolocatie__c, GEOLOCATION(' + lat + ', ' + lon + ' ), \'km\') dist,'+
                    ' Address, City, Street, Medewerker_Type__c , PostalCode, Productgroep__c, State, Uren_per_week__c, Country, Name, Label__c, Longitude, Latitude '+
                    ' FROM User where isActive = true order by DISTANCE(Geolocatie__c, '+
                    'GEOLOCATION(' + lat +
                     ', ' + lon + ' ), \'km\')  '); 
                Map <Id, User> usersById = new Map <Id,User>(userList);
                System.debug('userList ' + userList);
                Map<Id, Dossier__c> dossiersByUser = new Map <Id, Dossier__c>([select Id, handler__c, Einddatum__c,Datum_Binnenkomst__c, Product_Exception__c , Verwijzer__c, Relatie__c   
                                                                from Dossier__c where handler__c in: usersById.keySet() 
                                                                and (Status__c = 'In Behandeling' OR Status__c ='Voorlopig gematched')
                                                                and ((Datum_Binnenkomst__c >=: selected.dossier.Datum_Binnenkomst__c 
                                                                    AND Einddatum__c <=: selected.dossier.Einddatum__c) 
                                                                OR (Datum_Binnenkomst__c <: selected.dossier.Datum_Binnenkomst__c  
                                                                    AND Einddatum__c >=: selected.dossier.Datum_Binnenkomst__c 
                                                                    AND Einddatum__c <=: selected.dossier.Einddatum__c )
                                                                OR (Datum_Binnenkomst__c >=: selected.dossier.Datum_Binnenkomst__c 
                                                                    AND Datum_Binnenkomst__c <=: selected.dossier.Einddatum__c 
                                                                    AND Einddatum__c >: selected.dossier.Einddatum__c)
                                                                OR (Datum_Binnenkomst__c <:  selected.dossier.Datum_Binnenkomst__c 
                                                                    AND Einddatum__c >: selected.dossier.Einddatum__c ) ) ]);
                List <DossierProduct__c> dosProds = [select Id, Product__r.Product_tijd_UU_MM__c, Dossier__r.Verwijzer__c, Dossier__r.Relatie__c, 
                                                                Product__r.Doorlooptijd_in_dagen__c, Dossier__r.Datum_Binnenkomst__c,
                                                                Dossier__r.Einddatum__c, Dossier__c, Dossier__r.Handler__c, Product__c, 
                                                                Dossier__r.Product_Exception__c, Dossier__r.Name 
                                                                from DossierProduct__c where Dossier__c in: dossiersByUser.keySet() ];
                
                Map <Id, Decimal> urenPerUser = new Map <Id, Decimal>();


                Set <Id> accountIds = new Set <Id>();
                Set <Id> productIds = new Set <Id>();
                Set <Id> prExIds = new Set <Id>();
                Map <Id , Product_exeption__c>  prExByProd = new Map <Id , Product_exeption__c>();

                Map <Id, Map <Id , Product_exeption__c>>  prExByProdByAcc = new Map <Id, Map< Id , Product_exeption__c>>();
                for(DossierProduct__c dosPr : dosProds){
                    productIds.add(dosPr.Product__c);
                    if(dosPr.Dossier__r.Relatie__c != null){
                        accountIds.add(dosPr.Dossier__r.Relatie__c);
                    }
                    if(dosPr.Dossier__r.Verwijzer__c != null){
                        accountIds.add(dosPr.Dossier__r.Verwijzer__c);
                    }
                }
                System.debug('*** accountIds : ' + accountIds);

                System.debug('*** productIds : ' + productIds);

                Map <Id, Product__c> productMap = new Map <Id, Product__c>([SELECT Id, Name, Doorlooptijd_in_dagen__c, Product_tijd_UU_MM__c FROM Product__c WHERE Id =: productIds]);

                Map <Id, Product_exeption__c> prExMap = new Map <Id, Product_exeption__c>([SELECT Id, Name, Product__c, Account__c, Product_tijd_UU_MM__c FROM Product_exeption__c WHERE Account__c =: accountIds]);
                for(Product_exeption__c prEx : prExMap.values()){
                    
                    prExByProd.put(prEx.Product__c, prEx);
                    prExByProdByAcc.put(prEx.Account__c, prExByProd);
                    if (prExByProdByAcc.containsKey(prEx.Account__c)) {
                        prExByProdByAcc.get(prEx.Account__c).put(prEx.Product__c, prEx);
                    } else {
                        Map <Id, Product_exeption__c> prExMp = new MAp <Id, Product_Exeption__c> ();
                        prExMp.put(prEx.Product__c, prEx);
                        prExByProdByAcc.put(prEx.Account__c,prExMp );
                    }
                }

                /*Map <String, List<DossierProduct__c>> dossierProductsPerUser = new Map <String, List<DossierProduct__c>>();
                for (DossierProduct__c dP: dosProds){
                    if (dossierProductsPerUser.containsKey(dp.dossier__r.Handler__c)) {
                        dossierProductsPerUser.get(dp.dossier__r.Handler__c ).add(dp);
                    } else {
                        dossierProductsPerUser.put(dp.dossier__r.Handler__c , new List <DossierProduct__c>{dp});
                    }
                }
                System.debug('dossierProductsPerUser '+ usersById.keySet());
                System.debug('userById  '+ dossierProductsPerUser);
                for (User user: usersById.values()) {
                    if (dossierProductsPerUser.containsKey(user.Id)) {*/
                        for (DossierProduct__c dP: dosProds) {
                            Product__c prod = productMap.get(dP.Product__c);
                            System.debug('***  dP prod : ' + prod);
                            System.debug('*** BEFORE dP prod.Product_tijd_UU_MM__c : ' + prod.Product_tijd_UU_MM__c);
                            System.debug('dp.Dossier__r.Product_Exception__c  = ' + dp.Dossier__r.Name);

                            System.debug('dp.Dossier__r.Product_Exception__c  = ' + dp.Dossier__r.Product_Exception__c);

                            prod = overrideProductPartOne(dossiersByUser.get(dp.Dossier__c), prod, prExByProdByAcc);
/*                            if(dp.Dossier__r.Product_Exception__c == 'Verwijzer'){
                                System.debug('prExByProdByAcc.get Verwijzer = ' + dp.Dossier__r.Verwijzer__c);
                                System.debug('prExByProdByAcc.get(dp.Dossier__r.Verwijzer__c) = ' + prExByProdByAcc.get(dp.Dossier__r.Verwijzer__c));
                                if(prExByProdByAcc.containskey(dp.Dossier__r.Verwijzer__c) && prExByProdByAcc.get(dp.Dossier__r.Verwijzer__c).containskey(dP.Product__c)){
                                     System.debug('***  dP prodEx Verwijzer : ' + prExByProdByAcc.get(dp.Dossier__r.Verwijzer__c).get(dP.Product__c).Name);

                                    prod = overrideProduct(prod, prExByProdByAcc.get(dp.Dossier__r.Verwijzer__c).get(dP.Product__c));

                                }
                            }else if(dp.Dossier__r.Product_Exception__c == 'Relatie'){
                              if(prExByProdByAcc.containskey(dp.Dossier__r.Relatie__c) && prExByProdByAcc.get(dp.Dossier__r.Relatie__c).containskey(dP.Product__c)){
                                     System.debug('***  dP prodEx Relatie : ' + prExByProdByAcc.get(dp.Dossier__r.Relatie__c).get(dP.Product__c).Name);

                                    prod = overrideProduct(prod, prExByProdByAcc.get(dp.Dossier__r.Relatie__c).get(dP.Product__c));

                                }
                                //prod = overrideProduct(prod, prExByProdByAcc.get(dp.Dossier__r.Relatie__c).get(dP.Product__c));

                            }*/
                            System.debug('*** AFTER dP prod.Product_tijd_UU_MM__c : ' + prod.Product_tijd_UU_MM__c);

                            System.debug('DosProd ' + dp + ' ' + user.Name);
                            Decimal hours = 0;
                            if (prod.Product_tijd_UU_MM__c != null && prod.Product_tijd_UU_MM__c.length() >3 && selected.product!= null && selected.product.Product_tijd_UU_MM__c!= null) {
                                String hou = prod.Product_tijd_UU_MM__c.substring(0,3);
                                if (hou!= '000') {
                                    while (hou.startsWith('0')) {
                                        hou = hou.substring(1, hou.length());
                                    }
                                } else {
                                    hou = '0';
                                }
                                String mins = '0';
                                if (prod.Product_tijd_UU_MM__c.length()>=6) {
                                    mins = prod.Product_tijd_UU_MM__c.substring(4,6);
                                }
                                
                                if (mins != '00') {
                                    while (mins.startsWith('0') && mins.length()>=hou.length()) {
                                        mins = mins.substring(1, hou.length());
                                    }
                                } else {
                                    mins = '0';
                                }
                                hou = hou.replace(':', '');
                                Decimal hoursPerDay =   (Decimal.valueOf(hou)+Decimal.valueOf(mins)/60)/prod.Doorlooptijd_in_dagen__c;  
                                hours  = hoursPerDay * dP.Product__r.Doorlooptijd_in_dagen__c;
                                System.debug('hours ' + hours);
                                System.debug('interval '+dP.Product__r.Doorlooptijd_in_dagen__c);
                                System.debug('hoursPerDay ' + hoursPerDay);
                                Decimal spentHours = 0;
                                if (selected.dossier.Datum_Binnenkomst__c> dp.Dossier__r.Datum_Binnenkomst__c) {
                                    spentHours = dp.Dossier__r.Datum_Binnenkomst__c.daysBetween(selected.dossier.Datum_Binnenkomst__c)  + ( dp.Dossier__r.Datum_Binnenkomst__c.daysBetween(selected.dossier.Datum_Binnenkomst__c) - getBusinessDays(dp.Dossier__r.Datum_Binnenkomst__c, dp.Dossier__r.Datum_Binnenkomst__c.daysBetween(selected.dossier.Datum_Binnenkomst__c)));
                                    System.debug('date diff '+ dp.Dossier__r.Datum_Binnenkomst__c.daysBetween(selected.dossier.Datum_Binnenkomst__c));
                                    System.debug('interval '+spentHours);
                                    spentHours = spentHours*hoursPerDay;
                                }
                                System.debug('spentHours ' + spentHours);
                                hours = hours - spentHours;
                            }
                            if (urenPerUser.containsKey(dP.dossier__r.Handler__c)) {
                                urenPerUser.put(dP.dossier__r.Handler__c, urenPerUser.get(dP.dossier__r.Handler__c) + hours );
                                
                            } else {
                                urenPerUser.put(dP.dossier__r.Handler__c,  hours );
                                
                            }
                        }
                    //}
               //}
                
                for (User u: userList) {
                    
                    String address = '';
                    if (selected.dossier.Straat__c != null)
                        address += selected.dossier.Straat__c  +',';
                    if (selected.dossier.Plaats__c!= null)
                        address += selected.dossier.Plaats__c +',';
                    
                    if (selected.dossier.PostCode__c != null)
                        address += selected.dossier.PostCode__c  +',';
                    if (selected.dossier.Land__c != null)
                        address += selected.dossier.Land__c ;
                    
                    String addressUser = '';
                    if (u.Street != null)
                        addressUser += u.Street +',';
                    if (u.City != null)
                        addressUser += u.City +',';
                    if (u.State != null)
                        addressUser += u.State +',';
                    if (u.PostalCode != null)
                        addressUser += u.PostalCode +',';
                    if (u.Country != null)
                        addressUser += u.Country;
    
                    //System.debug(u.get('dist'));
                    Decimal dist = 0;
                    try {
                        
                        dist = GeolocationCallout.getDistance(address, addressUser);
                    } catch (Exception e){
                        System.debug('ERROR GOOGLE ' + e.getLineNumber() + ' '  + e.getMessage());
                    }
                    users.add(new UserList(u, false, true, dist));//(Decimal) u.get('dist')
                }
                
                Integer i = 0;
                List <Integer> toRemove = new List <Integer>();
                Set<String> allSkill = new Set <String>();
                for (UserList u: users) {
                    u.show = true;
                    Decimal loadSum = 0;
                    if (urenPerUser.containsKey(u.user.Id)) {
                        loadSum = urenPerUser.get(u.user.Id);
                    }
                    
                    if ( (((usersIds.contains(u.user.ID) || usersIds.size()==0 ) && showTeamOnly) || !showTeamOnly) ){
                    
                        if (usersIds.contains(u.user.ID) ) {
                            u.voorkeur = 'Ja';
                        } else {
                            u.voorkeur  = 'Nee';
                        }
                        //16:03:44:566 USER_DEBUG [682]|DEBUG|******* selected.dossier.Datum_Binnenkomst__c - Dossier:[ASCENDING=ASCENDING, Load=null, 
                        //SortDirection=null, SortField=null, dossier=Dossier__c:{Id=a095E000000VlSEQA0, Name=DN-0003254, Product_gekoppeld__c=Nee, 
                        //    Datum_Binnenkomst__c=2017-02-27 00:00:00, reference_Id__c=DN-0003254, Label__c=Elabo, Status__c=Unmatched, 
                        //    Ingangsdatum__c=2017-02-27 00:00:00, handler__c=00558000000jl8bAAA, ClientName__c=De Groot Consultancy B.V., 
                        //    Relatie__c=0015E00000B4aQ6QAJ, Straat__c=24 Kulparkivska Street, Plaats__c=L'viv, RecordTypeId=01258000000c3XwAAI}, 
                        //    isSelected=true, product=Product__c:{}, show=true]

                        Decimal loadDos = 0;
                        if (selected.product.Id != null && u.user.Uren_per_week__c != null) {
                            //loadDos = Decimal.valueOf(selected.product.Product_tijd_UU_MM__c.substring(0,3))+Decimal.valueOf(selected.product.Product_tijd_UU_MM__c.substring(4,6))/100;
                            Decimal workLoadPerDay = u.user.Uren_per_week__c / 5;
                            Decimal businessDaysInDossier = selected.product.Doorlooptijd_in_dagen__c;//getBusinessDays(selected.dossier.Datum_Binnenkomst__c ,Integer.valueOf(selected.product.Doorlooptijd_in_dagen__c) ) ;
                            System.debug('*******workLoadPerDay - '+workLoadPerDay);
                            System.debug('****** selected.dossier.Datum_Binnenkomst__c - '+selected.dossier.Datum_Binnenkomst__c);  
                            System.debug('******* selected.dossier.Datum_Binnenkomst__c - '+selected);  

                            System.debug('******selected.product - '+selected.product);                            
                            System.debug('******selected.product.Doorlooptijd_in_dagen__c - '+selected.product.Doorlooptijd_in_dagen__c);                            

                            System.debug('******businessDaysInDossier - '+businessDaysInDossier);                            
                            Decimal businessHoursAvailableInDossierPeriod = businessDaysInDossier * workLoadPerDay;
                            Decimal emptyHours = businessHoursAvailableInDossierPeriod - loadSum;
                            loadDos = emptyHours ;

                            System.debug('businessHoursAvailableInDossierPeriod - '+businessHoursAvailableInDossierPeriod);
                            System.debug('loadSum - '+loadSum);
                        }
                        System.debug('loadDos - '+loadDos);
                        u.loadDos = loadDos  ;
                        
                        if (loadDos  > u.user.Uren_per_week__c) {
                            u.mogelick = 'Ja';
                        } else {
                            u.mogelick  = 'Nee';
                        }
                        
                        
                        List <String> skills = new List <String>();
                        if (u.user.Label__c != null) {
                         skills  = u.user.Label__c.split(';');
                         }
                        List <String> labels = selected.dossier.Label__c.split(';');
                        Set <String> sk = new Set <String>(skills);
                        Set <String> lb = new Set <String>(labels);
                        
                        List <String> userGroup = new List <String>();
                        if (u.user.Productgroep__c != null) {
                            userGroup  = u.user.Productgroep__c.split(';');
                        }
                        List <String> productG = new List <String>();
                        if (selected.product != null &&  selected.product.Productgroep__c!= null) {
                            productG = selected.product.Productgroep__c.split(';');
                        }
                        Set <String> uG = new Set <String>(userGroup );
                        Set <String> pG = new Set <String>(productG );
                        
                        
                        u.show = false;
                        for (String l: lb) {
                            for (String s: sk) {
                                if (s.equals(l) ) {
                                    u.show =  true;
                                    selectedSkill = u.user.Label__c ;
                                    selectedProductGroup = u.user.ProductGroep__c;
                                    allSkill.add(u.user.Label__c );
                                }
                            }
                        }
                        for (String l: pG) {
                            for (String s: uG) {
                                if (s.equals(l) && u.show ) {
                                   // u.show =  true;
                                    
                                    selectedProductGroup = u.user.ProductGroep__c;
                                   
                                }
                            }
                        }
                        
                        if ((u.mogelick == 'Nee' && showLessThanLoad ) || (u.voorkeur == 'Nee' && showTeamOnly) || (productShow && u.user.ProductGroep__c!= null && selected.product != null && selected.product.productgroep__c!= null && !(u.user.ProductGroep__c.contains(selected.product.productgroep__c)) ) || (productShow && u.user.productgroep__c== null)  ||(productShow && selected.product ==null) || (productShow && selected.product!=null && selected.product.productgroep__c== null)) {
                            u.show = false;
                            System.debug('mogelick' + u.mogelick  + ' + '+ showLessThanLoad + ' ' + u.user);
                        } else {
                          
                           
                        }
                        
                        
                        /*if (productShow && u.user.ProductGroep__c!= null && selected.product != null && selected.product.productgroep__c!= null && !(u.user.ProductGroep__c.contains(selected.product.productgroep__c))) {
                            u.show = false;
                             System.debug('productShow ' +productShow  + ' ' + u.user);
                        }*/
                        /*if ( sk.contains(selected.dossier.Label__c)) {
                            System.debug(u.user);
                            u.show =  true;
                            selectedSkill = u.user.Label__c ;
                        } else {
                            System.debug('i='+i+' ' +u.user);
                            u.show = false;
                            
                        }*/
                    } else {
                        u.show = false;
                       
                    }
                     
                    i++;
                }
                
                if (allSkill.size() == 1) {
                    List <String> l = new List<String>(allSkill);
                    selectedSkill = l.get(0);
                } else {
    
                    selectedSkill = 'All'; 
                    selectedProductGroup = 'All'; 
                    /*for (UserList u: users) {
                        u.show = true;
                    }*/
                }
               
              
         } else {
             errorMessage = Label.No_dos_selected;
         }
            
            /*if (selectedSkill1 == 'All' || selectedSkill1 == '') {
                    selectedSkill1 = selectedSkillUn;
            }
            if (selectedProductgroup1== 'All' || selectedProductgroup1 == '') {
                    selectedProductgroup1 = selectedProductGroup;
            }*/
            
           
           sortByFiledUser();

    }
    
    public String sortDirection {get;set;}
    public String sortField {get;set;}
    public String focus {get;set;}

    public void saveDefault () {
        System.debug('focus'+focus);
    }
    public PageReference sortByFiled() {
       
        Dossier.SortDirection = sortDirection;
        Dossier.SortField = sortField;
        this.unmatchedDossiers.sort();
       
        return null;
    }
    public PageReference sortByFiledUser() {
    
        if (sortDirection  == null || sortDirection  == ''){
            sortDirection  = 'Descending';
            sortField = 'uren';
        }
        
        UserList.SortDirection = sortDirection;
        UserList.SortField = sortField;
        this.users.sort();
        
        return null;
    }
    public void unmatch () {
        errorMessage  = '';
        List <Dossier__c> toUpdate = new List <Dossier__c>();
       
        for (Dossier d: voorDossiers) {
            if (d.isSelected) {
                d.dossier.Status__c = 'Unmatched';
                d.dossier.handler__c = null;
                toUpdate.add(d.dossier);
                
               
            }
        }
        try{
            update toUpdate ;
        }catch(Exception e) {
            errorMessage = e.getDmlMessage(0) ;
        }

        loadData();
    }
    public PageReference sortByFiledVoor() {
        
        Dossier.SortDirection = sortDirection;
        Dossier.SortField = sortField;
        this.voorDossiers.sort();
        
        return null;
    }

    public static Product__c overrideProduct (Product__c dosProduct, Product_exeption__c ex) {
       System.debug('Override' + dosProduct +' /// ' + ex);
        System.debug('BEf Override.Product_tijd_UU_MM__c = ' + dosProduct.Product_tijd_UU_MM__c );

        try {
            if(ex.Product_tijd_UU_MM__c != null){
                dosProduct.Product_tijd_UU_MM__c = ex.Product_tijd_UU_MM__c;

            }
            System.debug('AF Override Product_tijd_UU_MM__c ' + dosProduct.Product_tijd_UU_MM__c );

            System.debug('Override' + dosProduct );
            return dosProduct;
        } catch (Exception e) {
            System.debug('ERROR '+ e.getMessage());
            return dosProduct;
        }
    }

    public static Product__c overrideProductPartOne(Dossier__c dos, Product__c prod, Map <Id, Map <Id , Product_exeption__c>> prExByProdByAcc){
        System.debug(dos);
        System.debug(prExByProdByAcc);
        System.debug(prod);
        if(dos.Product_Exception__c == 'Verwijzer'){ 
            System.debug('dos Verwijzer + ' + dos.id);

            System.debug('prExByProdByAcc.get Verwijzer = ' + dos.Verwijzer__c);
            System.debug('prExByProdByAcc.get(dos.Verwijzer__c) = ' + prExByProdByAcc.get(dos.Verwijzer__c));
            if(prExByProdByAcc.containskey(dos.Verwijzer__c) && prExByProdByAcc.get(dos.Verwijzer__c).containskey(prod.Id)){
                 System.debug('***  dP prodEx Verwijzer : ' + prExByProdByAcc.get(dos.Verwijzer__c).get(prod.Id).Name);

                prod = overrideProduct(prod, prExByProdByAcc.get(dos.Verwijzer__c).get(prod.Id));
            }
            return prod;

        }else if(dos.Product_Exception__c == 'Relatie'){
            System.debug('dos Relatie + ' + dos.id);

            if(prExByProdByAcc.containskey(dos.Relatie__c) && prExByProdByAcc.get(dos.Relatie__c).containskey(prod.Id)){
                 System.debug('***  dP prodEx Relatie : ' + prExByProdByAcc.get(dos.Relatie__c).get(prod.Id).Name);

                prod = overrideProduct(prod, prExByProdByAcc.get(dos.Relatie__c).get(prod.Id));
            }
            return prod;

        }else{
            return prod;
        }
            
    }
}