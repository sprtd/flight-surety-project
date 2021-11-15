// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import './AirlineData.sol';

contract FlightSuretyData is AirlineData {
  using SafeMath for uint256;

  /********************************************************************************************/
  /*                                      FLIGHT STATE VARIABLES                          */
  /******************************************************************************************/

  address public contractOwner;

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

  event LogFlightRegistered(string name, bytes32 flightKey, address indexed airline, uint256 timestamp, uint8 statusCode);
  event LogFlightStatusProcessed(address indexed airline, uint256 timestamp, uint8 statusCode);
  event LogFlightStatusCodeChanged(uint256 flightId, uint8 statusCode);

   // Event fired when flight status request is requested
  event LogOracleRequest(uint8 index, address airline, string flight, uint256 timestamp);

  
  /********************************************************************************************/
  /*                                      MODIFIER                                    */
  /******************************************************************************************/


  modifier isAirlineAuthorized() {
    checkAirlineCommitmentStatus();
    _;
  }

  function checkAirlineCommitmentStatus() public view {
    (bool checkStatus ) = this.isAirlineCommitted(msg.sender);
    require(checkStatus == true, 'nt com.');

  }


   constructor() {
    contractOwner = msg.sender;

  }

  /********************************************************************************************/
  /*                                      FLIGHT CORE FUNCTIONS                 */
  /******************************************************************************************/
  
  // Register flight
  function registerFlight(uint8 _statusCode) public isAirlineAuthorized {


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

    emit LogFlightRegistered(name, flightKey, msg.sender, block.timestamp, _statusCode);
  }

  // Generate a request for oracles  to fetch flight information
  function fetchFlightStatus(uint8 _index, uint256 _flightId) external {
    (, address airline, string memory flightName,, bytes32 flightKey, uint256 timestamp) = getFlightDetails(_flightId);

    require(flightKeys[_flightId] == flightKey, 'NE flight');

    // Generate a unique key for storing  the request
    bytes32 key = keccak256(abi.encodePacked(_index, airline, flightName, timestamp));
    oracleResponses[key].requester = tx.origin;
    oracleResponses[key].isOpen = true;

    emit LogOracleRequest(_index, airline, flightName, timestamp);
  }

  // 
  function processFlightStatus(address _airline, uint256 _timestamp, uint8 _statusCode)  private {
    bytes32 key = generateFlightKey(_airline, _timestamp);
    flights[key].statusCode = _statusCode;

    emit LogFlightStatusProcessed(_airline, _timestamp, _statusCode);
  }


  
  /********************************************************************************************/
  /*                                      FLIGHT UTILITY FUNCTIONS                 */
  /******************************************************************************************/

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
    require(_flightId != 0 || _flightId <= flightCounter, 'inv id');
    bytes32 key = flightKeys[_flightId];
    id = flights[key].id;
    airline = flights[key].airline;
    flightName = flights[key].flightName;
    statusCode = flights[key].statusCode;
    flightKey = flights[key].flightKey;
    timestamp = flights[key].timestamp;
    
  }

  // Generate flight key
  function generateFlightKey(address _airline, uint256 _timestamp) public pure returns(bytes32) {
    return keccak256(abi.encodePacked(_airline, _timestamp));
  }

  /*__________________________________ORACLE______________________________*/

  
  /********************************************************************************************/
  /*                               ORACLE STATE VARIABLES                                    */
  /******************************************************************************************/
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
  /*                                    ORACLE  EVENTS                                             */
  /******************************************************************************************/
  event LogOracleRegistered(address indexed oracle, uint8[3] indexes);

  // Event fired each time an oracle submits a response
  event LogFlightStatusInfo(address airline, string flightName, uint256 timestamp, uint8 statusCode);

  event LogOracleReport(address airline, uint256 timestamp, uint8 status);

  /********************************************************************************************/
  /*                                      ORACLE CORE FUNCTIONS                              */
  /******************************************************************************************/
  function registerOracle(uint8[3] memory _indexes) external payable {
    require(!oracles[tx.origin].isRegistered, 'OR.reg');
    require(_indexes.length == 3, 'IND. Req');
    oracles[tx.origin] = Oracle({
      isRegistered: true,
      indexes: _indexes
    });

    emit LogOracleRegistered(tx.origin, _indexes);
  }
  

  /**
    * @dev Called by oracle in response to an outstanding request
    * response is only valid if there's a pending open request status  and  that its responxe index matches that which was assigned during oracle registration
   */

  function submitOracleResponse
    (
      uint8 _index, 
      address _airline, 
      string memory _flightName,
      uint256 _timestamp, 
      uint8 _statusCode
    ) external 
  {
    require((oracles[msg.sender].indexes[0] == _index) || (oracles[msg.sender].indexes[1] == _index) || (oracles[msg.sender].indexes[2] == _index));
    bytes32 key = keccak256(abi.encodePacked(_index, _airline, _flightName, _timestamp));
    require(oracleResponses[key].isOpen, 'Fli. tm msmcth');
    oracleResponses[key].responses[_statusCode].push(msg.sender);

    // oracle response is not valid until MIN_RESPONSES threshold is reached
    emit LogOracleReport(msg.sender, _timestamp, _statusCode);
    if(oracleResponses[key].responses[_statusCode].length >= MIN_RESPONSES) {
      emit LogFlightStatusInfo(_airline, _flightName, _timestamp, _statusCode);
      processFlightStatus(_airline,_timestamp, _statusCode);
    }
  }

  /********************************************************************************************/
  /*                                      ORACLE UTILITY FUNCTIONS                           */
  /******************************************************************************************/
  function getOracleIndexes() external view returns(uint8[3] memory) {
    require(oracles[msg.sender].isRegistered, 'nrg');
    return oracles[msg.sender].indexes;

  }

  function isOracleRegistered(address _account) public view returns(bool) {
    return oracles[_account].isRegistered;
  }

 
 
  /*__________________________________PASSENGER_______________________________*/


  /********************************************************************************************/
  /*                                      PASSENGER STATE VARIABLE FUNCTIONS                  */
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
  mapping (uint256 => address) public passengerIdToAddress;
  mapping(address => uint256) public passengersBalances;

  
  uint256 public constant PASSENGER_INSURANCE_FEE = 1 ether;
  uint256 passengerRefundAmount = 0;


  /********************************************************************************************/
  /*                                       EVENT                            */
  /********************************************************************************************/
  event LogPassengerInsurance(address indexed passenger, uint256 amount);
  event LogPassengerCredited(address indexed passenger, uint256 amount);
  event LogWithdrawPassengerInsurance(address indexed passenger, uint256 withdrawAmount, uint256 formPassengerBalance );



  
  /********************************************************************************************/
  /*                                       MODIFIER                         */
  /********************************************************************************************/
  modifier checkPassenger {
    isPassengerAuthorizedToWithdraw();
    _;
  }

  /*******************************************************************************************/
  /*                                       PASSENGER FUNCTIONS                         */
  /*****************************************************************************************/

  function payInsurance(uint256 _flightId)  external payable {
    require(msg.value == PASSENGER_INSURANCE_FEE, '1ETH req');
    require(_flightId != 0 || _flightId <= flightCounter, 'inv fli. id');

    bytes32 key = flightKeys[_flightId];
    require(_flightId == flights[key].id, "fli nt ex");

    
    require(passengersInsurance[tx.origin].state == PassengerInsuranceState.Unassigned, 'ins exits');
    (uint256 id, string memory name, address airlineAccount,) = this.getAirlineDetails(flights[key].airline);

    (bool send, ) = address(this).call{value: msg.value}('');
    require(send, 'failed to ETH');
    passengersBalances[tx.origin] = msg.value;

    passengersInsurance[tx.origin] = Insurance({
      id: id,
      flightAddress: airlineAccount,
      passenger: msg.sender,
      flightName: name, 
      amount: passengersBalances[tx.origin],
      state: PassengerInsuranceState.Paid,
      refundAmount: 0
    });
    passengerIdToAddress[_flightId] = tx.origin;

    emit LogPassengerInsurance(msg.sender, passengersInsurance[msg.sender].amount);
  }

  function claimPassengerInsurance(uint256 _flightId) public  {
    require(_flightId != 0 || _flightId <= flightCounter, 'inv id');
    (,,,, bytes32 flightKey,) = getFlightDetails(_flightId);


    bytes32 key = flightKeys[_flightId];
    require(_flightId == flights[key].id, 'NO FLI');
    require(passengersInsurance[msg.sender].state == PassengerInsuranceState.Paid);
    require(flights[flightKey].statusCode == 20, 'FL EL');
    uint256 currentBalance  = passengersBalances[msg.sender];
    uint256 refundAmount  =  currentBalance / 2;
    
    
    passengersBalances[msg.sender] += refundAmount;
    passengersInsurance[msg.sender].refundAmount = passengersBalances[msg.sender];


    emit LogPassengerCredited(msg.sender, passengersBalances[msg.sender]);




  }

  function changeFlightStatusCode(uint256 _flightId) public  {
    require(msg.sender == contractOwner, 'OWN');
      require(_flightId != 0 || _flightId <= flightCounter);
    (,,,, bytes32 flightKey,) = getFlightDetails(_flightId);

    bytes32 key = flightKeys[_flightId];
    require(_flightId == flights[key].id, "fli. ne");
    flights[flightKey].statusCode = 20;
    (,,, uint8 statusCode,,) = getFlightDetails(_flightId);
    emit LogFlightStatusCodeChanged(_flightId, statusCode);
  }

  function withdrawPassengerBalance() public checkPassenger  {
    require(msg.sender == tx.origin);
    require(passengersBalances[msg.sender] == 1.5 ether);
    passengersInsurance[msg.sender].state == PassengerInsuranceState.Claimed;
    // passengersInsurance[msg.sender].refundAmount = 0;
    uint256 withdrawAmount = passengersBalances[msg.sender];
    passengersBalances[msg.sender] -= withdrawAmount;
    (bool sent, ) = msg.sender.call{value: withdrawAmount}('');
    require(sent, 'PASSG. WD FAIL');
    emit LogWithdrawPassengerInsurance(msg.sender, withdrawAmount, passengersBalances[msg.sender]);
  }

  /*******************************************************************************************/
  /*                                       PASSENGER UTILITY FUNCTIONS                      */
  /*****************************************************************************************/
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

  function isPassengerAuthorizedToWithdraw() public view {
    require(passengersInsurance[msg.sender].state == PassengerInsuranceState.Paid, 'PG NT PD');

  }

  /********************************************************************************************/
  /*                                      CONTRACT RECEIVE ETHER                              */
  /********************************************************************************************/

  function emergencyWithdraw() external payable {
    require(msg.sender == contractOwner, 'not');
    uint256 contractBalance = address(this).balance;
    require(contractBalance > 0);
    
    (bool sent,) = payable(contractOwner).call{value: contractBalance}('');
    require(sent, 'sd fail');
  }



  /********************************************************************************************/
  /*                                      CONTRACT RECEIVE ETHER                                */
  /********************************************************************************************/
  receive() payable external {

  }

}
