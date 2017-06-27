public class TwinfieldXmlUtil {
  public static Map<String, Twinfield_ParsedXmlResult> parseTransactionXmlResults(String xmlResult) {
    Map<String, Twinfield_ParsedXmlResult> resultMap = new Map<String, Twinfield_ParsedXmlResult>();
    //Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, xmlResult));
    try{
      Xmlstreamreader reader = new Xmlstreamreader(xmlResult);
      
      while(reader.hasNext()){
        if(reader.isStartElement() && reader.getLocalName()=='transaction'){
          String resultIdentifier = reader.getAttributeValue(null, 'id');
          
          Twinfield_ParsedXmlResult result = new Twinfield_ParsedXmlResult();
          result.hasErrors = false;
          TwinfieldXmlUtil.parseXmlErrors(reader, result);
          
          resultMap.put(resultIdentifier, result);
        }
        reader.next();
      }
    } catch(Exception e) {
      System.debug('ERROR TF:' + e.getMessage());
    }
    return resultMap;
  }
  
  public static Twinfield_ParsedXmlResult parseXmlResult(String xmlResult, String identifierPath) {
    Twinfield_ParsedXmlResult result = new Twinfield_ParsedXmlResult();
    result.hasErrors = false;
    try{
      XMLDom xmlDom = new XMLDom(xmlResult);
              
      List<XMLDom.Element> identifiers = xmlDom.ownerDocument().getElementsByPath(identifierPath);
      if(identifiers != null && identifiers.size()>0) {
        result.identifier = identifiers.get(0).textContent();
      }
              
      //parse the returned xml message for errors
      List<TwinfieldXmlErrorMessage> errors = TwinfieldXmlUtil.parseXmlErrors(xmlResult);
      //if the list of returned errors isn't empty, add each error to the page and set the hasError boolean true
      if(!errors.isEmpty()){
        for(TwinfieldXmlErrorMessage error : errors) {
          if(error.message != null || error.msgType != null) {
            System.debug('ERROR TF:'+ error.getFormattedError());
          }
        }
        result.hasErrors = true;
      }
    } catch(Exception e) {
      result.hasErrors = true;
      System.debug('ERROR TF:' +e.getMessage());
    }
    return result;
  }
  
  public static void parseXmlErrors(Xmlstreamreader xmlReader, Twinfield_ParsedXmlResult result) {
    List<TwinfieldXmlErrorMessage> errors = new List<TwinfieldXmlErrorMessage>();
    String entryElement = xmlReader.getLocalName();
    
    Boolean inHeader = false;
    
    while(xmlReader.hasNext()){
      if(xmlReader.getEventType() == XmlTag.START_ELEMENT) {
        if(xmlReader.getLocalName().toLowerCase()=='header') {
          inHeader = true;
        }
        
        TwinfieldXmlErrorMessage errMsg = new TwinfieldXmlErrorMessage();
        for(integer i=0;i<xmlReader.getAttributeCount();i++){
          if(xmlReader.getAttributeLocalName(i) == 'result') {
            errMsg.result = xmlReader.getAttributeValueAt(i)=='1';
          }
          else if(xmlReader.getAttributeLocalName(i) == 'msgtype') {
            errMsg.msgType = xmlReader.getAttributeValueAt(i);
          }
          else if(xmlReader.getAttributeLocalName(i) == 'msg') {
            errMsg.message = xmlReader.getAttributeValueAt(i);
          }
        }
        if(errMsg.result != null && errMsg.result != true && (errMsg.msgType!=null||errMsg.message!=null)) {
          result.addError(errMsg);
        }
        
        if(inHeader && xmlReader.getLocalName().toLowerCase()=='number') {
          xmlReader.next();
          result.identifier = xmlReader.getText();
        }
      }
      xmlReader.next();
      if(xmlReader.isEndElement()) {
        if(xmlReader.getLocalName() == 'header') {
          inHeader = false;
        }
        if(xmlReader.getLocalName() == entryElement) {
          break;
        }
      }
    }
  }
  
  public static List<TwinfieldXmlErrorMessage> parseXmlErrors(String xmlResult) {
    List<TwinfieldXmlErrorMessage> errors = new List<TwinfieldXmlErrorMessage>();
    
    Xmlstreamreader xmlReader = new Xmlstreamreader(xmlResult);
    while(xmlReader.hasNext()){
      if(xmlReader.getEventType() == XmlTag.START_ELEMENT) {
        TwinfieldXmlErrorMessage errMsg = new TwinfieldXmlErrorMessage();
        for(integer i=0;i<xmlReader.getAttributeCount();i++){
          if(xmlReader.getAttributeLocalName(i) == 'result') {
            errMsg.result = xmlReader.getAttributeValueAt(i)=='1'?true:false;
          }
          if(xmlReader.getAttributeLocalName(i) == 'msgtype') {
            errMsg.msgType = xmlReader.getAttributeValueAt(i);
          }
          if(xmlReader.getAttributeLocalName(i) == 'msg') {
            errMsg.message = xmlReader.getAttributeValueAt(i);
          }
        }
        if(errMsg.result != null && errMsg.result != true && (errMsg.msgType!=null||errMsg.message!=null)) {
          errors.add(errMsg);
        }
      }
      xmlReader.next();
    }
    return errors;
  }

  public static TwinfieldXmlErrorMessage hasError(XMLDom.Element element) {
    String result = element.getAttribute('result');
    TwinfieldXmlErrorMessage message = new TwinfieldXmlErrorMessage();
    
    if (result == null || result == '1') {
      // Everything is right
      message.result = true;
      return message;
    } else {
      // result == '0'
      // something is wrong
      String msgType = element.getAttribute('msgtype');
      String msg = element.getAttribute('msg');
      
      message.result = false;
      message.msgType = msgType;
      message.message = msg;
      
      return message;
    }
  }
  
  public static Boolean displayErrors(List<TwinfieldXmlErrorMessage> errors) {
    if(errors != null && !errors.isEmpty()){
      for(TwinfieldXmlErrorMessage error : errors) {
        System.debug('ERROR TF:' +error.getFormattedError());
      }
      return true;
    }
    return false;
  }
}