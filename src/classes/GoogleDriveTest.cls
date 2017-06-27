/**	Author       :    Marcus Yavorskyy
*   Email        :    marcus.yavorskyy@beethree.net
*   Description  :    Class for GoogleDrive.cls Testing.
*   Created Date :    27.02.2017
**/


@isTest
private class GoogleDriveTest {
    @testSetup static void setupForTest() {
        TestData.init_custom_settings();
        googleDriveParents__c parentsIds = new googleDriveParents__c(Name = 'Dossier Mappen', ParentId__c = '9864964986496');

        insert parentsIds;

        Date mydate = System.today()+1;
        Account acc = new Account(Factuur_E_mail__c = 'test@test.com',Name = 'TestAccount', Betalingsconditie__c = 14);
        insert acc;
        Contact contactpers = new Contact(AccountId = acc.Id, Lastname = 'Yo', FirstName= 'No');
        insert contactpers;

        Product__c prod = new Product__c(Name = 'testprod', Vaste_prijs__c = 80);
        insert prod;
    }

    // Test the HttpRequest Folder insert when Dossier created.
    @isTest static void googleDriveFolderTest() {

        List<StaticResource> response = [select id, name, body from StaticResource 
                    WHERE name = 'GoogleDriveTestFolderResponse' LIMIT 1]; 
        String responseBody = response[0].body.toString();
        Date mydate = System.today()+1;

        Product__c prod = [SELECT Id From Product__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact contactpers = [SELECT Id FROM Contact LIMIT 1];
        Dossier__c dossier = new Dossier__c(Product__c = prod.Id ,OwnerId = UserInfo.getUserId() , 
                                            Relatie__c = acc.Id, Product_exception__c = 'Geen uitzondering', 
                                            Contactpersoon_opdrachtgever__c = contactpers.Id, Verwijzer__c = acc.Id,
                                            handler__c = UserInfo.getUserId() , Datum_Binnenkomst__c= mydate, Ingangsdatum__c = mydate+1, Einddatum__c = mydate); 
        

      //  Map<String, String> responseHeaders = new Map<String, String>();
      //  responseHeaders.put('Content-type', 'application/json');
		    //System.debug(' ---- responseHeaders : ' + responseHeaders);


      //  Map<String, HttpCalloutMock> endpoint2TestResp =  new Map<String,HttpCalloutMock>();

        //Map<String, String> params = new Map<String, String>();
        //params.put('q', '(mimeType = \'application/vnd.google-apps.folder\') and title = \'DN-888888\' and \'464644686468\' in parents and trashed = false');
        //params.put('max_results', '1');
        //params.put('fields', 'items(id)');
        //String queryString = '?';
        //for (String name : params.keySet()) {
        //   if (queryString.length() > 1) {
        //       queryString += '&';
        //     }
        //    String value = params.get(name);
        //    queryString += EncodingUtil.urlEncode(name, 'UTF-8') + '=' + EncodingUtil.urlEncode(value, 'UTF-8');
        //}

        //GoogleHttpCalloutMockTest fakeSessionResp = new GoogleHttpCalloutMockTest(200,
        //                                          'Complete',
        //                                           responseBody,
        //                                           responseHeaders);
        //GoogleHttpCalloutMockTest fakeFindFolder = new GoogleHttpCalloutMockTest(200,
        //                                          'Complete',
        //                                           responseBody,
        //                                           null);
        //System.Debug('fakeSessionResp: '+fakeSessionResp);
        //endpoint2TestResp.put('1', fakeFindFolder);

        //endpoint2TestResp.put('callout:GoogleDriveFiles', fakeSessionResp);
        //HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp); 
        //Test.setMock(HttpCalloutMock.class, multiCalloutMock); 
        Test.startTest();
        

		//System.debug(' ---- responseHeaders : ' + responseHeaders);
        insert dossier;
        Test.stopTest();
        Dossier__c dossierToTest = [SELECT ID, Google_Drive_Folder__c FROM Dossier__c WHERE Id =: dossier.Id]; 

        System.assertEquals('https://alternate', dossierToTest.Google_Drive_Folder__c);


    }

    // Test Bad HttpRequest Folder insert when Dossier created.
    @isTest static void googleDriveBADFolderTest() {

        List<StaticResource> response = [select id, name, body from StaticResource 
                    WHERE name = 'GoogleDriveTestFolderResponse' LIMIT 1]; 
        String responseBody = response[0].body.toString();
        Date mydate = System.today()+1;

        Product__c prod = [SELECT Id From Product__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact contactpers = [SELECT Id FROM Contact LIMIT 1];
        Dossier__c dossier = new Dossier__c(Product__c = prod.Id ,OwnerId = UserInfo.getUserId() , 
                                            Relatie__c = acc.Id, Product_exception__c = 'Geen uitzondering', 
                                            Contactpersoon_opdrachtgever__c = contactpers.Id, Verwijzer__c = acc.Id,
                                            handler__c = UserInfo.getUserId() , Datum_Binnenkomst__c= mydate, Ingangsdatum__c = mydate+1, Einddatum__c = mydate); 


        //Map<String, String> responseHeaders = new Map<String, String>();
        //responseHeaders.put('Content-type', 'application/json');
        //    System.debug(' ---- responseHeaders : ' + responseHeaders);


        //Map<String, HttpCalloutMock> endpoint2TestResp =  new Map<String,HttpCalloutMock>();

        //Map<String, String> params = new Map<String, String>();
        //params.put('q', '(mimeType = \'application/vnd.google-apps.folder\') and title = \'DN-888888\' and \'464644686468\' in parents and trashed = false');
        //params.put('max_results', '1');
        //params.put('fields', 'items(id)');
        //String queryString = '?';
        //for (String name : params.keySet()) {
        //   if (queryString.length() > 1) {
        //       queryString += '&';
        //     }
        //    String value = params.get(name);
        //    queryString += EncodingUtil.urlEncode(name, 'UTF-8') + '=' + EncodingUtil.urlEncode(value, 'UTF-8');
        //}

        //GoogleHttpCalloutMockTest fakeSessionResp = new GoogleHttpCalloutMockTest(200,
        //                                          'Complete',
        //                                           responseBody,
        //                                           responseHeaders);
        //GoogleHttpCalloutMockTest fakeFindFolder = new GoogleHttpCalloutMockTest(200,
        //                                          'Complete',
        //                                           responseBody,
        //                                           null);
        //System.Debug('fakeSessionResp: '+fakeSessionResp);
        //endpoint2TestResp.put('1', fakeFindFolder);

        //endpoint2TestResp.put('callout:GoogleDriveFiles', fakeSessionResp);
        //HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp); 

        Test.startTest();
        insert dossier;

        
        //Test.setMock(HttpCalloutMock.class, multiCalloutMock);         

        Test.stopTest();

    }
    public class MultiRequestMock implements HttpCalloutMock {
    Map<String, HttpCalloutMock> requests;

        public MultiRequestMock(Map<String, HttpCalloutMock> requests) {
            this.requests = requests;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpCalloutMock mock = requests.get(req.getEndpoint());
            if (mock != null) {
                return mock.respond(req);
            }else{
                return null;
            }
        }

        public void addRequestMock(String url, HttpCalloutMock mock) {
            requests.put(url, mock);
        }
    }
}