"use strict"

frisby = require "frisby"

config = require "../../config"

userRoute = "/" + config.apiVersion + "/users"
authRoute = "/" + config.apiVersion + "/auth"

{model:User} = require "../users/user"

testUser =
    name: "authAdmin"
    email: "auth@admin.com"
    password: "admin"

frisby.globalSetup
    request:
        body: undefined
        headers:
            "Accept": "application/json"
        inspectOnFailure: true
        json: true
        baseUri: config.url

User.findOneAndRemove {
    "name": testUser.name
}, (error, doc, result) ->

    frisby.create "Create a user for authentication"
        .post userRoute,
            email: testUser.email
            name: testUser.name
            password: testUser.password
        .after (error, res, body) ->
            user = body

            frisby.create "unsuccessfully authenticate user"
                .get authRoute
                .auth user.email, "admin2"
                .expectStatus 401
                .toss()

            frisby.create "successfully authenticate user"
                .get authRoute
                .auth user.email, testUser.password
                .expectStatus 200
                .expectJSON {
                    message: "successfully authenticated"
                }
                .toss()

        .toss()

