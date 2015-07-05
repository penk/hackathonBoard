import QtQuick 2.4
import QtQuick.Window 2.0 
import QtGraphicalEffects 1.0

Rectangle {
    id: root
    visible: true
    width: Screen.width
    height: Screen.height
    color: "#913839"
    property variant currentCount: 60*60*5 + 20*60
    property variant weibo: []
    property variant slideshow: []
    property variant count: 0

    FontLoader { id: alte; source: "AlteHaasGroteskBold.ttf" }

    Image {
        id: logo
        source: "ubuntu.png"
        anchors {
            top: parent.top
            left: parent.left
            margins: -15
        }
    }
        
    ListView { 
        id: listView
        z: 3
        width: root.width - 340
        height: root.height
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: 220
        model: listModel
        visible: countDown.visible

        delegate: Rectangle { 
                width: parent.width 
                height: retweet.text !== "" ?  weiboContent.height + retweetContent.height : weiboContent.height
                anchors.left: parent.left
                anchors.leftMargin: 50
                color: "transparent"
                Image { 
                    id: image
                    source: avatar_hd; width: 80; height: 80 
                    visible: false
                }
                Rectangle {
                    id: mask
                    anchors.margins: 10
                    anchors.topMargin: 50
                    width: 65
                    height: 65
                    color: "black"
                    radius: width/2
                    clip: true
                    visible: false
                }
                OpacityMask {
                    anchors.fill: mask
                    source: image
                    maskSource: mask
                }
                Text { 
                    id: weiboContent
                    text: name + ": \n" + content + "\n"; anchors.left: parent.left; anchors.leftMargin: 80; 
                    anchors.top: parent.top; anchors.topMargin: 5;  
                    color: "white"
                    font.pointSize: 22
                    wrapMode: Text.WordWrap
                    width: parent.width - 280
                }
                Rectangle { 
                    id: retweetContent
                    visible: retweet.text !== ""
                    width: weiboContent.width * 0.8
                    radius: 15
                    color: "#BA6666"
                    anchors {
                        left: parent.left
                        leftMargin: 150
                        top: weiboContent.bottom
                        topMargin: -10
                    }
                    height: retweet.height + 20
                    Text {
                        id: retweet
                        anchors {
                            top: parent.top
                            left: parent.left
                            margins: 10
                            right: parent.right
                        }
                        text: retweetedContent
                        wrapMode: Text.WordWrap
                        color: "white"
                        font.pointSize: 22
                    }
                }
                Image {
                    anchors.top: parent.top; anchors.topMargin: 5
                    anchors.right: parent.right
                    anchors.rightMargin: 60
                    source: thumbnail
                    width: 120
                }

        }
        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 400 }
        }
        displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 400; easing.type: Easing.OutBounce }
        }
    }
    ListModel { 
        id: listModel 
    }
    Timer {
        id: slideshowTimer
        interval: 5500
        running: countDown.visible
        repeat: true 
        onTriggered: { 
            if (slideshow.length > 0) {
                if (count >= slideshow.length) count = 0;
                slideshowImage.source = slideshow[count]
                count++
            }
        }
    }
    Timer {
        id: weiboTimer
        interval: 30000; running: countDown.visible; repeat: true
        triggeredOnStart: true
        onTriggered: {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "https://api.weibo.com/2/search/topics.json?source=5786724301&q=Ubuntu手机黑客松&count=7", true); 
            xhr.onreadystatechange = function()
            {
                if ( xhr.readyState == xhr.DONE) {
                    var response;
                    try { response = JSON.parse(xhr.responseText); } catch (e) { console.error(e) } 

                    for (var i = response.statuses.length - 1; i > -1; i--) { 
                        console.log(response.statuses[i].user.name, ":", response.statuses[i].text)
                        if (weibo[response.statuses[i].id] !== 1) {
                            var thumbnail = "";
                            var retweetedContent = "";
                            if (response.statuses[i].pic_ids.length > 0) { 
                                thumbnail = response.statuses[i].thumbnail_pic
                                for (var j = 0; j < response.statuses[i].pic_ids.length; j++) {
                                    slideshow.push(thumbnail.replace(/thumbnail\/(\w+?)\.jpg/, "bmiddle/"+response.statuses[i].pic_ids[j]+".jpg"))
                                }
                            }

                            if (typeof(response.statuses[i].retweeted_status) !== "undefined") {
                                console.log("\t", response.statuses[i].retweeted_status.user.name, ": ", response.statuses[i].retweeted_status.text)
                                retweetedContent = response.statuses[i].retweeted_status.user.name + ": " + response.statuses[i].retweeted_status.text 
                            }
                            listModel.insert(0, {"content": response.statuses[i].text, "avatar_hd": response.statuses[i].user.avatar_hd, "name": response.statuses[i].user.name, "thumbnail": thumbnail, "retweetedContent": retweetedContent });
                            weibo[response.statuses[i].id] = 1;
                        } 
                    }
                }
            }
            xhr.send();
        }
    }

    Rectangle { 
        id: pulse
        width: 180
        height: 180 
        radius: width/2
        color: "#BA6666"
        
        anchors {
            //horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: countDown.visible ? 50 : root.height/3 
            right: parent.right
            margins: 50
            rightMargin: countDown.visible ? 50 : root.width/2-90
        }

        Rectangle {
            id: innerBox
            width: pulse.width - 20
            height: pulse.height - 20
            radius: height/2
            anchors.centerIn: parent
        }

        Timer {
            id: timer
            interval: 1000; running: false; repeat: true
            onTriggered: {
                time.text = new Date().toLocaleTimeString(Qt.locale(), "HH : mm");
                currentCount--;
                if (currentCount == 0) timer.stop();
                countDown.text = Math.floor(currentCount/3600)
                countDownMin.text =(((Math.floor((currentCount%3600)/60)) >= 10)?"":"0") +  Math.floor((currentCount%3600)/60) + " : " + (((currentCount%60) >= 10)?"":"0") + (currentCount%60)
            }
        }


        SequentialAnimation  {
            ScaleAnimator {
                target: pulse
                from: 1
                to: 2
                duration: 1000
                easing.type: Easing.OutBack
                easing.overshoot: 2.2	
                loops: Animation.Infinite
            }
            running: currentCount > 0 ? true : false
        }
    }

    Text {
        visible: false
        anchors.top: qrcode.bottom
        anchors.left: qrcode.right
        anchors.leftMargin: 20
        anchors.topMargin: 10
        text: "etherpad.mozilla.org/MvFaBUEPRd"
        font.pointSize: 20
        font.bold: true
        font.family: alte.name
        color: "white"
    }

    Text { 
        id: time
        color: "#D8BEAB"
        anchors {
            left: parent.left
            top: parent.top
            margins: 30
            leftMargin: 30
        }
        font.pointSize: 40
        font.bold: true
        font.family: alte.name
        visible: false
    }

    Text {
        id: countDown
        visible: (text !== "0")
        anchors {
            horizontalCenter: pulse.horizontalCenter
            top: pulse.top
            topMargin: text === "Ready!" ? 15 :-40
        }
        text: "Ready!"
        font.pointSize: text === "Ready!" ? 80 : 140
        color: text === "Ready!" ? "red" : "black"
        font.bold: true
        font.family: alte.name
        MouseArea {
            anchors.fill: parent
            onClicked: timer.start()
        }

    }
    Text { 
        id: countDownMin
        anchors.top: countDown.bottom
        anchors.topMargin: countDown.visible ? 0 : -100
        anchors.horizontalCenter: pulse.horizontalCenter
        font.pointSize: countDown.visible ? 60 : 90
        font.bold: true
        font.family: alte.name
        color: countDown.visible ? "black" : "red"

    }
    TextEdit {
        id: announce
        anchors {
            left: parent.left
            leftMargin: 20
            top: parent.top
            topMargin: 100 
        }

        height: 100
        font.pointSize: 40 
        font.bold: true
        font.family: alte.name
        text: "微博话题墙: #Ubuntu手机黑客松# \nUbuntu Pin: hackubuntu"
        color: "white"
        MouseArea {
            anchors.fill: parent
            onClicked: parent.focus = !parent.focus
        }
    }
    Image {
        id: qrcode
        anchors.top: parent.top
        anchors.left: announce.right
        anchors.topMargin: 20
        anchors.leftMargin: 100
        visible: countDown.visible
        source: "qrcode.ubuntu.png"
        width: 180
        height: 180
        z: 2
    }
    Image {
        id: slideshowImage
        visible: countDown.visible
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        anchors.bottomMargin: 50
        fillMode: Image.PreserveAspectFit
        width: 300
        //onSourceChanged: fade.start()
    }
    SequentialAnimation {
        id: fade
        PropertyAnimation { target: slideshowImage; property: "opacity"; to: 1; duration: 600 }
        PropertyAnimation { target: slideshowImage; property: "opacity"; to: 0; duration: 1000 }
    }
}
