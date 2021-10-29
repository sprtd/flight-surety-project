// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';


contract FlightSuretyApp {
  IFlightSuretyData iFlightSuretyData;
  using SafeMath for uint256;
    
  address flightSuretyDataAddress;
    
  address public contractOwner;

  uint256 public constant AIRLINE_FEE =  10 ether;
    
    
  address[] minimumAirlines = new address[](0);
  uint quorum;
    
  
  
  constructor(address _flightSuretyDataAddress) {
    contractOwner = msg.sender;
    flightSuretyDataAddress = _flightSuretyDataAddress;
    iFlightSuretyData = IFlightSuretyData(_flightSuretyDataAddress);
    
    startAirlineApplication('alpha');
    registerAirline(contractOwner, 2);
    
  }
    
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
    emit LogPayCommitment(msg.sender, msg.value );
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



      
  /********************************************************************************************/
  /*                                      FLIGHT STATE VARIABLES                          */
  /******************************************************************************************/
  
  
  // Flight status codes
  uint8 private constant STATUS_CODE_UNKNOWN = 0;
  uint8 private constant STATUS_CODE_ON_TIME = 10;
  uint8 private constant STATUS_CODE_LATE_AIRLINE = 20;
  uint8 private constant STATUS_CODE_LATE_WEATHER = 30;
  uint8 private constant STATUS_CODE_LATE_TECHNICAL = 40;
  uint8 private constant STATUS_CODE_LATE_OTHER = 50;

  uint256 public flightCounter = 0;


  struct Flight {
    uint256 id;
    address airline;
    string flightName;
    uint8 statusCode;
    bytes32 flightKey;
    uint256 updatedTimestamp;

  }

  mapping(bytes32 => Flight) private flights;

  mapping(uint256 => bytes32) public flightKeys;

  /********************************************************************************************/
  /*                                      FLIGHT EVENTS                                      */
  /******************************************************************************************/

  event LogFlightStatusProcessed(address indexed airline, uint256 timestamp);




  /********************************************************************************************/
  /*                                      FLIGHT CORE FUNCTIONS                 */
  /******************************************************************************************/

  function registerFlight(uint8 _statusCode) public {
    (bool checkStatus ) = iFlightSuretyData.isAirlineCommitted(msg.sender);
    require(checkStatus == true, 'airline not commited');

    (uint256 id, string memory name, address airlineAccount,) = airlineDetails(msg.sender);  

    flightCounter = flightCounter.add(1);
    

    bytes32 flightKey = generateFlightKey(msg.sender, block.timestamp);


    flightKeys[id] = flightKey;
  

    flights[flightKey] = Flight({
      id: id,
      airline: airlineAccount,
      flightName: name,
      statusCode: _statusCode,
      flightKey: flightKey,
      updatedTimestamp: block.timestamp
    });
  }


  function processFlightStatus(address _airline, uint256 _timestamp, uint8 _statusCode)  private {
    bytes32 key = generateFlightKey(_airline, _timestamp);
    flights[key].statusCode = _statusCode;

    emit LogFlightStatusProcessed(_airline, _timestamp);
  }

  // Generate a request for oracles  to fetch flight information
  function fetchFlightStatus(address _airline, uint256 _timestamp) public {
    uint8 index = getRandomIndex(msg.sender);

    // Generate a unique key for storing  the request
    bytes32 key = keccak256(abi.encodePacked(index, _airline, _timestamp));
    oracleResponses[key].requester = msg.sender;
    oracleResponses[key].isOpen = true;

  
    (,string memory name,,) = airlineDetails(_airline);  

    emit LogOracleRequest(index, _airline, name, _timestamp);

  }



  /********************************************************************************************/
  /*                                      FLIGHT UTILITY FUNCTIONS                 */
  /******************************************************************************************/

  function generateFlightKey(address _airline, uint256 _timestamp) public pure returns(bytes32) {
    return keccak256(abi.encodePacked(_airline, _timestamp));
  }




  



  /*__________________________________ORACLE______________________________*/

  
  /********************************************************************************************/
  /*                               ORACLE STATE VARIABLES                                    */
  /******************************************************************************************/

  uint8 private nonce = 0;

  uint256 public constant ORACLE_REGISTRATION_FEE = 1 ether;

  // Number of oracles that must respond for valid status
  uint256 private constant  MIN_RESPONSES = 3;

  struct Oracle {
    bool isRegistered;
    uint8[3] indexes;
  }

  // Track all registered oracles
  mapping(address => Oracle) private oracles; 

  // Model for responses from oracles
  struct ResponseInfo {
    address requester;  // account that triggered the requested status
    bool isOpen;        // if open, oracle responses are accepted
    mapping(uint8 => address[]) responses; // key is the status code reported
  }

  // Track all oracle responses 
  mapping(bytes32 => ResponseInfo) oracleResponses;


  /********************************************************************************************/
  /*                                      EVENTS                                             */
  /******************************************************************************************/

  // Event fired each time an oracle submits a response
  event LogFlightStatusInfo(address airline, string flight, uint256 timestamp, uint8 status);

  event LogOracleReport(address airline, string flight, uint256 timestamp, uint8 status);

  // Event fired when flight status request is requested
  event LogOracleRequest(uint8 index, address airline, string flight, uint256 timestamp);


        
  /********************************************************************************************/
  /*                                      ORACLE CORE FUNCTIONS                              */
  /******************************************************************************************/
  function registerOracle() external payable {
    require(msg.value == ORACLE_REGISTRATION_FEE, 'oracle reg. fee required');
    require(!oracles[msg.sender].isRegistered, 'oracle already registered');
    uint8[3] memory indexes = generateIndexes(msg.sender);
    oracles[msg.sender] = Oracle({
      isRegistered: true,
      indexes: indexes
    });

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

  function getOracleIndexes() external view returns(uint8[3] memory) {
    require(oracles[msg.sender].isRegistered, 'caller not registered oracle');
    return oracles[msg.sender].indexes;

  }

  function isOracleRegistered(address _account) public view returns(bool) {
    return oracles[_account].isRegistered;
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


  // passenger functions
}


