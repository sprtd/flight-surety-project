// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';


contract FlightSuretyApp {
  IFlightSuretyData iFlightSuretyData;
  using SafeMath for uint256;
    
  address flightSuretyDataAddress;
    
  address public contractOwner;




  uint256 public constant AIRLINE_FEE =  10 ether;
    
    
  address[] minimumAirlines = new address[](0);
  uint quorum;
    
  
      


    
  /********************************************************************************************/
  /*                                       FUNCTION MODIFIERS                                 */
  /********************************************************************************************/
  
  modifier onlyAuthorizedAirlines(address _account) {
    iFlightSuretyData.onlyAuthorizedAirlines(_account);
    _;
      
  }
  
  modifier onlyRegistered() {
    iFlightSuretyData.onlyRegisteredAirlines(msg.sender);
    _;
  }

  
  

  /********************************************************************************************/
  /*                                       EVENTS                                */
  /********************************************************************************************/
  
  event LogRegisteredViaConsensus(address indexed callerAirline, address indexed registeredAirline, uint8 state);
  event LogPayCommitment(address indexed airline, uint256 airlineFee);


  /********************************************************************************************/
  /*                                       CONSTRUCTOR                                        */
  /********************************************************************************************/
  constructor(address _flightSuretyDataAddress) {
    contractOwner = msg.sender;
    flightSuretyDataAddress = _flightSuretyDataAddress;
    iFlightSuretyData = IFlightSuretyData(_flightSuretyDataAddress);
    
    startAirlineApplication('alpha');
    registerAirline(contractOwner, 2);

    // payCommitmentFee();
  }

    /********************************************************************************************/
  /*                                       AIRLINE CORE FUNCTION                               */
  /********************************************************************************************/
    
  function startAirlineApplication(string memory _name) public  {
    iFlightSuretyData.createNewAirline(_name, msg.sender);
      
          
  }

  function registerAirline(address _account, uint8 _state) public {
    iFlightSuretyData.updateAirlineStatus(_account, _state);
    
  }
    
    
    
  // register via consensus
  function registerViaConsensus(address _account, uint8 _state) public  onlyRegistered {

    require(iFlightSuretyData.isAirlineRegistered(_account) == false, 'airline already registered');
    
    uint regAirlines =  iFlightSuretyData.getTotalRegisteredAirlines();
    quorum = regAirlines / 2;
      
      
    bool isDuplicate = false;
    
    for(uint i = 0; i < minimumAirlines.length; i ++) {
      if(minimumAirlines[i] == msg.sender) {
        isDuplicate = true;
        break;
      }
    }

    require(!isDuplicate, 'caller already called the function');

    minimumAirlines.push(msg.sender);
    

    if(minimumAirlines.length == quorum) {
    iFlightSuretyData.enableOperationalStatus(true);
      iFlightSuretyData.updateAirlineStatus(_account, _state);
      minimumAirlines = new address[](0);
      emit LogRegisteredViaConsensus(msg.sender, _account, _state);
    }
  }


  // pay airline fee
  function payCommitmentFee() public payable onlyRegistered {
    require(msg.value == AIRLINE_FEE, 'fee is required');
    (bool send, ) = flightSuretyDataAddress.call{value: msg.value}('');
    require(send, 'failed to deposit ETH');
    iFlightSuretyData.updateToCommitState(3);
    emit LogPayCommitment(msg.sender, msg.value);
  }


  
    
   
/********************************************************************************************/
/*                                      AIRLINE UTILITY FUNCTIONS                                 */
/********************************************************************************************/
      
  function getOwner() external view returns(address) {
    return contractOwner;
  }


  
  function airlineAuthorizationStatus(address _account)  public view returns(bool) {
    return iFlightSuretyData.getAirlineAuthorizationStatus(_account);
  }
    
      

  function airlineDetails(address _account) public view returns(uint256 id, string memory name, address airlineAccount, string memory state) {
    (id, name, airlineAccount, state) = iFlightSuretyData.getAirlineDetails(_account);
    return (id, name, airlineAccount, state);
  }

  function isCallerAirlineRegistered() public view returns(bool) {
    (bool status) = iFlightSuretyData.isAirlineRegistered(msg.sender);
    return status;
  }
    
    
  function getTotalRegisteredAirlines() public view returns(uint256) {
    return iFlightSuretyData.getTotalRegisteredAirlines();
  }
    
  function getOperationalStatus() public view returns(bool) {
    return iFlightSuretyData.getOperationalStatus();
  }

      
  function getQuorum() public view returns(uint) {
    return quorum;
  }
  
  
  
  /*__________________________________FLIGHT_______________________________*/

  /*                                       FLIGHT FUNCTIONS                        */
  /********************************************************************************************/

  function fetchFlightStatus(uint256 _flightID) public {
    uint8 index = getRandomIndex(msg.sender);

    iFlightSuretyData.fetchFlightStatus(index, _flightID);
  }
 

  /*__________________________________ORACLE_______________________________*/

  /*                                       ORACLE VARIABLES                         */
  /********************************************************************************************/
  uint256 public constant ORACLE_REGISTRATION_FEE = 1 ether;
  uint8 private nonce = 0;




    /********************************************************************************************/
  /*                                       ORACLE CORE FUNCTION                               */
  /********************************************************************************************/
  function payOracleRegFees() public payable {
    require(msg.value == ORACLE_REGISTRATION_FEE, 'OR. FEE MUST');
    (bool sent, ) = flightSuretyDataAddress.call{value: msg.value}('');
    require(sent, 'SEND FAILED');
    
    uint8[3] memory indexes = generateIndexes(msg.sender);
    iFlightSuretyData.registerOracle(indexes);
  }


  /********************************************************************************************/
  /*                                      ORACLE UTILITY FUNCTIONS                           */
  /******************************************************************************************/

  function getRandomIndex(address _account) internal returns(uint8) {
    uint8 maxValue = 10;
    uint8 random  = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - nonce++), _account))) % maxValue);

    if(nonce > 250) {
      nonce = 0;
    }

    return random;
  }
  
  // Return non-duplicating integers
  function generateIndexes(address _account) internal returns(uint8[3] memory) {
    uint8[3] memory indexes;
    indexes[0] = getRandomIndex(_account);


    while(indexes[1] == indexes[0]) {
      indexes[1] = getRandomIndex(_account);
    }

    while((indexes[2] == indexes[0]) || (indexes[2] == indexes[1])) {
      indexes[2] =  getRandomIndex(_account);
    }

    return indexes;
  }

}

      






interface IFlightSuretyData {

  // airline functions
  function createNewAirline(string memory _name, address _account) external;
  function updateAirlineStatus(address _account, uint8 _state) external;
  function onlyAuthorizedAirlines(address _account) external view;
  function getAirlineAuthorizationStatus(address _account) external view returns(bool status);
  function getAirlineDetails(address _account) external view returns(uint256 id, string memory name, address airlineAccount, string memory state);
  function isAirlineRegistered(address _account) external view returns(bool);
  function onlyRegisteredAirlines(address _account) external view;
  function getTotalRegisteredAirlines() external view returns(uint256);
  function enableOperationalStatus(bool _status) external;
  function getOperationalStatus() external view  returns(bool);
  function updateToCommitState(uint8 _state) external;
  function isAirlineCommitted(address _account) external view returns(bool checkStatus);

  // flight functions
  function fetchFlightStatus(uint8 _index, uint256 _timestamp) external;


  // oracle functions
  function registerOracle(uint8[3] memory _indexes) external payable;

}


