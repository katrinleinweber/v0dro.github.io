---
layout: post
title: "An Overview Of Automatic Speech Recognition"
date: 2014-10-01 18:59:11 +0530
comments: true
categories: 
---
Speech is the fundamental method of communication between human beings. Everyone within Human civilization, whether literate or illiterate, can communicate with the people around them through speech.

Using a computer can be a scary proposition for most people. It involves GUIs, text, images, video; intangible entities that many first time users are unable to relate to.

In contrast to the rapid evolution of computing, development of modes of communication between human and computer has been painfully slow and has been primarily restricted to text, images, videos and the like. 

This is where the idea of Automatic Speech Recognition comes in. It aims to bridge the communication gap between humans and computers and bring it as close as possible to a human-human interaction. In aims to teach a computer the primary method of communication between humans: speech.

To cite Wikipedia, Automatic Speech Recognition is the translation of spoken words into text. Once we have text (which is the most portable method of information transfer), we can do absolutely anything with it.

In this article, we will be gaining a brief overview of Automatic Speech Recognition (ASR), and take a look at a few algorithms that are used for the same. Most of the methods listed here are language neutral, unless explicitly stated. Let us start with how speech is actually produced by a normal Human being.

The primary organ of speech production is the Vocal Tract. The lungs push out the air, which passes through the vocal tract and mouth and then is released into the atmosphere. On its way out of the mouth, the air is manipulated by a series of obstacles present in the vocal tract, nose and mouth. These manipulations in the raw air pushed through the lungs manifest as speech. 

Air first passes through the glottis, which is the combination of the vocal folds (vocal cords) and the space in between the folds. It then passes through the mouth, where the tongue plays a major role in overall speech modulation. Factors like constriction of the vocal tract (for /g/ in 'ghost'), aspirated stops and nasal tones play a major role in modulating the overall sound wave.

{% img center /images/speech_recognition/glottis.jpg "An Diagram Of The Human Glottis"%}

The primary organ of speech production is the Vocal Tract. The lungs push out the air, which passes through the vocal tract and mouth and then is released into the atmosphere. On its way out of the mouth, the air is manipulated by a series of obstacles present in the vocal tract, nose and mouth. These manipulations in the raw air pushed through the lungs manifest as speech. 

Air first passes through the glottis, which is the combination of the vocal folds (vocal cords) and the space in between the folds. It then passes through the mouth, where the tongue plays a major role in overall speech modulation. Factors like constriction of the vocal tract (for /g/ in 'ghost'), aspirated stops and nasal tones play a major role in modulating the overall sound wave. 

For the purpose of processing speech using computers, there is a need to digitize the signal. When we receive a speech signal in a computer, we first sample the analog signal at a frequency such that the original waveform is completely preserved. We then perform some basic pre-filtering; for example, observations indicate that human speech is the range of 0-4 kHz, so we pass the sampled signal through a low-pass filter to remove any frequecies above 4 kHz.

Before proceeding with the working of an ASR, we make some fundamental assumptions: 
* Vocal tract changes shape rather slowly in continuos speech and it can be assumed that the vocal tract has fixed shape and characterestics for 10 ms. Thus on an average, the shape of the vocal tract changes every 10 ms.
* Source of excitation (lungs) and vocal tract are independent of each other.

To extract any meaning from sound, we need to make certain measurements from the sampled wave. Let us explore these one by one:

* Zero Crossing Count - This is number of times the signal crosses the zero-line per unit time. This gives an idea of the frequency of the wave per unit time.
* Energy - Energy of a signal is represented by the square of each sample of the signal, over the entire duration of the signal. 

{% img center /images/speech_recognition/energy_equation.jpg "Energy Equation" %}

* Pitch period of utterances - It is found that most utterances have a certain 'pseudo periodicity' associated with them. This is called the pitch period.

Speech can be classified into two broad categories - VOICED speech(top) and UNVOICED speech(bottom).

{% img center /images/speech_recognition/voiced_speech.jpg "Waveform of voiced speech" %}
{% img center /images/speech_recognition/unvoiced_speech.jpg "Waveform of unvoiced speech" %}

