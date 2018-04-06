

### BHM - Decentralized Property Transaction & Investment Platform
Welcome to BHOM contracts source repository. BHOM, which stands for BLOCKCHAIN HOME, is a blockchain-based property transaction & funding platform. It is a DApp commercial service which allows users to quickly and safely invest in properties using smart contracts and cryptocurrency.

### Resources
#### 1. [Contracts](./contracts)
#### 2. [Documents](./docs)
#### 3. [Website](https://bhom.io)
#### 4. [White Paper](http://bhom.io/common/BHOMwhitepaper_eng.pdf)
#### 5. [Telegram Group](https://t.me/BHOMproject)

### BHOM 플랫폼의 구조
BHOM 플랫폼은 여러 단위로 구성되어 있으며 컨트랙은 그 중의 일부입니다. 각 단위들은 기능과 권한에 따라서 분리되어 있으며, 컨트랙을 제외한 단위들은 보안상의 이유로 공개하지 않는 것을 원칙으로 하고 있습니다. BHOM 플랫폼의 구성 단위로는 컨트랙, 프론트엔드, 백엔드 서버, DB 서버, 어드민 서버, 이벤트 수신 서버가 있습니다.

1. BHOM 컨트랙

BHOM 컨트랙은 solidity라는 언어로 작성되었으며 이더리움 네트워크를 이용합니다. 컨트랙에는 크고 무거운 정보들이 아닌 가장 중요한 최소한의 정보들만이 기록되며, 컨트랙의 변동사항들은 이벤트 수신 서버를 통해서 DB에 기록됩니다.

2. 프론트엔드

프론트엔드는 web3와 metamask를 이용합니다. 사용자의 정보, 특히 지갑을 열람할 수 있는 키에 관한 정보는 BHOM 플랫폼에 저장되어서는 안됩니다. 사용자는 metamask를 통해서 본인의 키에 접근하고 인증을 할 것이며, BHOM 플랫폼에 키에 관한 정보를 제공하지 않고도 스마트 컨트랙에 접근하고 서명하는 것이 가능할 것입니다. 

3. 백엔드 서버

플랫폼의 백엔드 서버는 spring framework로 구성되어 있습니다. 백엔드 서버는 사용자에게 보여주어야 하는 정보들을 DB에서 불러와서 재가공하며, 프론트엔드로 넘겨줍니다. 또한 스마트 컨트랙에 담을 필요가 없는 정보들을 받아서 전통적인 형태의 DB에 저장하는 역할도 담당하고 있습니다. 

4. DB 서버

전통적인 형태의 DB 서버에는 스마트 컨트랙에 담기 어려운 무거운 정보들과 스마트 컨트랙을 찾아가기 위한 일종의 인덱스들을 저장하고, 스마트 컨트랙에 변동 사항이 발생했을 때 이벤트 서버로부터 전달받은 데이터들을 담게 됩니다.

5. 어드민 서버

어드민 서버는 플랫폼의 관리를 위한 기능을 담당하는 서버입니다. 예를 들어 중개인을 등록하는 Admin을 등록해주는 작업과 같은 것들을 담당하며, 플랫폼의 가장 위험하고 중요한 기능을 수행합니다. 어드민 서버는 제한된 ip, 제한된 key, 제한된 계정을 통해서만 접근이 가능하며, 사용자들이 접근하는 백엔드 서버와 분리되어 있습니다.

6. 이벤트 수신 서버

이벤트 수신 서버는 web3와 nodejs를 이용합니다. 스마트 컨트랙에 새로운 거래의 등록이나 입찰과 같은 변동 사항이 생겼을 때 그 정보를 받아서 DB로 전달합니다. 사용자들에게 시각화된 정보를 제공하기 위해서 매번 스마트 컨트랙을 뒤지는 것이 아니라, 전통적인 형태의 DB에서 어떠한 거래들이 등록되어 있고 그 인덱스는 무엇인지를 찾아 알려줍니다.


### Hiring
We want to hire developers ready to build blockchain world. If you don't mind, send email to us. contact@bhom.io



