import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.3
import Ubuntu.Layouts 1.0
import Ubuntu.Components.ListItems 1.3 as ListItem
/* a custom plugin */
import Fileutils 1.0

import QtQuick.LocalStorage 2.0
import "./js/Storage.js" as Storage

/* import folder */
import "./dialog"

/*
  Show the images associated at the selected Moment TABLET version
  and offer Zoom function or deletion of the image
*/
Page {
     id: showImagesPage

     /* Values passed as input properties when a Moment is selected form the list */
     property string id;
     property string title;

     /* info about selected image in the GridView, used in delete/zoom Dialog */
     property string targetImageName;
     property string targetMomentId;
     property string imageListModelIndex;

     header: PageHeader {
        title: showImagesPage.title
        subtitle:  i18n.tr("Images found")+": "+momentsImagesListModel.count
     }

     Component {
         id: imageZoomtDialogue
         ImageZoomDialog{targetImagePath:Fileutils.getHomePath()+"/"+root.imagesSavingRootPath+"/moments/"+showImagesPage.title+"/images/"+showImagesPage.targetImageName; imageName: showImagesPage.targetImageName}
     }

     Component {
         id: removeImageDialog
         RemoveImageDialog{targetImagePath:Fileutils.getHomePath()+"/"+root.imagesSavingRootPath+"/moments/"+showImagesPage.title+"/images/"+showImagesPage.targetImageName; imageListModelIndex: showImagesPage.imageListModelIndex}
     }

     /* filled with the image names/path associated with the moment */
     Component.onCompleted: {

          //console.log("showImagesPage loading images for moment with id:"+showImagesPage.id)

          var imagePath = Fileutils.getHomePath()+"/"+root.imagesSavingRootPath+"/moments/"+showImagesPage.title+"/images";
          console.log("showImagesPage searching under path: "+imagePath);

          var fileList = Fileutils.getMomentImages(imagePath);
          momentsImagesListModel.clear();

         for(var i=0; i<fileList.length; i++) {
            momentsImagesListModel.append( { imageName: fileList[i], imagePath: imagePath, value:i } );
         }

         if(momentsImagesListModel.count > 0){
            removeButton.enabled = true;
            zoomButton.enabled = true;
            /* set as target the first image */
            showImagesPage.targetImageName = momentsImagesListModel.get(0).imageName;
            showImagesPage.targetMomentId = id;
         }

         //console.log("showImagesPage Total found images:"+ momentsImagesListModel.count);
     }

     /* highlighter Component for selected image */
     Component {
          id: highlightComponent
          Rectangle {
               width: imageGridView.cellWidth
               height: imageGridView.cellHeight
               color: "blue"; radius: 5
               x: imageGridView.currentItem.x
               y: imageGridView.currentItem.y
               Behavior on x { SpringAnimation { spring: 3; damping: 0.2 } }
               Behavior on y { SpringAnimation { spring: 3; damping: 0.2 } }
          }
      }

      GridView {
             id: imageGridView
             anchors.topMargin: units.gu(10) /* amount of space from the above component */
             anchors.fill: parent
             cellWidth: parent.width/5
             cellHeight: parent.height/5
             model: momentsImagesListModel
             delegate: ShowImageDelegate{}
             highlight: highlightComponent
             highlightFollowsCurrentItem: false
             focus: true
             clip: true
      }

      Column{
           anchors.fill: parent
           spacing: units.gu(4)

           Row{
               id:commandButtonsRow
               spacing: units.gu(2)
               anchors.horizontalCenter: parent.horizontalCenter
               anchors.bottom: parent.bottom
               anchors.margins: units.gu(2)

               Button{
                  id: zoomButton
                  enabled: false
                  text: i18n.tr("Zoom")
                  width: units.gu(20)
                  color: UbuntuColors.green
                  onClicked: {
                      PopupUtils.open(imageZoomtDialogue)
                  }
               }

               Button{
                  id: removeButton
                  enabled: false
                  text: i18n.tr("Remove")
                  width: units.gu(20)
                  color: UbuntuColors.red
                  onClicked: {
                      showImagesPage.imageListModelIndex = imageGridView.currentIndex
                      PopupUtils.open(removeImageDialog)
                  }
              }
           }

           /* To show a scrolbar on the side */
           Scrollbar {
               flickableItem: imageGridView
               align: Qt.AlignBottom
           }
     }
}
