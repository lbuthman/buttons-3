# Buttons, and More!

With many ideas floating around at any one given time, a few ideas have come together
and taken shape.
    1. Levels Jerry, levels! [ref](https://www.youtube.com/watch?v=aQyXeLSL0II&ab_channel=Indigoblue25)
    2. Luke, the Cowboy Coder: trail guide
    3. App Driven Development, Domain Driven Development, & Unlocked Org-Dependent Packages
    4. Wanting to know it all

## Levels Jerry, Levels! [ref](https://www.youtube.com/watch?v=aQyXeLSL0II&ab_channel=Indigoblue25)

Well, not levels exactly, but Buttons. Buttons Jerry, buttons! This is an exploration in how
users really would like to use Salesforce, given they knew what was possible. In reality, we
have a huge degree of cognitive tech debt. Luckily, Salesforce emerges from the need for low
level implementation, understanding, or thinking. Salesforce developers are blessed to think
and work in a high level language and framework, that is incredibly dynamic, flexible and 
powerful. With this degree of power comes responsibility. Responsibility to whom? To our customers!

And that can be a little misunderstood, because our customers are typically our internal business
users. As Salesforce developers and administrators, our primary customer is the supporting 
structures that enable the business's customers. And even when we expose data to the same customer
base, with things like Experience Cloud and more, we have deeper games going aimed at serving
our business users.

These kinds of user may be more or less tech-savvy, and the definition of what is tech-savvy is
relative to the group and may be far away from we developers and adminstrators. Seen in such
a light, what is the most optimal, easily understood, and intuitive UI experience. The idea
I have in my mind now is Buttons! Kinda like how buttons drive our smart phone interactions and
user experience. Smart phones are so intuitive, even small children can figure them out quickly.

## Luke, the Cowboy Coder: trail guide

There are a couple other personas as marketing gimmicks and means for a little fun. This one is
Cowboy Coder, a friendly trail guide to help with accomplishing badges, putting badges together,
and providing hikes to build on the skills introduced in the badges. The Salesforce badges
introduce the concepts and provide some ideas for further exploration. The Cowboy Coder provides
experiences to navigate those explorations.

## App Driven Development, Domain Driven Development, & Unlocked Org-Dependent Packages

After reading through portions of the Big Blue Book [ref](), I became confident that thinking in domains
was the way to go for organizing Salesforce metadata and architecture. The ability to group
like functionality in an independent code repository is to overcome the Happy Soup [ref]() of the past.
Using Org-Dependent Unlock Packages is a way to do this so simply. And as far as I can tell,
the only case for normal 2Gen Unlocked Packages is when the metadata needs to be dependent of the
org, in cases where large organizations need this ability or when release small, independent,
reusable tools like the Nebula Logger [ref]().

The key really came to me when I found what I believe is the start point order of abstraction for
development in Salesforce, given this model. The starting point is the App (via App Manager), 
and it is composed of Lightning Apps and configurations. With the ubiquitous language of DDD and the
segregation of metadata into O-DUPs, the domain is encapsulated cognitively and technically.

## Wanting to know it all, introducing Guided Hikes

Haven't we all been here before? You just learned something knew or saw something inspiring, and
now you want to keep going! What else can I learn?! What else can I do?! This takes a process
and is a long term investment. The guided hike
