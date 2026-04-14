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
        ListElement { text: "All of us had to live their lives drunk on something, else we had no cause to keep pushing on."; author: "Kenny Ackermann" }
        ListElement { text: "A slave to money holds a whip just so he can act like he owns a slave bought by money. But he is not aware of one thing, the truth is all of us are slaves to something."; author: "Askeladd" }
        ListElement { text: "This world is cruel but it's also, it's also beautiful."; author: "Mikasa Ackermann" }
        ListElement { text: "My god, a moment of bliss. Why isn't that enough for a lifetime?"; author: "Fyodor Dostoevsky" }
        ListElement { text: "Life is not a problem to be solved, but a reality to be experienced."; author: "Søren Kierkegaard" }
        ListElement { text: "It's not death a man should fear, but he should fear never beginning to live."; author: "Marcus Aurelius" }
        ListElement { text: "It takes the whole life to learn how to live, and what will perhaps make you wonder more, it takes the whole of life to learn how to die."; author: "Seneca" }
        ListElement { text: "You don't have enemies, the truth is that nobody has them."; author: "Thors Snorresson" }
        ListElement { text: "It's better to shoot and miss, than to let time run out and wonder what if."; author: "Michael Jordan" }
        ListElement { text: "Believe in yourself."; author: "Someone" }
        ListElement { text: "Take the chance and you may lose. Take not a chance, and you have already lost."; author: "Søren Kierkegaard" }
        ListElement { text: "Failure is success in progress."; author: "Albert Einstein" }
        ListElement { text: "Keep moving forward."; author: "Eren Yeager" }
        ListElement { text: "Linux is only free if your time has no value."; author: "Jamie Zawinski" }
        ListElement { text: "So Nvidia, fuck you!"; author: "Linus Torvalds" }
        ListElement { text: "I use Arch btw."; author: "Many people" }
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
            color: config.primary
            font.pointSize: 15
            font.family:  "CaskaydiaCove NF"
            font.bold: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter 
        }
    }
    
}