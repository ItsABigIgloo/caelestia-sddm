import QtQuick

Item {
    id: root
    anchors.fill: parent 
    property alias color: quote.color 
    property alias maxWidth: quote.width
    property int index: Math.floor(Math.random() * quotesModel.count)
    ListModel {
        id: quotesModel
        ListElement { text: "There is nothing impossible to him who will try"; author: "Alexander the Great" }
        ListElement { text: "The darker the night, the brighter the stars, the deeper the grief, the closer is God!"; author: "Fyodor Dostoevsky" }
        ListElement { text: "Life is not a problem to be solved but a reality to be experienced."; author: "Soren Kierkegaard" }
        ListElement { text: "I think, therefore I am"; author: "Rene Descartes" }
        ListElement { text: "Be not afraid of greatness. Some are born great, some achieve greatness, and others have greatness thrust upon them."; author: "William Shakespeare" }
        ListElement { text: "Pain and suffering are always inevitable for a large intelligence and a deep heart. The really great men must, I think, have great sadness on earth."; author: "Fydor Dostoevsky" }
        ListElement { text: "But how could you live and have no story to tell?"; author: "Fydor Dostoevsky" }
        ListElement { text: "And there is nothing more beautiful than choosing to live rather than simply exist."; author: "Unknown" }
        ListElement { text: "The only true wisdom is in knowing you know nothing."; author: "Socrates" }
        ListElement { text: "Worrying does not take away tomorrows troubles, it takes away todays peace"; author: "Randy Armstrong" }
        ListElement { text: "I will either find a way, or make one"; author: "Hannibal Barca" }
        ListElement { text: "The man who moves a mountain begins by carrying away small stones."; author: "Confucius" }
        ListElement { text: "You miss 100 percent of the shots you do not take."; author: "Wayne Gretzky" }
        ListElement { text: "Do not watch the clock, do what it does. Keep going."; author: "Sam Levenson" }
        ListElement { text: "The journey of a thousand miles begins with one step."; author: "Lao Tzu" }
        ListElement { text: "A smooth sea never made a skilled sailor."; author: "Franklin D. Roosevelt" }
        ListElement { text: "Fall seven times and stand up eight."; author: "Japanese Proverb" }
        ListElement { text: "The only limit to our realization of tomorrow is our doubts of today."; author: "Franklin D. Roosevelt" }
        ListElement { text: "He who has a why to live can bear almost any how."; author: "Friedrich Nietzsche" }
        ListElement { text: "What we think, we become."; author: "Buddha" }
        ListElement { text: "The only way to do great work is to love what you do."; author: "Steve Jobs" }
        ListElement { text: "Stay hungry, stay foolish."; author: "Steve Jobs" }
        ListElement { text: "Knowledge speaks, but wisdom listens."; author: "Jimi Hendrix" }
        ListElement { text: "Reality is wrong, dreams are for real."; author: "Tupac Shakur" }
        ListElement { text: "Everything should be made as simple as possible, but not simpler."; author: "Albert Einstein" }
    }
    Column {
        anchors.centerIn: parent
        spacing: 30
        Text {
            width: 100
            id: quote
            text: quotesModel.get(root.index).text
            color: "white"
            font.pointSize: 20
            font.family: "Rubik"
            font.italic: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter 
        }
        Text {
            width: quote.width
            id: author
            text: "~ " + quotesModel.get(root.index).author
            color: config.accent
            font.pointSize: 15
            font.family:  "CaskaydiaCove NF"
            font.bold: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter 
        }
    }
    
}