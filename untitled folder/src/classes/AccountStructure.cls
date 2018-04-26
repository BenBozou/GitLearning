global with sharing class AccountStructure {

    private static Account[] accLst;
    private static Boolean showMessage;
    private static integer maxLimit = 2000;

    public AccountStructure(ApexPages.StandardController stdCtrl) {
    }

    private static Id getParentNode(id curAccId) {
        Id parentId = null;
        Account A = [
            SELECT Id, ParentId, Name,
            Parent.Parent.Parent.Parent.Parent.ParentId,
            Parent.Parent.Parent.Parent.ParentId,
            Parent.Parent.Parent.ParentId,
            Parent.Parent.ParentId,
            Parent.ParentId

            FROM Account
            WHERE Id= : curAccId
        ];
        Account tmp = A;
        for (Integer I=0; I<5; I++) {
            if (tmp.Parent!=null) tmp = tmp.Parent;
            else {
                system.debug(LoggingLevel.Error, I);
                parentId = tmp.Id;
                break;
            }
        }
        if (parentId == null) parentId = getParentNode(tmp.Id);
        system.debug(LoggingLevel.Error,parentId);
        return parentId;
    }

    private static void genTree(set<id> rootId) {
        //AggregateResult[] counter= [SELECT count(Id) myCount FROM Account WHERE ParentId IN :rootId OR (Id IN :rootId AND ParentId=null)];
        //if ((Integer) counter[0].get('myCount') >= maxLimit) showMessage=true;
        map<id, Account> tmp = new map<id, Account>([SELECT Id, Name, ParentId, RecordType.DeveloperName FROM Account WHERE ParentId IN :rootId OR (Id IN :rootId AND ParentId=null) LIMIT 501]);
        accLst.addAll(tmp.values());
        if (tmp.keyset().size() > 0) {
            for (id item : tmp.keyset()) {
                if (tmp.get(item).ParentId == null) tmp.remove(item);
            }
            genTree(tmp.keyset());
        }

    }


    @RemoteAction
    global static String getAccounts(String rootId) {
        accLst = new Account[]{};

        Id realRootId = getParentNode(rootId);
        genTree(new set<Id>{realRootId});
        accLst[0].CELL_Ind__c = showMessage;
        return JSON.serialize(accLst);
    }

    /* Additional implementation accordingly PLR-1530*/

    private static void genTreeNew(set<id> rootId) {
        //AggregateResult[] counter= [SELECT count(Id) myCount FROM Account WHERE ParentId IN :rootId OR (Id IN :rootId AND ParentId=null)];
        //if ((Integer) counter[0].get('myCount') > 500) showMessage=true;
        map<id, Account> tmp = new map<id, Account>([SELECT Id, Name, ParentId, CELL_Ind__c, NETV_Ind__c, BANPSID__c, NVID__c, RecordType.DeveloperName FROM Account WHERE ((id IN:rootId AND ParentId=null) OR ParentId IN:rootId) AND (RecordType.DeveloperName='Business' OR RecordType.DeveloperName='Billing' OR RecordType.DeveloperName='BusinessAggregator') ORDER BY CreatedDate]); //ORDER BY RecordType.DeveloperName, CELL_IND__C, NETV_IND__C
        accLst.addAll(tmp.values());
        if (tmp.keyset().size() > 0) {
            for (id item : tmp.keyset()) {
                if (tmp.get(item).ParentId == null) tmp.remove(item);
            }
            genTreeNew(tmp.keyset());
        }

    }

    @RemoteAction
    global static String getAccountsNew(String rootId) {
        accLst = new Account[]{};

        Id realRootId = getParentNode(rootId);
        genTreeNew(new set<Id>{realRootId});
        //accLst[0].CELL_Ind__c = showMessage;
        Account[] accTmp = new Account[]{};

        if (accLst.size()>=maxLimit) {
            for (Integer i=0; i<=maxLimit; i++) {
                accTmp.add(accLst[i]);
            }
            accLst = accTmp;
        }
        return JSON.serialize(accLst);
    }

}