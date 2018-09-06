********************************
Protocol Nomenclature
********************************

Let us talk about Nomenclature first

.. _entity:

Entity
======

The entity is a smart contract designed to track membership. It is operated by the contract owner, called the
admin. The entity contains information about which ethereum addresses are part of the governance unit.


.. _poll:

Poll
====

A poll is a smart contract designed to track votes of people belonging to a certain entity, or combination of
entities. The poll contains information about what the governance unit wishes for in a certain matter.

.. _action:

Action
======

An action is a smart contract which can be triggered to take certain action or execute a strategy based on
the result of a poll. They are triggered by transactions and carry out the instructions in a 'code is law’ fashion.