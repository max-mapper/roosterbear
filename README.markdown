# Roosterbear

2009 Max Ogden (max@maxogden.com)

## Information about Roosterbear

Roosterbear is a Twitterclone that uses a superfast nonrelational key/value database called Redis and a lightweight Ruby web framework called Sinatra.

## Installation

To get Roosterbear to run you will need to:

1. Get Redis running on your server (I developed against beta 8)
2. Install the redis-rb rubygem that's bundled with whatever Redis version you choose. I initially tried the github current redis-rb with the google code current Redis and stuff broke. Go with the redis-rb that's bundled with the Google Code version of Redis.

To start the sinatra server just execute 'ruby roosterbear.rb'. It will then look at localhost to try and find your Redis instance.

## About Google Authentication

Roosterbear uses an OpenID extension to facilitate a Google login mechanism. If you want a more traditional (and less user-friendly) approach you can easily redevelop the system to accept all OpenID providers through the 'paste your OpenID url into this box' login system. All the app does currently is take the OpenID auth token response and store that as a user's unique identifier in Redis. I made it Google only for a fast, streamlined approach.

## "Roosterbear?"

The name is a complete joke, half inspired by ridiculous web2.0 mashup names and half inspired by ridiculous indie rock band names. Credit for the name goes to Vernon Effalo. 

I engineered Roosterbear to be lightweight, fast, extensible and scalable but also highly usable and deployable for web projects large and small. If you do something cool with Roosterbear, let me know!