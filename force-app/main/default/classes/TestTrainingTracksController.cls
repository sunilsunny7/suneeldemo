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
@isTest
private class TestTrainingTracksController{

    private static testMethod void testWithoutSharedTracks(){

        List<User> adminUsers;
        List<User> lmsUsers;

        System.runAs(new User(Id = Userinfo.getUserId())){
            //Create admin users
            adminUsers = TestUtilClass.createUsers(2,'System Administrator');
            lmsUsers = TestUtilClass.createUsers(5,'Standard User');
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        List<TestParams.TrainingTrackParam> params = new List<TestParams.TrainingTrackParam>();
        params.add(new TestParams.TrainingTrackParam());
        params.add(new TestParams.TrainingTrackParam());
        params.add(new TestParams.TrainingTrackParam());
        params.add(new TestParams.TrainingTrackParam());

        List<Training_Track__c> tracks = TestTrainingTrackData.createTrainingTracks(params);

        Test.startTest();

            System.runAs(lmsUsers.get(0)){
                TrainingTracksController cont = new TrainingTracksController();
                System.assertEquals(0,cont.tTracks.size());
            }

        Test.stopTest();

    }

    private static testMethod void testWithSharedTracks(){

        List<User> adminUsers;
        List<User> lmsUsers;

        System.runAs(new User(Id = Userinfo.getUserId())){
            //Create admin users
            adminUsers = TestUtilClass.createUsers(2,'System Administrator');
            lmsUsers = TestUtilClass.createUsers(5,'Standard User');
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        List<TestParams.TrainingTrackParam> params = new List<TestParams.TrainingTrackParam>();
        params.add(new TestParams.TrainingTrackParam());
        params.add(new TestParams.TrainingTrackParam());
        params.add(new TestParams.TrainingTrackParam());
        params.add(new TestParams.TrainingTrackParam());

        List<Training_Track__c> tracks = TestTrainingTrackData.createTrainingTracks(params);
        List<Training_Track__Share> shares = new List<Training_Track__Share>();

        for(Training_Track__c t : tracks){
            Training_Track__Share tShr  = new Training_Track__Share();
            tShr.ParentId = t.Id;
            tShr.UserOrGroupId = lmsUsers.get(0).Id;
            tShr.AccessLevel = 'Read';
            shares.add(tShr);
        }

        insert shares;

        Test.startTest();

            System.runAs(lmsUsers.get(0)){
                TrainingTracksController cont = new TrainingTracksController();
                System.assertEquals(4,cont.tTracks.size());
            }

        Test.stopTest();

    }


}