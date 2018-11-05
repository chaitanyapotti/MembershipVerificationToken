# Membership Verification Token

<!-- <img align="center" src="./img/colonyNetwork_color.svg" /> -->

[![Gitter chat](https://badges.gitter.im/gitterHQ/gitter.png)](https://gitter.im/MembershipVerificationToken/Lobby)
[![CircleCI](https://circleci.com/gh/chaitanyapotti/MembershipVerificationToken/tree/master.svg?style=shield)](https://circleci.com/gh/chaitanyapotti/MembershipVerificationToken/tree/master)
[![Greenkeeper badge](https://badges.greenkeeper.io/chaitanyapotti/MembershipVerificationToken.svg)](https://greenkeeper.io/)
[![codecov](https://codecov.io/gh/chaitanyapotti/MembershipVerificationToken/branch/master/graph/badge.svg)](https://codecov.io/gh/chaitanyapotti/MembershipVerificationToken)

## Install

```
git clone https://github.com/chaitanyapotti/MembershipVerificationToken.git
cd MembershipVerificationToken
npm install
```

## Contracts

The protocol level contracts use OpenZeppelin extensively for referencing standard EIPs.
Membership Verification Token utilizes OpenZeppelin's implementations for EIP-165 and EIP-173.
Please refer to OpenZeppelin's github page [here](https://github.com/OpenZeppelin/openzeppelin-solidity)

## truffle

To use with Truffle, first install it and initialize your project with `truffle init`.

```sh
npm install -g truffle@beta
mkdir myproject && cd myproject
truffle init
```

## Installing Membership Verification Token

After installing either Framework, to install the Membership Verification Token library, run the following in your Solidity project root directory:

```sh
npm init -y
npm install --save MembershipVerificationToken
```

After that, you'll get all the library's contracts in the `node_modules/MembershipVerificationToken/contracts` folder. You can use the contracts in the library like so:

```solidity
import 'MembershipVerificationToken/contracts/Protocol/IElectusProtocol.sol';

contract MyContract is IElectusProtocol {
  ...
}
```

#Linting
To lint solidity, use

```sh
node ./node_modules/solhint ./contracts/poll/BasePoll.sol
```

For linting Solidity files you need to run Solhint with one or more Globs as arguments. For example, to lint all files inside contracts directory, you can do:

```sh
solhint "contracts/**/*.sol"
```

To lint a single file:

```sh
solhint contracts/MyToken.sol
```

To disable linting for next line, use

// solhint-disable-next-line

To use eslint,

```sh
node .\node_modules\eslint\bin\eslint.js . --fix
```

## Testing

Unit test are critical to the Membership Verification Token framework. They help ensure code quality and mitigate against security vulnerabilities. The directory structure within the `/test` directory corresponds to the `/contracts` directory. OpenZeppelin uses Mocha’s JavaScript testing framework and Chai’s assertion library. To learn more about how to tests are structured, please reference Membership Verification Token's Testing Guide.

To run all tests:

Start ganache-cli or other testrpc

```
npm run test
truffle test
```

## Security

Membership Verification Token is meant to provide secure, tested and community-audited code, but please use common sense when doing anything that deals with real money! We take no responsibility for your implementation decisions and any security problem you might experience.

The core development principles and strategies that Membership Verification Token is based on include: security in depth, simple and modular code, clarity-driven naming conventions, comprehensive unit testing, pre-and-post-condition sanity checks, code consistency, and regular audits.

If you find a security issue, please email [chaitanya@electus.network](mailto:chaitanya@electus.network).

## Contributing

For details about how to contribute you can check the [contributing page](CONTRIBUTING.md)
