public without sharing class GeolocationCallout {
    public GeolocationCallout() {
        
    }
    public static List<Decimal> getLocation (String address) {

        List <Decimal> coordinates = new List <Decimal>();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address='+address+
            '&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU');
        req.setMethod('GET');
        req.setTimeout(60000);
        System.debug('https://maps.googleapis.com/maps/api/geocode/json?address='+address+'&key=AIzaSyCgdJ5_32jiWfmXrgGeT2T5vcg7sGvn42c');
        // callout
        
        String body;
        if (Test.isRunningTest()) {
            body =([select Body from StaticResource where Name = 'GoogleLongLat'].Body).toString();
        } else {
            HttpResponse res = h.send(req);
            body = res.getBody();
        }
        // parse coordinates from response
        JSONParser parser = JSON.createParser(body);
        System.debug(parser);
        double lat = null;
        double lon = null;
        System.debug(parser.nextToken());
        while (parser.nextToken() != null) {
            System.debug(JSONToken.FIELD_NAME + ' == ' + parser.getCurrentToken() + ' ' + parser.getText());
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                (parser.getText() == 'location')){
                   parser.nextToken(); // object start
                   System.debug(parser.getText());
                    while (parser.nextToken() != JSONToken.END_OBJECT){
                       String txt = parser.getText();
                      
                       parser.nextToken();
                       System.debug(txt);
                       if (txt == 'lat')
                           lat = parser.getDoubleValue();
                       else if (txt == 'lng')
                           lon = parser.getDoubleValue();
                    }

            }
        }
      
        coordinates.add(lat);
        coordinates.add(lon);
        System.debug('long ' + lon + ' lat ' + lat);
        return coordinates;
    }
    public static Decimal getDistance (String address, String userAddress) {
        address = address.replace(' ','+' );
        address = address.replace('\n','' );
        userAddress = userAddress.replace(' ','+' );
        userAddress = userAddress.replace('\n','' );
        System.debug('address'+address);
        System.debug('userAddress'+userAddress);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins='+address
                                +'&destinations='+userAddress+'&key=AIzaSyAka8I8NHOgBmeqzFE1dIg1I-dBktW10DU');
        req.setMethod('GET');
        req.setTimeout(60000);
        System.debug('===== req endpoint' + req.getEndpoint());
        HttpResponse res = h.send(req);
        System.debug('===== res body' + res.getBody());
        // parse coordinates from response
        JSONParser parser = JSON.createParser(res.getBody());
        System.debug(parser);
        double distance = 0;
        System.debug(parser.nextToken());
        while (parser.nextToken() != null) {
            System.debug(JSONToken.FIELD_NAME + ' == ' + parser.getCurrentToken() + ' ' + parser.getText());
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                (parser.getText() == 'distance')){
                   parser.nextToken(); // object start
                   System.debug(parser.getText());
                    while (parser.nextToken() != JSONToken.END_OBJECT){
                       String txt = parser.getText();
                      
                       parser.nextToken();
                       System.debug(txt);
                       if (txt == 'text'){
                            if (parser!=null) {
                                String text = parser.getText();
                                if (text != null && text.contains('km') ) {
                                     distance = Decimal.valueOf(text.substring(0, text.length()-3));
                                }
                                if (text != null && !text.contains('km') ) {
                                    System.debug('text' + text + ' ' + text.substring(0, text.length()-2));
                                    distance = Decimal.valueOf(text.substring(0, text.length()-2))/1000;
                                }
                            }                          
                       }
                       
                    }

            }
        }
      
        
        System.debug('distance ' + distance);
        return distance;
    }
}