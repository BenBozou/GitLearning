PK
     Yn�J               css/PK
     dj�JX�{�       css/AssignmentTable.css.hotLeadAndExist {
            background-color: #404040;
        }
        
        .hotLeadAndExistHead {
            background-color: #404040;
            color: #FDC82F;
        }
        .hotLead {
            background-color: #404040;
            color: #FDC82F;
        }
        .potnLead {
            background-color: #404040;
            color: #FDC82F;
        }
        .existLead {
            background-color: #404040;
            color: #FDC82F;
        }
        
        .userRoleAndUser {
            background-color: #6E2C6B;
            color: white !important;
            
        }
        
        .userRoleAndUserName {
            color: white !important;
            
            
        }
        
        .userRoleHeader {
            background-color: #6E2C6B !important;
            color: #FFFFFF;
        }
        
        .quantityHeader {
            background-color: #964893 !important;
            color: #FFFFFF;
            text-align: center;
        }
        
        input[type='checkbox'] {
            
        }
        .used {
            background-color: #BFBFBF;
        }
        
        .products {
            background-color: #FFFFFF;
        }
        
        .quantityRec {
            color: #FFFFFF!important;
            background-color: #964893;
            text-align: center;
        }
        .quantityCol {
            color: #FFFFFF!important;
            background-color: #964893;
            text-align: center;
        }
        
        .productHeader {
            color: #6E2C6B;
        }
        
        .tableClass th {
            padding-left: 10px;
            padding-top: 10px;
            padding-right: 10px;
            //white-space: pre-line;
            border-bottom:1px solid #F0F0F0;
            text-align: center;
            vertical-align: top;
        }
        
        .tableClass td {
            padding: 15px;
            border-bottom:1px solid #F0F0F0;
            text-align: center;
        }
        
        .btn.divButton {
            background: #6E2C6B;
            color: white;
            outline: none;
            border-radius: 10px;
            margin: 30px;
            padding: 1px 35px;
            font-size: 15px;
        }
        
        .btn.resetButton {
            position: relative;
            border-radius: 10px;
            color: #8C288C;
            border: none;
            outline: none;
            background: #ffffff;
            font-size: 15px;
        }
        
        .btn.saveButton {
            background: #6E2C6B;
            color: white;
            outline: none;
            border-radius: 10px;
            padding: 1px 35px;
            font-size: 15px;
            position: relative;
        }
        
        .top {
            display: flex;
        }
        
        .userName {
            padding: 5px;
            color: #404040;
            font-size: 15px;
            font-weight: bold
        }
        
        .quantity {
            padding: 5px;
            position: relative;
            right: 400px;
            color: #404040;
            font-size: 15px;
            font-weight: bold
        }
        
        .roleName {
            padding: 5px;
            position: relative;
            right: 200px;
            color: #404040;
            font-size: 15px;
            font-weight: bold
        }
        
        .ssOverlay {
            width: 100%;
            height: 100%;
            position: fixed;
            top: 0px;
            left: 0px;
            z-index: 1000;
            vertical-align: middle;
            font-weight: bold;
            font-size: 12pt;
            color: red;
            line-height: 2em;
            display: none;
            text-align: center;
            opacity: 0.75;
            background-color: #ffffff !important;
        }
        
        .ssText {
            display: table-cell;
            vertical-align: middle;
        }
        
        .contactBlock>div {
            background-color: #ffffff !important;
        }

	thead {
            vertical-align: bottom;
        }

        th.used, th.userRoleHeader, th.quantityHeader {
           
        }
        
        .table-wrapper-small { 
            overflow-x:auto;
            overflow-y:auto;
            width:650px;
        }
        
        .mainTable {
            width:100%;
        }
        .firstTd {
            width: 1%;
        }
        .secondTd {
            width: 50%;
        }
        tr {
            height:55px;
        }
        td {
            white-space: nowrap;
        }
        .roleList {
            padding: 5px;
        }
       PK
     Yn�J               js/PK
     <r�J@�O2^  ^     js/AssignmentTable.js﻿ function addCommas(nStr) {
    nStr+= '';
    x = nStr.split('.');
    x1 = x[0];
    x2 = x.length > 1 ? '.' + x[1] : '';
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1)) {
        x1 = x1.replace(rgx, '$1' + ',' + '$2');
    }
    return x1 + x2;
  }
    
  jQuery(document).ready(function(){
     var sum = 0;
     jQuery('input[type="text"]').each(function(el,ind){
         sum += Number(jQuery(this).val());
     });
     jQuery('[id$="totalQuantity"').text(addCommas(globalQuantity - sum)); 
     var wd = ($('[id$="frm"]').width() < $('.tableClass').width());
     if (wd) { 
         $('[id$="frm"]').css('width', $('.tableClass').width() + 30 + 'px');
     } 
 });
 
 var div = function() {
         var value = Number(globalQuantity) / $('.quantityRec').length;
         console.log(Math.floor(value));
         console.log(value%1);
         if (value%1 < 1) {
             value = Math.floor(value);
         }
         jQuery('.quantityRec').val(value);
         value = value * $('.quantityRec').length;
         jQuery('[id$="totalQuantity"').text(addCommas(Number(globalQuantity)-value));
         jQuery(".saveButton").show();
       
 }
 
 var resetFunc = function() {
        jQuery('.quantityRec').val(0);
        jQuery('[id$="totalQuantity"').text(addCommas(globalQuantity));
        jQuery(".saveButton").show(); 
 }
 
 var checkSum = function() {
     var sum = 0;
     jQuery('input[type="text"]').each(function(el,ind){
         sum += Number(jQuery(this).val());
     });
    if (sum > globalQuantity ) {
             console.log('TAHAT');
             jQuery(".saveButton").hide();
             jQuery('[id$="totalQuantity"').text(' חורגת מההקצאה');
              
    } else {
        jQuery('[id$="totalQuantity"').text(addCommas(globalQuantity - sum));
        console.log('DVASH');
        jQuery(".saveButton").show(); 
    }

    
 }

 $('body').on('click', '.checker', function(event) {
            var curState = $(this).prop('checked');
            $('.ch' + event.target.id).prop('checked', curState);
        });
PK 
     Yn�J                            css/PK 
     dj�JX�{�                 "   css/AssignmentTable.cssPK 
     Yn�J                        t  js/PK 
     <r�J@�O2^  ^               �  js/AssignmentTable.jsPK      �   &    