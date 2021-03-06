//Generated by wsdl2apex

public class TF_ProcessXML {
  public class ProcessXmlStringResponse_element {
    public String ProcessXmlStringResult;
    private String[] ProcessXmlStringResult_type_info = new String[]{'ProcessXmlStringResult','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
    private String[] apex_schema_type_info = new String[]{'http://www.twinfield.com/','true','false'};
    private String[] field_order_type_info = new String[]{'ProcessXmlStringResult'};
  }
  public class Header {
    public String SessionID;
    private String[] SessionID_type_info = new String[]{'SessionID','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
    private String[] apex_schema_type_info = new String[]{'http://www.twinfield.com/','true','false'};
    private String[] field_order_type_info = new String[]{'SessionID'};
  }
  public class ProcessXmlDocument_element {
    public TF_ProcessXML.xmlRequest_element xmlRequest;
    private String[] xmlRequest_type_info = new String[]{'xmlRequest','http://www.twinfield.com/','xmlRequest_element','0','1','false'};
    private String[] apex_schema_type_info = new String[]{'http://www.twinfield.com/','true','false'};
    private String[] field_order_type_info = new String[]{'xmlRequest'};
  }
  public class ProcessXmlCompressed_element {
    public String xmlRequest;
    private String[] xmlRequest_type_info = new String[]{'xmlRequest','http://www.w3.org/2001/XMLSchema','base64Binary','0','1','false'};
    private String[] apex_schema_type_info = new String[]{'http://www.twinfield.com/','true','false'};
    private String[] field_order_type_info = new String[]{'xmlRequest'};
  }
  public class xmlRequest_element {
    private String[] apex_schema_type_info = new String[]{'http://www.twinfield.com/','true','false'};
    private String[] field_order_type_info = new String[]{};
  }
  public class ProcessXmlString_element {
    public String xmlRequest;
    private String[] xmlRequest_type_info = new String[]{'xmlRequest','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
    private String[] apex_schema_type_info = new String[]{'http://www.twinfield.com/','true','false'};
    private String[] field_order_type_info = new String[]{'xmlRequest'};
  }
  /*public class ProcessXmlDocumentResult_element {
    private String[] apex_schema_type_info = new String[]{'http://www.twinfield.com/','true','false'};
    private String[] field_order_type_info = new String[]{};
  }
  public class ProcessXmlDocumentResponse_element {
    public TF_ProcessXML.ProcessXmlDocumentResult_element ProcessXmlDocumentResult;
    private String[] ProcessXmlDocumentResult_type_info = new String[]{'ProcessXmlDocumentResult','http://www.twinfield.com/','ProcessXmlDocumentResult_element','0','1','false'};
    private String[] apex_schema_type_info = new String[]{'http://www.twinfield.com/','true','false'};
    private String[] field_order_type_info = new String[]{'ProcessXmlDocumentResult'};
  }*/
  public class ProcessXmlCompressedResponse_element {
    public String ProcessXmlCompressedResult;
    private String[] ProcessXmlCompressedResult_type_info = new String[]{'ProcessXmlCompressedResult','http://www.w3.org/2001/XMLSchema','base64Binary','0','1','false'};
    private String[] apex_schema_type_info = new String[]{'http://www.twinfield.com/','true','false'};
    private String[] field_order_type_info = new String[]{'ProcessXmlCompressedResult'};
  }
  public class ProcessXmlSoap {
    public String endpoint_x;
    public Map<String,String> inputHttpHeaders_x;
    public Map<String,String> outputHttpHeaders_x;
    public String clientCertName_x;
    public String clientCert_x;
    public String clientCertPasswd_x;
    public Integer timeout_x;
    public TF_ProcessXML.Header Header;
    private String Header_hns = 'Header=http://www.twinfield.com/';
    private String[] ns_map_type_info = new String[]{'http://www.twinfield.com/', 'TF_ProcessXML'};
    
    public ProcessXmlSoap(String cluster, string sessionId) {
      endpoint_x = cluster+'/webservices/processxml.asmx';
      Header = new TF_ProcessXML.Header();
      Header.SessionID = sessionId;
    }
    
    public String ProcessXmlString(String xmlRequest) {
      TF_ProcessXML.ProcessXmlString_element request_x = new TF_ProcessXML.ProcessXmlString_element();
      TF_ProcessXML.ProcessXmlStringResponse_element response_x;
      request_x.xmlRequest = xmlRequest;
      Map<String, TF_ProcessXML.ProcessXmlStringResponse_element> response_map_x = new Map<String, TF_ProcessXML.ProcessXmlStringResponse_element>();
      response_map_x.put('response_x', response_x);
        if (!Test.isRunningTest()){
      WebServiceCallout.invoke(
        this,
        request_x,
        response_map_x,
        new String[]{endpoint_x,
        'http://www.twinfield.com/ProcessXmlString',
        'http://www.twinfield.com/',
        'ProcessXmlString',
        'http://www.twinfield.com/',
        'ProcessXmlStringResponse',
        'TF_ProcessXML.ProcessXmlStringResponse_element'}
      );
      response_x = response_map_x.get('response_x');
      return response_x.ProcessXmlStringResult;
        } else {
            return null;
        }
    }
   /* public TF_ProcessXML.ProcessXmlDocumentResult_element ProcessXmlDocument(TF_ProcessXML.xmlRequest_element xmlRequest) {
      TF_ProcessXML.ProcessXmlDocument_element request_x = new TF_ProcessXML.ProcessXmlDocument_element();
      TF_ProcessXML.ProcessXmlDocumentResponse_element response_x;
      request_x.xmlRequest = xmlRequest;
      Map<String, TF_ProcessXML.ProcessXmlDocumentResponse_element> response_map_x = new Map<String, TF_ProcessXML.ProcessXmlDocumentResponse_element>();
      response_map_x.put('response_x', response_x);
      WebServiceCallout.invoke(
        this,
        request_x,
        response_map_x,
        new String[]{endpoint_x,
        'http://www.twinfield.com/ProcessXmlDocument',
        'http://www.twinfield.com/',
        'ProcessXmlDocument',
        'http://www.twinfield.com/',
        'ProcessXmlDocumentResponse',
        'TF_ProcessXML.ProcessXmlDocumentResponse_element'}
      );
      response_x = response_map_x.get('response_x');
      return response_x.ProcessXmlDocumentResult;
    }*/
    public String ProcessXmlCompressed(String xmlRequest) {
      TF_ProcessXML.ProcessXmlCompressed_element request_x = new TF_ProcessXML.ProcessXmlCompressed_element();
      TF_ProcessXML.ProcessXmlCompressedResponse_element response_x;
      request_x.xmlRequest = xmlRequest;
      Map<String, TF_ProcessXML.ProcessXmlCompressedResponse_element> response_map_x = new Map<String, TF_ProcessXML.ProcessXmlCompressedResponse_element>();
      response_map_x.put('response_x', response_x);
        if (!Test.isRunningTest()){
      WebServiceCallout.invoke(
        this,
        request_x,
        response_map_x,
        new String[]{endpoint_x,
        'http://www.twinfield.com/ProcessXmlCompressed',
        'http://www.twinfield.com/',
        'ProcessXmlCompressed',
        'http://www.twinfield.com/',
        'ProcessXmlCompressedResponse',
        'TF_ProcessXML.ProcessXmlCompressedResponse_element'}
      );
      response_x = response_map_x.get('response_x');
      return response_x.ProcessXmlCompressedResult;
        } else {
            return null;
        }
    }
  }
}