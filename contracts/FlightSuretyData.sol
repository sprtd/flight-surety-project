// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';

contract FlightSuretyData {
  using SafeMath for uint256;
  
 


  /********************************************************************************************/
  /*                                       DATA VARIABLES                                     */
  /********************************************************************************************/

  uint256 airlineID;
  address private contractOwner;
  bool private operational;

  enum AirlineStatus { 
    Unassigned,
    Applied,
    Registered,
    Committed
  }

  struct Airline {
    uint256 id;
    string name;
    AirlineStatus status;
    address airlineAccount;
    
  }



  mapping(address => Airline) airlines;
  
  


  /********************************************************************************************/
  /*                                       FUNCTION MODIFIERS                                 */
  /********************************************************************************************/
 
  
 

  function _onlyOwner() internal view {
    require(msg.sender == contractOwner, 'caller not owner');
  }
  
  function _onlyAuthorizedAirlines() internal view {
      require(msg.sender == contractOwner || airlines[msg.sender].status == AirlineStatus.Applied);
  }

  modifier onlyOwner() {
    _onlyOwner();
    _;
  }
  
  modifier onlyAuthorizedAirlines() {
      _onlyAuthorizedAirlines();
      _;
  }





  modifier isOperational() {
    require(operational, 'contract not operational');
    _;
  }

  modifier hasApplied(address _account) {
    require(airlines[_account].status == AirlineStatus.Applied, 'na application');
    _;
  }
  
  modifier statusNumRange(uint8 _num) {
      airlineStatusLimit(_num);
      _;
  }

  /********************************************************************************************/
  /*                                       EVENTS                                */
  /********************************************************************************************/

  event LogNewAirline(address indexed account, uint256 timestamp, string airlineStatus);


  constructor() {
    contractOwner = msg.sender;
    operational = true;

  }
  
  
  
    /********************************************************************************************/
  /*                                       CORE FUNCTIONS                                 */
  /********************************************************************************************/


  function setOperatinalStatus(bool _status) external onlyOwner {
    require(operational != _status, 'must not be current status');
    operational = _status;
  }


  function createNewAirline(string memory _name, address _account) external {
    require(airlines[_account].status == AirlineStatus.Unassigned, 'airline not in unassigned state');
    airlineID = airlineID.add(1);
    airlines[_account] = Airline({
      id: airlineID,
      name: _name,
      status: AirlineStatus.Applied, 
      airlineAccount: _account
    });
    
    string memory state;
    
    (,,,state) = getAirlineDetails(_account);

    emit LogNewAirline(msg.sender, block.timestamp, state);
  }
  
  
  function updateAirlineStatus(address _account, uint8 _state) public hasApplied(_account) statusNumRange(_state) onlyAuthorizedAirlines {
      airlines[_account].status = AirlineStatus(_state);
     
  }



  /********************************************************************************************/
  /*                                       UTILITY FUNCTIONS                                 */
  /********************************************************************************************/

  function getOperationalStatus() external view  returns(bool) {
    return operational;
  }


  function getOwner() external view returns(address) {
    return contractOwner;
  }
  
  function airlineStatusLimit(uint8 _num) public pure {
 
      require(_num <= 3, 'not withing enum range');
  }
  
  function getAirlineID() external view returns(uint256) {
      return airlineID;
  }
 
  
  

  function getAirlineDetails(address _account) public view returns(uint256 id, string memory name, address airlineAccount, string memory state) {
    uint8 airlineState = uint8(airlines[_account].status);
    if(airlineState == 0) {
      state = 'Unassigned';

    } else if(airlineState == 1) {
      state = 'Applied';
    } else if(airlineState == 2) {
      state = 'Registered';
    } else if(airlineState == 3) {
      state = 'Committed';

    }
    
    id = airlines[_account].id;
    name = airlines[_account].name;
    airlineAccount = airlines[_account].airlineAccount;
    
    return (id, name, airlineAccount, state);
    
  }
  
  
  function getAirlineApplicationStatus(address _account) public view returns(string memory status) {
    (,,,status) = getAirlineDetails(_account);
  }






}
