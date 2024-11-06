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
Winter months can be tough for people living in the north. I enjoy cycling during the warmer months, but long periods of cold and darkness can make me shy away from this activity. Sometimes, I just need a bit of reassurance that I won’t be caught in a storm at the top of a hill. After a particularly long week of cold slush in February, I felt like I needed something to help me decide when it was a good window to get outside. And so, after a couple days Fairweather was a-live!

At the initial sketch, I wanted the app to:
- display the current location;
- provide a quick glimpse of the weather conditions and temperature;
- offer a short description of how the day might feel for me;
- show wind and humidity levels;
- include a forecast for the next few hours;
- highlight any potential hazards, like ice and snow.

I kept the design minimal and a bit boring —just enough information to help me decide whether it was a good day to head out. I didn’t want too much data or too many details. I was after something that would be quick to read and would make the decision easier, not harder. The least straightforward logic was the helper text, I wanted a single sentence to remind me how *I* personally feel under those conditions.

For the design, I kept it simple: just two contrasting colors, a technical font with a bit of roughness to it, and simple, outlined icons.

I ended up using [OpenWeather](https://openweathermap.org/) to pull the essential weather data, as it's accurate enough for my use case. The app itself was built with TypeScript, and I wanted to give [Next.js](https://nextjs.org/docs) another try. The middleware was useful for data fetching, and deploying with Vercel was straightforward. For the "next few hours" line graph, I used [Airbnb’s visx/curve](https://airbnb.io/visx/docs/curve), which had the exact look and shape I was going for, and was easy to use.

![](https://imgur.com/dUZhy1B.png)*The final(current) version and my initial lousy sketch*

You can check it out or install the app [here](https://fairweather.belinhacbr.xyz/). The source code is available on [github](https://github.com/belinhacbr/fairweather).

This app was made in less than a week in February, and I've been using it ever since, it's simple and it gets me out there. While I could add more detailed information, I’ve realized that too much data just leads to overthinking. After all, I’m not looking for *perfect* weather; I’m just looking for a window when it’s *good enough* to get outside.

Living in Scotland, you quickly realize that the “perfect” time to get out is a myth. The perfect time to get out is the time you *do* get out, with the right precautions in place to not get caught in a sticky situation.

That said, I’m considering adding a feature highlighting visibility and sunset times, especially for the months when the sun is setting quickly and earlier. This could be useful for planning when the sunsets overlaps with the "next few hours" forecast.

Overall, Fairweather has been exactly what I needed. It does just enough to help me get outside without overwhelming me with unnecessary data. It’s not a fancy weather app—it’s a no-frills way to get a quick snapshot of the weather and make a decision about getting out. And for now, that’s all I need.
