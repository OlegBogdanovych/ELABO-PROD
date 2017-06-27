global with sharing class UserList implements Comparable{
        public User user {get;set;}
        public Boolean isSelected {get;set;}
        public Boolean show {get;set;}
        public Decimal closest {get;set;}
        public Decimal loadDos {get;set;}
        public String mogelick {get;set;}
        public String voorkeur {get;set;}
       
        public UserList (User user, Boolean isSelected, Boolean show, Decimal closest) {
            this.user = user;
            this.isSelected = isSelected;
            this.show = show;
            this.closest = closest;
            if (user.Productgroep__c != null) {
                this.user.Productgroep__c = user.Productgroep__c.replace(';', '; ');
            }

        }
        public static final String ASCENDING = 'ASCENDING'; 
        public static String SortDirection;
        public static String SortField;

        global Integer compareTo(Object compareTo) {
            UserList compateToDos = (UserList) compareTo;
            if (SortField == 'Name') {
                //System.debug(compareToName(compareTo));
                return compareToName(compareTo);
            }
            if (SortField == 'Skill') {
                return compareToSkill(compareTo);
            }
            //System.debug('SortField' + SortField);
            if (SortField == 'Address' || SortField == 'Address3') {
                return compareToAddress(compareTo);
            }
            if (SortField == 'uren' ) {
                return compareTouren(compareTo);
            }
            if (SortField == 'Mogelijk' ) {
                return compareToMogelijk(compareTo);
            }
            if (SortField == 'type' ) {
                return compareTotype(compareTo);
            }
            if (SortField == 'Voorkeur' ) {
                return compareToVoorkeur(compareTo);
            }
            return 0;
        }
        public Integer compareToName(Object obj) {
            UserList employee = (UserList)(obj);
           // System.debug('compareToName' + this.user.Name  +  ' ' + employee.user.Name);

            if (this.user.Name > employee.user.Name) {
                if (SortDirection == ASCENDING) {
                return 1;
                } else {
                    return -1;
                }
            }

            if (this.user.Name == employee.user.Name) {
                return 0;
            }

            if (SortDirection == ASCENDING) {
                return -1;
            } else {
                return 1;
            }
        }
        public Integer compareToSkill(Object obj) {
            UserList employee = (UserList)(obj);
            //System.debug('compareToName' + this.user.Label__c  +  ' ' + employee.user.Label__c);

            if (this.user.Label__c  > employee.user.Label__c  ) {
                if (SortDirection == ASCENDING) {
                return 1;
                } else {
                    return -1;
                }
            }

            if (this.user.Label__c  == employee.user.Label__c  ) {
                return 0;
            }

            if (SortDirection == ASCENDING) {
                return -1;
            } else {
                return 1;
            }
        }
        public Integer compareTotype(Object obj) {
            UserList employee = (UserList)(obj);
           // System.debug('compareToName' + this.user.Medewerker_Type__c  +  ' ' + employee.user.Medewerker_Type__c);

            if (this.user.Medewerker_Type__c > employee.user.Medewerker_Type__c) {
                if (SortDirection == ASCENDING) {
                return 1;
                } else {
                    return -1;
                }
            }

            if (this.user.Medewerker_Type__c == employee.user.Medewerker_Type__c) {
                return 0;
            }

            if (SortDirection == ASCENDING) {
                return -1;
            } else {
                return 1;
            }
        }
        public Integer compareTouren(Object obj) {
            
           UserList employee = (UserList)(obj);
            //System.debug('compareToName' + this.loadDos  +  ' ' + employee.loadDos );

            if (this.loadDos  > employee.loadDos   ) {
                if (SortDirection == ASCENDING) {
                return 1;
                } else {
                    return -1;
                }
            }

            if (this.loadDos  == employee.loadDos   ) {
                return 0;
            }

            if (SortDirection == ASCENDING) {
                return -1;
            } else {
                return 1;
            }
            
        }
        public Integer compareToVoorkeur(Object obj) {
            
            UserList employee = (UserList)(obj);
            //System.debug('compareToName' + this.voorkeur +  ' ' + employee.voorkeur  );

            if (this.voorkeur > employee.voorkeur ) {
                if (SortDirection == ASCENDING) {
                return 1;
                } else {
                    return -1;
                }
            }

            if (this.voorkeur == employee.voorkeur ) {
                return 0;
            }

            if (SortDirection == ASCENDING) {
                return -1;
            } else {
                return 1;
            }
            
        }
        public Integer compareToMogelijk(Object obj) {
            
            UserList employee = (UserList)(obj);
            //System.debug('compareToName' + this.mogelick +  ' ' + employee.mogelick );

            if (this.mogelick > employee.mogelick ) {
                if (SortDirection == ASCENDING) {
                return 1;
                } else {
                    return -1;
                }
            }

            if (this.mogelick == employee.mogelick ) {
                return 0;
            }

            if (SortDirection == ASCENDING) {
                return -1;
            } else {
                return 1;
            }
            
        }
        public Integer compareToAddress(Object obj) {
            UserList employee = (UserList)(obj);

            if (this.closest > employee.closest) {
                if (SortDirection == ASCENDING) {
                    return 1;
                } else {
                    return -1;
                }
            }

            if (this.closest == employee.closest) {
                return 0;
            }

            if (SortDirection == ASCENDING) {
                return -1;
            } else {
                return 1;
            }
        }

}