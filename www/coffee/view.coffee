class myUI
    constructor: (@db) ->
        @mainPanel = document.getElementById('main-panel')
        height = window.innerHeight
        @questionField = document.getElementById('question-field')

        $("#commitItem").click( =>
            itemName = $("#itemName").val()
            itemContent = $("#itemContent").val()
            if this.db.addItem(itemName, itemContent)
                $("#itemName").val('')
                $("#itemContent").val('')
                alert('提交成功')
        )
        @createButton()
        @init('语文')
        @showSubject()
        @con = new Connection('http://172.246.147.104:5000', @db)
        
        $("#importWeb").click(=>
            #con = new Connection('http://127.0.0.1:5000', @db)
            func = (list) =>
                for l in list
                    a = document.createElement('a')
                    a.setAttribute('class','button btn-subject')
                    a.setAttribute('data',l)
                    a.innerHTML = l
                    field = document.getElementById("subject-field")
                    field.appendChild(a)
                $(".btn-subject").click( (event)=>
                    target = event.target
                    name = $(target).attr('data')
                    @con.importFromServer(name)
                )
            @con.showSubject(func)
            
        )
        
    showSubject: ->
        @frame = document.getElementById('subject_choice')
        show = (r) =>
            for i in r
                a = document.createElement('a')
                a.innerHTML = i['name']
                li = document.createElement('li')
                li.appendChild(a)
                a.setAttribute('href','#main')
                a.setAttribute('class','pressed')
                @frame.appendChild(li)
                $(a).click((event) =>
                    @init(event.target.innerHTML)
                )
        @db.showAllSubject(show)
        
    init: (subject_name) ->
        createNode= (obj) =>
            content = obj['content']
            attrs = content.match(/\{.*?}/g)
            if attrs
                for attr in attrs
                    #console.log(attr)
                    at = attr.replace('{','')
                    at = at.replace('}','')
                    c = "<span class='mask'>#{at}</span>"
                    content = content.replace(attr,c)
            $(@questionField).html("<span class='item'>#{content}</span>")
            $(".mask").bind('hover', (event)->
                    target = event.target
                    $(target).css('background-color','transparent')
                , (event) ->
                    target = event.target
                    $(target).css('background-color','black')
            )
        
            
        @db.showRandomItemFromName(subject_name,createNode)
        
        $(".next").click( =>
            this.db.showRandomItemFromName(subject_name,createNode)
        )
        
        
    createButton: ->
        anser = document.createElement('a')
        next = document.createElement('a')
        $(anser).attr('class','button icon pencil')
        $(next).attr('class','button next')
        anser.innerHTML = 'Anser'
        next.innerHTML = 'Next'
        buttonField = document.createElement('div')
        buttonField.appendChild(anser)
        buttonField.appendChild(next)
        $(buttonField).attr('class','button-field')
        $(anser).click( ->
            $(".mask").css('background-color','transparent')              
            $(".mask").css('color','red')
        )
        @mainPanel.appendChild(buttonField)



this.ui = new myUI this.db