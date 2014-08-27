---
layout: post
title: "[code]Managing Large Open Source Projects: for Beginners."
date: 2014-08-27 16:59:16 +0530
comments: true
categories: 
---

I had just started writing some meaningful code in college and gaining an interest in scientific computation, and really wanted to apply my knowledge somewhere and create a real impact. That is when I read about the ruby [NMatrix](https://github.com/sciruby/nmatrix) gem and thought maybe I'd contribute some code, both for experience in dealing with non-trivial software and the personal satifaction derived from the feeling of my work being used by people around the world.

I cloned and installed the source code like any other programmer would, and just as I first open the Issue tracker to find a project to work on, I was hit by an avalanche of information ranging from bugs, documentation appeals, and new feature requests. And this was nothing compared to my first reaction upon going through the source code. Having never worked with more than a few files of source in college, I was dwarfed by the scores of source files and hundreds of method definitions that hung above me like a mountain. I quickly discovered that software is no small thing and that to make real, non-trivial, production grade software requires a certain discipline, focus and patience.

I had never dealt with something like this before, and set out to discover books/courses that would enlighten me on the topic. Most of the blog posts that I came across told me to keep looking through the code and that eventually I would become good at it. While this is true, none spoke of any specific methods to use to get out of this dilemma. It was then that I came across the course [Learning How To Learn](https://www.coursera.org/course/learning), and after enrolling and seeing it through, I must say I have gained quite an insight into managing large software and even my day to day activities, the course having encompassed a large variety of practtical scenarios.

I have written this blog post for the final assignment of the course, which asks me to share the insights I have gained with people who might be in the same dilemma that I was in. I hope you find it helpful.

When first faced with something that you are not trained to handle, you tend to get overwhelhmed and try to avoid it, even dislike it. But this takes you nowhere close to the goal that you might want to accomplish. You just stagnate in the exact same spot that you initially were in and you never really move ahead.

To move ahead, it is important to focus your energies and force yourself to work on a particular problem for a length of time. But how does one do this? And for what length of time? After taking the course, I learned that the mind, at any time, is basically in two modes of thinking, the focused mode and the diffused mode.

Your mind is in the focused mode when you are intently focusing on, say implementing a tree travelsal algorithm that your professor might have told you to implement. Focused mode is required in situations where you know *exactly* what you're looking for and want to devise a method of getting there.

The focused mode, however, is not much use when first faced with a large software project. Focusing on just one aspect of the system the first time will leave you more confused than before and more often than not, any changes that you make will create more problems that you'd want to care about.

Scenarios like these are where the diffused mode comes to the rescue. In the diffused mode, the mind is capable of thinking about many things at a time, maybe not making sense of them all, but creating connections between them nonetheless. It is a phase of light concentration that your mind goes through, with the problem you want to solve lightly running in the background. The diffused mode is what helps in making sense of a large project.

You must first learn to relax, sit back and take stock of the entire project and at the same time keep in mind the new functionality that you want to implement or the bug that you want to quash. Try to simply read the names of the files and folders and try to connect them with your problem. Most Open Source projects use very strict conventions and upon lightly thinking for a while you will stumble upon a particular file or folder that will be relevant to what you are looking for.

The diffused mode will only help you in getting a larger picture of things. Once you have a tentative idea of where you might find the problem area, then it is time to switch to the focused mode and dive into ONLY that particular file/function that you think is the right one. Do not think of anything else while searching in the place your diffused mode has taken you to.

You first think in the diffused mode, and then the focused mode. Keep repeating this procedure until you solve the problem, and you will find that eventually, you can intuitively figure out where a particular line of code might reside.

Thinking in the focused mode requires practice, and you will soon realize that you tend to feel distracted after some focused thinking. This is where certain techniques for focused mode thinking come into play. One of the best and easiest to practice is the 'Pomodoro' technique, which advocates being focused for 25 min. and then taking a short break for 5 min., then keep repeating this cycle until you think you've had enough. 

While focusing it is extremely important to focus ONLY on the problem at hand and nowhere else. You should typically sit in a quiet environment and away from distractions if you want pomodoro to work for you. While taking a break, do some light activity, like taking a walk around your work area or watching a small TED talk. Pomodoro has worked wonders for me and I highly recommend using it. You can use one of the scores of mobile apps available for setting a pomodoro timer.

One of the most dangerous things to be absolutely careful about is procrastination. It is very easy to get carried away by some fancy code that you come across for the first time while tracing method calls  and completely forget about the problem that you are trying to tackle. Procrastination happens when you allow yourself to get carried away. It leads you to think that you've done a lot of work, when in reality you have done nothing.

If faced by a somewhat difficult problem, write it down on a Post-It note and stick it in a place that is always within your field of view, like in my case, my desk or the palm rest of my laptop. Keep looking at what's written on this note and periodically ask yourself, "Am I closer to solving the problem than I was before?", "Will the particular line of code that I am reading right now be of any use in solving this problem?". If your answers to these questions are negative, you need to realign yourself and remind yourself to get back to work.

Over and above the techniques mentioned above, also remember to break your problem down into small, manageable chunks, and go after one chunk at a time. Also, be sure to mentally go over these chunks once you're done with your current session so that things will be more clear next time.If you're having problems in visualizing an algorithm or the flow of a program, take a piece of paper and write down whatever you understand, and you will find that the rest will become clear once you ponder over what you have written. Theres only so much that your memory can store.

Over and above, have fun programming. Its a great thing to do, really.