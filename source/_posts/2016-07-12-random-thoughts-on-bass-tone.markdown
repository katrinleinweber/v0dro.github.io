---
layout: post
title: "Random thoughts on bass tone"
date: 2016-07-12 16:39:06 +0530
comments: true
categories: 
---

This post is about my learnings about bass tone. I'm currently using the following rig:

* Laney RB2 amplifier
* Tech 21 Sansamp Bass Driver Programmable DI
* Fender Mexican Standard Jazz Bass (4 string)

I will updating this post as and when I learn something new that I'd like to document or share. Suggestions are welcome. You can email me (see the 'about' section) or post a comment below.

#### 26 July 2016

As of now I'm tweaking the sansamp and trying to achieve good tone that will compliment the post/prog rock sound of my band [Cat Kamikazee](). I'm also reading up on different terminologies and use cases on the internet. For instance I found [this explanation](http://www.premierguitar.com/articles/solving-the-bass-di-dilemma-1) on DI boxes quite useful. For instance I learned that the 'XLR Out Pad' button on the sansamp actually provides a 20 db cut to the soundboard if your signal is too hot.

I am trying to couple the sansamp with a basic overdrive pedal I picked up from a friend. [This thread on talkbass](https://www.talkbass.com/threads/sansamp-bddi-pedal-placement.843750/) is pretty useful for that. The guy who answered the question states that it's better to place the sansamp last in the chain so that the DI can deliver the output of the sound chain.

So the BLEND knob on the sansamp modulates how much of the dry signal is mixed with the sansamp tube amplifier emulation circutry. Can be useful when chaining effects pedals with the sansamp by reducing the blend and letting more of the dry signal pass through. Btw the _bass_, _treble_ and _level_ controls remain active irrespective of the position of BLEND.

One thing that was a little confusing was the whole thing about 'harmonic partials'. I found a pretty informative thread about the same on [this TalkBass thread](https://www.talkbass.com/threads/what-are-upper-harmonics-or-harmonic-partials.471553/).

[Here's](http://www.studybass.com/gear/bass-effects/bass-compressor-settings/) an interesting piece on compressors.

Some more useful links I came across over the course of the past few days:

* https://theproaudiofiles.com/amp-overdrive-vs-pedal-overdrive/
* http://www.offbeatband.com/2009/08/the-difference-between-gain-volume-level-and-loudness/

#### 28 July 2016

Found an interesting and informative piece on bass pedals [here](http://www.premierguitar.com/articles/Bass_Pedals_Basic_to_Playhouse). It's a good walkthrough of different pedal types and their functionality and purpose.

I wanted to check out some overdrive pedals today but was soon sinking in a sea of terminologies. One thing that intrigued me is the difference between an overdrive, distortion and fuzz. I found a [pretty informative article](http://www.gibson.com/News-Lifestyle/Features/en-us/effects-explained-overdrive-di.aspx) on this topic. The author has the following to say about these 3 different but seemingly similar things.

I had a look at the Darkglass b3k and b7k pedals too. They look like promising overdrive pedals. I'll explore the b3k more since the only difference between the 3 and the 7 is that the 7 also functions as a DI box and has an EQ, while the 3 doesn't. I already have a DI with a 2 band EQ in the sansamp.

#### 29 July 2016

One thing that I noticed when tweaking my sansamp is the level of 'distortion' in my tone varies a LOT when you change the bass or treble keeping the drive at the same level. Why does this happen?

#### 2 August 2016

Trying to dive further into distortion today. Found [this](http://www.tyquinn.com/2009/lead-tone-part-3-distortion/) article kind of useful. It relates mostly to lead guitar tones, but I think it applies in a general case too. I learned about symmetric and asymmetric clipping in that article. 

According to the article, symmetric clipping is more focused and clear, because it is only generating one set of harmonic overtones. Since asymmetric clipping can be hard-clipped on one side, and soft-clipped on the other, it has the potential to create very thick complex sounds. This means that if you want plenty of overtones, but do not want a lot of gain, asymmetric clipping can be useful. For full-blown distortion symmetric clipping is usually more suitable, since high-gain tones are already very harmonically complex. _Typically asymmetric clipping will have a predominant first harmonic, which the symmetric clipping will not_ (that's probably why in [this](https://www.youtube.com/watch?v=pzua3-xZKHM) video, the SD1 sounds brigther than than the TS-9). High gain distortion tones sound best with most of the distortion coming from the pre-amp, so try to use a fairly neutral pickup or even a slightly 'bright' pickup.

The follow up to the above post [talks about EQ in relation with distortion](http://www.tyquinn.com/2009/lead-tone-part-4-eq-for-distortion-voicing/). It has stuff on pre and post EQ distortion and how it can affect the overall tone. If you place the EQ before the distortion, you can actually shape which frequencies will be clipped. However if you place it after the distortion then the EQ will only act for shaping the already distorted tone. Pre-dist EQ is more useful in most cases since it let's you control the frequencies for clipping.

It also says that humbucking pickups have a mid-boost that is more focused by the lower part of the frequency range. Single coil pickups on the other hand have a mid-boost focused by the upper part of the frequency range. Single coils generally have clearer, more articulate bass end.

#### 3 August 2016

Read something about bass DI in [this](http://www.bestbassgear.com/ebass/gear/electronics/pedals/why-is-di-so-important-to-bass-players.html) article today.

#### 10 October 2016

Posting after quite a while!

Reading about the use of compression for bass guitars. Found [this article](http://www.studybass.com/gear/bass-effects/bass-compressors/) which explains why we need compression in the first place.

Also, my band's installation of Main Stage 3 has started giving some really weird problems. More about that soon.

#### 11 October 2016

Coming back to Main Stage. For some reason, pressing Space Bar for play/pause reduces the default sampling rate and makes the tracks sound weird. We need to go to preferences and increase the sampling rate to 48 kHz again (that's what our backing tracks are recorded at). I think its something to do with the key mappings, but I'm not sure. Will need to check it out.

It also so happens that after the space bar has been pressed and the issue with the sampling rate is resolved, the samples (which come from a M-Audio M-Track) start emitting a strange crackling sound. This sounds persists only if the headphones are connected into the audio jack (we use the onboard Mac sound card too). The sound goes away if the headphones are unplugged. Restarting the Mac resolves the issue. I suspect there might be a way without having to restart. Will investigate.
