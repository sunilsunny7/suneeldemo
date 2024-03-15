global class TeliaSE_CustomLabel implements vlocity_cmt.VlocityOpenInterface2{
global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {

Boolean result = true;
if(methodName.equals('CustomLabel')){
TeliaSE_CustomLabel.CustomLabel();
Map<String, Object> CL = CustomLabel();
outMap.put('CL',CL);
}
else{
result = false;
}
return result;
}
global static Map<String, Object> CustomLabel()
{

Map<String,object> CustomlabelMap = new Map<String,object>();
string Re = system.label.TeliaSE_Ren;
string SF = system.label.TeliaSE_SFAgreement;
string MADAM = system.label.TeliaSE_MADAMAgree;
string Agreement = system.label.TeliaSE_Agreement_duration;
string end1 = system.label.TeliaSE_end;
string Switching = system.label.TeliaSE_Switching_solution;
string Owner = system.label.TeliaSE_Owner;
string LEVEL = system.label.TeliaSE_LEVEL;
string TYPE1 = system.label.TeliasSE_Type;
string Start = system.label.TeliaSE_Start;
string Valid = system.label.TeliaSE_Valid_Switching_Solu;
string Agreement1 = system.label.TeliaSE_Agreement_status_MADAM;
string Utiliser = system.label.TeliaSE_Utiliser_counts;
string Sub = system.label.TeliaSE_Sub_agreements_exists;
string Priceplan = system.label.TeliaSE_Priceplan0;
string MiniDeb = system.label.TeliaSE_MC_MiniDeb_Mobile;
string Touchpoint = system.label.TeliaSE_MC_MiniDeb_Touchpoint;
string TeliaSE_Tuppinfo1 = system.label.TeliaSE_Tuppinfo1;
string TeliaSE_Tuppinfo2 = system.label.TeliaSE_Tuppinfo2;
string TeliaSE_Tuppinfo3 = system.label.TeliaSE_Tuppinfo3;
string TeliaSE_Tuppinfo4 = system.label.TeliaSE_Tuppinfo4;
string TeliaSE_Tuppinfo5 = system.label.TeliaSE_Tuppinfo5;
string TeliaSE_Tuppinfo6 = system.label.TeliaSE_Tuppinfo6;
string TeliaSE_Tuppinfo7 = system.label.TeliaSE_Tuppinfo7;
string TeliaSE_Tuppinfo8 = system.label.TeliaSE_Tuppinfo8;
string TeliaSE_Tuppinfo9 = system.label.TeliaSE_Tuppinfo9;
string TeliaSE_TuppLink = system.label.TeliaSE_TuppLink;
string TeliaSE_MC_MiniDebWarningMessage = system.label.TeliaSE_MC_MiniDebWarningMessage;
string TeliaSE_MC_SubAgreementWarningMessage = system.label.TeliaSE_MC_SubAgreementWarningMessage;
string TeliaSE_MC_SubAgreementWarningMessage2 = system.label.TeliaSE_MC_SubAgreementWarningMessage2;
string TeliaSE_TuppHead = system.label.TeliaSE_TuppHead;
string TeliaSE_TuppHead1 = system.label.TeliaSE_TuppHead1;

CustomlabelMap.put('Renegotiation',Re);
CustomlabelMap.put('SFAgreement',SF);
CustomlabelMap.put('MADAMagree',MADAM);
CustomlabelMap.put('AgreementDuration',Agreement);
CustomlabelMap.put('End',end1);
CustomlabelMap.put('SwitchingSolution',Switching);
CustomlabelMap.put('Owner',Owner);
CustomlabelMap.put('LEVEL', LEVEL);
CustomlabelMap.put('TYPE',TYPE1);
CustomlabelMap.put('Start',Start);
CustomlabelMap.put('ValidswitchingsolutiontorenegotiateinSF',Valid);
CustomlabelMap.put('Agreementstatus',Agreement1);
CustomlabelMap.put('UtiliserCounts',Utiliser);
CustomlabelMap.put('SubAgreementsExists',Sub);
CustomlabelMap.put('Priceplan',Priceplan);
CustomlabelMap.put('MiniDeb',MiniDeb);
CustomlabelMap.put('MiniDebTP',Touchpoint);
CustomlabelMap.put('TeliaSE_Tuppinfo1',TeliaSE_Tuppinfo1);
CustomlabelMap.put('TeliaSE_Tuppinfo2',TeliaSE_Tuppinfo2);
CustomlabelMap.put('TeliaSE_Tuppinfo3',TeliaSE_Tuppinfo3);
CustomlabelMap.put('TeliaSE_Tuppinfo4',TeliaSE_Tuppinfo4);
CustomlabelMap.put('TeliaSE_Tuppinfo5',TeliaSE_Tuppinfo5);
CustomlabelMap.put('TeliaSE_Tuppinfo6',TeliaSE_Tuppinfo6);
CustomlabelMap.put('TeliaSE_Tuppinfo7',TeliaSE_Tuppinfo7);
CustomlabelMap.put('TeliaSE_Tuppinfo8',TeliaSE_Tuppinfo8);
CustomlabelMap.put('TeliaSE_Tuppinfo9',TeliaSE_Tuppinfo9);
CustomlabelMap.put('TeliaSE_TuppLink',TeliaSE_TuppLink);
CustomlabelMap.put('TeliaSE_MC_MiniDebWarningMessage',TeliaSE_MC_MiniDebWarningMessage);
CustomlabelMap.put('TeliaSE_MC_SubAgreementWarningMessage',TeliaSE_MC_SubAgreementWarningMessage);
CustomlabelMap.put('TeliaSE_MC_SubAgreementWarningMessage2',TeliaSE_MC_SubAgreementWarningMessage2);
CustomlabelMap.put('TeliaSE_TuppHead',TeliaSE_TuppHead);
CustomlabelMap.put('TeliaSE_TuppHead1',TeliaSE_TuppHead1);



return CustomlabelMap;

}
}