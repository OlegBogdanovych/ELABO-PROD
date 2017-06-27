public with sharing class triggerHelper {

public static boolean entryHasStartedBeforeIn=false;
public static boolean entryHasStartedBeforeUp=false;
public static boolean entryHasStartedAfterIn=false;
public static boolean entryHasStartedAfterUp=false;
public static boolean entryHasStartedTFDos=false;
public static boolean entryHasStartedTFAcc=false;
public static boolean entryHasStartedGeoLoc=false;


//A boolean that is set and then checked at the beginning of update triggers to be sure they only execute once
    public static  void  recursiveHelperBeforeIn (Boolean tempBool){
        entryHasStartedBeforeIn=tempBool;
    }
    public static  void  recursiveHelperBeforeUp (Boolean tempBool){
        entryHasStartedBeforeUp=tempBool;
    }
    public static  void  recursiveHelperAfterIn (Boolean tempBool){
        entryHasStartedAfterIn=tempBool;
    }
    public static  void  recursiveHelperAfterUp (Boolean tempBool){
        entryHasStartedAfterUp=tempBool;
    }
    public static  void  recursiveHelperTFDos (Boolean tempBool){
        entryHasStartedTFDos=tempBool;
    }
    public static  void  recursiveHelperTFAcc (Boolean tempBool){
        entryHasStartedTFAcc=tempBool;
    }
    public static  void  recursiveHelperGeoLoc (Boolean tempBool){
        entryHasStartedGeoLoc=tempBool;
    }
}