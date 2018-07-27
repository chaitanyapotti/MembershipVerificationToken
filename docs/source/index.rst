Electus Protocol
===========================================

.. image:: Electus.svg
    :width: 250px
    :alt: Electus logo
    :align: center

Electus Protocol is a standard interface for Membership Verification Token(MVT).

The following standard allows for the implementation of a standard API for Membership Verification Token within smart contracts(called entities). 
This standard provides basic functionality to track membership of individuals in certain on-chain ‘organizations’. 
This allows for several use cases like automated compliance, and several forms of governance and membership structures.

We considered use cases of MVTs being assigned to individuals which are non-transferable and revocable by the owner. MVTs can represent proof of recognition, proof of membership, proof of right-to-vote and several such otherwise abstract concepts on the blockchain. The following are some examples of those use cases, and it is possible to come up with several others:

* Voting: Voting is inherently supposed to be a permissioned activity. So far, onchain voting systems are only able to carry out voting with coin balance based polls. This can now change and take various shapes and forms.
* Passport issuance, social benefit distribution, Travel permit issuance, Drivers licence issuance are all applications which can be abstracted into membership, that is belonging of an individual to a small set, recognized by some authority as having certain entitlements, without needing any individual specific information(right to welfare, freedom of movement, authorization to operate vehicles, immigration)
* Investor permissioning: Making regulatory compliance a simple on chain process. Tokenization of securities, that are streamlined to flow only to accredited addresses, tracing and certifying on chain addresses for AML purposes.
* Software licencing: Software companies like game developers can use the protocol to authorize certain hardware units(consoles) to download and use specific software(games)


In general, an individual can have different memberships in his day to day life. The protocol allows for the creation of software that puts everything all at one place. 
His identity can be verified instantly. Imagine a world where you don't need to carry a wallet full of identity cards (Passport, gym membership, SSN, Company ID etc) and organizations can easily keep track of all its members. 
Organizations can easily identify and disallow fake identities.

Useful links
------------

* `Electus Network <https://electus.network>`_

* `Source Code <https://github.com/chaitanyapotti/ElectusProtocol/>`_

* `Ethereum Stackexchange <https://ethereum.stackexchange.com/>`_

* `Gitter Chat <https://gitter.im/electusnetwork/electusprotocol/>`_


.. note::
    The best implementation of Electus Protocol right now is
    `Electus Network <https://electus.network/>`_.
    Electus Network is a sample implementation but not the most
    exhaustive version.

.. warning::
    Since software is written by humans, it can have bugs. Thus, also
    smart contracts should be created following well-known best-practices in
    software development. This includes code review, testing, audits and correctness proofs.
    Also note that users are sometimes more confident in code than its authors.
    Finally, blockchains have their own things to watch out for, so please take
    a look at the section :ref:`Security_considerations`.


Contents
========

:ref:`Keyword Index <genindex>`, :ref:`Search Page <search>`

.. toctree::
   :maxdepth: 2

   entity.rst
   polls.rst
   actions.rst
   products.rst
   security-considerations.rst
   contributing.rst
   faq.rst