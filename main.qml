import QtQuick 2.4
import QtQuick.Window 2.0
import QtGraphicalEffects 1.0
import "qrcode.js" as QR

Rectangle {
    id: root
    visible: true
    width: 1024
    height: 768
    color: "#913839"
    property variant currentCount: 0
    property date finalDate: new Date(2015, 6, 15, 0, 00)
    property variant weibo: []
    property var pictureList: []

    property var index: 0

    Image {
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
        width: root.width*.6
        height: root.height
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: 250
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
                font.pointSize: 20
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
        id: weiboTimer
        interval: 50000; running: countDown.visible; repeat: true
        triggeredOnStart: true
        onTriggered: {
            index = 0
            var xhr = new XMLHttpRequest();
            // FIXME: add twitter https://api.twitter.com/1.1/search/tweets.json?q=%23ubuntuphon 
            xhr.open("GET", "https://api.weibo.com/2/search/topics.json?source=5786724301&q=Ubuntu手机黑客松&count=20", true);
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

                            // handle thumbnails
                            if (response.statuses[i].pic_ids.length > 0) { 
                                thumbnail = response.statuses[i].thumbnail_pic

                                // FIXME: how to display multiple pics in one post?
                            /*
                                for (var j = 0; j < response.statuses[i].pic_ids.length; j++) {
                                    slideshow.push(thumbnail.replace(/thumbnail\/(\w+?)\.jpg/, "bmiddle/"+response.statuses[i].pic_ids[j]+".jpg"))
                                }
                            */
                            }

                            if (typeof(response.statuses[i].retweeted_status) !== "undefined") {
                                console.log("\t", response.statuses[i].retweeted_status.user.name, ": ", response.statuses[i].retweeted_status.text)
                                retweetedContent = response.statuses[i].retweeted_status.user.name + ": " + response.statuses[i].retweeted_status.text 
                            }
                            listModel.insert(0, {"content": response.statuses[i].text, "avatar_hd": response.statuses[i].user.avatar_hd, "name": response.statuses[i].user.name, "thumbnail": thumbnail, "retweetedContent": retweetedContent });
                            weibo[response.statuses[i].id] = 1;
                        }

                        // print out the pictures
                        var pictures = response.statuses[i].pic_ids;
                        var originalPic = response.statuses[i].original_pic;

                        if ( originalPic !== undefined ) {
                            var patt = /(?!\/)([A-Z0-9_-]{1,}\.(?:png|jpg|gif|jpeg))/i
                            var myArray = patt.exec(originalPic);
//                            console.log("originalPic: " + originalPic );

                            for (var j in pictures ) {
                                // console.log("j: " + j + pictures[ j ]);
                                var picture = pictures[j]
                                var picPath = originalPic.replace(myArray[0], picture);
                                picPath += ".jpg"
//                                console.log("picPath: " + picPath)
                                pictureList.push(picPath);
                            }

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
            rightMargin: countDown.visible ? 70 : root.width/2-90
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
        id: url
        anchors.top: qrcode.bottom
        anchors.left: qrcode.left
        anchors.topMargin: 10
        text: "pad.ubuntu.com/Xi4U5YvCF0"
        font.pointSize: 20
        font.bold: true
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

        MouseArea {
            anchors.fill: parent
            onClicked: timer.start()
        }

    }
    Text {
        id: countDownMin
        anchors.top: countDown.bottom
        anchors.topMargin: countDown.visible ? -35 : -100
        anchors.horizontalCenter: pulse.horizontalCenter
        font.pointSize: countDown.visible ? 60 : 90
        font.bold: true
        color: countDown.visible ? "black" : "red"

    }
    TextEdit {
        id: broadcast
        anchors {
            left: parent.left
            leftMargin: 20
            top: parent.top
            topMargin: 100
        }

        height: 100
        font.pointSize: 30
        font.bold: true
        text: "微博话题墙: \n#Ubuntu手机黑客松#"
        color: "white"
        MouseArea {
            anchors.fill: parent
            onClicked: parent.focus = !parent.focus
        }
    }
    Image {
        id: qrcode
        anchors.top: parent.top
        anchors.left: broadcast.right
        anchors.topMargin: 20
        anchors.leftMargin: 70
        visible: countDown.visible
        width: 120
        height: 120
        z: 2
    }


    Image {
        id: pic
        width: parent.width*.4
        height: parent.height*.4
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.bottomMargin: 10
        fillMode: Image.PreserveAspectFit
        z: 100

        Behavior on opacity {
            NumberAnimation { duration: 2000 }
        }

        states: [
            State {
                name: "disappear"
                PropertyChanges {
                    target: pic
                    opacity: 0
                }
            }
        ]

        transitions: [
            Transition {
                from: "*"
                to: "disappear"

                NumberAnimation { properties: "opacity"; duration: 8000 }
            }
        ]
    }

    Timer {
        interval: 8000; running: true; repeat: true
        onTriggered: {
            var count = pictureList.length;

            if ( count == 0 )
                return;

            if ( index < count ) {
                index ++
            } else {
                index = 0
            }

            pic.source = pictureList[index]

            if ( pic.state == "")
                pic.state = "disappear"
            else
                pic.state = ""
        }
    }

    Component.onCompleted: {
        // Let's calculate the count we should go
        var now = new Date()

        var diff = finalDate.getTime() - now.getTime()

        console.log("diff: " + diff)
        var seconds = diff / 1000;
        var Seconds = Math.abs(seconds);
        currentCount = Math.floor(seconds)
        console.log("currentCount: " + currentCount );

        // Generate QRCode 
        var qr = QR.qrcode(3, 'L')
        qr.addData('http://' + url.text);
        qr.make()
        qrcode.source = qr.createImgTag();
    }
}
