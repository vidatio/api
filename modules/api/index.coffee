"use strict"

express = require "express"
{Router} = express
passport = require "passport"
{BasicStrategy} = require "passport-http"

{model:User} = require "./users/user"

{forward} = require "./forward"
{user} = require "./users"
{auth} = require "./auth"
{dataset} = require "./datasets"
{category} = require "./categories"
{tag} = require "./tags"

{routes:logRoutes, auth:logger} = require "../logger"

path = require "path"

router = Router()

passport.use new BasicStrategy (nameOrEmail, password, done) ->
    logger.info "basic strategy called"
    logger.debug params: {nameOrEmail, password}

    User.findByNameOrEmail nameOrEmail, (error, user) ->
        return done error if error
        return done null, false if !user
        return done null, false if !user.authenticate password

        logger.debug
            user: user
            name: user.name
            email: user.email
            password: password
        , "user auth successful"
        return done null, user

router.use "/forward", forward
router.use "/users", user
router.use "/auth", auth
router.use "/datasets", dataset
router.use "/categories", category
router.use "/tags", tag

router.use "/docs", express.static path.join process.cwd(), "docs"
router.use "/logs", logRoutes

router.all "/*", (req, res) ->
    logger.error req: req, "not found!"

    res.status(404).json error: "not found"


module.exports = router
