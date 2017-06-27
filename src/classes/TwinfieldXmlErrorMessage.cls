public class TwinfieldXmlErrorMessage {
  public boolean result;
  public String msgType;
  public String message;
  
  public String getFormattedError() {
    String error = String.format('{0} {1} - {2}', new String[]{'Twinfield', msgType, message});
    return error;
  }
}