********************************
Poll Nomenclature
********************************

Let us talk about Nomenclature first

.. _poll:

Poll
====

A poll is a smart contract designed to track votes of people belonging to a certain entity, or combination of
entities. The poll contains information about what the governance unit wishes for in a certain matter.

How are they related to an Entity?
---------------------------------

Polls aggregate voting information based on 2 things::

> Whether or not the voter is a member of a specific entity or combination of entities, for example:
must be a member of entity X and not a member of entity Y.
> A vote weightage policy, for example: proportional to some token balance, or proportional to time
locked tokens, or delegated democracy etc.

Polls can also be divided into time bound or time unbound polls. Bound polls stop recording votes after a
certain time while unbound polls continually record votes with no time bound.


Kinds of polls
--------------

There is no limit to the kind of vote weightage policy, so several kinds of polls can be made. Some examples which
illustrate this fact: 

    1. One person - One Vote
    2. Token weight with freeze
    3. Delegated voting
    4. Karma voting;
    5. Token weight times Stake Duration