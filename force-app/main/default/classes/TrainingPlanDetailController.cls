/*
Copyright (c) 2014, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
public with sharing class TrainingPlanDetailController extends LMSBaseController{

    public TrainingPlan tPlan{get;set;}
    public String learningLaunchURL{get;set;}
    public String learningTarget{get;set;}

    public Boolean byPassLaunchModal{get;set;}
    public Boolean hasPreRequisite{get;private set;}

    public String selectedSectionId{get;set;}
    public String selectedItemId{get;set;}
    public TrainingPlanSectionItem selectedItem{get;set;}

    public transient List<User> lUsersWithAchievement{get;set;}
    public transient String tPlanAssignmentStatus{get;private set;}

    public String selectedItemStatusLabel{get{
        if(selectedItem != null && selectedItem.latestAssignment != null && selectedItem.latestAssignment.Progress__c != null){
            if(selectedItem.latestAssignment.Progress__c == LMSConstants.ASSIGNMENT_STATUS_COMPLETED){
                return 'label-success';
            }else if(selectedItem.latestAssignment.Progress__c == LMSConstants.ASSIGNMENT_STATUS_IN_PROGRESS){
                return 'label-warning';
            }else{
                return 'label-default';
            }
        }else{
            return 'label-default';
        }
    }}

    private Id trainingPlanId;

    //Custom exception class
    public class TrainingPlanDetailException extends Exception{}

    public TrainingPlanDetailController(ApexPages.StandardController cont){
        trainingPlanId = cont.getId();
        init();
    }

    public TrainingPlanDetailController(){
        trainingPlanId = ApexPages.currentPage().getParameters().get('id');
        init();
    }

    @TestVisible
    private void init(){
        try{
            tPlanAssignmentStatus = null;
            learningLaunchURL = null;
            learningTarget = '_self';
            selectedItem = null;
            byPassLaunchModal = false;
            hasPreRequisite = false;
            loadTrainingPlanInfo();
            if(tPlan != null){
                if(tPlan.mainAchievement != null){
                    lUsersWithAchievement = LMSService.getUsersForAchievement(tPlan.mainAchievement.Id, LMSConstants.AA_ACQUIRED_STATUS, 10);
                }
                loadAssignmentStatus();
            }
        }catch(Exception e){
            LMSUtils.logException(e,'TrainingPlanDetailController');
            LMSUtils.addGenericUnknownErrorMessage('TrainingPlanDetailController - init (1)');
        }
    }

    private void loadAssignmentStatus(){
        Map<Id,Map<Id,Training_Plan_Assignment__c>> assignmentsMap = LMSService.getTrainingPlanAssignments(new Set<Id>{UserInfo.getUserId()}, new Set<Id>{trainingPlanId});
        if(assignmentsMap.size()>0 && assignmentsMap.get(UserInfo.getUserId()) != null){
            Map<Id,Training_Plan_Assignment__c> tplanAssignmentMap = assignmentsMap.get(UserInfo.getUserId());
            Training_Plan_Assignment__c userTPlanAssignment = tplanAssignmentMap.get(trainingPlanId);
            if(userTPlanAssignment != null){
                tPlanAssignmentStatus = userTPlanAssignment.Status__c;
            }
        }
    }

    private void loadTrainingPlanInfo(){
        tPlan = LMSWrappersService.getTrainingPlanDetails(trainingPlanId,UserInfo.getUserId(),false, true);
    }

    public void retrieveItemDetails(){

        try{

            byPassLaunchModal = false;

            if(String.isBlank(selectedSectionId) || String.isBlank(selectedItemId)){
                throw new TrainingPlanDetailException(System.Label.ALMS_Invalid_Parameters_Message);
            }else{

                Set<Id> previousSectionIds = new Set<Id>();

                TrainingPlanSectionItem currentItem = null;
                List<TrainingPlanSection> planSections  = tPlan.sections;

                for(TrainingPlanSection s :planSections){

                    if(s.previousSectionId != null && !s.previousSectionOptional){
                        previousSectionIds.add(s.previousSectionId);
                    }

                    if(s.TrainingPlanSection.Id == selectedSectionId){

                        List<TrainingPlanSectionItem> items = s.items;

                        for(TrainingPlanSectionItem item : items){

                            if(item.currentSectionItemId == selectedItemId){
                                currentItem = item;
                                break;
                            }

                        }

                        break;
                    }

                }

                if(currentItem != null){

                    selectedItem = currentItem;

                    //Validate sequence if applicable
                    if(tPlan.trainingPlan.Enforce_Sequence__c){

                        LMSService.WithoutSharingOps wsops = new LMSService.WithoutSharingOps();

                        hasPreRequisite = false;

                        //Validate previous section item, if applicable
                        if(selectedItem.previousSectionItemId != null){
                            if(wsops.hasIncompleteLearningAssignment(selectedItem.previousSectionItemId, UserInfo.getUserId())){
                                hasPreRequisite = true;
                            }
                        }

                        //Always validate that the previous sections have been completed, if applicable
                        if(!hasPreRequisite && previousSectionIds.size()>0){
                            //Verify status of the assignment for the previous sections
                            if(wsops.hasIncompleteTPlanSectionAssignments(previousSectionIds, UserInfo.getUserId())){
                                hasPreRequisite = true;
                            }
                        }

                    }

                }else{
                    throw new TrainingPlanDetailException(System.Label.ALMS_Unable_Retrieve_Assignment_Info);
                }

                if(!hasPreRequisite && !(selectedItem.launchBehavior=='ask_user' || selectedItem.launchBehavior=='update_version')){
                    launchLearning();
                    byPassLaunchModal = true;
                }

            }


        }catch(Exception e){
            LMSUtils.logException(e,'TrainingPlanDetailController');
            LMSUtils.addGenericUnknownErrorMessage('TrainingPlanDetailController - retrieveItemDetails (2)');
        }
    }

    public PageReference launchLearning(){

        PageReference ref = null;

        Learning__c learning = selectedItem.learning;

        PageReference lPR = null;
        String currentRecordType = learning.RecordType.DeveloperName;

        if(currentRecordType == LMSConstants.RT_TASK){

            lPR = Page.TaskViewer;

            learningTarget = '_self';
        }else if(currentRecordType == LMSConstants.RT_TRAINING_RESOURCE){
            //Not necessary to enforce CRUD/FLS here, this is just to determine how to handle the content no data is exposed to the user
            LMSService.WithoutSharingOps wsops = new LMSService.WithoutSharingOps();
            Learning__c l = wsops.getLearningDetails(learning.Id);

            lPR = Page.ResourceViewer;

            if(l.Current_Published_Version__r.Training_Resource__r.Display_in_Iframe__c){
                learningTarget = 'iframe';
            }else{
                learningTarget = '_blank';
                String resourceURL = l.Current_Published_Version__r.Training_Resource__r.Resource_URL__c;
                if(resourceURL != null && (resourceURL.contains('.visual.force.com/apex/') || resourceURL.contains('.lightning.force.com/'))){
                    learningTarget = '_internal';
                }
            }
        }else if(currentRecordType == LMSConstants.RT_QUIZ){
            lPR = Page.QuizViewer;
            learningTarget = '_self';
        }else{
            learningTarget = '_internal';
            //Check for plugin launch URL
            LMSPlugins.LearningConfig customLearningConfig = LMSPlugins.getLearningPluginConfig(currentRecordType);
            lPR = new PageReference(customLearningConfig.getLaunchURLWithNamespace());
            Set<String> validLaunchTargets = new Set<String>{'_self','_blank','_internal','iframe'};
            learningTarget = validLaunchTargets.contains(customLearningConfig.launchTarget)?customLearningConfig.launchTarget:'_internal';
        }

        if(learning.Custom_Preview_URL__c != null){
            ref = new PageReference(learning.Custom_Preview_URL__c);
        }else{
            ref = lPR;
        }

        if(ref != null){
            ref.setRedirect(true);
            ref.getParameters().put('aid',selectedItem.latestAssignment.Id);
            ref.getParameters().put('tpid',trainingPlanId);
            ref.getParameters().put('tpsid',selectedSectionId);
            ref.getParameters().put('tpitid',selectedItemId);
        }

        learningLaunchURL = LMSUtils.updateURLCommunityPath(ref.getUrl());
        return null;

    }

    public PageReference updateToNewVersionAndLaunch(){
        selectedItem.updateToLatestVersion();
        byPassLaunchModal = true;
        return launchLearning();
    }

    public PageReference keepOldVersionAndLaunch(){
        selectedItem.keepOldVersion();
        byPassLaunchModal = true;
        return launchLearning();
    }

}