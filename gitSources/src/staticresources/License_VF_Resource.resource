PK
     b_�J               css/PK
     DW�JZ'��  �     css/LicenseVF.css.success {
    padding: 20px;
    background-color: #8bc34a;
    color: black;
    text-align: center;
}
.error {
    padding: 20px;
    background-color: #f44336;
    color: black;
    text-align: center;
}
.saveButton {
    text-align: center;
}
.warning {
    background: red;
    color: black;
}
.checkRed {

        background: red;
    
}
    
.checkGreen {

	background: green;

}
.userLabelDiv {
    color: #6E2C6B !important;
    font-weight: bold;
}
.selaLabelTd {
    color: #6E2C6B !important;
    font-weight: bold;
    text-align: center !important;
}
.subTotal{ 
    background:rgba(158, 158, 158, 0.46);
}

/*.userTable thead {*/
    /*display: block;*/
/*}*/
/*.userTable tbody {*/
/*    height: 300px;*/
/*    overflow-y: scroll;*/
    /*display: block;*/
    
/*}*/
/*table {*/
    /*width: 100%; */
/*}*/
/*.userTdBody {*/
    
/*}*/
PK
     b_�J               js/PK
     ��Jv�$�   �      js/LicenseVF.jsvar app = angular.module('MyApp', ['ngSanitize']).config(function($locationProvider) {
    $locationProvider.html5Mode({
        enabled: true,
        requireBase: false
    });
});
app.controller('myController', ['$scope', '$rootScope', '$sce', '$window', '$location', function($scope, $rootScope, $sce, $window, $location) {
    $scope.currentUser = $window.currentUser;
    $scope.labelSela = $window.labelSela;
    $scope.labelUser = $window.labelUser;
    $scope.fieldSelaSet = $window.fieldSelaSet;
    $scope.fieldUserSet = $window.fieldUserSet;
    $rootScope.spinner = true;
    $scope.messages = $window.messages;
    $scope.remoteActionInit = $window.remoteActionInit;
    $scope.remoreActionSave = $window.remoreActionSave;
    $scope.isPartner = false;
    $scope.data = null;
    $scope.exceptionFieldSet = {};
    $scope.oldUserMap = {};
    
    /*init function*/
    $scope.init = function() {
        var ownerUrl = $location.search().ownerId;
        var ownerId = typeof(ownerUrl) != 'undefined' ? ownerUrl : $scope.currentUser;
        Visualforce.remoting.Manager.invokeAction($scope.remoteActionInit, ownerId, function(result, event) {
            $scope.$apply(function() {
                $scope.data = result;
                $rootScope.spinner = false;
                for (var i = 0; i < $scope.data['Users'].length; i++) {
                    console.log($scope.data['Users'][i].Contact);
                    var item = $scope.data['Users'][i];
                    $scope.isPartner = (typeof(item.Contact) !== 'undefined');
                    //if ($scope.isPartner) break;
                    $scope.oldUserMap[item.Id] = item.IsActive;
                }
                console.log($scope.data);
            });
        });
        
    } /* function get field in low level */
    $scope.getField = function(item, field) {
        var path = field.split('.');
        var value = item;
        for (var i = 0; i < path.length; i++) {
            if (value == null) {
                break;
            }
            
            value = value[path[i]];
        }
        return value;
    } /*Save fanction*/
    $scope.save = function() {
        var ownerUrl = $location.search().ownerId;
        var ownerId = typeof(ownerUrl) != 'undefined' ? ownerUrl : $scope.currentUser;
        $scope.message = null;
        $scope.maxLicenses = $scope.data['Sela__c'][0].NumberOfLicenseNew__c;
        $scope.sum = 0;
        console.log($scope.maxLicenses); 
        var selectedLicensePerProfile = {};
        /*validatian check sum Active users */
        for (var i = 0; i < $scope.data['Sela__c'][0].Sela_Roles__r.length; i++) {
            for (var j = 0; j < $scope.data['Users'].length; j++) {
                if ($scope.data['Users'][j].IsActive && ($scope.data['Users'][j].UserRole.DeveloperName == $scope.data['Sela__c'][0].Sela_Roles__r[i].Name || 
                    $scope.data['Users'][j].Profile.Id == $scope.data['Sela__c'][0].Sela_Roles__r[i].Id)) {
                    $scope.sum++;
                    /*if($scope.maxLicenses < $scope.sum) {
                        break;
                    }*/
                    var profileId = $scope.data['Users'][j].Profile.Name;
                    if (!(profileId in selectedLicensePerProfile)) selectedLicensePerProfile[profileId] = 0;
                    selectedLicensePerProfile[profileId] ++;
                }
            }
        }
        // precheck all profiles
        var isFoundError = false;
        for (itemInd in $scope.data['Sela__c'][0].SelaProfiles__r) {
            //for (var key in selectedLicensePerProfile) {
                console.log(item);
                var item = $scope.data['Sela__c'][0].SelaProfiles__r[itemInd];
                item.NumberOfUsedLicensesNew__c = selectedLicensePerProfile[item.Name];
                item.UsedLicenses__c = (item.NumberOfUsedLicensesNew__c / item.NumberOfLicenses__c) * 100;
                isFoundError = isFoundError || (item.NumberOfUsedLicensesNew__c > item.NumberOfLicenses__c)
                console.log(item, item.NumberOfUsedLicensesNew__c);
            //}
        }
        
        if ($scope.maxLicenses < $scope.sum || isFoundError) {
            $scope.messageType = 'error';
            $scope.message = $scope.messages[3];
            $rootScope.spinner = false;
        } else {
            var tmpToSent = {Users: [], Sela__c:[]};
            var tmp = JSON.parse(angular.toJson($scope.data));
            delete Sela__c;
            //populate list with relevant users 
            for (var j = 0; j < tmp.Users.length; j++) {
                if (tmp.Users[j].IsActive != $scope.oldUserMap[tmp.Users[j].Id]) {
                    tmpToSent.Users.push(tmp.Users[j]);
                    $scope.oldUserMap[tmp.Users[j].Id] = tmp.Users[j].IsActive;
                }
            }
            
            //console.log(tmpToSent);
            if (tmpToSent.Users.length === 0 ) {
                $scope.messageType = 'error';
                $scope.message = $scope.messages[8];
                return;
            } else if (tmpToSent.Users.length >200) {
                $scope.messageType = 'error';
                $scope.message = $scope.messages[9];
                return;
            }
            
            $rootScope.spinner = true;
            
            Visualforce.remoting.Manager.invokeAction($scope.remoreActionSave, angular.toJson(tmpToSent), ownerId, true, function(result, event) {
                $scope.$apply(function() {
                    // console.log(angular.toJson(tmpToSent));
                    if(result != null) {
                        $scope.data = result;
                        Visualforce.remoting.Manager.invokeAction($scope.remoreActionSave, angular.toJson(tmpToSent), ownerId, false, function(result, event) {
                            $scope.$apply(function() {
                                // console.log(angular.toJson(tmpToSent));
                                if(result != null) {
                                    $scope.data = result;
                                    $scope.messageType = 'success'; 
                                    /*check if we have 90% used licenses */
                                    if ($scope.data['Sela__c'][0].UsedLicenses__c >= 90) {
                                        /* check if we have 100% of used licenses */
                                        if ($scope.data['Sela__c'][0].UsedLicenses__c == 100) {
                                            $scope.messageType = 'error';
                                            $scope.message = $scope.messages[7] + ' ' + $scope.data['Sela__c'][0].UsedLicenses__c + '%';
                                        } else {
                                            $scope.message = $scope.messages[2] +
                                            ' ' + $scope.messages[4] + 
                                            ' ' + $scope.data['Sela__c'][0].UsedLicenses__c + '%';
                                        }
                                    }
                                    else {
                                        $scope.message = $scope.messages[2];
                                    }
                                    $rootScope.spinner = false;
                                } else {
                                    $scope.messageType = 'error';
                                    $scope.message = $scope.messages[6];
                                    $rootScope.spinner = false;
                                }
                            });
                        });
                    } else {
                        console.log('User');
                        $scope.messageType = 'error';
                        $scope.message = $scope.messages[5];
                        $rootScope.spinner = false;
                    }
                });
                
            });
        }
    } /* checked all checkbox or unchecked */
    $scope.checkAll = function(param) {
        for (var j = 0; j < $scope.result.length; j++) {
            $scope.result[j].IsActive = param;
        }
    };
    
    // $scope.checkTd = function(param) {
    //     var elem = angular.element(document.getElementById('container').wight);
    //     console.log(elem);
    // };
    $scope.init();
}]);PK 
     b_�J                            css/PK 
     DW�JZ'��  �               "   css/LicenseVF.cssPK 
     b_�J                        �  js/PK 
     ��Jv�$�   �                  js/LicenseVF.jsPK      �   �$    