public with sharing class IntaktController {

public Id accId;
public List<Revenue__c> revenuelist{get;set;}
integer currentYear, lastyear;
integer month,revenueYear;
decimal currentyrJanRevenue,currentyrFebRevenue,currentyrMarRevenue,currentyrAprRevenue,currentyrMayRevenue,currentyrJunRevenue;
decimal currentyrJulRevenue,currentyrAugRevenue,currentyrSepRevenue,currentyrOctRevenue, currentyrNovRevenue, currentyrDecRevenue;
decimal lastyrJanRevenue,lastyrFebRevenue,lastyrMarRevenue,lastyrAprRevenue, lastyrMayRevenue, lastyrJunRevenue;
decimal lastyrJulRevenue,lastyrAugRevenue,lastyrSepRevenue,lastyrOctRevenue, lastyrNovRevenue, lastyrDecRevenue;
decimal diffJanRevenue,diffFebRevenue,diffMarRevenue,diffAprRevenue,diffMayRevenue,diffJunRevenue,diffJulRevenue;
decimal diffAugRevenue, diffSeptRevenue, diffOctRevenue, diffNovRevenue, diffDecRevenue;

    public IntaktController(ApexPages.StandardController controller) 
    {
        accId = ApexPages.currentPage().getParameters().get('Id');
        
        if(accId != null)
        {
            revenuelist = [select Id,Date__c,Year__c,RevenueAmount__c, Name from Revenue__c where Account__c =: accId ORDER BY Date__c ASC];
        }
        currentYear = System.Today().year();
        lastyear = system.today().year()-1;
        if(revenuelist != null && revenuelist.size() > 0)
        {
            for(Revenue__c rev : revenuelist)
            {
                month = rev.Date__c.month();
                revenueYear = rev.Date__c.year();
                system.debug('---month----'+month);  
                system.debug('---revenueYear----'+revenueYear); 
                if(month == 1)
                {
                    if(revenueYear == currentYear)
                    {
                        currentyrJanRevenue = rev.RevenueAmount__c;
                    }
                    else if(revenueYear == lastyear)
                    {
                        lastyrJanRevenue = rev.RevenueAmount__c;
                    }
                    if(lastyrJanRevenue!= null && currentyrJanRevenue != null && lastyrJanRevenue!= 0)
                    {
                        diffJanRevenue = 100*((currentyrJanRevenue/lastyrJanRevenue)-1);
                    }
                    
                }
                else if(month == 2)
                {
                    if(revenueYear == currentYear)
                    {
                        currentyrFebRevenue = rev.RevenueAmount__c;
                    }
                    else if(revenueYear == lastyear)
                    {
                        lastyrFebRevenue = rev.RevenueAmount__c;
                    }
                    if(lastyrFebRevenue != null && currentyrFebRevenue != null && lastyrFebRevenue != 0)
                    {
                        diffFebRevenue = 100*((currentyrFebRevenue/lastyrFebRevenue)-1);
                    }
                }
                else if(month == 3)
                {
                    if(revenueYear == currentYear)
                    {
                        currentyrMarRevenue = rev.RevenueAmount__c;
                    }
                    else if(revenueYear == lastyear)
                    {
                        lastyrMarRevenue = rev.RevenueAmount__c;
                    }
                    if(lastyrMarRevenue != null && currentyrMarRevenue != null && lastyrMarRevenue != 0)
                    {
                        diffMarRevenue =100*((currentyrMarRevenue/lastyrMarRevenue)-1);
                    }
                }
                else if(month == 4)
                {
                    if(revenueYear == currentYear)
                    {
                        currentyrAprRevenue = rev.RevenueAmount__c;
                    }
                    else if(revenueYear == lastyear)
                    {
                        lastyrAprRevenue = rev.RevenueAmount__c;
                    }
                    if(lastyrAprRevenue != null && currentyrAprRevenue != null && lastyrAprRevenue != 0)
                    {
                        diffAprRevenue = 100*((currentyrAprRevenue/lastyrAprRevenue)-1);
                    }
                }
                else if(month == 5)
                {
                    if(revenueYear == currentYear)
                    {
                        currentyrMayRevenue = rev.RevenueAmount__c;
                    }
                    else if(revenueYear == lastyear)
                    {
                        lastyrMayRevenue = rev.RevenueAmount__c;
                    }
                    if(lastyrMayRevenue != null && currentyrMayRevenue != null && lastyrMayRevenue != 0)
                    {
                        diffMayRevenue = 100*((currentyrMayRevenue/lastyrMayRevenue)-1);
                    }
                }
                else if(month == 6)
                {
                    if(revenueYear == currentYear)
                    {
                        currentyrJunRevenue = rev.RevenueAmount__c;
                    }
                    else if(revenueYear == lastyear)
                    {
                        lastyrJunRevenue = rev.RevenueAmount__c;
                    }
                    if(lastyrJunRevenue != null && currentyrJunRevenue != null && lastyrJunRevenue != 0)
                    {
                        diffJunRevenue = 100*((currentyrJunRevenue/lastyrJunRevenue)-1);
                    }
                }
                else if(month == 7)
                {
                    if(revenueYear == currentYear)
                    {
                        currentyrJulRevenue = rev.RevenueAmount__c;
                    }
                    else if(revenueYear == lastyear)
                    {
                        lastyrJulRevenue = rev.RevenueAmount__c;
                    }
                    if(lastyrJulRevenue != null && currentyrJulRevenue != null && lastyrJulRevenue != 0)
                    {
                        diffJulRevenue = 100*((currentyrJulRevenue/lastyrJulRevenue)-1);
                    }
                }
                else if(month == 8)
                {
                    if(revenueYear == currentYear)
                    {
                        currentyrAugRevenue = rev.RevenueAmount__c;
                    }
                    else if(revenueYear == lastyear)
                    {
                        lastyrAugRevenue = rev.RevenueAmount__c;
                    }
                    if(lastyrAugRevenue != null && currentyrAugRevenue != null && lastyrAugRevenue != 0)
                    {
                        diffAugRevenue = 100*((currentyrAugRevenue/lastyrAugRevenue)-1);
                    }
                }
                else if(month == 9)
                {
                    if(revenueYear == currentYear)
                    {
                        currentyrSepRevenue = rev.RevenueAmount__c;
                    }
                    else if(revenueYear == lastyear)
                    {
                        lastyrSepRevenue = rev.RevenueAmount__c;
                    }
                    if(lastyrSepRevenue != null && currentyrSepRevenue != null && lastyrSepRevenue != 0)
                    {
                        diffSeptRevenue = 100*((currentyrSepRevenue/lastyrSepRevenue)-1);
                    }
                }
                else if(month == 10)
                {
                    if(revenueYear == currentYear)
                    {
                        currentyrOctRevenue = rev.RevenueAmount__c;
                    }
                    else if(revenueYear == lastyear)
                    {
                        lastyrOctRevenue = rev.RevenueAmount__c;
                    }
                    if(lastyrOctRevenue != null && currentyrOctRevenue != null && lastyrOctRevenue != 0)
                    {
                        diffOctRevenue = 100*((currentyrOctRevenue/lastyrOctRevenue)-1);
                    }
                }
                else if(month == 11)
                {
                    if(revenueYear == currentYear)
                    {
                        currentyrNovRevenue = rev.RevenueAmount__c;
                    }
                    else if(revenueYear == lastyear)
                    {
                        lastyrNovRevenue = rev.RevenueAmount__c;
                    }
                    if(lastyrNovRevenue != null && currentyrNovRevenue != null && lastyrNovRevenue != 0)
                    {
                        diffNovRevenue = 100*((currentyrNovRevenue/lastyrNovRevenue)-1);
                    }
                }
                else if(month == 12)
                {
                    if(revenueYear == currentYear)
                    {
                        currentyrDecRevenue = rev.RevenueAmount__c;
                    }
                    else if(revenueYear == lastyear)
                    {
                        lastyrDecRevenue = rev.RevenueAmount__c;
                    }
                    if(lastyrDecRevenue != null && currentyrDecRevenue != null && lastyrDecRevenue != 0)
                    {
                        diffDecRevenue = 100*((currentyrDecRevenue/lastyrDecRevenue)-1);
                    }
                }
                
            }
        
        }

    }
    
    public Decimal getcurrentyrJanRevenue(){
        return currentyrJanRevenue;
    }
    public Decimal getcurrentyrFebRevenue(){
        return currentyrFebRevenue;
    }
    public Decimal getcurrentyrMarRevenue(){
        return currentyrMarRevenue;
    }
    public Decimal getcurrentyrAprRevenue(){
        return currentyrAprRevenue;
    }
    public Decimal getcurrentyrMayRevenue(){
        return currentyrMayRevenue;
    }
    public Decimal getcurrentyrJunRevenue(){
        return currentyrJunRevenue;
    }
     public Decimal getcurrentyrJulRevenue(){
        return currentyrJulRevenue;
    }
    public Decimal getcurrentyrAugRevenue(){
        return currentyrAugRevenue;
    }
    public Decimal getcurrentyrSepRevenue(){
        return currentyrSepRevenue;
    }
    public Decimal getcurrentyrOctRevenue(){
        return currentyrOctRevenue;
    }
    public Decimal getcurrentyrNovRevenue(){
        return currentyrNovRevenue;
    }
    public Decimal getcurrentyrDecRevenue(){
        return currentyrDecRevenue;
    }
    public Decimal getlastyrJanRevenue(){
        return lastyrJanRevenue;
    }
    public Decimal getlastyrFebRevenue(){
        return lastyrFebRevenue;
    }
    public Decimal getlastyrMarRevenue(){
        return lastyrMarRevenue;
    }
    public Decimal getlastyrAprRevenue(){
        return lastyrAprRevenue;
    }
    public Decimal getlastyrMayRevenue(){
        return lastyrMayRevenue;
    }
    public Decimal getlastyrJunRevenue(){
        return lastyrJunRevenue;
    }
     public Decimal getlastyrJulRevenue(){
        return lastyrJulRevenue;
    }
    public Decimal getlastyrAugRevenue(){
        return lastyrAugRevenue;
    }
    public Decimal getlastyrSepRevenue(){
        return lastyrSepRevenue;
    }
    public Decimal getlastyrOctRevenue(){
        return lastyrOctRevenue;
    }
    public Decimal getlastyrNovRevenue(){
        return lastyrNovRevenue;
    }
    public Decimal getlastyrDecRevenue(){
        return lastyrDecRevenue;
    }
    
    public Decimal getdiffJanRevenue(){
        return diffJanRevenue;
    }
    public Decimal getdiffFebRevenue(){
        return diffFebRevenue;
    }
    public Decimal getdiffMarRevenue(){
        return diffMarRevenue;
    }
    public Decimal getdiffAprRevenue(){
        return diffAprRevenue;
    }
    public Decimal getdiffMayRevenue(){
        return diffMayRevenue;
    }
    public Decimal getdiffJunRevenue(){
        return diffJunRevenue;
    }
    public Decimal getdiffJulRevenue(){
        return diffJulRevenue;
    }
    public Decimal getdiffAugRevenue(){
        return diffAugRevenue;
    }
    public Decimal getdiffSeptRevenue(){
        return diffSeptRevenue;
    }
    public Decimal getdiffOctRevenue(){
        return diffOctRevenue;
    }
    public Decimal getdiffNovRevenue(){
        return diffNovRevenue;
    }
    public Decimal getdiffDecRevenue(){
        return diffDecRevenue;
    }
}