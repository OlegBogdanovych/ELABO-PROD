@isTest
public class GoogleHttpCalloutMockTest implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public GoogleHttpCalloutMockTest(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }

    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }



    public static void runMockUp(){
        /*
        List<StaticResource> response = [select id, name, body from StaticResource 
                                         WHERE name = 'GoogleDriveTestFolderResponseFail' LIMIT 1]; 
        String responseBody = response[0].body.toString();
        Map<String, String> responseHeaders = new Map<String, String>();
        responseHeaders.put('Content-type', 'application/json');
            System.debug(' ---- responseHeaders : ' + responseHeaders);


        Map<String, HttpCalloutMock> endpoint2TestResp =  new Map<String,HttpCalloutMock>();

        GoogleHttpCalloutMockTest fakeSessionResp = new GoogleHttpCalloutMockTest(200,
                                                  'Complete',
                                                   responseBody,
                                                   responseHeaders);
        GoogleHttpCalloutMockTest fakeFindFolder = new GoogleHttpCalloutMockTest(200,
                                                  'Complete',
                                                   responseBody,
                                                   null);
        System.Debug('fakeSessionResp: '+fakeSessionResp);
        endpoint2TestResp.put('callout:GoogleDriveFiles', fakeFindFolder);

        endpoint2TestResp.put('callout:GoogleDriveFiles', fakeSessionResp);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp); 
        Test.setMock(HttpCalloutMock.class, multiCalloutMock); 
        */
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