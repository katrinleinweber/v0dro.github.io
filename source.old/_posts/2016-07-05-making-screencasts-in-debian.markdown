---
layout: post
title: "Making screencasts in Debian"
date: 2016-07-05 13:07:45 +0530
comments: true
categories: 
---

# Overview

I thought I'll try something new by recording screencasts for some of my [work on Ruby](https://github.com/v0dro) open source libraries.

This is quite a change for me since I'm primarily focused on the programming and designing side of things. Creating documentation is something I've not ventured into a lot except the usual [YARD markup](http://yardoc.org/) for Ruby methods and classes.

In this blog post (which I will keep updating as time progresses) I hope to document my efforts in creating screencasts. Mind you this is the first time I'm creating a screencast so if you find any potential improvements in my methods please point them out in the comments.

# Creating the video

My first ever screencast will be for my [benchmark-plot](https://github.com/v0dro/benchmark-plot) gem. For creating the video I'm mainly using two tools - [Kdenlive](https://kdenlive.org/) for video editing and [Kazam](https://launchpad.net/kazam) for recording screen activity. I initially tried using [Pitivi](http://www.pitivi.org/) and [OpenShot](http://www.openshot.org/) for video editing, but the former did not seem user friendly and the latter kept crashing on my system. For the desktop recording I first tried using [RecordMyDesktop](http://recordmydesktop.sourceforge.net/about.php) but gave up on it since it's too heavy on resources and recoreded poor quality screencasts with not too many customization options.

For creating informative visuals, I'm using [LibreOffice Impress](https://www.libreoffice.org/discover/impress/) so that I can create a slide, take it's screenshot when in slideshow mode and put in the screencast. However I've generally found that using slides does not serve well the content delivery in a screencast and will probably not feature too many slides in future screencasts.

[Sublime Text 3](https://www.sublimetext.com/3) is my primary text editor. I use it's in built code execution functionality (by pressing `Ctrl + Shift + B`) to execute a code snippet and display the results immediately.

# Creating the audio

I am using Audacity for recording sound. Sadly my mic produces a lot of noise, so for removing that noise in Audacity, I use the inbuilt noise reduction tools.

Noise reduction in Audacity can be achieved by first selecting a small part of the sound that does not contain speech, then go to Effects -> Noise Reduction and click on 'Get Noise Profile'. Then select the whole sound wave with `Ctrl + A`. Go to Effects -> Noise Reduction again and click 'OK'. It should considerably reduce static noise from your sound file.

All files are exported to Ogg Vorbis.

# Putting it all together

I did some research on the screencasting process and found [this article](http://devblog.avdi.org/2013/01/21/my-screencasting-process/) by Avdi Grimm and [this one](https://build-podcast.com/setup/) by Sayanee Basu extremely helpful.

I first started by writing the transcript along with any code samples that I had to show. I made it a point to describe the code being typed/displayed on the screen since it's generally more useful to have a voice over explaning the code than having to pause the video and go over it yourself.

Then I recorded the voice over just for the part that featured slides. I imported the screenshots of the slides in kdenlive and adjusted them such that they fit the voice over. Recording the code samples was a bit of a challenge. I started typing out the code and talking about it into the mic. This was more difficult than I thought, almost like playing a Guitar and singing at the same time. I ended up recording the screencast in 4 separate takes, with several retakes for each take.

After importing the screencast with voice over into kdenlive and separating the audio and video components, I did some cuts to reduce redundancy or imperfections in my VO. Some of the parts of the video where there was a lot of typing had to be sped up by using kdenlive's Speed tool.

Once this was upto my satisfaction, I exported it to mp4.

The video of my first screencast is now up on YouTube in the video below. Have a look and leave your feedback in the comments!

<iframe width="560" height="315" src="https://www.youtube.com/embed/WW6M4Df-soQ" frameborder="0" allowfullscreen></iframe>