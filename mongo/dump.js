
var generalCollection = 'backlogdirectory';
var backlogCollection = 'backlog'
var dbId = null;
var count = 0;

db.getSiblingDB(Database).getCollection(generalCollection).find().forEach(
    function(x){
        if( x.name == Backlog ){
            dbId = x.id; 
            count = 0;
            db.getSiblingDB(dbId).getCollection(backlogCollection).find({$and:[{timestamp:{$gt:ISODate(SDate)}},{timestamp:{$lt:ISODate(EDate)}}]}).sort({$natural:1}).forEach(
                function(y){
                    count++;
                    lastEvent = y;
                    printjson(y);
                }
            )
        }
    }
)

if( dbId == null ){
    print("Backlogger witn name "+Backlog+" does not exists in database "+Database+"!!");
}
