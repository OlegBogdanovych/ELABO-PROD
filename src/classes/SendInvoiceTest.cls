@isTest
public class SendInvoiceTest {
    
    @isTest public static void test_Km() {
        CreateDossierProductTest.createDosProduct();
        Account account = [select id from account];
        account.Debiteurnummer__c = '123456';
        update account;
        User user = [select Id from User where isActive =  true and (Profile.Name = 'System Administrator' or Profile.Name =  'System Admin') limit 1];
        user.Kostenplaats__c = '5001';
        update user;
        Product__c pr = [select Id from Product__c ];
        pr.Tariefsoort__c = 'Uurtarief';
        pr.Rit_Registratie__c = 'KM\'s Retour';
        update pr;
        Dossier__c dossier = [select Id from Dossier__c];
       
        dossier.handler__c = user.id;
        RecordType rt = [select Id from RecordType where Name = 'Kilometerregistratie'];
        Task kMtask = new Task(RecordTypeId = rt.id, WhatId = dossier.Id,  Aantal_Kilometers_gereden__c=1,Reden__c = 'Km kosten, anders', Datum_gereden__c = date.today());
        insert kmTask;
        System.runAs(user){
            Test.startTest();
            update dossier;
            ApexPages.StandardController sc = new ApexPages.StandardController(dossier);
            SendInvoice ctrl = new SendInvoice(sc);
            ctrl.sendInvoice();
            Test.stopTest();
            //System.assertEquals(1, [select Id from Attachment where ParentId =: dossier.Id ].size());
            System.debug(ctrl.data);
        }

    }
    @isTest public static void test_TimeInvoice() {
        CreateDossierProductTest.createDosProduct();
        Account account = [select id from account];
        account.Debiteurnummer__c = '123456';
        update account;
        User user = [select Id from User where isActive =  true and (Profile.Name = 'System Administrator' or Profile.Name =  'System Admin') limit 1];
        user.Kostenplaats__c = '5001';
        update user;
        Product__c pr = [select Id from Product__c ];
        pr.Tariefsoort__c = 'Uurtarief';
        pr.Rit_Registratie__c = 'Tijd enkele reis';
        update pr;
        Dossier__c dossier = [select Id from Dossier__c];
       
        dossier.handler__c = user.id;
        RecordType rt = [select Id from RecordType where Name = 'Urenregistratie'];
        Task urtask = new Task(RecordTypeId = rt.id, WhatId = dossier.Id, Aantal_uur__c = 10, Uursoort__c = 'Anders', Datum__c = date.today());
        insert urtask;
        System.runAs(user){
            Test.startTest();
            update dossier;
            ApexPages.StandardController sc = new ApexPages.StandardController(dossier);
            SendInvoice ctrl = new SendInvoice(sc);
            ctrl.sendInvoice();
            Test.stopTest();
            //System.assertEquals(1, [select Id from Attachment where ParentId =: dossier.Id ].size());
            System.debug(ctrl.data);
        }
         
    }
    @isTest public static void test_One() {
        CreateDossierProductTest.createDosProduct();
        Account account = [select id from account];
        account.Debiteurnummer__c = '123456';
        update account;
        User user = [select Id from User where isActive =  true and (Profile.Name = 'System Administrator' or Profile.Name =  'System Admin') limit 1];
        user.Kostenplaats__c = '5001';
        update user;
        Product__c pr = [select Id from Product__c ];
        pr.Tariefsoort__c = 'Vast tarief';
        pr.Quantity_invoice__c = 2;
        update pr;
        Dossier__c dossier = [select Id from Dossier__c];
       
        dossier.handler__c = user.id;
        System.runAs(user){
            Test.startTest();
            update dossier;
            ApexPages.StandardController sc = new ApexPages.StandardController(dossier);
            SendInvoice ctrl = new SendInvoice(sc);
            ctrl.sendInvoice();
            Test.stopTest();
            System.assertEquals(1, [select Id from Attachment where ParentId =: dossier.Id ].size());
            System.debug(ctrl.data);
        }
         
    }
    @isTest public static void test_Basic() {
        CreateDossierProductTest.createDosProduct();
        Account account = [select id from account];
        account.Debiteurnummer__c = '123456';
        update account;
        User user = [select Id from User where isActive =  true and (Profile.Name = 'System Administrator' or Profile.Name =  'System Admin') limit 1];
        user.Kostenplaats__c = '5001';
        update user;
        Product__c pr = [select Id from Product__c ];
        pr.Tariefsoort__c = 'Vast tarief';
        pr.Quantity_invoice__c = 2;
        update pr;
        Dossier__c dossier = [select Id from Dossier__c];
       
        dossier.handler__c = user.id;
        ErrorHandeling.saveLog('', 'salesline', '');
        TF_ProcessXML x = new TF_ProcessXML ();
        TF_ProcessXML.ProcessXmlSoap xml = new TF_ProcessXML.ProcessXmlSoap('', '');
        xml.ProcessXmlCompressed('');
        xml.ProcessXmlString('');
        
       // TF_SESSION ses = new TF_SESSION();
        //TF_SESSION.Logon('', '', '');
        //TF_SESSION.abandon();
        TwinfieldXmlUtil util = new TwinfieldXmlUtil();
        TwinfieldXmlUtil.parseTransactionXmlResults('');
        TwinfieldXmlUtil.parseXmlResult('', '');
        TwinfieldXmlUtil.parseXmlErrors('<salesinvoice status="Concept" result="1"><header><invoicetype>FACTUUR</invoicetype><invoiceaddressnumber>1</invoiceaddressnumber><office>2716072</office><invoicedate>20161019</invoicedate><customer>100049</customer><currency>EUR</currency><duedate>20161102</duedate><paymentmethod>bank</paymentmethod><headertext>Onze referentie: DN-0000252 Uw referentie:  Medewerker: Test Ok Arbeidsdeskundige: Gerwin Tromp</headertext><status>concept</status><period>2016/10</period><bank>BNK</bank><deliveraddressnumber>1</deliveraddressnumber><footertext></footertext><invoicenumber>104</invoicenumber></header><lines><line id="1"><article>0</article><vatcode name="BTW 21%" shortname="BTW 21%">VH21</vatcode><quantity>5.00</quantity><description>Overleg Derden</description><unitspriceexcl>10.56</unitspriceexcl><freetext1 name="Omzet Elabo" shortname="" dimensiontype="PNL">8150</freetext1><freetext2 name="Martijn Brinkman" shortname="" dimensiontype="KPL">5081</freetext2><freetext3 name="Test Ok" shortname="100049" dimensiontype="PRJ">DN-0000252</freetext3><performancetype></performancetype><subarticle></subarticle><units>1</units><allowdiscountorpremium>true</allowdiscountorpremium><performancedate /><dim1 name="Omzet Elabo" shortname="">8150</dim1><dim2 name="Martijn Brinkman" shortname="">5081</dim2><dim3 name="Test Ok" shortname="100049">DN-0000252</dim3><valueexcl>52.80</valueexcl><vatvalue>11.09</vatvalue><valueinc>63.89</valueinc></line><line id="2"><article>0</article><vatcode name="BTW 21%" shortname="BTW 21%">VH21</vatcode><quantity>5</quantity><description>Overleg Client</description><unitspriceexcl>1.00</unitspriceexcl><freetext1 name="Omzet Elabo" shortname="" dimensiontype="PNL">8150</freetext1><freetext2 name="Martijn Brinkman" shortname="" dimensiontype="KPL">5081</freetext2><freetext3 name="Test Ok" shortname="100049" dimensiontype="PRJ">DN-0000252</freetext3><performancetype></performancetype><subarticle></subarticle><units>1</units><allowdiscountorpremium>true</allowdiscountorpremium><performancedate /><dim1 name="Omzet Elabo" shortname="">8150</dim1><dim2 name="Martijn Brinkman" shortname="">5081</dim2><dim3 name="Test Ok" shortname="100049">DN-0000252</dim3><valueexcl>5.00</valueexcl><vatvalue>1.05</vatvalue><valueinc>6.05</valueinc></line></lines><totals><valueexcl>57.80</valueexcl><valueinc>69.94</valueinc></totals><vatlines><vatline><vatcode name="BTW 21%" shortname="BTW 21%" percentage="21.000000000">VH21</vatcode><vatvalue>12.14</vatvalue><performancetype></performancetype><performancedate></performancedate></vatline></vatlines></salesinvoice>');
        TwinfieldXmlErrorMessage m = new TwinfieldXmlErrorMessage();
        m.getFormattedError();
        Twinfield_ParsedXmlResult c = new Twinfield_ParsedXmlResult();
        c.addError(m);
        SendInvoice.coverageToDelete();
        TF_Session.logon('','','');
        TF_Session.session_ID = '';
        TF_Session.abandon();
    }
}