/**
 * Description: 
 * RevenueImpactCalculationController test class.
 * 
 * Modifications:
 * 14.11.2022 [Tomass Brazovskis] SALEF-7482 - Introduced. Refactored RevenueImpactController controller and its test class, introduced with 
 *               SALEF-3861 by P.S on 11.2020, to accommodate for the original Lightning component transfer from Aura to LWC.
 **/
@isTest
public with sharing class RevenueImpactCalculationController_Test {
    
    // Setup data record values to be used throughout the test class
	public static String TEST_OPP_NAME = 'TestOppRevenueEffect';
	public static String BYPASS_USER_USERNAME = 'test@bypassUser.com';

	/**@Description:
     * Set up the User, parent Opportunity and its 3 related Revenue Effect records
	 * to be used by the other test methods.
     * Modifications:
     *  14.11.2022 [TB] SALEF-7482 - Introduced.
     **/ 
	@testSetup 
	static void setup() {
		User testByPassUser = Test_DataFactory.getByPassUser();
		testByPassUser.Bypass_VR__c = true;
		testByPassUser.Username = BYPASS_USER_USERNAME;
		update testByPassUser;
		System.runAs(testByPassUser){
			// Create parent Opportunity
			List<Opportunity> lstTestOpp = new List<Opportunity>{Test_DataFactory.createOpportunity()};
			lstTestOpp[0].Name = TEST_OPP_NAME;
			insert lstTestOpp;
			// Create 3 Revenue Effect records related to the Opportunity
			List<Revenue_Effect__c> lstTestOppRevenueEffect = new List<Revenue_Effect__c>();
			Map<String, List<Integer>> mapFieldApiNamesToLstOfValues = new Map<String, List<Integer>>();
			Integer NUM_OF_REVENUE_EFFECT_TEST_RECORDS = 3;
			mapFieldApiNamesToLstOfValues.put('New_Antal__c', 			new List<Integer>{2, 3, 5});
			mapFieldApiNamesToLstOfValues.put('New_Monthly_Cost__c', 	new List<Integer>{20, 30, 50});
			mapFieldApiNamesToLstOfValues.put('Old_Antal__c', 			new List<Integer>{2, 3, 5});
			mapFieldApiNamesToLstOfValues.put('Old_Monthly_Cost__c', 	new List<Integer>{10, 20, 50});
			for(Integer idx = 0; idx < NUM_OF_REVENUE_EFFECT_TEST_RECORDS; idx++){
				Revenue_Effect__c curRevenueEffect = new Revenue_Effect__c();
				curRevenueEffect.Category__c = 'MOBILT';
				curRevenueEffect.Sub_Category__c = 'MOBIL ABG';
				curRevenueEffect.Opportunity__c = lstTestOpp[0].Id;
				for(String curFieldApiName : mapFieldApiNamesToLstOfValues.keySet()){
					curRevenueEffect.put(curFieldApiName, mapFieldApiNamesToLstOfValues.get(curFieldApiName)[idx]);
				}
				lstTestOppRevenueEffect.add(curRevenueEffect);
			}
			insert lstTestOppRevenueEffect;
			// Currently there is not a trigger action on Revenue Effect updating its parent Opportunity
			// summary Int_ktseffekt_12_m_n_Kr__c and Int_ktseffekt_12_m_n__c, so the method bellow must be called explicitly 
			RevenueImpactCalculationController.updateOpportunityRevenueEffectSummaries(lstTestOpp[0].id);
		}
	}

	/**@Description:
	 * Test controller helperPerformSummaryCalculations() method
     * Modifications:
     *  14.11.2022 [TB] SALEF-7482 - Introduced.
     **/ 
	@isTest
	public static void testHelperPerformSummaryCalculations(){
		List<Opportunity> lstTestOpp = [SELECT Id FROM Opportunity WHERE Name = :TEST_OPP_NAME];
		List<Revenue_Effect__c> lstTestOppRevenueEffect = [	SELECT 	Id, New_Antal__c, New_Monthly_Cost__c,
																	Old_Antal__c, Old_Monthly_Cost__c 
															FROM Revenue_Effect__c
															WHERE Opportunity__c = :lstTestOpp[0].Id];
		Decimal totalOld = 0;
		Decimal totalNew = 0;
		Decimal revenueEffect = 0;
		Decimal revenueEffectPer = 0;

		// Calculate the expected Revenue Effect summary values
		for(Revenue_Effect__c curRevenueEffect : lstTestOppRevenueEffect){
			totalOld += helperCalculateOldAmount(curRevenueEffect);
			totalNew += helperCalculateNewAmount(curRevenueEffect);
		}
		revenueEffect = (totalNew - totalOld);
		revenueEffectPer = (revenueEffect/totalold) * 100;
		
		Test.startTest();
		Map<String,Decimal> mapSummaryCalculationNamesToResults = RevenueImpactCalculationController.helperPerformSummaryCalculations(lstTestOppRevenueEffect);
		Test.stopTest();
		// Verify the correctness of the calculated summary values
		System.assertEquals(totalOld, mapSummaryCalculationNamesToResults.get('totalOld'));
		System.assertEquals(totalNew, mapSummaryCalculationNamesToResults.get('totalNew'));
		System.assertEquals(revenueEffect, mapSummaryCalculationNamesToResults.get('revenueEffect'));
		System.assertEquals(revenueEffectPer, mapSummaryCalculationNamesToResults.get('revenueEffectPer')); 
	}

	/**@Description:
	 * Test controller getRevenueEffectDetails() method
     * Modifications:
     *  14.11.2022 [TB] SALEF-7482 - Introduced.
     **/ 
	@isTest
	public static void testGetRevenueEffectDetails(){
		List<Opportunity> lstTestOpp = [SELECT Id FROM Opportunity WHERE Name = :TEST_OPP_NAME];
		Opportunity oppRecordBeforeUpdate = lstTestOpp[0];
		List<Revenue_Effect__c> lstTestOppRevenueEffect = [	SELECT 	Id, New_Antal__c, New_Monthly_Cost__c,
																	Old_Antal__c, Old_Monthly_Cost__c 
															FROM Revenue_Effect__c
															WHERE Opportunity__c = :lstTestOpp[0].Id];
		Test.startTest();
		RevenueImpactCalculationController.RevenueEffectDetailsWrapper testREDetailsWrapper = RevenueImpactCalculationController.getRevenueEffectDetails(lstTestOpp[0].Id);
		Test.stopTest();

		// Verify the correctness of the returned wrapper properties
		System.assertNotEquals(null, testREDetailsWrapper.lstRevenueEffectRecords);
		System.assertNotEquals(null, testREDetailsWrapper.mapCalculationNamesToResults);
		System.assertEquals(lstTestOppRevenueEffect.size(), testREDetailsWrapper.lstRevenueEffectRecords.size());
		System.assertEquals(4, testREDetailsWrapper.mapCalculationNamesToResults.keySet().size());
	}

	/**@Description:
	 * Test controller updateRi() method, performing updates of the
	 * existing Revenue Effect records 
     * Modifications:
     *  14.11.2022 [TB] SALEF-7482 - Introduced.
     **/ 
	@isTest
	public static void testUpdateRi(){
		List<Opportunity> lstTestOpp = [SELECT Id, Int_ktseffekt_12_m_n_Kr__c, Int_ktseffekt_12_m_n__c 
										FROM Opportunity
										WHERE Name = :TEST_OPP_NAME];
		Opportunity oppRecordBeforeUpdate = lstTestOpp[0];
		List<Revenue_Effect__c> lstTestOppRevenueEffect = [	SELECT 	Id, New_Antal__c, New_Monthly_Cost__c,
																	Old_Antal__c, Old_Monthly_Cost__c 
															FROM Revenue_Effect__c
															WHERE Opportunity__c = :lstTestOpp[0].Id];
		// Attempt to update two Revenue Effect 'New Monthly Cost's by the amounts listed below
		Decimal RENewMonthlyCostIncrement1 = 10.0;
		Decimal RENewMonthlyCostIncrement2 = 5.0;
		Map<Id, Decimal> mapRevenueEffectIdsToExpectedUpdatedNewMonthlyCostVals = new Map<Id, Decimal>();
		mapRevenueEffectIdsToExpectedUpdatedNewMonthlyCostVals.put(	lstTestOppRevenueEffect[0].Id, 
																	lstTestOppRevenueEffect[0].New_Monthly_Cost__c + RENewMonthlyCostIncrement1);
		mapRevenueEffectIdsToExpectedUpdatedNewMonthlyCostVals.put(	lstTestOppRevenueEffect[1].Id, 
																	lstTestOppRevenueEffect[1].New_Monthly_Cost__c + RENewMonthlyCostIncrement1);
		// Construct a list with records to update
		List<Revenue_Effect__c> lstRevenueEffectsToUpdate = new List<Revenue_Effect__c>();
		for(Id curRevenueEffectId : mapRevenueEffectIdsToExpectedUpdatedNewMonthlyCostVals.keySet()){
			lstRevenueEffectsToUpdate.add(new Revenue_Effect__c(
				Id = curRevenueEffectId,
				New_Monthly_Cost__c = mapRevenueEffectIdsToExpectedUpdatedNewMonthlyCostVals.get(curRevenueEffectId)));
		}

		List<User> lstTestBypassUsers = [SELECT Id FROM User WHERE username = :BYPASS_USER_USERNAME];
		Boolean isUpdateSuccessful = false;
		// Update Revenue Effects
		Test.startTest();
		System.runAs(lstTestBypassUsers[0]){
			isUpdateSuccessful = RevenueImpactCalculationController.updateRi(lstRevenueEffectsToUpdate);
		}
		Test.stopTest();

		// Verify the Revenue Effect 'New Monthly Costs' have been updated with the new values
		System.assert(isUpdateSuccessful);
		Map<Id, Revenue_Effect__c> mapUpdatedREIdsToREs = new Map<Id, Revenue_Effect__c>([	SELECT Id, New_Monthly_Cost__c 
																							FROM Revenue_Effect__c
																							WHERE Id IN :mapRevenueEffectIdsToExpectedUpdatedNewMonthlyCostVals.keySet()]);
		for(Id updatedREId : mapUpdatedREIdsToREs.keySet()){
			System.assertEquals(mapRevenueEffectIdsToExpectedUpdatedNewMonthlyCostVals.get(updatedREId), 
								(Decimal)mapUpdatedREIdsToREs.get(updatedREId).New_Monthly_Cost__c);
		}
		// Verify the Revenue Effect parent Opportunity overall Revene Impact has increased 
		// (as 'New Monthly Costs' increased and all other values and records remained unchanged)
		List<Opportunity> lstParentOppAfterRevenueEffectUpdate = [	SELECT Id, Int_ktseffekt_12_m_n_Kr__c, Int_ktseffekt_12_m_n__c 
																	FROM Opportunity
																	WHERE Id = :oppRecordBeforeUpdate.Id];
		System.assert(lstParentOppAfterRevenueEffectUpdate[0].Int_ktseffekt_12_m_n__c > oppRecordBeforeUpdate.Int_ktseffekt_12_m_n__c);
	}

	/**@Description:
	 * Test controller updateRi() method, trying to update
	 * existing Revenue Effect records with invalid/empty values
     * Modifications:
     *  14.11.2022 [TB] SALEF-7482 - Introduced.
     **/ 
	@isTest
	public static void testUpdateRiWithEmptyValues(){
		List<Opportunity> lstTestOpp = [SELECT Id, Int_ktseffekt_12_m_n_Kr__c, Int_ktseffekt_12_m_n__c 
										FROM Opportunity
										WHERE Name = :TEST_OPP_NAME];
		List<Revenue_Effect__c> lstTestOppRevenueEffect = [	SELECT 	Id, New_Antal__c, New_Monthly_Cost__c,
																	Old_Antal__c, Old_Monthly_Cost__c 
															FROM Revenue_Effect__c
															WHERE Opportunity__c = :lstTestOpp[0].Id];
		// Attempt to update a Revenue Effect 'Monthly Cost's with empty values, which is not a valid update
		Revenue_Effect__c revenueEffectBeforeUpdate = lstTestOppRevenueEffect[0];
		List<Revenue_Effect__c> lstRevenueEffectsToUpdate = new List<Revenue_Effect__c>();
		lstRevenueEffectsToUpdate.add(new Revenue_Effect__c(	Id = revenueEffectBeforeUpdate.Id,
																New_Monthly_Cost__c = null,
																Old_Monthly_Cost__c = null));

		List<User> lstTestBypassUsers = [SELECT Id FROM User WHERE username = :BYPASS_USER_USERNAME];

		// Attempt the invalid Revenue Effect update
		Test.startTest();
		System.runAs(lstTestBypassUsers[0]){
			// For now, update will simply not update/skip the invalid/empty field values,
			// but the returned boolean will remain true
			RevenueImpactCalculationController.updateRi(lstRevenueEffectsToUpdate);
		}
		Test.stopTest();

		List<Revenue_Effect__c> lstUpdatedREs = [	SELECT Id, New_Monthly_Cost__c, Old_Monthly_Cost__c
													FROM Revenue_Effect__c
													WHERE Id = :revenueEffectBeforeUpdate.Id];

		// Ensure the Revenue Effect has not been updated with invalid values
		System.assertEquals(revenueEffectBeforeUpdate.New_Monthly_Cost__c, lstUpdatedREs[0].New_Monthly_Cost__c);
		System.assertEquals(revenueEffectBeforeUpdate.Old_Monthly_Cost__c, lstUpdatedREs[0].Old_Monthly_Cost__c);
	}

	/**@Description:
	 * Test controller deleteRecord() method, deleting a single Revenue Effect record
     * Modifications:
     *  14.11.2022 [TB] SALEF-7482 - Introduced.
     **/ 
	@isTest
	public static void testDeleteRecord(){
		List<Opportunity> lstTestOpp = [SELECT Id, Int_ktseffekt_12_m_n_Kr__c, Int_ktseffekt_12_m_n__c 
										FROM Opportunity
										WHERE Name = :TEST_OPP_NAME];
		Opportunity oppBeforeREDeletion = lstTestOpp[0];
		List<Revenue_Effect__c> lstTestOppRevenueEffect = [	SELECT Id 
															FROM Revenue_Effect__c
															WHERE Opportunity__c = :lstTestOpp[0].Id];

		List<User> lstTestBypassUsers = [SELECT Id FROM User WHERE username = :BYPASS_USER_USERNAME];
		String successMsg;
		// Delete a single Revenue Effect record
		Test.startTest();
		System.runAs(lstTestBypassUsers[0]){
			successMsg = RevenueImpactCalculationController.deleteRecord(lstTestOppRevenueEffect[0].Id);
		}
		Test.stopTest();

		// Verify that a single Revenue Effect has been deleted
		List<AggregateResult> lstRevenueEffectAggregate = [	SELECT COUNT(Id) numRevenueEffects
															FROM Revenue_Effect__c
															WHERE Opportunity__c = :lstTestOpp[0].Id];
		System.assertEquals(lstTestOppRevenueEffect.size() - 1, lstRevenueEffectAggregate[0].get('numRevenueEffects'));

		// Verify that the Opportunity summary fields have been updated upon the Revenue Effect deletion
		List<Opportunity> lstParentOppAfterREDeletion = [	SELECT Id, Int_ktseffekt_12_m_n_Kr__c, Int_ktseffekt_12_m_n__c 
															FROM Opportunity
															WHERE Id = :oppBeforeREDeletion.Id];
		System.assertNotEquals(oppBeforeREDeletion.Int_ktseffekt_12_m_n_Kr__c, lstParentOppAfterREDeletion[0].Int_ktseffekt_12_m_n__c);
	}

	/**@Description:
	 * Test controller saveRevenueImpact() method,
	 * attempting to create a valid Revenue Effect record
     * Modifications:
     *  14.11.2022 [TB] SALEF-7482 - Introduced.
     **/ 
	@isTest
	public static void testSaveRevenueImpact_Success(){
		List<Opportunity> lstTestOpp = [SELECT Id 
										FROM Opportunity
										WHERE Name = :TEST_OPP_NAME];
		List<AggregateResult> lstRevenueEffectAggregateBeforeInsertion = [	SELECT COUNT(Id) numRevenueEffects
																			FROM Revenue_Effect__c
																			WHERE Opportunity__c = :lstTestOpp[0].Id];
		// Query a Revenue Effect with all fields required for a successful insertion,
		// and (shallow) clone the record to create a Revenue Effect to insert
		List<Revenue_Effect__c> lstRevenueEffectsWithAllReqFields = helperSOQLQueryRevenueEffectWithAllReqFields(lstTestOpp[0].Id);
		Revenue_Effect__c newRevenueEffectToInsert = lstRevenueEffectsWithAllReqFields[0].clone();
		List<Revenue_Effect__c> lstRevenueEffectsToInsert = new List<Revenue_Effect__c>{newRevenueEffectToInsert};

		List<User> lstTestBypassUsers = [SELECT Id FROM User WHERE username = :BYPASS_USER_USERNAME];
		// Attempt to insert a valid Revenue Effect
		Test.startTest();
		System.runAs(lstTestBypassUsers[0]){
			RevenueImpactCalculationController.saveRevenueImpact(lstRevenueEffectsToInsert);
		}
		Test.stopTest();

		// Verify that a single Revenue Effect has been inserted
		List<AggregateResult> lstRevenueEffectAggregateAfterInsertion = [	SELECT COUNT(Id) numRevenueEffects
																			FROM Revenue_Effect__c
																			WHERE Opportunity__c = :lstTestOpp[0].Id];
													
		System.assertEquals((Integer)lstRevenueEffectAggregateBeforeInsertion[0].get('numRevenueEffects') + 1, 
							(Integer)lstRevenueEffectAggregateAfterInsertion[0].get('numRevenueEffects'));
	}

	/**@Description:
	 * Test controller saveRevenueImpact() method,
	 * attempting to create a Revenue Effect record with field values not valid for insertion
     * Modifications:
     *  14.11.2022 [TB] SALEF-7482 - Introduced.
     **/
	@isTest
	public static void testSaveRevenueImpact_InvalidRecordFailure(){
		List<Opportunity> lstTestOpp = [SELECT Id 
										FROM Opportunity
										WHERE Name = :TEST_OPP_NAME];
		List<AggregateResult> lstRevenueEffectAggregateBeforeInsertion = [	SELECT COUNT(Id) numRevenueEffects
																			FROM Revenue_Effect__c
																			WHERE Opportunity__c = :lstTestOpp[0].Id];
		// Query a Revenue Effect with all fields required for a successful insertion,
		// and (shallow) clone the record to create a Revenue Effect to insert. 
		List<Revenue_Effect__c> lstRevenueEffectsWithAllReqFields = helperSOQLQueryRevenueEffectWithAllReqFields(lstTestOpp[0].Id);
		Revenue_Effect__c newRevenueEffectToInsert = lstRevenueEffectsWithAllReqFields[0].clone();

		// Clear some of the fields required to have a value for a successful insertion
		if(RevenueImpactCalculationController.lstRevenueEffectFieldApiNamesRequiredUponInsertion.size() > 0){
			newRevenueEffectToInsert.put(RevenueImpactCalculationController.lstRevenueEffectFieldApiNamesRequiredUponInsertion[0], null);
		}
		List<Revenue_Effect__c> lstRevenueEffectsToInsert = new List<Revenue_Effect__c>{newRevenueEffectToInsert};

		List<User> lstTestBypassUsers = [SELECT Id FROM User WHERE username = :BYPASS_USER_USERNAME];
		// Attempt to insert a Revenue Effect invalid due to a missing field value 
		Test.startTest();
		System.runAs(lstTestBypassUsers[0]){
			try{
				RevenueImpactCalculationController.saveRevenueImpact(lstRevenueEffectsToInsert);
				System.assert(	false, 
								'Attempt to insert a Revenue Effect with a missing value in a field required upon creation '
								+ 'should have generated an error.');
			} catch(Exception curException){
				// Thrown exception is the expected behavior.
				System.assert(true);
			}
		}
		Test.stopTest();

		// Verify that a Revenue Effect has not been inserted
		List<AggregateResult> lstRevenueEffectAggregateAfterInsertAttempt = [	SELECT COUNT(Id) numRevenueEffects
																				FROM Revenue_Effect__c
																				WHERE Opportunity__c = :lstTestOpp[0].Id];
													
		System.assertEquals((Integer)lstRevenueEffectAggregateBeforeInsertion[0].get('numRevenueEffects'), 
							(Integer)lstRevenueEffectAggregateAfterInsertAttempt[0].get('numRevenueEffects'));
	}
	
	/**@Description:
	 * Test controller saveRevenueImpact() method,
	 * attempting to create a Revenue Effect record with an issue causing 
	 * a DML error to be thrown 
     * Modifications:
     *  14.11.2022 [TB] SALEF-7482 - Introduced.
     **/
	@isTest
	public static void testSaveRevenueImpact_DMLOperationFailure(){
		List<Opportunity> lstTestOpp = [SELECT Id 
										FROM Opportunity
										WHERE Name = :TEST_OPP_NAME];
		List<AggregateResult> lstRevenueEffectAggregateBeforeInsertion = [	SELECT COUNT(Id) numRevenueEffects
																			FROM Revenue_Effect__c
																			WHERE Opportunity__c = :lstTestOpp[0].Id];
		// Query a Revenue Effect with all fields required for a successful insertion,
		// and (shallow) clone the record to create a Revenue Effect to insert. 
		List<Revenue_Effect__c> lstRevenueEffectsWithAllReqFields = helperSOQLQueryRevenueEffectWithAllReqFields(lstTestOpp[0].Id);
		Revenue_Effect__c newRevenueEffectToInsert = lstRevenueEffectsWithAllReqFields[0].clone();

		// Set an invalid dependent picklist field value for the record to be inserted
		newRevenueEffectToInsert.Sub_Category__c = 'InvalidValue';
		List<Revenue_Effect__c> lstRevenueEffectsToInsert = new List<Revenue_Effect__c>{newRevenueEffectToInsert};

		List<User> lstTestBypassUsers = [SELECT Id FROM User WHERE username = :BYPASS_USER_USERNAME];
		// Attempt to insert a Revenue Effect invalid due to an invalid dependent picklist field value 
		// (any issue causing an unsuccessful DML operation would work) 
		Test.startTest();
		System.runAs(lstTestBypassUsers[0]){
			try{
				RevenueImpactCalculationController.saveRevenueImpact(lstRevenueEffectsToInsert);
				System.assert(	false, 
								'Attempt to insert a Revenue Effect with an invalid dependent picklist value must have thrown an exception.');
			} catch(Exception curException){
				// Thrown exception is the expected behavior.
				System.assert(true);
			}
		}
		Test.stopTest();

		// Verify that a Revenue Effect has not been inserted
		List<AggregateResult> lstRevenueEffectAggregateAfterInsertAttempt = [	SELECT COUNT(Id) numRevenueEffects
																				FROM Revenue_Effect__c
																				WHERE Opportunity__c = :lstTestOpp[0].Id];
													
		System.assertEquals((Integer)lstRevenueEffectAggregateBeforeInsertion[0].get('numRevenueEffects'), 
							(Integer)lstRevenueEffectAggregateAfterInsertAttempt[0].get('numRevenueEffects'));
	}

	/**@Description:
	 * Helper calculation method
	 * @param revenueEffect - Revenue Effect record
     * @return Calculation result
	 * Modifications:
     *  14.11.2022 [TB] SALEF-7482 - Introduced.
     **/
	public static Decimal helperCalculateNewAmount(Revenue_Effect__c revenueEffect){
		return (revenueEffect.New_Antal__c * revenueEffect.New_Monthly_Cost__c * 12);
	}

	/**@Description:
	 * Helper calculation method
	 * @param revenueEffect - Revenue Effect record
     * @return Calculation result
	 * Modifications:
     *  14.11.2022 [TB] SALEF-7482 - Introduced.
     **/
	public static Decimal helperCalculateOldAmount(Revenue_Effect__c revenueEffect){
		return (revenueEffect.Old_Antal__c * revenueEffect.Old_Monthly_Cost__c * 12);
	}

	/**@Description:
	 * Helper method querying a Revenue Effect with all the fields required for a successful
	 * record insertion. Used to create a new valid Revenue Effect to insert by cloning the
	 * returned record.
	 * @param parentOppId - Id of the REs parent Opportunity
     * @return - List containing a single Revenue Effects with all fields required upon insertion 
	 * Modifications:
     *  14.11.2022 [TB] SALEF-7482 - Introduced.
     **/
	public static List<Revenue_Effect__c> helperSOQLQueryRevenueEffectWithAllReqFields(Id parentOppId){
		String revenueEffectSOQLQueryWithReqFields = 'SELECT Id';
		for(String reqFieldApiName : RevenueImpactCalculationController.lstRevenueEffectFieldApiNamesRequiredUponInsertion){
			revenueEffectSOQLQueryWithReqFields += (', ' + reqFieldApiName);
		}
		revenueEffectSOQLQueryWithReqFields += (', Opportunity__c ');
		revenueEffectSOQLQueryWithReqFields += 	'FROM Revenue_Effect__c '
												+ 'WHERE Opportunity__c = :parentOppId ' 
												+ 'LIMIT 1';
		return (List<Revenue_Effect__c>)Database.query(revenueEffectSOQLQueryWithReqFields);
	}
}