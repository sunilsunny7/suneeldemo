/****************************************************************************************************************************

* @author                 Sunita Tudu   <sunita.tudu@capgemini.com>
* @modifiedBy             Sunita Tudu   <sunita.tudu@capgemini.com>
* @maintainedBy           Sunita Tudu
* @version                1.0
* @description            Controller class for Orderunderlag VF Pages(CRM Fiber)
* @modified               05-09-2022

******************************************************************************************************************************/
public class Orderunderlag_controller{
    
    
    public String xmlHeader{get;set;}
    public String previousContractLink{get;set;}
    public Contract orderContractdetails{get;set;}
    public static Map<String,Object> newmap1 {get;set;}
    public static Map<String,Object> order1 {get;set;}
    public static Map<String,Object> vtemap {get;set;}
    public static List<producker> Produkter {get;set;}
    public static Map<String,Object> allmant {get;set;}
    public static Map<String,Object> allmant1 {get;set;}
    public static Map<String,Object> Kundinformation {get;set;}
    public static Map<String,Object> Kontaktpersoner {get;set;}
    public static Map<String,Object> Affarsinformation {get;set;}
    public static Map<String,Object> Anslutning {get;set;}
    public static Map<String,Object> Koppar1 {get;set;}
    public static Map<String,Object> Koppar2 {get;set;}
    public static Map<String,Object> fiber1 {get;set;}
    public static Map<String,Object> fiber2 {get;set;}
    public static Map<String,Object> ovrigt {get;set;}
    public static Map<String,Object> Hardvara {get;set;}
    public static Map<String,Object> FAtjanster {get;set;}
    public static Map<String,Object> serviceAvtal {get;set;}
    public static Map<String,Object> nathyara {get;set;}
    public static String selectedRoles1{get;set;}
    public static String selectedRoles2{get;set;}
    public static String Fastighetsnat{get;set;}
    public static String omradesnat{get;set;}
    public static String typeofAffar{get;set;}
    public static List<flitWrap> flit {get;set;}
    public static vlocity_cmt__VlocityTrackingEntry__c vte {get;set;}
    
    public Orderunderlag_controller(){
        String message = System.currentPagereference().getParameters().get('ContractID');
        
        vte = [Select Id, MCResponseJSON__c from vlocity_cmt__VlocityTrackingEntry__c where vlocity_cmt__ContextId__c =: message WITH SECURITY_ENFORCED order by CreatedDate DESC  limit 1 ];
        
        try{
            xmlHeader = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>';
            
            newmap1 = (Map<String,Object>) JSON.deserializeUntyped(vte.MCResponseJSON__c);
            
            if(newmap1.get('allmant1') != null){allmant1 = (Map<String,Object>)newmap1.get('allmant1');}
            if(allmant1.get('typeofAffar') != '' ){
                String affartype = '';
                for(object obj: (List<object>)allmant1.get('typeofAffar')){
                    affartype += obj+',';
                }
                typeofAffar = affartype.removeEnd(',');
            }
            if(newmap1.get('Kundinformation') != null){Kundinformation = (Map<String,Object>)newmap1.get('Kundinformation');}
            if(newmap1.get('Kontaktpersoner') != null){Kontaktpersoner = (Map<String,Object>)newmap1.get('Kontaktpersoner');}
            
            if(Kontaktpersoner.get('selectedRoles1') != null){
                String roles1 = '';
                for(object obj: (List<object>)Kontaktpersoner.get('selectedRoles1')){
                    roles1+=obj+',';
                }
                selectedRoles1 = roles1.removeEnd(',');
            }
            if(Kontaktpersoner.get('selectedRoles2') != null){
                String roles2 = '';
                for(object obj: (List<object>)Kontaktpersoner.get('selectedRoles2')){
                    roles2+=obj+',';
                }
                selectedRoles2 = roles2.removeEnd(',');
            }
            if(newmap1.get('Affarsinformation') != null){Affarsinformation = (Map<String,Object>)newmap1.get('Affarsinformation');}
            
            if(newmap1.get('Anslutning') != null){Anslutning = (Map<String,Object>)newmap1.get('Anslutning');}
            if(Anslutning.get('Fastighetsnat') != null){
                String FastighetsnatStr = '';
                for(object obj: (List<object>)Anslutning.get('Fastighetsnat')){
                    FastighetsnatStr+=obj+',';
                }
                Fastighetsnat = FastighetsnatStr.removeEnd(',');
            }
            
            if(Anslutning.get('omradesnat') != null){
                String omradesnatStr = '';
                for(object obj: (List<object>)Anslutning.get('omradesnat')){
                    omradesnatStr+=obj+',';
                }
                omradesnat = omradesnatStr.removeEnd(',');
            }
            if(Anslutning.get('Koppar') != null){
                List<Object> kopparList = (List<Object>)Anslutning.get('Koppar');
                Koppar1 = (Map<String,Object>)kopparList[0];
                Koppar2 = (Map<String,Object>)kopparList[1];                
            }  
            if(Anslutning.get('Fiber') != null){
                List<Object> fiberList = (List<Object>)Anslutning.get('Fiber');
                fiber1 = (Map<String,Object>)fiberList[0];
                fiber2 = (Map<String,Object>)fiberList[1];                
            }
            
            if(newmap1.get('ovrigt') != null){ovrigt = (Map<String,Object>)newmap1.get('ovrigt');}
            if(newmap1.get('Hardvara') != null){Hardvara = (Map<String,Object>)newmap1.get('Hardvara');}
            if(newmap1.get('FAtjanster') != null){FAtjanster = (Map<String,Object>)newmap1.get('FAtjanster');}
            if(newmap1.get('flit') != null){
                flit = getFlit(newmap1);                
            }
            if(newmap1.get('serviceAvtal') != null){serviceAvtal = (Map<String,Object>)newmap1.get('serviceAvtal');}
            if(newmap1.get('nathyara') != null){nathyara = (Map<String,Object>)newmap1.get('nathyara');}
            system.debug('serviceAvtal '+ newmap1.get('serviceAvtal'));
            system.debug('nathyara '+ newmap1.get('nathyara'));
            if(newmap1.get('Produkter') != ''){
                Produkter = getProducter(newmap1);                
            }
            
        }
        catch(Exception e){
            System.debug('exception'+ e.getStackTraceString());  
        }        
    }
    
    
    
