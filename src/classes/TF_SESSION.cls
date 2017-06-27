public class TF_SESSION {
  public static final String TF_AUTH_ENDPOINT = 'https://login.twinfield.com/webservices/session.asmx';
  public static final String TF_NS = 'http://www.twinfield.com/';
  public static final String SOAP_NS = 'http://schemas.xmlsoap.org/soap/envelope/';
  
  public static final String XML_ENCODING = 'UTF-8';
  public static final String XML_VERSION = '1.0';
  
  public static String session_Id = null;
  public static String cluster_Url = null;
  public static String logonResult = '';
  public static Boolean loggedOn = false;
  
  @TestVisible private TF_SESSION () {}
  
  public static void Logon(String user_x,String password,String organisation){
    Http http = new Http();
    HttpRequest httpRequest = new HttpRequest();
    
    String body = '<?xml version="'+XML_VERSION+'" encoding="'+XML_ENCODING+'"?>\r\n' +
            '<SOAP-ENV:Envelope xmlns:SOAP-ENV="'+SOAP_NS+'" xmlns:ns1="'+TF_NS+'">' + 
              '<SOAP-ENV:Body>' +
                '<ns1:Logon>' +
                  '<ns1:user>'+user_x+'</ns1:user>' +
                  '<ns1:password>'+password+'</ns1:password>' +
                  '<ns1:organisation>'+organisation+'</ns1:organisation>' +
                '</ns1:Logon>' +
              '</SOAP-ENV:Body>' +
            '</SOAP-ENV:Envelope>';
    
    httpRequest.setMethod('POST');
    httpRequest.setHeader('Content-Type', 'text/xml; charset=utf-8');
    httpRequest.setHeader('SOAPAction', 'http://www.twinfield.com/Logon');
    httpRequest.setHeader('Content-Length', String.valueOf(body.length()));
    httpRequest.setEndpoint(TF_AUTH_ENDPOINT);
    httpRequest.setBody(body);
      if(!Test.isRunningTest()){
        HttpResponse httpResponse = http.send(httpRequest);
        Dom.Document doc = httpResponse.getBodyDocument();
        Dom.XmlNode envelope = doc.getRootElement();
    
        logonResult = httpResponse.getStatus();
        loggedOn = envelope.getChildElement('Body', SOAP_NS).getChildElement('LogonResponse', TF_NS).getChildElement('LogonResult', TF_NS).getText()=='OK';
        
        if(loggedOn) {
          Dom.XmlNode head = envelope.getChildElement('Header', SOAP_NS);
          head = head.getChildElement('Header', TF_NS);
          Dom.XmlNode sessionIdNode = head.getChildElement('SessionID', TF_NS);
          
          
          session_Id = sessionIdNode.getText();
          cluster_Url = envelope.getChildElement('Body', SOAP_NS).getChildElement('LogonResponse', TF_NS).getChildElement('cluster', TF_NS).getText();
        }
      }
  }
  
  public static void abandon() {
    system.debug(Logginglevel.INFO, 'abandon()');
    
    Http http = new Http();
    HttpRequest httpReq = new HttpRequest();
    
    Xmlstreamwriter writer = new Xmlstreamwriter();
    writer.writeStartDocument(XML_ENCODING, XML_VERSION);
      writer.writeStartElement('soap', 'Envelope', SOAP_NS);
      writer.writeNamespace('soap', SOAP_NS);
      writer.writeNamespace('ns1', TF_NS);
        writer.writeStartElement('soap', 'Header', '');
          writer.writeStartElement('ns1', 'Header', '');
            writer.writeStartElement('ns1', 'SessionId', '');
              writer.writeCharacters(session_Id);
            writer.writeEndElement();//end  ns1SessionId
          writer.writeEndElement();//end ns1 Header
        writer.writeEndElement();
        writer.writeStartElement('soap', 'Body', '');
          writer.writeStartElement('ns1', 'Abandon', '');
          writer.writeEndElement();//end Abandon
        writer.writeEndElement();//end soap Body
      writer.writeEndElement();//end soap
    writer.writeEndDocument();
    
    String body = writer.getXmlString();
    system.debug(Logginglevel.INFO, 'bodylength:' + body);

    
    httpReq.setMethod('POST');
    httpReq.setHeader('Content-Type', 'text/xml; charset=utf-8');
    httpReq.setHeader('SOAPAction', TF_NS+'Abandon');
    httpReq.setHeader('Content-Length', String.valueOf(body.length()));
    httpReq.setEndpoint(cluster_Url + '/webservices/session.asmx');
    httpReq.setBody(body);
      if (!Test.isRunningTest()) {
        HttpResponse httpRes = http.send(httpReq);
        system.debug(system.Logginglevel.INFO, 'Abandon() response: ' + httpRes.getBody());
      }
    loggedOn = false;
        cluster_Url = null;
        session_Id = null;
    
  }
}