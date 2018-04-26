        html{
            font-size: 16px !important;
        }
        body {
            margin: 0px !important;
            padding: 0px !important;
            background: #FFF;
        }
        #startLayout {
            width: 22%;
            float: right;
            overflow-y: scroll;
        }
        #main-preview{
            width: 75%;
            border: 1px solid #cecaca;
            float: right;
            padding: 0 7px;
        }
        #main-preview iframe{
            width: 100%;
            border: 1px solid #b5b2b2;
            height: 100%;
        }
        #breadcrumbs a{
            color: #15377e;
            font-size: 16px;
            margin: 5px;
            text-decoration: underline;
            cursor: pointer;
            width: 70%;
        }
        #breadcrumbs a.selected,  #static-links a.selected{
            font-weight: bold;
        }

        #breadcrumbs{
            margin: 5px 0;
            float: right;
        }
        #wrapup-link{
            display: none;
            padding-right: 5px;
            color: #15377e !important;
        }
        #detail-link,
        #source-link{
            color: #15377e !important;
        }
        #dol-link{
            color: #15377e !important;
            padding-right: 5px;
        }
        #lead-link{
            display: none;
            padding-right: 5px;
            color: #15377e !important;
        }
        #static-links{
            padding-left: 5px;
            padding-right: 5px;
            font-size: 16px;
            margin: 5px;
            cursor: pointer;
            width: 70%;
            float: left;
            text-align: left;
        }

         .dropdown, .dropup {
            position: fixed;
            height: 0px;
         }

         .dropdown-menu {
             box-shadow: none !important;
             border:none !important;
             background-color: transparent !important;
             height:0px;
         }

          .btnDropDwon,
          .btn-primary:hover{
              background-color: rgb(108, 33, 111) !important;
              color: white !important;
              background:none;
          }

          #linksIframe{

              max-height: 340px;
             
          }
          
          #static-links a + a:after {
              content: "|";
              padding: 0 8px;
            }
        .spinnerMin {
            height: 100px;
        }