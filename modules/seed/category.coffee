"use strict"

seedCategories = [
    "Politik"
    "Sport"
    "Finanzen"
    "Umwelt"
    "Bildung"
]

module.exports =  (db) ->
    promiseArray = []
    Category = db.model "Category"

    return new Promise (resolve, reject) ->
        Category.find {}, (err, categories) ->
            if categories.length < seedCategories.length
                console.log "No or not enough categories available in categories collection"

                for category, i in seedCategories
                    console.log "Upserting category #{seedCategories[i]}"

                    promise = new Promise (resolve, reject) ->
                        Category.update
                            name: seedCategories[i]
                        ,
                            $setOnInsert:
                                name: seedCategories[i]
                        ,
                            upsert: true
                        , (error, doc) ->
                            reject error if error
                            resolve doc

                    promiseArray.push promise

                Promise.all(promiseArray)
                .then (result) ->
                    resolve result
                , (error) ->
                    reject error

            else
                console.log "No need to seed categories"
                resolve categories