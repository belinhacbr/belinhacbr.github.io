---
title: "Flask Sync vs. Async: Understanding the Performance Bottleneck in IO-Bound Tasks"
layout: post
date: 2024-10-30 22:10
tags: [python, flask, WSGI, ASGI, FastAPI]
image: /assets/images/banner.png
headerImage: true
blog: true
hidden: false # don't count this post in blog pagination
description: ""
category: blog
author: belinhacbr
externalLink: false
---

A while ago, I was implementing an application using the well-known Python WSGI-based framework, [Flask](https://flask.palletsprojects.com/en/stable/). My application was running with 4 workers, there was route sending a request to an API and waiting for the response—a typical IO-bound operation, this operation could also be a database access or a file system call.

During testing, I noticed that whenever my application received more than 4 requests at once, they would 'wait' and take longer to respond. The access logs looked something like this:

{% highlight text %}
[2024-10-29 17:04:15] [pid-worker0] GET /io
[2024-10-29 17:04:15] [pid-worker1] GET /io
[2024-10-29 17:04:15] [pid-worker2] GET /io
[2024-10-29 17:04:15] [pid-worker3] GET /io
[2024-10-29 17:04:16] [pid-worker0] GET /io
[2024-10-29 17:04:16] [pid-worker1] GET /io
[2024-10-29 17:04:16] [pid-worker2] GET /io
[2024-10-29 17:04:16] [pid-worker3] GET /io
[2024-10-29 17:04:17] [pid-worker0] GET /io
[2024-10-29 17:04:17] [pid-worker1] GET /io
[2024-10-29 17:04:17] [pid-worker2] GET /io
[2024-10-29 17:04:17] [pid-worker3] GET /io
[2024-10-29 17:04:18] [pid-worker0] GET /io
[2024-10-29 17:04:18] [pid-worker1] GET /io
[2024-10-29 17:04:18] [pid-worker2] GET /io
[2024-10-29 17:04:18] [pid-worker3] GET /io
{% endhighlight %}

In this example, `/io` is an endpoint with an IO-bound task that took 1 second to be completed. So, sending 16 requests at once to this route, Flask would handle a batch of 4 requests concurrently, taking a total time of 4 seconds to process all of them. As you can see from the timestamps, even though all requests were sent concurrently, the request `n` takes `⌊n/number_workers⌋*task_time` to respond.

That was happening because of two reasons:

 1. Flask is by default a *synchronous* framework
 2. Flask is based on WSGI, and WSGI uses *one worker* to handle *one request/response* cycle

I had this issue a while ago. Since then, [Flask 2.0](https://flask.palletsprojects.com/en/stable/changes/#version-2-0-0) was released with support for [async views](https://github.com/pallets/flask/pull/3412/commits/6979265fa643ed982d062f38d386c37bbbef0d9b), adding a more support for asynchronous tasks. Even though I was no longer working with Flask when this feature was released, I wanted to try the new `async views` and experience _some wild gains_.

I created an `async` route for a similar, now asynchronous task, and the access logs looked like this:

{% highlight text %}
[2024-10-29 17:37:30] [pid-worker0] GET /async-io
[2024-10-29 17:37:30] [pid-worker1] GET /async-io
[2024-10-29 17:37:30] [pid-worker2] GET /async-io
[2024-10-29 17:37:30] [pid-worker3] GET /async-io
[2024-10-29 17:37:31] [pid-worker0] GET /async-io
[2024-10-29 17:37:31] [pid-worker1] GET /async-io
[2024-10-29 17:37:31] [pid-worker3] GET /async-io
[2024-10-29 17:37:31] [pid-worker2] GET /async-io
[2024-10-29 17:37:32] [pid-worker1] GET /async-io
[2024-10-29 17:37:32] [pid-worker0] GET /async-io
[2024-10-29 17:37:32] [pid-worker2] GET /async-io
[2024-10-29 17:37:32] [pid-worker3] GET /async-io
[2024-10-29 17:37:33] [pid-worker1] GET /async-io
[2024-10-29 17:37:33] [pid-worker2] GET /async-io
[2024-10-29 17:37:33] [pid-worker3] GET /async-io
[2024-10-29 17:37:33] [pid-worker0] GET /async-io
{% endhighlight %}

And... it was exactly the same! It still took 4 seconds for all 16 requests to be completed.

After the initial disappointment, I looked for answers in the Flask documentation, and this very helpful [performance](https://flask.palletsprojects.com/en/stable/async-await/#performance) section clarified my troubles.

Even though my request was now asynchronous, Flask is still using WSGI, which means that one worker handling one request/response cycle is still the case. The request is assigned to an available worker, if the route is an `async view`, Flask initializes an event loop in a thread, runs the task there, and returns the result.

Here is `Worker0` processing a request to a synchronous route:

{% highlight ascii %}
              ┌──────────────────────────┐
   Request    │        ┌───────────────┐ │
──────────────► Worker0│/io            │ │
◄─────────────┬────────┤def ...        │ │
   Response   │        └───────────────┘ │
              └──────────────────────────┘
{% endhighlight %}


And here is `Worker1` processing a request to an asynchronous route:

{% highlight ascii %}
              ┌──────────────────────────┐
   Request    │        ┌───────────────┐ │       ┌───────────────┐
──────────────► Worker1│/async-io      │ │       │  Event Loop   │
◄─────────────┼────────┤async def ...  ~~~~~~~~~~►   └run Task0  │
   Response   │        └────────▲──────┘ │Thread └───────────────┘
              └─────────────────┼────────┘            │
                                │                     │
                                └─────────────────────┘
                                          Result
{% endhighlight %}

while `Worker2` is processing a request to an asynchronous route with multiple concurrent tasks:

{% highlight ascii %}
              ┌──────────────────────────┐
   Request    │        ┌───────────────┐ │       ┌───────────────┐
──────────────► Worker2│/async-io-multi│ │       │  Event Loop   │
◄─────────────┬────────│async def ...  ~~~~~~~~~~►   └run Task0  │
   Response   │        └────────▲──────┘ │Thread │   └run Task1  │
              └─────────────────┼────────┘       └───────────────┘
                                │                     │
                                └─────────────────────┘
                                          Result
{% endhighlight %}

Since I had a single asynchronous task per request, the worker being idle instead of switching to other incoming requests, makes the asynchronous benefit invisible.

If my IO-bound task could be divided in multiple concurrent tasks, then I would benefit from the `async view` feature.

For example, a scenario where you need to fetch data from multiple external APIs for a single request. If each API call takes 1 second and if you handle them either synchronously or asynchronously, your app might take several seconds to respond. But, if you split those requests into smaller concurrent tasks using async views, those can handled in parallel and respond much quicker.

With that in mind, I created another route to try that out, and the access logs for this case looked like:

{% highlight text %}
[2024-10-29 18:14:15] [pid-worker0] GET /async-io-multi
[2024-10-29 18:14:15] [pid-worker1] GET /async-io-multi
[2024-10-29 18:14:15] [pid-worker2] GET /async-io-multi
[2024-10-29 18:14:15] [pid-worker3] GET /async-io-multi
[2024-10-29 18:14:15] [pid-worker0] GET /async-io-multi
[2024-10-29 18:14:15] [pid-worker1] GET /async-io-multi
[2024-10-29 18:14:15] [pid-worker2] GET /async-io-multi
[2024-10-29 18:14:15] [pid-worker3] GET /async-io-multi
[2024-10-29 18:14:16] [pid-worker0] GET /async-io-multi
[2024-10-29 18:14:16] [pid-worker1] GET /async-io-multi
[2024-10-29 18:14:16] [pid-worker2] GET /async-io-multi
[2024-10-29 18:14:16] [pid-worker3] GET /async-io-multi
[2024-10-29 18:14:16] [pid-worker0] GET /async-io-multi
[2024-10-29 18:14:16] [pid-worker1] GET /async-io-multi
[2024-10-29 18:14:16] [pid-worker2] GET /async-io-multi
[2024-10-29 18:14:16] [pid-worker3] GET /async-io-multi
{% endhighlight %}

As you can see, dividing the task into two concurrent tasks, each taking 0.5 seconds, and using the same 4 workers. It processed 16 requests in 2 seconds, giving a 2x speed-up. In similar fashion, the request n for multiple concurrent tasks takes `⌊n/number_workers⌋*slowest_task_time` to return. If the task workload could be divided in even more tasks, there would be a benefit as well.

The real limitation lies with WSGI, which ties one worker to a request, limiting throughput due to the lack of an asynchronous request stack. An alternative, implemented by other fully asynchronous interfaces like ASGI, allows workers to handle multiple concurrent requests at once. Where, when an asynchronous task is blocked waiting for an IO-Bound operation, the worker can immediately switch to another request, optimizing resource usage and reducing latency. This approach favours frameworks based on ASGI, [FastAPI](https://fastapi.tiangolo.com/) for example.

To be able to visualize that, here's a simple comparison of response times for 100 requests to each framework, both using 4 workers, with the same tasks and similar routes based on the previous examples:

![Flask vs. FastAPI IO-Bound](https://imgur.com/mPf7TTe.png)

As you can see, FastAPI consistently performs better due to its ASGI foundation, while Flask’s async views still face limitations due to WSGI. FastAPI, in comparison to Flask, the synchronous endpoint `/io` is already blazing fast, taking less than 10% of the time Flask takes.

On the asynchronous endpoint with a single task `/async-io`, FastAPI is almost twice as fast than its own synchronous-self, and for the asychronous with multiple concurrent tasks `/async-io-multi` FastAPI is again almost twice as fast than its single-task-self.

Indeed, **async is not inherently faster than sync code**, even in a strictly IO-bound context and, that's specially true with Flask. Between all considerations, Flask does offer an interface for multiple concurrent IO-bound tasks, in which can be useful if you are able to subdivide your tasks in smaller chunks and optimize a few endpoints that are being slow. However, if you are doing mainly asynchronous tasks, it's worth considering other ASGI based frameworks.

---
- Both frameworks were run with 4 workers, using [Gunicorn](https://gunicorn.org/) as the WSGI server for Flask and [Uvicorn](https://www.uvicorn.org/) as the ASGI server for FastAPI;
- You can find the code for this post on [GitHub](https://github.com/belinhacbr/flask-perf).