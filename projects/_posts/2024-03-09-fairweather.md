---
title: "Fairweather - An app for moderate weather activity enthusiasts"
layout: post
date: 2024-03-09 09:34
tags: [fairweather, nextjs, typescript]
image: https://imgur.com/NiXmnXU.png
headerImage: true
projects: true
hidden: true # don't count this post in blog pagination
description: 'An app for moderate weather activity enthusiasts'
category: projects
author: belinhacbr
externalLink: false
---
Winter months can be hard for the people living in the north. I enjoy cycling in the warmer months, but long periods of cold and darkness can shy me away from this activity, sometimes I just need a bit of reassurance that I won't be caught in a storm at the top of a hill. After an extra long week of cold slush in February I felt like a I needed something to tell me when it was a good window to get out.
After a couple days Fairweather was a-live!

At the initial sketch, I wanted:
- display the given location;
- a quick way to glimpse the weather conditions and temperature;
- a few words describing how the day out would look like for me;
- the wind and humidity;
- the forecast for the next few hours;
- highlight some selected harzards like ice and snow.

I kept the design minimal and a bit boring —just enough information to help me decide whether it was a good day to head out. I didn’t want too much data or too many details. I was after something that would be quick to read and would make the decision easier, not harder. By design, the least straight forward logic was the helper text, I wanted a single sentence to remind me how I *personally* feel under those conditions. For the looks, I wanted two contrasting colors only, a font that was technical and also rough around the edges, and simple outlined icons.

I ended up using [Openweather](https://openweathermap.org/) to get the essential weather data, it's fairly accurate for my use case. I used Typescript for the app, and I wanted to give [Next.js](https://nextjs.org/docs) another chance, the middleware would be useful for data fetching and the deployment vercel was very straight forward. For the "next few hours" line graph, I used [Airbnb's visx/curve](https://airbnb.io/visx/docs/curve), it already had the look and shape I was looking for, and was easy to use.

![](https://imgur.com/dUZhy1B.png)*The final(current) version and my initial lousy sketch*

You can check it out or install the app [here](https://fairweather.belinhacbr.xyz/). The source code is available on [github](https://github.com/belinhacbr/fairweather).

This app was made in less than a week in February, and I've been using it ever since, it's simple and it gets me out there. I could add more elaborate information but after a thought I realised that too much information would make me overthink the whole process. After all, I’m not looking for the *perfect* weather —I’m just looking for a window when it’s *good enough* to get outside. Living in Scotland, you quickly realize that the “perfect” time to get out is a myth. The perfect time to get out is the time you *do* get out, with the right precautions in place to not get caught in a sticky situation.

That said, I’m considering adding a feature highlighting visibility and sunset times, especially for the months when the sun is setting quickly and earlier. This could be useful for planning when the sunsets overlaps with the "next few hours" forecast.

Overall, Fairweather has been exactly what I needed. It does just enough to help me get outside without overwhelming me with unnecessary data. It’s not a fancy weather app—it’s a no-frills way to get a quick snapshot of the weather and make a decision about getting out. And for now, that’s all I need.
