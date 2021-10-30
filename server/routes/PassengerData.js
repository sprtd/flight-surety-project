// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import '@openzeppelin/contracts/utils/math/SafeMath.sol';
// // import './';

// contract PassengerData  { 


//   /*__________________________________PASSENGER_______________________________*/


//   /********************************************************************************************/
//   /*                                      PASSENGER STATE VARIABLE FUNCTIONS                            */
//   /********************************************************************************************/

//   enum PassengerInsuranceState {
//     Unassigned,
//     Paid,
//     Claimed
//   }

//   struct Insurance {
//     uint256 id;
//     address flightAddress;
//     address passenger;
//     string flightName;
//     uint256 amount;
//     PassengerInsuranceState state;
//     uint256 refundAmount;
//   }

//   mapping(address =>  Insurance) passengersInsurance;

  
//   uint256 public constant PASSENGER_INSURANCE_FEE = 1 ether;


//   /********************************************************************************************/
//   /*                                       EVENT                            */
//   /********************************************************************************************/
//   event LogPassengerInsurance(address indexed account, uint256 amount);


//   /*******************************************************************************************/
//   /*                                       PASSENGER FUNCTIONS                         */
//   /*****************************************************************************************/

//   function payInsurance(uint256 _flightId)  external payable {

//   //    mapping(bytes32 => Flight) private flights;

//   // mapping(uint256 => bytes32) public flightKeys;

//     require(_flightId != 0 || _flightId <= flightCounter, 'invalid flight id');

//     bytes32 key = flightKeys[_flightId];
//     require(_flightId == flights[key].id, "flight does not exist");


    
    
//     // require(airlines[_account].status == AirlineStatus.Committed, 'flight does not exist');
//     // require(passengersInsurance[tx.origin].state == PassengerInsuranceState.Unassigned, 'insurance exits');
//     (uint256 id, string memory name, address airlineAccount,) = this.getAirlineDetails(_account);

//     require(msg.value <= PASSENGER_INSURANCE_FEE, '1ETH insurance must be paid');
//     (bool send, ) = address(this).call{value: msg.value}('');
//     require(send, 'failed to send ETH');

//     passengersInsurance[msg.sender] = Insurance({
//       id: id,
//       flightAddress: airlineAccount,
//       passenger: msg.sender,
//       flightName: name, 
//       amount: msg.value,
//       state: PassengerInsuranceState.Paid,
//       refundAmount: 0
//     });

//     emit LogPassengerInsurance(msg.sender, passengersInsurance[msg.sender].amount);
//   }

//   /*******************************************************************************************/
//   /*                                       PASSENGER UTILITY FUNCTIONS                         */
//   /*****************************************************************************************/

//   // mapping(address =>  Insurance) passengersInsurance;

//   function getPassengerDetails(address _account) external view returns
//     (
//       uint256 id, 
//       address flightAddress,
//       string memory flightName, 
//       address passenger, 
//       string memory state, 
//       uint256 amount, 
//       uint256 refundAmount
//     ) 
  
//   {
//     uint8 passengerState = uint8(passengersInsurance[_account].state);
//     if(passengerState == 0) {
//       state = 'Unassigned';
//     } else if(passengerState == 1) {
//       state = 'Paid';
//     } else if(passengerState == 2) {
//       state = 'Claimed';
//     } 
    
//     id = passengersInsurance[_account].id;
//     flightName = passengersInsurance[_account].flightName;
//     flightAddress = passengersInsurance[_account].flightAddress;
//     passenger = passengersInsurance[_account].passenger;
//     amount = passengersInsurance[_account].amount;
//     refundAmount = passengersInsurance[_account].refundAmount;
    
//     return (id, flightAddress, flightName, passenger, state, amount, refundAmount);
    
//   }

//   function getPassengerBalance(address _account) external view returns(uint256) {
//     return passengersInsurance[_account].amount;
//   }


// }
