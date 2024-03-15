/**
 * Created by kwn687 on 2021-09-21.
 */

public with sharing class ContractAftermarketTabController {
    public ApexPages.StandardController controllerStand;
    public String commentaryVarOutput { get; set; }
    public String commentaryVarInput { get; set; }
    public Boolean saveCancelButton { get; set; }
    public contractAftermarketTabController(ApexPages.StandardController sc) {
        commentaryVarOutput = 'Block';
        commentaryVarInput = 'none';
        saveCancelButton = false;
        controllerStand = sc;
    }
    public PageReference commentary() {
        commentaryVarInput = 'Block';
        commentaryVarOutput = 'none';
        saveCancelButton = true;
        return null ;
    }
    public PageReference cancel() {
        commentaryVarOutput = 'Block';
        commentaryVarInput = 'none';
        saveCancelButton = false;
        return null ;
    }
    public PageReference save() {
        controllerStand.save();
        commentaryVarOutput = 'Block';
        commentaryVarInput = 'none';
        saveCancelButton = false;
        return null ;
    }

}