    public static List<producker> getProducter(Map<String,Object> newmap1){
        List<producker> tempProdukter = new List<producker>();
        
        tempProdukter = (List<producker>) System.JSON.deserialize(JSON.serialize(newmap1.get('Produkter')), List<producker>.class);   
        
        integer index = 11;
        List<producker> temppp = new List<producker>();
        for(producker temp : tempProdukter){
            
            if(temp != null){
                temp.indexA = 'A'+index;
                temp.indexB = 'B'+index;
                temp.indexC = 'C'+index;
                temp.indexD = 'D'+index;
                temp.indexE = 'E'+index;
                temp.indexF = 'F'+index;
                temp.indexG = 'G'+index;
                temp.rowIndex = string.valueOf(index);
                temppp.add(temp);                        
            }                    
            index++;
        }
        return temppp;          
    }
    
    public class producker{
        public string Omforhandling{get; set;}
        public string activationtype{get; set;}
        public string otc{get; set;}
        public string productCode{get; set;}
        public decimal price{get; set;}
        public Integer quantity{get; set;}
        public Boolean addButton{get; set;}
        public Boolean disablefield{get; set;}
        public string indexA{get;set;}
        public string indexB{get;set;}
        public string indexC{get;set;}
        public string indexD{get;set;}
        public string indexE{get;set;}
        public string indexF{get;set;}
        public string indexG{get;set;}
        public string rowIndex{get;set;}
    }
    
    public class flitWrap{
        public string adressanslutning{get; set;}
        public Integer Antal{get; set;}
        public decimal price{get; set;}
        public string addButton{get; set;}
        public string indexA{get;set;}
        public string indexB{get;set;}
        public string indexC{get;set;}
        
        public string rowIndexFlit{get;set;}
    }
    
    
    public static List<flitWrap> getFlit(Map<String,Object> newmap1){
        List<flitWrap> tempFlit = new List<flitWrap>();
        tempFlit = (List<flitWrap>) System.JSON.deserialize(JSON.serialize(newmap1.get('flit')), List<flitWrap>.class);   
        
        integer indexf = 3;
        List<flitWrap> tempflitList = new List<flitWrap>();
        for(flitWrap tempf : tempFlit){
            if(tempf != null){
                tempf.indexA = 'A'+indexf;
                tempf.indexB = 'B'+indexf;
                tempf.indexC = 'C'+indexf;
                
                tempf.rowIndexFlit = string.valueOf(indexf);
                tempflitList.add(tempf);                        
            }                    
            indexf++;
        }
        return tempflitList;          
    }
    
    
}