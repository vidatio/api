"use strict"

frisby = require "frisby"

config = require "../../config"

frisby.globalSetup
    request:
        body: undefined
        headers:
            "Accept": "application/json"
        inspectOnFailure: true
        json: true
        baseUri: config.url

frisby.create "Expect 500 on registering user without email"
    .post "/v0/user",
        email: ""
        password: "admin"
    .expectHeaderContains("Content-Type", "json")
    .expectStatus(500)
    .toss()

frisby.create "Expect email validation error on registering user with wrong email"
    .post "/v0/user",
        email: "admin"
        password: "admin"
    .expectHeaderContains("Content-Type", "json")
    .expectStatus(500)
    .after (err, res, body) ->
        expect(body.error.name).toBe("ValidationError")
        expect(body.error.errors).toEqual(jasmine.any(Object))
        expect(body.error.errors.email).toEqual(jasmine.any(Object))
        expect(body.error.errors.email.properties).toEqual(jasmine.any(Object))
        expect(body.error.errors.email.message).toBe("API.USER.REGISTER.EMAIL.NOTVALID")
        expect(body.error.errors.email.name).toBe("ValidatorError")
        expect(body.error.errors.email.path).toBe("email")
        expect(body.error.errors.email.value).toBe("admin")
    .toss()

# frisby.create "Expect json with content on successfully registering user"
#     .post "/v0/user",
#         email: "admin@admin.com"
#         password: "admin"
#     , json: true
#     .expectHeaderContains("Content-Type", "json")
#     .expectStatus(200)
#     .expectJSONTypes
#         _id: String
#         email: String
#         username: String
#         deleted: Boolean
#     .inspectJSON()
#     .toss()
