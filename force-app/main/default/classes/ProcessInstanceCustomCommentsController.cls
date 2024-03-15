public with sharing class  ProcessInstanceCustomCommentsController {
    @AuraEnabled
    public static Quote getQuote(Id ProcessInstanceStepId) {
        Quote q;
        String s = '';
        List <ProcessInstanceStep> prInsList = [SELECT Id, ProcessInstanceId FROM ProcessInstanceStep where id=:ProcessInstanceStepId];
        //ProcessInstanceStep ProcessInstanceStepObj = [SELECT Id, ProcessInstanceId FROM ProcessInstanceStep where id=:ProcessInstanceStepId];

        if(prInsList != null && prInsList.size()>0) {
            
            ProcessInstanceStep ProcessInstanceStepObj = (ProcessInstanceStep)prInsList.get(0);
            ProcessInstance ProcessInstanceObj = [SELECT Id, Status, TargetObjectId FROM ProcessInstance where id=:ProcessInstanceStepObj.ProcessInstanceId];
            q = [select id , Product_Details__c, MC_Payment_Term__c ,TeliaSE_Invoice_Fee__c , MC_Commercial_Benchmark__c,TeliaSE_Comments__c,TeliaSE_MC_ApprovalFileLink__c from Quote where id =:ProcessInstanceObj.TargetObjectId];
            s = q.Product_Details__c == null ? '' : q.Product_Details__c;
            //s=s.replace(') ', ')\r\n');
            s= s.contains(')') ? s.replace(')', ') <br/>') : '';
            q.Product_Details__c = s;
        }
        else {
            List <ProcessInstanceWorkitem> prWrkInsList = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem where id=:ProcessInstanceStepId];
            if(prWrkInsList != null && prWrkInsList.size()>0) {
                
                ProcessInstanceWorkitem ProcessInstanceStepObj = (ProcessInstanceWorkitem)prWrkInsList.get(0);
                ProcessInstance ProcessInstanceObj = [SELECT Id, Status, TargetObjectId FROM ProcessInstance where id=:ProcessInstanceStepObj.ProcessInstanceId];
                q = [select id , Product_Details__c, MC_Payment_Term__c ,TeliaSE_Invoice_Fee__c , MC_Commercial_Benchmark__c,TeliaSE_Comments__c,TeliaSE_MC_ApprovalFileLink__c from Quote where id =:ProcessInstanceObj.TargetObjectId];
                s = q.Product_Details__c == null ? '' : q.Product_Details__c;
                s = s.contains(')') ? s.replace(')', ') <br/>') : '';
                q.Product_Details__c = s;
            }
        } 
        return q;
    }
    @AuraEnabled
    public static Wrapper getQuoteLineItem(Id ProcessInstanceStepId) {
        List<QuoteLineItem> qliList;
        String s = '';
        String commTermAttrStr = '';
        List <ProcessInstanceStep> prInsList = [SELECT Id, ProcessInstanceId FROM ProcessInstanceStep where id=:ProcessInstanceStepId];
        //ProcessInstanceStep ProcessInstanceStepObj = [SELECT Id, ProcessInstanceId FROM ProcessInstanceStep where id=:ProcessInstanceStepId];
        Wrapper wr = new Wrapper();

        if(prInsList != null && prInsList.size()>0) {
            
            ProcessInstanceStep ProcessInstanceStepObj = (ProcessInstanceStep)prInsList.get(0);
            ProcessInstance ProcessInstanceObj = [SELECT Id, Status, TargetObjectId FROM ProcessInstance where id=:ProcessInstanceStepObj.ProcessInstanceId];
            qliList = [select id, TeliaSE_Product_Object_Type__c,QuoteId, MC_Quarantine_Time__c, TeliaSE_Minimum_Value_Commit__c,vlocity_cmt__ParentItemId__c from QuoteLineItem where QuoteId  =:ProcessInstanceObj.TargetObjectId AND TeliaSE_Product_Object_Type__c in ('Mobile Offer Specification', 'Touch Point Offer Spec')  AND vlocity_cmt__ParentItemId__c = null AND (MC_Quarantine_Time__c != Null OR TeliaSE_Minimum_Value_Commit__c != Null)];
            for(QuoteLineItem qli: qliList){
                    if(qli.TeliaSE_Product_Object_Type__c == 'Mobile Offer Specification'){
                        //commTermAttrStr += 'Jobbmobil: '+qli.TeliaSE_Minimum_Value_Commit__c+'%'+'\n';
                        //commTermAttrStr += 'Tid för att uppfylla basnivå Jobmobil: '+qli.MC_Quarantine_Time__c+'<br/>';
                        wr.jobmobileQuarantine = qli.MC_Quarantine_Time__c;
                        wr.jobmobileMinimum_Value = qli.TeliaSE_Minimum_Value_Commit__c;
                        
                    }else if(qli.TeliaSE_Product_Object_Type__c == 'Touch Point Offer Spec'){
                        //commTermAttrStr += 'Touchpoint: '+qli.TeliaSE_Minimum_Value_Commit__c+'<br/>';
                        //commTermAttrStr += 'Tid för att uppfylla basnivå Touchpoint: '+qli.MC_Quarantine_Time__c+'<br/>';
                        wr.touchpointQuarantine = qli.MC_Quarantine_Time__c;
                        wr.touchpointMinimum_Value = qli.TeliaSE_Minimum_Value_Commit__c;
                    }
                }
        }
        else {
            List <ProcessInstanceWorkitem> prWrkInsList = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem where id=:ProcessInstanceStepId];
            if(prWrkInsList != null && prWrkInsList.size()>0) {
                
                ProcessInstanceWorkitem ProcessInstanceStepObj = (ProcessInstanceWorkitem)prWrkInsList.get(0);
                ProcessInstance ProcessInstanceObj = [SELECT Id, Status, TargetObjectId FROM ProcessInstance where id=:ProcessInstanceStepObj.ProcessInstanceId];
               qliList = [select id, TeliaSE_Product_Object_Type__c,QuoteId, MC_Quarantine_Time__c, TeliaSE_Minimum_Value_Commit__c,vlocity_cmt__ParentItemId__c from QuoteLineItem where QuoteId  =:ProcessInstanceObj.TargetObjectId AND TeliaSE_Product_Object_Type__c in ('Mobile Offer Specification', 'Touch Point Offer Spec')  AND vlocity_cmt__ParentItemId__c = null AND (MC_Quarantine_Time__c != Null OR TeliaSE_Minimum_Value_Commit__c != Null)];
                
                for(QuoteLineItem qli: qliList){
                    if(qli.TeliaSE_Product_Object_Type__c == 'Mobile Offer Specification'){
                        //commTermAttrStr += 'Jobbmobil: '+qli.TeliaSE_Minimum_Value_Commit__c+'%'+'\n';
                        //commTermAttrStr += 'Tid för att uppfylla basnivå Jobmobil: '+qli.MC_Quarantine_Time__c+'<br/>';
                        wr.jobmobileQuarantine = qli.MC_Quarantine_Time__c;
                        wr.jobmobileMinimum_Value = qli.TeliaSE_Minimum_Value_Commit__c;
                        
                    }else if(qli.TeliaSE_Product_Object_Type__c == 'Touch Point Offer Spec'){
                        //commTermAttrStr += 'Touchpoint: '+qli.TeliaSE_Minimum_Value_Commit__c+'<br/>';
                        //commTermAttrStr += 'Tid för att uppfylla basnivå Touchpoint: '+qli.MC_Quarantine_Time__c+'<br/>';
                        wr.touchpointQuarantine = qli.MC_Quarantine_Time__c;
                        wr.touchpointMinimum_Value = qli.TeliaSE_Minimum_Value_Commit__c;
                    }
                }
            }
        } 
        return wr;
    }
    public with sharing class  Wrapper{
        @AuraEnabled
        Public String jobmobileQuarantine {get; set;}
        
        @AuraEnabled
        Public String touchpointQuarantine {get; set;}
        
        @AuraEnabled
        Public String touchpointMinimum_Value {get; set;}
        
        @AuraEnabled
        Public String jobmobileMinimum_Value {get; set;}
    }
    
}