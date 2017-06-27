global with sharing class Dossier implements Comparable{
        public Dossier__c dossier {get;set;}
        public Boolean isSelected {get;set;}
        public Boolean show {get;set;}
        public Decimal Load {get;set;}
        public Product__c product{get{if (product == null){product = new Product__c();}return product;}set;}
        public Dossier (Dossier__c dossier, Boolean isSelected, Boolean show, Product__c product) {
                this.dossier = dossier;
                this.isSelected = isSelected;
                this.show = show;
                this.product = product;
        }
        public static final String ASCENDING = 'ASCENDING'; 
        public static String SortDirection;
        public static String SortField;

        global Integer compareTo(Object compareTo) {
            Dossier compateToDos = (Dossier) compareTo;
            if (SortField == 'Name') {
                System.debug(compareToName(compareTo));
                return compareToName(compareTo);
            }
            if (SortField == 'AccountName') {
                return compareToAccount(compareTo);
            }
            
            if (SortField == 'Datum') {
                return compareToDate(compareTo);
            }
            if (SortField == 'End') {
                return compareToEnd(compareTo);
            }
            if (SortField == 'User') {
                return compareToUser(compareTo);
            }
            if (SortField == 'Branche') {
                return compareToBranche(compareTo);
            }
            if (SortField == 'OtherAddress') {
                return compareToAddress(compareTo);
            }
            if (SortField == 'Load') {
                return compareToLoad(compareTo);
            }
            
            
            return 0;
        }
        
        public Integer compareToName(Object obj) {
            Dossier employee = (Dossier)(obj);
            System.debug('compareToName' + this.dossier.Name  +  ' ' + employee.dossier.Name);
            
            if (this.dossier.Name > employee.dossier.Name) {
                if (SortDirection == ASCENDING) {
                    return 1;
                } else {
                    return -1;
                }
            }
            if (this.dossier.Name == employee.dossier.Name) {
                return 0;
            }
            if (SortDirection == ASCENDING) {
                return -1;
            } else {
                return 1;
            }
        }
        public Integer compareToAccount(Object obj) {
            Dossier employee = (Dossier)(obj);
            if (this.dossier.Relatie__r.Name  > employee.dossier.Relatie__r.Name ) {
                if (SortDirection == ASCENDING) {
                    return 1;
                } else {
                    return -1;
                }
            }
            if (this.dossier.Relatie__r.Name  == employee.dossier.Relatie__r.Name ) {
                return 0;
            }
            if (SortDirection == ASCENDING) {
                return -1;
            } else {
                return 1;
            }
            
        }
        public Integer compareToDate(Object obj) {
            Dossier employee = (Dossier)(obj);

            if (this.dossier.Datum_Binnenkomst__c > employee.dossier.Datum_Binnenkomst__c) {
               if (SortDirection == ASCENDING) {
                    return 1;
                } else {
                    return -1;
                }
            }

            if (this.dossier.Datum_Binnenkomst__c == employee.dossier.Datum_Binnenkomst__c) {
                return 0;
            }

            if (SortDirection == ASCENDING) {
                return -1;
            } else {
                return 1;
            }
        }
        public Integer compareToEnd(Object obj) {
            Dossier employee = (Dossier)(obj);

            if (this.dossier.Einddatum__c > employee.dossier.Einddatum__c) {
               if (SortDirection == ASCENDING) {
                    return 1;
                } else {
                    return -1;
                }
            }

            if (this.dossier.Einddatum__c == employee.dossier.Einddatum__c) {
                return 0;
            }

            if (SortDirection == ASCENDING) {
                return -1;
            } else {
                return 1;
            }
        }
        public Integer compareToUser(Object obj) {
            Dossier employee = (Dossier)(obj);

            if (this.dossier.Handler__r.Name > employee.dossier.Handler__r.Name) {
               if (SortDirection == ASCENDING) {
                    return 1;
                } else {
                    return -1;
                }
            }

            if (this.dossier.Handler__r.Name == employee.dossier.Handler__r.Name) {
                return 0;
            }

            if (SortDirection == ASCENDING) {
                return -1;
            } else {
                return 1;
            }
        }
        public Integer compareToAddress(Object obj) {
            Dossier employee = (Dossier)(obj);
            String address = '';
            if (this.dossier.Client__r.OtherStreet != null)
                address += this.dossier.Client__r.OtherStreet +', ';
            if (this.dossier.Client__r.OtherCity != null)
                address += this.dossier.Client__r.OtherCity +', ';
            if (this.dossier.Client__r.OtherState != null)
                address += this.dossier.Client__r.OtherState +' ';
            if (this.dossier.Client__r.OtherPostalCode != null)
                address += this.dossier.Client__r.OtherPostalCode +', ';
            if (this.dossier.Client__r.OtherCountry != null)
                address += this.dossier.Client__r.OtherCountry;

            String address1 = '';
            if (employee.dossier.Client__r.OtherStreet != null)
                address1 += employee.dossier.Client__r.OtherStreet +', ';
            if (employee.dossier.Client__r.OtherCity != null)
                address1 += employee.dossier.Client__r.OtherCity +', ';
            if (employee.dossier.Client__r.OtherState != null)
                address1 += employee.dossier.Client__r.OtherState +' ';
            if (employee.dossier.Client__r.OtherPostalCode != null)
                address1 += employee.dossier.Client__r.OtherPostalCode +', ';
            if (employee.dossier.Client__r.OtherCountry != null)
                address1 += employee.dossier.Client__r.OtherCountry;


            if (address > address1) {
               if (SortDirection == ASCENDING) {
                    return 1;
                } else {
                    return -1;
                }
            }

            if (address == address1) {
                return 0;
            }

            if (SortDirection == ASCENDING) {
                return -1;
            } else {
                return 1;
            }

        
        }
        public Integer compareToLoad(Object obj) {
            Dossier employee = (Dossier)(obj);

            if (this.Load > employee.Load) {
               if (SortDirection == ASCENDING) {
                    return 1;
                } else {
                    return -1;
                }
            }

            if (this.Load == employee.Load) {
                return 0;
            }

            if (SortDirection == ASCENDING) {
                return -1;
            } else {
                return 1;
            }

        
        }
        public Integer compareToBranche (Object obj) {
            Dossier employee = (Dossier)(obj);

            if (this.dossier.Branche3__c > employee.dossier.Branche3__c) {
               if (SortDirection == ASCENDING) {
                    return 1;
                } else {
                    return -1;
                }
            }

            if (this.dossier.Branche3__c == employee.dossier.Branche3__c) {
                return 0;
            }

            if (SortDirection == ASCENDING) {
                return -1;
            } else {
                return 1;
            }
        }

}