// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import './AirlineData.sol';

contract FlightSuretyData is AirlineData {
  using SafeMath for uint256;


  
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
    uint256 timestamp;

  }

  mapping(bytes32 => Flight) private flights;

  mapping(uint256 => bytes32) public flightKeys;

  /********************************************************************************************/
  /*                                      FLIGHT EVENTS                                      */
  /******************************************************************************************/

  event LogFlightRegistered(bytes32 flightKey, address indexed airline, uint256 timestamp, uint8 statusCode);
  event LogFlightStatusProcessed(address indexed airline, uint256 timestamp);

   // Event fired when flight status request is requested
  event LogOracleRequest(uint8 index, address airline, string flight, uint256 timestamp);

  /********************************************************************************************/
  /*                                      FLIGHT CORE FUNCTIONS                 */
  /******************************************************************************************/
  
  // Register flight
  function registerFlight(uint8 _statusCode) public {
    (bool checkStatus ) = this.isAirlineCommitted(msg.sender);
    require(checkStatus == true, 'airline not commited');

    (uint256 id, string memory name, address airlineAccount,) = this.getAirlineDetails(msg.sender);  

    flightCounter = flightCounter.add(1);
    

    bytes32 flightKey = generateFlightKey(msg.sender, block.timestamp);

    flightKeys[id] = flightKey;
  

    flights[flightKey] = Flight({
      id: id,
      airline: airlineAccount,
      flightName: name,
      statusCode: _statusCode,
      flightKey: flightKey,
      timestamp: block.timestamp
    });

    emit LogFlightRegistered(flightKey, msg.sender, block.timestamp, _statusCode);
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

  
    (,string memory name,,) = this.getAirlineDetails(_airline); 

    emit LogOracleRequest(index, _airline, name, _timestamp);

  }

  // Get flight details
  function getFlightDetails(uint256 _flightId) public view returns
    (
      uint256 id, 
      address airline, 
      string memory flightName,
      uint8 statusCode, 
      bytes32 flightKey, 
      uint256 timestamp

    )
  {
    require(_flightId != 0 || _flightId <= flightCounter, 'invalid flight id');
    bytes32 key = flightKeys[_flightId];
    id = flights[key].id;
    airline = flights[key].airline;
    flightName = flights[key].flightName;
    statusCode = flights[key].statusCode;
    flightKey = flights[key].flightKey;
    timestamp = flights[key].timestamp;
    
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

 


        
  /********************************************************************************************/
  /*                                      ORACLE CORE FUNCTIONS                              */
  /******************************************************************************************/
  function registerOracle() external payable {
    // require(msg.value == ORACLE_REGISTRATION_FEE, 'oracle reg. fee required');
    require(!oracles[tx.origin].isRegistered, 'oracle already registered');
    uint8[3] memory indexes = generateIndexes(tx.origin);
    oracles[tx.origin] = Oracle({
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

  /*__________________________________PASSENGER_______________________________*/


  /********************************************************************************************/
  /*                                      PASSENGER STATE VARIABLE FUNCTIONS                            */
  /********************************************************************************************/

  enum PassengerInsuranceState {
    Unassigned,
    Paid,
    Claimed
  }

  struct Insurance {
    uint256 id;
    address flightAddress;
    address passenger;
    string flightName;
    uint256 amount;
    PassengerInsuranceState state;
    uint256 refundAmount;
  }

  mapping(address =>  Insurance) passengersInsurance;

  
  uint256 public constant PASSENGER_INSURANCE_FEE = 1 ether;


  /********************************************************************************************/
  /*                                       EVENT                            */
  /********************************************************************************************/
  event LogPassengerInsurance(address indexed account, uint256 amount);


  /*******************************************************************************************/
  /*                                       PASSENGER FUNCTIONS                         */
  /*****************************************************************************************/

  function payInsurance(uint256 _flightId)  external payable {

    require(_flightId != 0 || _flightId <= flightCounter, 'invalid flight id');

    bytes32 key = flightKeys[_flightId];
    require(_flightId == flights[key].id, "flight does not exist");


    
    
    // require(airlines[_account].status == AirlineStatus.Committed, 'flight does not exist');
    // require(passengersInsurance[tx.origin].state == PassengerInsuranceState.Unassigned, 'insurance exits');
    (uint256 id, string memory name, address airlineAccount,) = this.getAirlineDetails(flights[key].airline);

    require(msg.value <= PASSENGER_INSURANCE_FEE, '1ETH insurance must be paid');
    (bool send, ) = address(this).call{value: msg.value}('');
    require(send, 'failed to send ETH');

    passengersInsurance[msg.sender] = Insurance({
      id: id,
      flightAddress: airlineAccount,
      passenger: msg.sender,
      flightName: name, 
      amount: msg.value,
      state: PassengerInsuranceState.Paid,
      refundAmount: 0
    });

    emit LogPassengerInsurance(msg.sender, passengersInsurance[msg.sender].amount);
  }

  /*******************************************************************************************/
  /*                                       PASSENGER UTILITY FUNCTIONS                         */
  /*****************************************************************************************/

  // mapping(address =>  Insurance) passengersInsurance;

  function getPassengerDetails(address _account) external view returns
    (
      uint256 id, 
      address flightAddress,
      string memory flightName, 
      address passenger, 
      string memory state, 
      uint256 amount, 
      uint256 refundAmount
    ) 
  
  {
    uint8 passengerState = uint8(passengersInsurance[_account].state);
    if(passengerState == 0) {
      state = 'Unassigned';
    } else if(passengerState == 1) {
      state = 'Paid';
    } else if(passengerState == 2) {
      state = 'Claimed';
    } 
    
    id = passengersInsurance[_account].id;
    flightName = passengersInsurance[_account].flightName;
    flightAddress = passengersInsurance[_account].flightAddress;
    passenger = passengersInsurance[_account].passenger;
    amount = passengersInsurance[_account].amount;
    refundAmount = passengersInsurance[_account].refundAmount;
    
    return (id, flightAddress, flightName, passenger, state, amount, refundAmount);
    
  }

  function getPassengerBalance(address _account) external view returns(uint256) {
    return passengersInsurance[_account].amount;
  }



  /********************************************************************************************/
  /*                                      CONTRACT RECEIVE ETHER                                */
  /********************************************************************************************/
  receive() payable external {

  }

}
