A/B Analytics
====================

A prototype analytics platform for analyzing and visualizing A/B testing results.  This app was built as a proof of concept for reporting A/B testing results in a video streaming company. It was built quick and dirty, and will need work if you want to make it a general purpose A/B testing reporting tool. It's great if you wanted some ideas or foundation for your A/B testing data visualization. Unfortunately, there's no much documentation, but feel free to extract any component, use all of it, or extend it.

## Prerequisite
* MySQL 5.1
* Rails 3.2.2
* Various gems (look at Gemfile)
* jQuery 1.7.1
* Bootstrap
* [SlickGrid](https://github.com/mleibman/SlickGrid)
* [DatePicker](http://foxrunsoftware.github.com/DatePicker/)
* [DropKick](https://github.com/JamieLottering/DropKick)

## Features
* Includes fabricated data so you can start playing with the app right away
* Calculates p-values (important for A/B testing!)
* Predefined streaming and retention metrics in fabricated data
* Ability to compare one cell with another cell (not just with control cell)
* Built in filters for multiple dimensions, such as Region, Time Period, and Device
* LDAP integration

## How it works
* Restore MySQL backup (in data/ directory)
* rake gems:install
* rake db:migrate
* rails server
* Go to localhost:3000 and type something in the text box

## Gotcha's
Like I mentioned earlier, this app was custom built for a single purpose, so you may not find it applicable for your A/B tests.  The backend data is an aggregation and table structure cannot be changed.  The frontend code is hacked together, although the results have been validated and are accurate. There are half written features, such as calendar date filter and user syncing with LDAP. Yet, it's still a great place to start if you have no prior experience with A/B testing data and how to visualize the results.