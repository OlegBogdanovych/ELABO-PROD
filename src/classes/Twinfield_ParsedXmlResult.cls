public class Twinfield_ParsedXmlResult {
  public boolean hasErrors;
  public String identifier;
  public List<TwinfieldXmlErrorMessage> errors;
  
  public void addError(TwinfieldXmlErrorMessage error) {
    errors = errors==null?new List<TwinfieldXmlErrorMessage>():errors;
    errors.add(error);
    hasErrors = true;
  }
}