Voiced speech is characterized in a signal with many undulations (ups and downs). Voiced signals tend to be louder like the vowels /_a_/, /_e_/, /_i_/, /_u_/, /_o_/. Unvoiced speech is more of a high frequency, low energy signal, which makes it difficult to interpret since it is difficult to distinguish it from noise. Unvoiced signals, by contrast, do not entail the use of the vocal cords, for example, /_s_/, /_z_/, /_f_/ and /_v_/. 

A basic ASR will consist of three basic steps - 

* End Point Detection - Marking the beginning and ending points of the actual utterance of the word in the given speech signal is called End Point Detection.
* Phoneme[^3] Segmentation - Segregating individual phonemes from a speech signal is called Phoneme Segmentation.
* Phoneme Identification - Recognizing the phoneme present in each phoneme segment of the waveform is called Phoneme Identification. 

Every step in the speech recognition process is an intricate algorithm in itself, and over the years, numerous approaches have been suggested by many people. Let us look at a few simple ones: 

* End Point Detection:
    - We make use of the Zero Crossing Count and Energy parameters of a sound wave for calculating the end points of an utterance in an input sound wave.- It assumes that the first 100 ms of the speech waveform are noise. Based on this assumption, it comes up with the ZCC and energy of the noise signal, through which it computes the points where the speech segment begins and ends. A detailed discussion would be out of the scope of this article, but those interested can always go through the paper written by Rabiner and Sambur[^1].

{% img center /images/speech_recognition/waveform_and_end_points.jpg "A speech waveform (top) and the detected End Points (bottom)" %}

* Phoneme Segmentation
    - This step in the process is the most important step because what Phoneme gets detected from a particular speech waveform is completely dependent on what wave we pass to the Phoneme Recognition algorithm. 
    - The algorithm proposed by Bapat and Nagalkar[^2] functions based on the fact that each phoneme will have a different energy and amplitude, and whenever a variation drastic deviation in these parameters is detected in the sound wave, it is marked as a different phoneme.

* Phoneme Recognition
    - This is by far the most intriguing and researched. Extensive work has been done in this domain, ranging from simple spectral energy analysis of signals, to more complicated Neural Network algorithms. One can find several hypotheses all over the internet regarding this domain. A discussion on these algorithms would get too large, but we will discuss a very simple algorithm which utilises the frequency domain representation of a signal to segregate 'varnas' or classes of Phonemes found in the Devnagiri script: 
        - Each class of phonemes in Devnagiri is generated using the same organ but with different air pressure and time of touch for each individual alphabet. This property of Devangiri can be used for detecting only the class of a particular phoneme. 
        - If we divide the entire frequency axis of 4 kHz into 17 bands of ~ 235 Hz each, and observe some sample utterances through this grid, we find that the phonemes of a particular class show peak frequencies in the same band or a very predictable set of 2-3 bands. Taking note of these peaks, one can identify the phoneme class by observing which bands the peaks fall into. 

We have discussed some major characterestics and components of an Automatic Speech Recognition engine, and have also seen some interesting facets of digital signals along the way. 

It is interesting to note how some basic principles of Digital Signal Processing can be applied to the real world for useful applications. 

--------------------------------------------------------------------------

[^1]: [An Algorithm For Determining The Endpoints For Isolated Utterances ; L.R. Rabiner and M.R. Sambur](http://web.cs.wpi.edu/~cs529/f04/slides/RS75.pdf)

[^2]: [Phonetic Speech Analysis for Speech to Text; A. V. Bapat, L. K. Nagalkar](http://ieeexplore.ieee.org/xpl/login.jsp?tp=&arnumber=4798390&url=http%3A%2F%2Fieeexplore.ieee.org%2Fiel5%2F4796894%2F4798312%2F04798390.pdf%3Farnumber%3D4798390)

[^3]: Phoneme - A phoneme is a basic unit of a language's phonology, which is combined with other phonemes to form meaningful units such as words. Alternatively, a phoneme is a set of phones or a set of sound features that are thought of as the same element within the phonology of a particular language. 
