********************************
Action Nomenclature
********************************

Let us talk about Nomenclature first

.. _action:

Action
======

An action is a smart contract which can be triggered to take certain action or execute a strategy based on
the result of a poll. They are triggered by transactions and carry out the instructions in a 'code is law’ fashion.

How are they related to polls?
------------------------------

Actions carry out certain pre decided tasks based on the outcome of consensus, or a combination
of such outcomes. Hence, it is crucial for these contracts to be linked with the polls that are
relevant to it.
Some examples of poll driven actions are:
A) Tap increment on a daico contract
B) Re-electing the admin of an entity contract


Are polls necessary?
--------------------

It is possible for actions to seek information directly from the entity as opposed to polls. Actions
taking messages from polls are Action Based on Consensus type(ABC), and actions reading
directly from entities are Action Based on Membership type(ABM).