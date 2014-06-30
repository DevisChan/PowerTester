class myDB
    constructor: (@dbName) ->
        @db = window.openDatabase(@dbName, "1.0", "Test DB", 1000000)
        createTable = (tx) ->
            tx.executeSql('CREATE TABLE IF NOT EXISTS subject
                (id INTEGER PRIMARY KEY AUTOINCREMENT,
                on_erver BOOLEAN DEFAULT 0,
                server_id INTEGER,
                name VARCHAR(255) NOT NULL)')
            tx.executeSql('CREATE TABLE IF NOT EXISTS item 
                (id INTEGER PRIMARY KEY AUTOINCREMENT,
                content TEXT NOT NULL,
                uploaded BOOLEAN DEFAULT 0,
                good INTEGER DEFAULT 0,
                bad INTEGER DEFAULT 0,
                server_id INTEGER,
                subject_id INTEGER,
                FOREIGN KEY(subject_id) REFERENCES subject(id))')
            tx.executeSql('CREATE TABLE IF NOT EXISTS kv
                (key TEXT PRIMARY KEY,
                value TEXT NOT NULL)')
            tx.executeSql('INSERT INTO kv (key,value) VALUES (?,?)',['version','0.1'],null,=>
                tx.executeSql('UPDATE kv SET value=? WHERE key=?',['0.1','version'])
            )
            tx.executeSql('INSERT INTO kv (key,value) VALUES (?,?)',['version_code','dev'],null,=>
                tx.executeSql('UPDATE kv SET value=? WHERE key=?',['dev','version_code'])
            )
        @db.transaction(createTable)
    
        
    addItem: (@itemName, @itemContent)->
        @db.transaction((tx) => 
            tx.executeSql("SELECT * FROM subject 
                WHERE name = ?", [@itemName], (tx, results)=>
                    if results.rows.length == 0
                        @db.transaction((tx)=>
                            tx.executeSql('INSERT INTO subject
                                (name) VALUES ("'+@itemName+'")')
                        )
                        @addItem(@itemName, @itemContent)
                    else
                        sid = results.rows.item(0)['id']
                        tx.executeSql("INSERT INTO item (content, subject_id) VALUES
                            (?,?)",[@itemContent, sid], (tx, results) =>
                                alert('添加成功')
                            )
                , (error) =>
                    console.log('query subject error')
                    console.log(error)
            )
        )
    showRandomItemFromName: (@itemName, @func)->
        @db.transaction( (tx) =>
            tx.executeSql('SELECT * FROM item,subject WHERE item.subject_id=subject.id AND subject.name = ?',[@itemName], (tx,results)=>
                length = results.rows.length
                RanNum = Math.floor((Math.random() * length))
                chosen_item = results.rows.item(RanNum)
                func(chosen_item)
                
            , ->
                alert('数据库查询错误')  
            )
        
        )
    showAllSubject: (@func) ->
        @db.transaction( (tx) =>
            tx.executeSql("SELECT * FROM subject", [], (tx ,results) =>
                if results.rows.length != 0
                    r = []
                    length = results.rows.length - 1
                    for num in [0..length]
                        r.push(results.rows.item(num))
                    @func(r)
            )
        )

    createFromServer: (@subject,@data) ->
        insertInto = (@db,@sub, @data, @cur) =>
            if @cur >= @data.length
                alert('导入完毕')
                window.location.href=''
                return
            @obj = @data[@cur]
            @db.transaction((tx) =>
                #console.log(@i)
                tx.executeSql("SELECT * FROM subject WHERE name=?", [@sub],(tx,results)=>
                    if results.rows.length == 0
                        tx.executeSql("INSERT INTO subject (name) VALUES (?)",[@sub])
                        @createFromServer(@sub,data)
                    else
                        console.log(@obj)
                        sub = results.rows.item(0)
                        tx.executeSql("INSERT INTO item (server_id,good,bad,content,subject_id) VALUES
                            (?,?,?,?,?)",[@obj['id'],
                                @obj['good'],
                                @obj['bad'],
                                @obj['content'],
                                sub['id']], =>
                            
                                    insertInto(@db, @subject,@data,@cur+1)
                        )
                )
                
            )
        insertInto(@db,@subject,@data, 0)
        
        
class Connection
    constructor: (@main_server, @db) ->
    
    importFromServer: (@name) ->   
        alert('正在导入，请稍后')
        $.get(@main_server+'/subject/'+@name,
            (data, Status) =>
                if Status == 'success'
                    d = JSON.parse(data)
                    dd = d['result']
                    subject = d['subject']
                    @db.createFromServer(subject,dd)
                else
                    alert('无法连接到服务器')
        )

    showSubject: (@func) ->
        console.log('begin download')
        $.get(@main_server+'/subject',
            (data,status) =>
                if status == 'success'
                    console.log(data)
                    d = JSON.parse(data)
                    sl = d['subject_list']
                    @func(sl)
                else 
                    alert('请检查您的网络链接')
        )

this.myDB = myDB
this.Connection = Connection
    
        
