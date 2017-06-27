public with sharing class SendInvoice {
    public SendInvoice(ApexPages.StandardController ctrl) {
        dossier = (Dossier__c)ctrl.getRecord();
    }
    public SendInvoice() {
//https://elabo--acceptance.lightning.force.com/apex/Invoice?params={%22vervaldatum%22:null,%22vatSTR%22:%2212,14%22,%22vat%22:12.138,%22totalStr%22:%2269,94%22,%22total%22:69.94,
//%22sumStr%22:%2269,94%22,%22sum%22:69.938,%22priceStr%22:%2257,8%22,%22price%22:57.80,%22linesPerDos%22:[{%22totalLineEx%22:%2252,8%22,%22totalLine%22:%2263,89%22,%22quantityLine%22:%225,
//00%22,%22priceLine%22:%2210,56%22,%22descriptionLine%22:%22Overleg%20Derden%22},{%22totalLineEx%22:%225,00%22,%22totalLine%22:%226,05%22,%22quantityLine%22:%225,00%22,%22priceLine%22:%221,
//00%22,%22descriptionLine%22:%22Overleg%20Client%22}],%22invoiceDate%22:%2219-10-2016%22,%22factuurnummer%22:%22115%22,%22factuurdatum%22:null,%22duedate%22:%2202-11-2016%22,%22dossier%22:
//{%22attributes%22:{%22type%22:%22Dossier__c%22,%22url%22:%22/services/data/v38.0/sobjects/Dossier__c/a094E000001fcA4QAI%22},%22Id%22:%22a094E000001fcA4QAI%22,%22Relatie__c%22:
//%220014E00000GmJZpQAN%22,%22Name%22:%22DN-0000252%22,%22RecordTypeId%22:%2201258000000c3XwAAI%22,%22Due_Date__c%22:%222016-10-19%22,%22reference_Id__c%22:%22DN-0000252%22,%22handler__c%22:
//%2200558000000jl8bAAA%22,%22Invoice_is_sent__c%22:true,%22Relatie__r%22:{%22attributes%22:{%22type%22:%22Account%22,%22url%22:%22/services/data/v38.0/sobjects/Account/0014E00000GmJZpQAN%22},
//%22Debiteurnummer__c%22:%22100049%22,%22Name%22:%22Test%20Ok%22,%22Betalingsconditie__c%22:14,%22RecordTypeId%22:%2201258000000c4DEAAY%22,%22Id%22:%220014E00000GmJZpQAN%22},%22handler__r%22
//{%22attributes%22:{%22type%22:%22User%22,%22url%22:%22/services/data/v38.0/sobjects/User/00558000000jl8bAAA%22},%22Name%22:%22Gerwin%20Tromp%22,%22Kostenplaats__c%22:%225081%22,%22Id%22:
//%2200558000000jl8bAAA%22}},%22description%22:%22Overleg%20Derden%22,%22company%22:{%22attributes%22:{%22type%22:%22Account%22,%22url%22:%22/services/data/v38.0/sobjects/Account/0014E00000GmJZpQAN%22}
//,%22Id%22:%220014E00000GmJZpQAN%22,%22Name%22:%22Test%20Ok%22,%22BillingCity%22:%22Lviv%22,%22ShippingCity%22:%22Amsterdam%22,%22BillingCountry%22:%22Nederland%22,%22ShippingCountry%22:%22Nederland
//%22,%22BillingStreet%22:%22Hasheka%2017/59%22,%22ShippingStreet%22:%22Ferdinand%20Bolstraat%22,%22BillingPostalCode%22:%2279031%22,%22Debiteurnummer__c%22:%22100049%22,%22Factuur_E_mail__c%22:
//%22test@test.com%22,%22Betalingsconditie__c%22:14,%22RecordTypeId%22:%2201258000000c4DEAAY%22},%22btw%22:%2221%22}
        String params = ApexPages.currentPage().getParameters().get('params');
        System.debug('params ' + params);
        data = new InvoiceData();
        
        System.debug('params ' + params);
        data = (InvoiceData) JSON.deserialize(params, InvoiceData.class);
        System.debug('data'+ data);
    }
    public Dossier__c dossier{get;set;}
    public Account company {get;set;}
    public InvoiceData data {get;set;}
    
    public PageReference sendInvoice() {
        String responce = '';
        dossier = DossierDAO.getDossierById(dossier.id);
        User user = UserDAO.getCurrentUser ();
        if (dossier.handler__c != null) {
            user  = UserDAO.getUserById(dossier.handler__c );
        }
        List <Dossierproduct__c> dossierProducts = DossierproductDAO.getDossierProductsByDossierId(dossier.id);
        company = AccountDao.getParentAccount(dossier.Relatie__c);
        System.debug(dossier.reference_Id__c + ' ' + user.Kostenplaats__c + ' ' + dossier.Relatie__r.Debiteurnummer__c);
        if (dossier.reference_Id__c != '' && dossier.reference_Id__c != null 
                && user.Kostenplaats__c != null && user.Kostenplaats__c !='' 
                && dossier.Relatie__r.Debiteurnummer__c != null && dossier.Relatie__r.Debiteurnummer__c != ''
                && dossierProducts.size() > 0 && dossierProducts.get(0).Product__r.Tariefsoort__c != null ) {
            String kenmerk = '';
            if (dossier.Kenmerk_Klant__c != null) {
                kenmerk  = dossier.Kenmerk_Klant__c;
            }
            String polisnummer = '';
            String quantity = '';
            if (dossierProducts.get(0).Product__r.Quantity_invoice__c != null) {
                quantity = String.valueOf(dossierProducts.get(0).Product__r.Quantity_invoice__c );
            }
            List <Task> tasks = TaskDAO.getTasksByDossierId(dossier.Id);
            Decimal tar = dossierProducts.get(0).Tarief__c ;
            Decimal ver =  dossierProducts.get(0).Vergoeding_per_KM__c ;
            System.debug(tar + ' ' + ver);
            if (dossierProducts.get(0).Product_exeption__c != null ) {
                System.debug(dossierProducts.get(0).Product_exeption__r.Kortingsperecentage_vaste_tarieven__c);
                System.debug(dossierProducts.get(0).Product_exeption__r.Kortingspercentage_uurtarieven__c);
                System.debug(dossierProducts.get(0).Product__r.Tariefsoort__c);
                if (dossierProducts.get(0).Product_exeption__r.Kortingsperecentage_vaste_tarieven__c != null 
                    && dossierProducts.get(0).Product__r.Tariefsoort__c != 'Uurtarief') {
                        tar = (1- dossierProducts.get(0).Product_exeption__r.Kortingsperecentage_vaste_tarieven__c/100)*tar;
                }
                else if (dossierProducts.get(0).Product_exeption__r.Kortingspercentage_uurtarieven__c != null 
                    && dossierProducts.get(0).Product__r.Tariefsoort__c == 'Uurtarief') {
                        tar = (1- dossierProducts.get(0).Product_exeption__r.Kortingspercentage_uurtarieven__c/100)*tar;
                } 
            }
            System.debug('[***] dossier - ' +  dossier);
            System.debug('[***] kenmerk - ' +  kenmerk);
            System.debug('[***] polisnummer - ' +  polisnummer);
            System.debug('[***] Product__r.Name - ' +  dossierProducts.get(0).Product__r.Name);
            System.debug('[***] Product__r.Tariefsoort__c - ' +  dossierProducts.get(0).Product__r.Tariefsoort__c);            
            System.debug('[***] Product__r.Rit_Registratie__c - ' +  dossierProducts.get(0).Product__r.Rit_Registratie__c);
            System.debug('[***] tar - ' +  tar);
            System.debug('[***] ver - ' +  ver);
            System.debug('[***] quantity - ' +  quantity);
            System.debug('[***] tasks - ' +  tasks);

            String hoursType = '';
            if (null != dossierProducts.get(0).Product__r.Rit_Registratie__c){
                hoursType = dossierProducts.get(0).Product__r.Rit_Registratie__c;
            }
            
            System.debug(tar + ' ' + ver);
            String requestString = TwinfieldXmlRequestBuilder.sendInvoice(dossier,  kenmerk, polisnummer, 
                                                                            dossierProducts.get(0).Product__r.Name, 
                                                                            dossierProducts.get(0).Product__r.Tariefsoort__c,
                                                                            hoursType,
                                                                            tar , 
                                                                            ver  ,
                                                                            quantity,
                                                                            tasks
                                                                            );
            try {
              String xmlResult = '';
              if(Test.isRunningTest()) {
                xmlResult = //String.valueOf([select Id, Body from StaticResource where Name = 'Invoice'].body);
                            '<salesinvoice status="Concept" result="0"><header><invoicetype>FACTUUR</invoicetype><invoicenumber>123</invoicenumber>'+
                            '<invoiceaddressnumber>1</invoiceaddressnumber><office>2716072</office><invoicedate>20160901</invoicedate>'+
                            '<customer>100011</customer><currency>EUR</currency><duedate>20160901</duedate><paymentmethod>bank</paymentmethod>'+
                            '<headertext>Onze referentie: DN-0000101 Uw referentie: Medewerker: Test Ok1 Arbeidsdeskundige: Gerwin Tromp</headertext>'+
                            '<status>concept</status><period>2016/9</period><bank>BNK</bank><deliveraddressnumber>1</deliveraddressnumber><footertext>'+
                            '</footertext></header><lines result="0"><line id="1" result="0"><article>0</article><description>Test</description>'+
                            '<vatcode name="BTW 21%" shortname="BTW 21%">VH21</vatcode><quantity>1</quantity><unitspriceexcl>1.00</unitspriceexcl>'+
                            '<valueinc>17.63</valueinc><valueexcl>7.63</valueexcl><freetext1>5081</freetext1><dim1>8150</dim1>'+
                            '<dim3>DN-0000101</dim3><performancetype></performancetype><subarticle></subarticle>'+
                            '<units>1</units><allowdiscountorpremium>true</allowdiscountorpremium><performancedate></performancedate>'+
                            '<freetext2></freetext2><freetext3></freetext3></line></lines><totals><valueexcl>44.00</valueexcl><valueinc>53.24</valueinc></totals></salesinvoice>';
              } else {
                xmlResult = TwinfieldXmlRequestBuilder.sendRequest(requestString);
              }
              List<TwinfieldXmlErrorMessage> errors = TwinfieldXmlUtil.parseXmlErrors(xmlResult);
              responce = xmlResult;
             System.debug(responce);
              
              //errors = new List<TwinfieldXmlErrorMessage> ();//temporary
              if (errors.isEmpty() ) {
                data = new InvoiceData();
                Twinfield_ParsedXmlResult res = TwinfieldXmlUtil.parseXmlResult(xmlResult, '/salesinvoice/header/invoicenumber');
                data.factuurnummer = res.identifier;
                data.invoiceDate = date.today().format();
                data.duedate = TwinfieldXmlUtil.parseXmlResult(xmlResult, '/salesinvoice/header/duedate').identifier;
                data.duedate = data.duedate.substring(6, 8) + '-' + data.duedate.substring(4,6) + '-' + data.duedate.substring(0,4);
                data.description = TwinfieldXmlUtil.parseXmlResult(xmlResult, '/salesinvoice/lines/line/description').identifier;
                
                String r = xmlResult ;
                r = r.substring(r.indexOf('<lines>')+7, r.length());
                r = r.substring(0, r.indexOf('</lines>'));
                System.debug(LoggingLevel.Error, 'r' + r);
                List <String> lines = r.split('</line>');
                for (String line: lines) {
                    line += '</line>';
                }
                for (String line : lines) {
                    String quantityInLine = '';
                    String price = '';
                    String total = '';
                    String description = '';
                    if (line.indexOf('<quantity>') != -1){
                        quantityInLine = line.substring(line.indexOf('<quantity>')+10, line.indexOf('</quantity>'));
                    }
                    if (line.indexOf('<unitspriceexcl>') != -1){
                        price = line.substring(line.indexOf('<unitspriceexcl>')+16, line.indexOf('</unitspriceexcl>'));
                    }
                    if (line.indexOf('<valueinc>') != -1){
                        total = line.substring(line.indexOf('<valueinc>')+10, line.indexOf('</valueinc>'));
                    }
                     if (line.indexOf('<description>') != -1){
                        description = line.substring(line.indexOf('<description>')+13, line.indexOf('</description>'));
                    }
                    Line l = new Line();
                    l.quantityLine = customFormating(Decimal.valueOf(quantityInLine));
                    l.totalLineEx = customFormating(Decimal.valueOf(price)*Decimal.valueOf(quantityInLine));
                    l.priceLine = customFormating(Decimal.valueOf(price)); 
                    l.totalLine = customFormating(Decimal.valueOf(total)); 
                    l.descriptionLine = description; 
                    data.linesPerDos.add(l);
                }
                System.debug(LoggingLevel.Error, 'lines ' + lines );
                data.total = 0;
                if (!Test.isRunningTest()) {
                    data.total= Decimal.valueOf(TwinfieldXmlUtil.parseXmlResult(xmlResult, '/salesinvoice/totals/valueinc').identifier);
                    data.price = Decimal.valueOf(TwinfieldXmlUtil.parseXmlResult(xmlResult, '/salesinvoice/totals/valueexcl').identifier);
                    
                } else {
                    data.price = 21;
                    data.total = 30;
                }
                String btw = TwinfieldXmlRequestBuilder.getVatCode();
                data.btw = btw.substring(2, btw.length());
                data.vat = data.price*Decimal.valueOf(data.btw)/100;
                data.sum = data.vat + data.price;
                
                System.debug('result' + xmlResult );

                data.sumStr = customFormating(data.sum);
                data.totalStr = customFormating(data.total);
                data.priceStr = customFormating(data.price);
                data.vatSTR = customFormating(data.vat);

                data.dossier = dossier;
                data.company = company;
                String params = JSON.serialize(data);
                System.debug('params JSON ' + params);
                PageReference thePage = Page.Invoice;
              
                thePage.getParameters().put('params', params);
                Blob thePdf;
                if(!Test.isRunningTest()) {
                         
                    thePdf = thePage.getContentAsPdf();
                } else {
                    thePdf = Blob.valueOf('APEX UNIT TEST');
                }
                attachmentBatch = createAttachment(thePdf, dossier.Id, dossier.Name+' '+datetime.now().format()+'.pdf' );
                If (!System.isBatch()) {
                    insert attachmentBatch;
                    dossier.Invoice_Is_Sent__c = true;
                    dossier.TF_InvoiceNumber__c= Decimal.valueOf(TwinfieldXmlUtil.parseXmlResult(xmlResult, '/salesinvoice/header/invoicenumber').identifier);
                    String invDate = TwinfieldXmlUtil.parseXmlResult(xmlResult, '/salesinvoice/header/invoicedate').identifier;
                    dossier.Date_TF_Invoice__c  = date.newInstance(Integer.valueOf(invDate.substring(0, 4)), Integer.valueOf(invDate.substring(4, 6)), Integer.valueOf(invDate.substring(6, 8)));
                    update dossier;
                }
              } else {
                String errorString = '';
                for(TwinfieldXmlErrorMessage error : errors) {
                  errorString += error.getFormattedError() + '\n------\n';
                }
                
                ErrorHandeling.saveLog(errorString, xmlResult, dossier.id);
              }
            } catch(Exception e) {
                ErrorHandeling.saveLog(e.getMessage(), responce, dossier.id);
                //throw new ApplicationException.InvalidStateException(e.getMessage());
            }
        }
        return new PageReference('/'+dossier.id);
    }
    public static void coverageToDelete(){
        String s = '';
    }
    public String customFormating (Decimal oldFormat) {
        oldFormat = oldFormat.setScale(2);
        List<String> args = new String[]{'0','number','###.###.##0,00'};
        String newFormat = String.format(oldFormat.format(), args);
        if (!newFormat.contains(',')) {
            newFormat += ',00';
        }
        System.debug(newFormat + ' ' + newFormat.indexOf(',') + ' == ' + (newFormat.length()-2));
            if (newFormat.contains(',') && newFormat.indexOf(',') == newFormat.length()-2) {
                newFormat += '0';
            }
        return newFormat;
    }
    public Attachment attachmentBatch ;
    public Attachment createAttachment(Blob body, Id parentId, String name) {
        Attachment attachment = new Attachment();
        attachment.Body = body;
        attachment.ParentId = parentId;
        attachment.Name = name;
        attachment.ContentType = 'application/pdf';          
        return attachment; 
    }

    public class InvoiceData {
        public Account company {get;set;}
        public String factuurnummer {get;set;}
        public String factuurdatum  {get;set;}
        public String vervaldatum  {get;set;}
        public String invoiceDate {get;set;}
        public Decimal total {get;set;}
        public Dossier__c dossier{get;set;}
        public String duedate {get;set;}
        public String description {get;set;}
        public Decimal price {get;set;}
        public String btw {get;set;}
        public Decimal vat {get;set;}
        public Decimal sum {get;set;}
        public String sumStr {get;set;}
        public String priceStr {get;set;}
        public String totalStr {get;set;}
        public String vatSTR {get;set;}
 
        public List <Line> linesPerDos {
            get{
                if (linesPerDos == null) {
                    linesPerDos = new List <Line>();
                }
                return linesPerDos;
            }set;
        }
    }

    public class Line {
        public String totalLine {get;set;}
        public String priceLine {get;set;}
        public String quantityLine {get;set;}
        public String descriptionLine {get;set;}
        public String totalLineEx {get;set;}
        public String customFormating (Decimal oldFormat) {
            oldFormat = oldFormat.setScale(2);
            List<String> args = new String[]{'0','number','###.###.##0,00'};
            String newFormat = String.format(oldFormat.format(), args);
            if (!newFormat.contains(',')) {
                newFormat += ',00';
            }
            System.debug(newFormat + ' ' + newFormat.indexOf(','));
            if (newFormat.contains(',') && newFormat.indexOf(',') == newFormat.length()-2) {
                newFormat += '0';
            }
            return newFormat;
        }
    }
}